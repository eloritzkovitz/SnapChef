import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/session_manager.dart';
import '../../theme/colors.dart';
import '../../viewmodels/cookbook_viewmodel.dart';
import '../../viewmodels/fridge_viewmodel.dart';
import '../../viewmodels/ingredient_viewmodel.dart';
import '../../viewmodels/user_viewmodel.dart';

class AnimatedSplashScreen extends StatefulWidget {
  const AnimatedSplashScreen({super.key});

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _squishAnimation;
  late Animation<double> _wiggleAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Fade controller for fade out effect
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 60),
      vsync: this,
    );
    _fadeAnimation =
        Tween<double>(begin: 1.0, end: 0.0).animate(_fadeController);

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

    _runSplashSequence();
  }

  Future<void> _runSplashSequence() async {
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    final ingredientViewModel =
        Provider.of<IngredientViewModel>(context, listen: false);
    final fridgeViewModel =
        Provider.of<FridgeViewModel>(context, listen: false);
    final cookbookViewModel =
        Provider.of<CookbookViewModel>(context, listen: false);

    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    final refreshToken = prefs.getString('refreshToken');

    bool isLoggedIn = false;

    // Start the main animation
    final animationFuture = _controller.forward().then((_) => true);

    // Start data loading
    final dataFuture = () async {
      if (accessToken != null && refreshToken != null) {
        try {
          await userViewModel.fetchUserData();
          isLoggedIn = userViewModel.user != null;

          if (isLoggedIn) {
            final fridgeId = userViewModel.fridgeId;
            final cookbookId = userViewModel.cookbookId;
            final futures = <Future>[];
            if (fridgeId != null) {
              futures.add(fridgeViewModel.fetchFridgeIngredients(
                  fridgeId, ingredientViewModel));
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

    // Wait for both animation and data loading (and a minimum duration)
    await Future.wait([
      animationFuture,
      dataFuture,
      Future.delayed(const Duration(milliseconds: 500)),
    ]);

    // Start fade-out animation
    await _fadeController.forward();

    // Now set system bars to match the next screen (after fade-out, just before navigation)
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        systemNavigationBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    if (!mounted) return;

    if (isLoggedIn) {
      SessionManager.createSession(context);
    } else {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: splashColor,
      resizeToAvoidBottomInset: false,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          color: splashColor,
          alignment: Alignment.center,
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
      ),
    );
  }
}
