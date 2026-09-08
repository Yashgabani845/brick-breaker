import 'package:flutter/material.dart';
import '../../core/constants/game_colors.dart';
import '../components/glass_button.dart';
import '../components/neon_glow_text.dart';

/// Glassmorphic Pause Modal
class PauseModal extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onSettings;
  final VoidCallback onExit;

  const PauseModal({
    super.key,
    required this.onResume,
    required this.onRestart,
    required this.onSettings,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const NeonGlowText(
          'GAME PAUSED',
          fontSize: 24.0,
          color: Colors.white,
          glowColor: GameColors.neonCyan,
        ),
        const SizedBox(height: 28),
        GlassButton(
          onPressed: onResume,
          gradient: const [GameColors.neonCyan, Color(0xFF0077FF)],
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
              SizedBox(width: 8),
              Text('RESUME', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        GlassButton(
          onPressed: onRestart,
          gradient: const [GameColors.electricAmber, Color(0xFFFF5500)],
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.replay_rounded, color: Colors.white, size: 22),
              SizedBox(width: 8),
              Text('RESTART', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        GlassButton(
          onPressed: onSettings,
          isPrimary: false,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.settings_rounded, color: Colors.white, size: 22),
              SizedBox(width: 8),
              Text('SETTINGS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        GlassButton(
          onPressed: onExit,
          isPrimary: false,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.home_rounded, color: Colors.white70, size: 22),
              SizedBox(width: 8),
              Text('MAIN MENU', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ),
      ],
    );
  }
}
