import 'package:flutter/material.dart';
import '../../core/constants/game_colors.dart';
import '../../game/systems/game_controller.dart';
import '../components/glass_button.dart';

/// In-Game Sandbox, Physics Testing & Quick Level Selector Suite
class SandboxDebugModal extends StatefulWidget {
  final GameController? controller;
  final ValueChanged<int>? onLoadLevel;

  const SandboxDebugModal({
    super.key,
    this.controller,
    this.onLoadLevel,
  });

  @override
  State<SandboxDebugModal> createState() => _SandboxDebugModalState();
}

class _SandboxDebugModalState extends State<SandboxDebugModal> {
  final TextEditingController _levelInputController = TextEditingController(text: '1');

  @override
  void dispose() {
    _levelInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PHYSICS & LEVEL SELECTOR',
          style: TextStyle(color: GameColors.neonCyan, fontSize: 16, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 14),

        // Quick Jump to any level 1 - 1000
        const Text('Jump to Any Level (1 - 1000):', style: TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _levelInputController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: 'Enter level (1 - 1000)',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.06),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: GameColors.neonCyan),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GlassButton(
              onPressed: () {
                final lvl = int.tryParse(_levelInputController.text.trim()) ?? 1;
                final clamped = lvl.clamp(1, 1000);
                if (widget.onLoadLevel != null) {
                  widget.onLoadLevel!(clamped);
                } else if (widget.controller != null) {
                  // In gameplay
                  Navigator.of(context).pop();
                }
              },
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              borderRadius: 12,
              child: const Text('GO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // In-Game Sandbox Modifiers (if controller is active)
        if (widget.controller != null) ...[
          const Text('Active In-Game Cheats & Modifiers:', style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildActionChip(
                label: '+100 Balls',
                color: GameColors.neonCyan,
                onTap: () {
                  widget.controller?.addPermanentBalls(100);
                },
              ),
              _buildActionChip(
                label: '+500 Mega Swarm',
                color: GameColors.solarGold,
                onTap: () {
                  widget.controller?.addPermanentBalls(500);
                },
              ),
              _buildActionChip(
                label: 'Trigger Nuke',
                color: GameColors.neonPurple,
                onTap: () {
                  widget.controller?.useSuperNukeBooster();
                },
              ),
              _buildActionChip(
                label: 'Lightning Strike',
                color: GameColors.neonCyan,
                onTap: () {
                  widget.controller?.useLightningBooster();
                },
              ),
              _buildActionChip(
                label: 'Clear All Bricks',
                color: GameColors.emeraldGreen,
                onTap: () {
                  widget.controller?.clearAllBricks();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],

        GlassButton(
          onPressed: () => Navigator.of(context).pop(),
          isPrimary: false,
          child: const Text('CLOSE', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
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
