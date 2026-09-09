import 'package:flutter/material.dart';
import '../../core/constants/game_colors.dart';
import '../components/glass_button.dart';
import '../components/neon_glow_text.dart';

/// Glassmorphic Level Victory Modal
class LevelCompleteModal extends StatelessWidget {
  final int levelNumber;
  final int score;
  final int stars;
  final int coinsEarned;
  final int ballsCollected;
  final VoidCallback onNextLevel;
  final VoidCallback onDoubleReward;
  final VoidCallback onMenu;

  const LevelCompleteModal({
    super.key,
    required this.levelNumber,
    required this.score,
    required this.stars,
    required this.coinsEarned,
    required this.ballsCollected,
    required this.onNextLevel,
    required this.onDoubleReward,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'LEVEL CLEARED!',
          style: TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 14),

        // Stars Display
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final isLit = index < stars;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Icon(
                Icons.star_rounded,
                size: 40.0,
                color: isLit ? GameColors.solarGold : Colors.white24,
              ),
            );
          }),
        ),
        const SizedBox(height: 16),

        // Score & Stats Container
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('FINAL SCORE', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                  Text(
                    '$score',
                    style: const TextStyle(color: GameColors.neonCyan, fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('COINS EARNED', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                  Text(
                    '+$coinsEarned 🪙',
                    style: const TextStyle(color: GameColors.electricAmber, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              if (ballsCollected > 0) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('PERMANENT AMMO', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                    Text(
                      '+$ballsCollected BALLS',
                      style: const TextStyle(color: GameColors.emeraldGreen, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Next Level CTA
        GlassButton(
          onPressed: onNextLevel,
          gradient: const [GameColors.emeraldGreen, Color(0xFF009960)],
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('NEXT LEVEL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 22),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Double Rewards Button
        GlassButton(
          onPressed: onDoubleReward,
          gradient: const [GameColors.solarGold, Color(0xFFFF8800)],
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.video_library_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('2X REWARD (FREE)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        ),
        const SizedBox(height: 10),

        GlassButton(
          onPressed: onMenu,
          isPrimary: false,
          child: const Text('MAIN MENU', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 14)),
        ),
      ],
    );
  }
}
