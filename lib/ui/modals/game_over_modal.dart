import 'package:flutter/material.dart';
import '../../core/constants/game_colors.dart';
import '../components/glass_button.dart';
import '../components/neon_glow_text.dart';

/// Glassmorphic Game Over Modal
class GameOverModal extends StatelessWidget {
  final int score;
  final VoidCallback onRetry;
  final VoidCallback onSaveWithGems;
  final VoidCallback onMenu;

  const GameOverModal({
    super.key,
    required this.score,
    required this.onRetry,
    required this.onSaveWithGems,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.warning_amber_rounded, size: 48, color: GameColors.crimsonDanger),
        const SizedBox(height: 8),
        const Text(
          'DANGER LINE BREACHED',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 1.0,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        const Text(
          'The bricks reached the threshold row!',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('SCORE ACHIEVED', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
              Text(
                '$score',
                style: const TextStyle(color: GameColors.neonCyan, fontSize: 18, fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        GlassButton(
          onPressed: onRetry,
          gradient: const [GameColors.electricAmber, Color(0xFFFF5500)],
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.replay_rounded, color: Colors.white, size: 22),
              SizedBox(width: 8),
              Text('TRY AGAIN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ),
        const SizedBox(height: 10),

        GlassButton(
          onPressed: onSaveWithGems,
          gradient: const [GameColors.neonPurple, Color(0xFF6B21A8)],
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shield_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('EMERGENCY SAVE (10 💎)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
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
