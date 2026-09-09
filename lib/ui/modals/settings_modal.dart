import 'package:flutter/material.dart';
import '../../core/constants/game_colors.dart';
import '../../core/constants/game_constants.dart';
import '../../game/systems/audio_synthesizer.dart';
import '../../storage/game_storage.dart';
import '../components/glass_button.dart';

/// Settings Modal with Ultra-Hard Difficulty Selector
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
        // Sound Switch
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.volume_up_rounded, color: GameColors.neonCyan),
                SizedBox(width: 10),
                Text('Sound & Chimes', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            Switch(
              value: !_isMuted,
              activeColor: GameColors.neonCyan,
              onChanged: (val) {
                setState(() => _isMuted = !val);
                AudioSynthesizer.instance.isMuted = !val;
                GameStorage.instance.setIsMuted(!val);
              },
            ),
          ],
        ),
        const Divider(color: Colors.white12, height: 24),

        // Dark Theme Style Options (OLED True Black vs Cyber Space Dark)
        const Row(
          children: [
            Icon(Icons.dark_mode_rounded, color: GameColors.neonPurple),
            SizedBox(width: 10),
            Text('Dark Background Style', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            // Option 1: OLED True Black
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => GameStorage.instance.setDarkThemeIndex(0));
                  AudioSynthesizer.instance.playUiClick();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  decoration: BoxDecoration(
                    color: GameStorage.instance.getDarkThemeIndex() == 0
                        ? GameColors.neonCyan.withOpacity(0.2)
                        : Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: GameStorage.instance.getDarkThemeIndex() == 0
                          ? GameColors.neonCyan
                          : Colors.white12,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white54, width: 1.5),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'OLED True Black',
                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const Text(
                        'Pure #000000',
                        style: TextStyle(color: Colors.white38, fontSize: 9),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Option 2: Cyber Space Dark
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => GameStorage.instance.setDarkThemeIndex(1));
                  AudioSynthesizer.instance.playUiClick();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  decoration: BoxDecoration(
                    color: GameStorage.instance.getDarkThemeIndex() == 1
                        ? GameColors.neonPurple.withOpacity(0.2)
                        : Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: GameStorage.instance.getDarkThemeIndex() == 1
                          ? GameColors.neonPurple
                          : Colors.white12,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: const Color(0xFF080D1A),
                          shape: BoxShape.circle,
                          border: Border.all(color: GameColors.neonPurple, width: 1.5),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Cyber Space Dark',
                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const Text(
                        'Cosmic Nebula',
                        style: TextStyle(color: Colors.white38, fontSize: 9),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const Divider(color: Colors.white12, height: 24),

        // Difficulty Tuning
        const Row(
          children: [
            Icon(Icons.tune_rounded, color: GameColors.electricAmber),
            SizedBox(width: 10),
            Text('Gameplay Difficulty', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),

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
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: isSelected
                    ? GameColors.neonCyan.withOpacity(0.2)
                    : Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? GameColors.neonCyan : Colors.white12,
                  width: isSelected ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: isSelected ? GameColors.neonCyan : Colors.white38,
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
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${mode.hpMultiplier}x HP • ${mode.maxAimBounces} Bounce Aim Guide',
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: GameColors.neonCyan,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${mode.turnScoreMultiplier}x SCORE',
                        style: const TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.w900),
                      ),
                    ),
                ],
              ),
            ),
          );
        }),

        const SizedBox(height: 20),
        GlassButton(
          onPressed: () => Navigator.of(context).pop(),
          isPrimary: true,
          child: const Text('SAVE & CLOSE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        ),
      ],
    );
  }
}
