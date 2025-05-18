import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../viewmodels/user_viewmodel.dart';
import '../../viewmodels/fridge_viewmodel.dart';
import '../../viewmodels/cookbook_viewmodel.dart';

class AnimatedSplashScreen extends StatefulWidget {
  const AnimatedSplashScreen({super.key});

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _squishAnimation;
  late Animation<double> _wiggleAnimation;

  @override
  void initState() {
    super.initState();

    // Enable immersive mode for full screen (behind system bars)
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Vertical squish: normal -> squished -> normal
    _squishAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.7)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.7, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 50,
      ),
    ]).animate(_controller);

    // Wiggle: rotate left and right, then settle
    _wiggleAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: -0.15)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.15, end: 0.15)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.15, end: -0.1)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.1, end: 0.05)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.05, end: 0.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 20,
      ),
    ]).animate(_controller);

    _controller.forward();
    _loadAndNavigate();
  }

  // Load user data and navigate to the appropriate screen
  Future<void> _loadAndNavigate() async {
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    final fridgeViewModel =
        Provider.of<FridgeViewModel>(context, listen: false);
    final cookbookViewModel =
        Provider.of<CookbookViewModel>(context, listen: false);

    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    final refreshToken = prefs.getString('refreshToken');

    bool isLoggedIn = false;

    // Start both the animation and the data loading
    final animationFuture = _controller.forward().then((_) => true);
    final dataFuture = () async {
      if (accessToken != null && refreshToken != null) {
        try {
          await userViewModel.fetchUserProfile();
          isLoggedIn = userViewModel.user != null;

          if (isLoggedIn) {
            final fridgeId = userViewModel.fridgeId;
            final cookbookId = userViewModel.cookbookId;
            final futures = <Future>[];
            if (fridgeId != null) {
              futures.add(fridgeViewModel.fetchFridgeIngredients(fridgeId));
            }
            if (cookbookId != null) {
              futures.add(cookbookViewModel.fetchCookbookRecipes(cookbookId));
            }
            await Future.wait(futures);
          }
        } catch (e) {
          isLoggedIn = false;
        }
      }
      return true;
    }();

    // Wait for both to complete, and enforce a minimum duration if you want
    await Future.wait([
      animationFuture,
      dataFuture,
      Future.delayed(const Duration(seconds: 2)), // Minimum splash duration
    ]);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    Navigator.of(context).pushReplacementNamed(
      isLoggedIn ? '/main' : '/login',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    // Restore system UI just in case
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF47851),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: const Color(0xFFF47851),
            ),
          ),
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _wiggleAnimation.value,
                  child: Transform.scale(
                    scaleY: _squishAnimation.value,
                    scaleX: 1.0,
                    child: child,
                  ),
                );
              },
              child: Image.asset(
                'assets/images/splash_icon.png',
                width: 300,
                height: 300,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
