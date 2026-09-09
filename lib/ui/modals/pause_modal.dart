import 'package:flutter/material.dart';
import '../../game/systems/audio_synthesizer.dart';

/// Pause Modal (Screen 8 from Master Reference Mockup)
/// Features glowing "PAUSED" title, Resume (green), Restart (blue), Settings (navy), and Home (red) pill buttons.
class PauseModal extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onSettings;
  final VoidCallback onMenu;

  const PauseModal({
    super.key,
    required this.onResume,
    required this.onRestart,
    required this.onSettings,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF0D162B),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF2A3D66), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title
          const Center(
            child: Text(
              'PAUSED',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.w900,
                color: Color(0xFF00E5FF),
                letterSpacing: 2.0,
                shadows: [
                  Shadow(
                    color: Color(0xFF00E5FF),
                    blurRadius: 12,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Resume Button (Green)
          _buildPillButton(
            label: 'Resume',
            gradient: const [Color(0xFF00E676), Color(0xFF00C853)],
            shadowColor: const Color(0xFF00E676),
            onTap: () {
              AudioSynthesizer.instance.playUiClick();
              onResume();
            },
          ),
          const SizedBox(height: 12),

          // Restart Button (Blue)
          _buildPillButton(
            label: 'Restart',
            gradient: const [Color(0xFF00B0FF), Color(0xFF0081CB)],
            shadowColor: const Color(0xFF00B0FF),
            onTap: () {
              AudioSynthesizer.instance.playUiClick();
              onRestart();
            },
          ),
          const SizedBox(height: 12),

          // Settings Button (Navy)
          _buildPillButton(
            label: 'Settings',
            gradient: const [Color(0xFF1E3A8A), Color(0xFF1E293B)],
            borderColor: const Color(0xFF3B82F6),
            onTap: () {
              AudioSynthesizer.instance.playUiClick();
              onSettings();
            },
          ),
          const SizedBox(height: 12),

          // Home Button (Red)
          _buildPillButton(
            label: 'Home',
            gradient: const [Color(0xFFFF1744), Color(0xFFD50000)],
            shadowColor: const Color(0xFFFF1744),
            onTap: () {
              AudioSynthesizer.instance.playUiClick();
              onMenu();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPillButton({
    required String label,
    required List<Color> gradient,
    Color? borderColor,
    Color? shadowColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: borderColor ?? Colors.white.withOpacity(0.3),
            width: 1.2,
          ),
          boxShadow: shadowColor != null
              ? [
                  BoxShadow(
                    color: shadowColor.withOpacity(0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
