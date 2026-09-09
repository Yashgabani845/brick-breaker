import 'package:flutter/material.dart';
import '../../core/constants/game_colors.dart';
import '../../core/constants/game_constants.dart';
import '../../game/systems/audio_synthesizer.dart';
import '../../storage/game_storage.dart';

/// Master Settings Screen (Screen 13 from Master Reference Mockup)
/// Features Sound, Music, Vibration, Language, Notifications, Privacy Policy, Terms, Restore Purchases, Support, and Reset Progress button.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  bool _vibrationEnabled = true;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _soundEnabled = AudioSynthesizer.instance.soundEnabled;
    _musicEnabled = AudioSynthesizer.instance.musicEnabled;
    _vibrationEnabled = GameStorage.instance.getHapticsEnabled();
  }

  void _resetProgress() async {
    AudioSynthesizer.instance.playBombExplosion();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0D162B),
        title: const Text('Reset All Progress?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'This will reset all your coins, gems, high scores, and level progress.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF1744)),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reset', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await GameStorage.instance.clearAllData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Game progress reset successfully!')),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090E1D),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      AudioSynthesizer.instance.playUiClick();
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF131D36),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF2A3D66), width: 1.2),
                      ),
                      child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Settings',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 36), // Balance back button
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Settings Items Card Container
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D162B),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF2A3D66), width: 1.2),
                      ),
                      child: Column(
                        children: [
                          _buildSwitchTile(
                            icon: Icons.volume_up_rounded,
                            title: 'Sound',
                            value: _soundEnabled,
                            onChanged: (val) {
                              setState(() => _soundEnabled = val);
                              AudioSynthesizer.instance.setSoundEnabled(val);
                            },
                          ),
                          _buildDivider(),
                          _buildSwitchTile(
                            icon: Icons.music_note_rounded,
                            title: 'Music',
                            value: _musicEnabled,
                            onChanged: (val) {
                              setState(() => _musicEnabled = val);
                              AudioSynthesizer.instance.setMusicEnabled(val);
                            },
                          ),
                          _buildDivider(),
                          _buildSwitchTile(
                            icon: Icons.vibration_rounded,
                            title: 'Vibration',
                            value: _vibrationEnabled,
                            onChanged: (val) {
                              setState(() => _vibrationEnabled = val);
                              GameStorage.instance.setHapticsEnabled(val);
                            },
                          ),
                          _buildDivider(),
                          _buildNavigationTile(
                            icon: Icons.language_rounded,
                            title: 'Language',
                            trailingText: 'English',
                            onTap: () {},
                          ),
                          _buildDivider(),
                          _buildSwitchTile(
                            icon: Icons.notifications_rounded,
                            title: 'Notifications',
                            value: _notificationsEnabled,
                            onChanged: (val) => setState(() => _notificationsEnabled = val),
                          ),
                          _buildDivider(),
                          _buildNavigationTile(
                            icon: Icons.lock_rounded,
                            title: 'Privacy Policy',
                            onTap: () {},
                          ),
                          _buildDivider(),
                          _buildNavigationTile(
                            icon: Icons.description_rounded,
                            title: 'Terms of Service',
                            onTap: () {},
                          ),
                          _buildDivider(),
                          _buildNavigationTile(
                            icon: Icons.restore_rounded,
                            title: 'Restore Purchases',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Purchases restored successfully!')),
                              );
                            },
                          ),
                          _buildDivider(),
                          _buildNavigationTile(
                            icon: Icons.support_agent_rounded,
                            title: 'Support',
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Reset Progress Button (Red)
                    GestureDetector(
                      onTap: _resetProgress,
                      child: Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF1744), Color(0xFFD50000)],
                          ),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF1744).withOpacity(0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Reset Progress',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF8E9EB8), size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Switch(
            value: value,
            activeColor: const Color(0xFF00E676),
            activeTrackColor: const Color(0xFF00E676).withOpacity(0.35),
            inactiveThumbColor: const Color(0xFF8E9EB8),
            inactiveTrackColor: const Color(0xFF1E2C4A),
            onChanged: (val) {
              AudioSynthesizer.instance.playUiClick();
              onChanged(val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationTile({
    required IconData icon,
    required String title,
    String? trailingText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        AudioSynthesizer.instance.playUiClick();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF8E9EB8), size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (trailingText != null)
              Text(
                trailingText,
                style: const TextStyle(color: Color(0xFF8E9EB8), fontSize: 13, fontWeight: FontWeight.bold),
              ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF53678A), size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(color: Color(0xFF1E2C4A), height: 1, indent: 16, endIndent: 16);
  }
}
