import 'package:flutter/material.dart';
import '../../game/systems/audio_synthesizer.dart';

/// Level Complete Modal (Screen 9 from Master Reference Mockup)
/// Features glowing "LEVEL COMPLETE!" title, 3 golden stars, Score & Best Score with NEW! badge,
/// Coins + Gems reward breakdown, Next Level (green), 2X Coins (orange), and Home button.
class LevelCompleteModal extends StatelessWidget {
  final int levelNumber;
  final int score;
  final int stars;
  final int coinsEarned;
  final int gemsEarned;
  final VoidCallback onNextLevel;
  final VoidCallback onDoubleReward;
  final VoidCallback onMenu;

  const LevelCompleteModal({
    super.key,
    required this.levelNumber,
    required this.score,
    required this.stars,
    required this.coinsEarned,
    this.gemsEarned = 5,
    required this.onNextLevel,
    required this.onDoubleReward,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
        children: [
          // Header: Close X
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: onMenu,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFF131D36),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded, color: Colors.white70, size: 16),
              ),
            ),
          ),

          // Title
          const Text(
            'LEVEL COMPLETE!',
            style: TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.w900,
              color: Color(0xFF00E676),
              letterSpacing: 1.2,
              shadows: [
                Shadow(color: Color(0xFF00E676), blurRadius: 10),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 3 Giant Glowing Gold Stars
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              final isLit = index < stars;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Icon(
                  Icons.star_rounded,
                  size: 42.0,
                  color: isLit ? const Color(0xFFFFD700) : const Color(0xFF223254),
                  shadows: isLit
                      ? const [
                          Shadow(color: Color(0xFFFF9100), blurRadius: 12),
                        ]
                      : null,
                ),
              );
            }),
          ),
          const SizedBox(height: 16),

          // Stats Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF101A36),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF223565), width: 1.2),
            ),
            child: Column(
              children: [
                _buildStatRow('Score', score.toString()),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Best Score',
                      style: TextStyle(color: Color(0xFF8E9EB8), fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Text(
                          score.toString(),
                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF9100),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'NEW!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Divider(color: Color(0xFF223565), height: 1),
                ),
                _buildRewardRow('Coins', '+$coinsEarned', const Color(0xFFFFD700), '🪙'),
                const SizedBox(height: 6),
                _buildRewardRow('Gems', '+$gemsEarned', const Color(0xFFE040FB), '💎'),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Next Level Button (Green)
          GestureDetector(
            onTap: () {
              AudioSynthesizer.instance.playUiClick();
              onNextLevel();
            },
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00E676), Color(0xFF00C853)],
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00E676).withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Text(
                'Next Level',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // 2X Coins - Watch Ad Button (Orange)
          GestureDetector(
            onTap: () {
              AudioSynthesizer.instance.playUiClick();
              onDoubleReward();
            },
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF9100), Color(0xFFFF6D00)],
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF9100).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.smart_display_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 6),
                  Text(
                    '2X Coins - Watch Ad',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Home Icon Button
          IconButton(
            icon: const Icon(Icons.home_rounded, color: Colors.white60, size: 24),
            onPressed: () {
              AudioSynthesizer.instance.playUiClick();
              onMenu();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF8E9EB8), fontSize: 13, fontWeight: FontWeight.bold),
        ),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }

  Widget _buildRewardRow(String label, String value, Color color, String icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(color: Color(0xFF8E9EB8), fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}
