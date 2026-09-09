import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/game_colors.dart';
import '../../storage/game_storage.dart';
import 'home_screen.dart';
import 'onboarding_screen.dart';

/// Master Splash Screen (Screen 1 in Master Reference Mockup)
/// Features bshomebg.png, bstitle.png, glowing "Loading..." text, and animated cyan loading bar.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _progressAnimation = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOutCubic,
    );

    _progressController.forward().then((_) {
      _navigateToNext();
    });
  }

  Future<void> _navigateToNext() async {
    await GameStorage.instance.init();
    final hasSeenOnboarding = GameStorage.instance.hasCompletedTutorial();

    if (!mounted) return;

    if (!hasSeenOnboarding) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (_, __, ___) => const OnboardingScreen(),
          transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
        ),
      );
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF070B18),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Cosmic Wallpaper
          Image.asset(
            'assets/images/bshomebg.png',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF0D162B), Color(0xFF060913)],
                ),
              ),
            ),
          ),

          // Center 3D Title
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Image.asset(
                'assets/images/bstitle.png',
                fit: BoxFit.contain,
                width: size.width * 0.88,
              ),
            ),
          ),

          // Bottom Loading Bar Section
          Positioned(
            bottom: 48,
            left: 36,
            right: 36,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Loading...',
                  style: TextStyle(
                    color: Color(0xFF8E9EB8),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 12),
                AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, _) {
                    return Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFF131D36),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF2A3D66),
                          width: 1.2,
                        ),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _progressAnimation.value.clamp(0.02, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF00B0FF),
                                Color(0xFF00E5FF),
                                Color(0xFF1DE9B6),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00E5FF).withOpacity(0.6),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
