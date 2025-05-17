import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AnimatedSplashScreen extends StatefulWidget {
  final bool isLoggedIn;
  const AnimatedSplashScreen({super.key, required this.isLoggedIn});

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
        tween: Tween<double>(begin: 1.0, end: 0.7).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.7, end: 1.0).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 50,
      ),
    ]).animate(_controller);

    // Wiggle: rotate left and right, then settle
    _wiggleAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: -0.15).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.15, end: 0.15).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.15, end: -0.1).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.1, end: 0.05).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.05, end: 0.0).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 20,
      ),
    ]).animate(_controller);

    _controller.forward();

    Future.delayed(const Duration(seconds: 2), () {
      // Restore system UI before navigating away
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      Navigator.of(context).pushReplacementNamed(
        widget.isLoggedIn ? '/main' : '/login',
      );
    });
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