import 'package:flutter/material.dart';
import '../../game/systems/audio_synthesizer.dart';
import '../../storage/game_storage.dart';

/// Level Failed Modal (Screen 10 from Master Reference Mockup)
/// Features glowing "LEVEL FAILED" title, broken heart icon, Score and Best Score breakdown,
/// Save Me (purple video ad button), Retry (blue), and Home (navy) buttons.
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
    final bestScore = GameStorage.instance.getHighScore();

    return Container(
      width: 290,
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
          // Close X
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
            'LEVEL FAILED',
            style: TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.w900,
              color: Color(0xFFFF2A6D),
              letterSpacing: 1.2,
              shadows: [
                Shadow(color: Color(0xFFFF2A6D), blurRadius: 10),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Broken Heart Icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1128),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFF2A6D).withOpacity(0.5), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF2A6D).withOpacity(0.25),
                  blurRadius: 14,
                ),
              ],
            ),
            child: const Icon(
              Icons.heart_broken_rounded,
              color: Color(0xFFFF2A6D),
              size: 36,
            ),
          ),
          const SizedBox(height: 16),

          // Score Stats Card
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
                const SizedBox(height: 6),
                _buildStatRow('Best Score', bestScore > score ? bestScore.toString() : score.toString()),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Save Me - Watch Ad Button (Purple)
          GestureDetector(
            onTap: () {
              AudioSynthesizer.instance.playRewardClaim();
              onSaveWithGems();
            },
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFAB47BC), Color(0xFF7B1FA2)],
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFAB47BC).withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.smart_display_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Save Me',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Watch Ad',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Retry Button (Blue)
          GestureDetector(
            onTap: () {
              AudioSynthesizer.instance.playUiClick();
              onRetry();
            },
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00B0FF), Color(0xFF0081CB)],
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00B0FF).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Text(
                'Retry',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Home Button (Navy)
          GestureDetector(
            onTap: () {
              AudioSynthesizer.instance.playUiClick();
              onMenu();
            },
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFF131D36),
                borderRadius: BorderRadius.circular(21),
                border: Border.all(color: const Color(0xFF2A3D66), width: 1.2),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Home',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
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
}
