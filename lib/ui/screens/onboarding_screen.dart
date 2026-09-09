import 'package:flutter/material.dart';
import '../../core/constants/game_colors.dart';
import '../../game/systems/audio_synthesizer.dart';
import '../../storage/game_storage.dart';
import 'home_screen.dart';

/// Onboarding Screen matching Screens 2, 3, 4 from Reference Mockup
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _onFinish() async {
    AudioSynthesizer.instance.playRewardClaim();
    await GameStorage.instance.setCompletedTutorial(true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  void _onNext() {
    AudioSynthesizer.instance.playUiClick();
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _onFinish();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090E1D),
      body: SafeArea(
        child: Stack(
          children: [
            // Top Close / Skip Button
            Positioned(
              top: 12,
              left: 16,
              child: GestureDetector(
                onTap: _onFinish,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131D36),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF2A3D66), width: 1.2),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white70,
                    size: 18,
                  ),
                ),
              ),
            ),

            // Main Page Content
            PageView(
              controller: _pageController,
              onPageChanged: (page) => setState(() => _currentPage = page),
              children: [
                _buildPage(
                  title: 'SMASH\nTHE BRICKS',
                  subtitle: 'Break all the bricks\nto clear the level!',
                  illustration: _buildSmashBricksIllustration(),
                  buttonText: 'Next',
                  isLast: false,
                ),
                _buildPage(
                  title: 'CONTROL\nTHE PADDLE',
                  subtitle: 'Drag left or right\nto move the paddle!',
                  illustration: _buildControlPaddleIllustration(),
                  buttonText: 'Next',
                  isLast: false,
                ),
                _buildPage(
                  title: 'USE\nPOWER-UPS',
                  subtitle: 'Collect power-ups\nto smash faster!',
                  illustration: _buildPowerUpsIllustration(),
                  buttonText: 'Get Started',
                  isLast: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage({
    required String title,
    required String subtitle,
    required Widget illustration,
    required String buttonText,
    required bool isLast,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 20.0),
      child: Column(
        children: [
          const SizedBox(height: 36),
          // Glowing Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              height: 1.15,
            ),
          ),

          const SizedBox(height: 24),

          // Center Illustration Card
          Expanded(
            child: Center(
              child: illustration,
            ),
          ),

          const SizedBox(height: 16),

          // Subtitle
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF8E9EB8),
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 28),

          // Page Dot Indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              final active = index == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: active ? 22 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: active ? const Color(0xFF00E5FF) : const Color(0xFF1E2C4A),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: active
                      ? [
                          BoxShadow(
                            color: const Color(0xFF00E5FF).withOpacity(0.5),
                            blurRadius: 6,
                          )
                        ]
                      : null,
                ),
              );
            }),
          ),

          const SizedBox(height: 24),

          // Bottom Action Pill Button
          GestureDetector(
            onTap: _onNext,
            child: Container(
              width: double.infinity,
              height: 54,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isLast
                      ? const [Color(0xFF00E676), Color(0xFF00C853)]
                      : const [Color(0xFF00B0FF), Color(0xFF0091EA)],
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: isLast
                        ? const Color(0xFF00E676).withOpacity(0.4)
                        : const Color(0xFF00B0FF).withOpacity(0.4),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                buttonText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // ONBOARDING 1: Smash Bricks Preview Card
  // ═════════════════════════════════════════════════════════════════════════════
  Widget _buildSmashBricksIllustration() {
    return Container(
      width: 260,
      height: 290,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D162B),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF2A3D66), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Row 1 bricks
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMiniBrick('30', const Color(0xFFFF9100)),
              _buildMiniBrick('20', const Color(0xFFFF3D00)),
              _buildMiniBrick('30', const Color(0xFFFF9100)),
              _buildMiniBrick('20', const Color(0xFFFF3D00)),
            ],
          ),
          const SizedBox(height: 6),
          // Row 2 bricks
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMiniBrick('30', const Color(0xFF00E676)),
              _buildMiniBrick('30', const Color(0xFF00E676)),
              _buildMiniBrick('20', const Color(0xFF00B0FF)),
              _buildMiniBrick('20', const Color(0xFF00B0FF)),
            ],
          ),
          const SizedBox(height: 6),
          // Row 3 bricks
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMiniBrick('20', const Color(0xFF00B0FF)),
              const SizedBox(width: 44),
              const SizedBox(width: 44),
              _buildMiniBrick('20', const Color(0xFF00B0FF)),
            ],
          ),

          const Spacer(),

          // Dotted trajectory line & glowing ball
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: const Color(0xFF00E5FF),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00E5FF).withOpacity(0.8),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Mini Paddle
          Container(
            width: 90,
            height: 12,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00E5FF), Color(0xFF0091EA)],
              ),
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00E5FF).withOpacity(0.5),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // ONBOARDING 2: Control Paddle Preview Card
  // ═════════════════════════════════════════════════════════════════════════════
  Widget _buildControlPaddleIllustration() {
    return Container(
      width: 260,
      height: 290,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D162B),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF2A3D66), width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMiniBrick('20', const Color(0xFF00E676)),
              _buildMiniBrick('30', const Color(0xFFFF9100)),
              _buildMiniBrick('20', const Color(0xFF7C4DFF)),
              _buildMiniBrick('20', const Color(0xFF7C4DFF)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMiniBrick('20', const Color(0xFF00E676)),
              _buildMiniBrick('30', const Color(0xFFFF9100)),
              _buildMiniBrick('20', const Color(0xFF00B0FF)),
              _buildMiniBrick('20', const Color(0xFF00B0FF)),
            ],
          ),

          const Spacer(),

          // Paddle with drag arrows & hand cursor
          Stack(
            alignment: Alignment.center,
            children: [
              // Horizontal Guide Line with Arrows
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.arrow_back_ios_rounded, color: Color(0xFF00E5FF), size: 16),
                  SizedBox(width: 140),
                  Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF00E5FF), size: 16),
                ],
              ),

              // Paddle
              Container(
                width: 100,
                height: 14,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00E5FF), Color(0xFF0091EA)],
                  ),
                  borderRadius: BorderRadius.circular(7),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00E5FF).withOpacity(0.6),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),

              // Hand Gesture Indicator
              Positioned(
                bottom: -22,
                child: const Icon(
                  Icons.touch_app_rounded,
                  color: Color(0xFFFFD54F),
                  size: 34,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // ONBOARDING 3: Power-Ups Preview Card
  // ═════════════════════════════════════════════════════════════════════════════
  Widget _buildPowerUpsIllustration() {
    return Container(
      width: 260,
      height: 290,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0D162B),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF2A3D66), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPowerUpCard(Icons.local_fire_department_rounded, const Color(0xFFFF5252)),
              _buildPowerUpCard(Icons.grain_rounded, const Color(0xFF00E5FF)),
              _buildPowerUpCard(Icons.bolt_rounded, const Color(0xFFFFD600)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPowerUpCard(Icons.brightness_7_rounded, const Color(0xFF00E676)),
              _buildPowerUpCard(Icons.width_wide_rounded, const Color(0xFFE040FB)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPowerUpCard(IconData icon, Color color) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: const Color(0xFF131D36),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: color, size: 28),
    );
  }

  Widget _buildMiniBrick(String hp, Color color) {
    return Container(
      width: 44,
      height: 22,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withOpacity(0.8), color],
        ),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.0),
      ),
      alignment: Alignment.center,
      child: Text(
        hp,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
