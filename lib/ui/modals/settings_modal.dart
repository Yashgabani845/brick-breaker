import 'package:flutter/material.dart';
import '../../core/constants/game_colors.dart';
import '../../core/constants/game_constants.dart';
import '../../game/systems/audio_synthesizer.dart';
import '../../storage/game_storage.dart';

/// Redesigned Settings Modal matching Brick Smash theme
class SettingsModal extends StatefulWidget {
  final DifficultyMode currentDifficulty;
  final ValueChanged<DifficultyMode> onDifficultyChanged;

  const SettingsModal({
    super.key,
    required this.currentDifficulty,
    required this.onDifficultyChanged,
  });

  @override
  State<SettingsModal> createState() => _SettingsModalState();
}

class _SettingsModalState extends State<SettingsModal> {
  late bool _isMuted;
  late DifficultyMode _selectedDifficulty;

  @override
  void initState() {
    super.initState();
    _isMuted = AudioSynthesizer.instance.isMuted;
    _selectedDifficulty = widget.currentDifficulty;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sound Switch Row
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF101A36),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF263868)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.volume_up_rounded, color: Color(0xFF00E5FF), size: 22),
                  SizedBox(width: 10),
                  Text('Sound & Music', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                ],
              ),
              Switch(
                value: !_isMuted,
                activeColor: const Color(0xFF00E5FF),
                onChanged: (val) {
                  setState(() => _isMuted = !val);
                  AudioSynthesizer.instance.isMuted = !val;
                  GameStorage.instance.setIsMuted(!val);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Difficulty Tuning
        const Text(
          'GAMEPLAY DIFFICULTY',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),

        ...DifficultyMode.values.map((mode) {
          final isSelected = _selectedDifficulty == mode;

          return GestureDetector(
            onTap: () {
              setState(() => _selectedDifficulty = mode);
              widget.onDifficultyChanged(mode);
              GameStorage.instance.setDifficultyMode(mode);
              AudioSynthesizer.instance.playUiClick();
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 8.0),
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF192A56) : const Color(0xFF101A36),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? const Color(0xFF00E5FF) : const Color(0xFF263868),
                  width: isSelected ? 1.8 : 1.0,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: isSelected ? const Color(0xFF00E5FF) : Colors.white38,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mode.displayName,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          '${mode.hpMultiplier}x HP • ${mode.maxAimBounces} Bounce Guide',
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00E5FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${mode.turnScoreMultiplier}x PTS',
                        style: const TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.w900),
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 16),

        // Close Button
        GestureDetector(
          onTap: () {
            AudioSynthesizer.instance.playUiClick();
            Navigator.of(context).pop();
          },
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00E676), Color(0xFF00C853)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00E676).withOpacity(0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'SAVE & CLOSE',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
