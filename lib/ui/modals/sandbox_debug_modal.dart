import 'package:flutter/material.dart';
import '../../core/constants/game_colors.dart';
import '../../game/systems/game_controller.dart';
import '../components/glass_button.dart';

/// In-Game Sandbox & Physics Testing Suite
class SandboxDebugModal extends StatelessWidget {
  final GameController controller;

  const SandboxDebugModal({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PHYSICS & SWARM SANDBOX',
          style: TextStyle(color: GameColors.neonCyan, fontSize: 16, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 14),

        // Ball Count Modifiers
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildActionChip(
              label: '+100 Balls',
              color: GameColors.neonCyan,
              onTap: () {
                controller.addPermanentBalls(100);
              },
            ),
            _buildActionChip(
              label: '+500 Mega Swarm',
              color: GameColors.solarGold,
              onTap: () {
                controller.addPermanentBalls(500);
              },
            ),
            _buildActionChip(
              label: 'Trigger Nuke',
              color: GameColors.neonPurple,
              onTap: () {
                controller.useSuperNukeBooster();
              },
            ),
            _buildActionChip(
              label: 'Lightning Strike',
              color: GameColors.neonCyan,
              onTap: () {
                controller.useLightningBooster();
              },
            ),
            _buildActionChip(
              label: 'Clear All Bricks',
              color: GameColors.emeraldGreen,
              onTap: () {
                controller.clearAllBricks();
              },
            ),
          ],
        ),

        const SizedBox(height: 20),
        GlassButton(
          onPressed: () => Navigator.of(context).pop(),
          isPrimary: false,
          child: const Text('CLOSE SANDBOX', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildActionChip({required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.18),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.6), width: 1.2),
        ),
        child: Text(
          label,
          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
