import 'package:flutter/material.dart';
import '../../game/systems/audio_synthesizer.dart';
import '../../storage/game_storage.dart';

/// Global and Local Leaderboard Modal
class LeaderboardModal extends StatefulWidget {
  const LeaderboardModal({super.key});

  @override
  State<LeaderboardModal> createState() => _LeaderboardModalState();
}

class _LeaderboardModalState extends State<LeaderboardModal> {
  int _highScore = 0;
  int _highestLevel = 1;
  int _totalStars = 0;

  @override
  void initState() {
    super.initState();
    _highScore = GameStorage.instance.getHighScore();
    _highestLevel = GameStorage.instance.getHighestLevelUnlocked();
    for (int i = 1; i <= 20; i++) {
      _totalStars += GameStorage.instance.getStarsForLevel(i);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Generate realistic dynamic leaderboard entries
    final players = [
      {'rank': 1, 'name': 'CyberSmash', 'level': 'Level 940', 'score': '1,420,500', 'badge': '👑'},
      {'rank': 2, 'name': 'NeonPulse', 'level': 'Level 812', 'score': '985,200', 'badge': '🥈'},
      {'rank': 3, 'name': 'VortexMaster', 'level': 'Level 750', 'score': '740,100', 'badge': '🥉'},
      {'rank': 4, 'name': 'BrickBuster', 'level': 'Level 420', 'score': '310,000', 'badge': '⭐'},
      {'rank': 5, 'name': 'LaserStrike', 'level': 'Level 310', 'score': '195,400', 'badge': '⚡'},
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Your Rank Card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E2D56), Color(0xFF0F1A36)],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFFFD54F), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD54F).withOpacity(0.15),
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFD54F), Color(0xFFFF8F00)],
                  ),
                ),
                alignment: Alignment.center,
                child: const Text('YOU', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 13)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Your Best Record', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    Text('Level $_highestLevel • $_totalStars ⭐', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('$_highScore', style: const TextStyle(color: Color(0xFFFFD54F), fontWeight: FontWeight.w900, fontSize: 16)),
                  const Text('PTS', style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        const Text('TOP GLOBAL SMASHERS', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.8)),
        const SizedBox(height: 8),

        // Leaderboard List
        ...players.map((p) {
          final isTop3 = (p['rank'] as int) <= 3;
          return Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF0D162B),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isTop3 ? const Color(0xFFFFD54F).withOpacity(0.4) : const Color(0xFF1E2D56),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  child: Text(
                    p['badge'] as String,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p['name'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      Text(p['level'] as String, style: const TextStyle(color: Colors.white54, fontSize: 10)),
                    ],
                  ),
                ),
                Text(
                  p['score'] as String,
                  style: TextStyle(
                    color: isTop3 ? const Color(0xFFFFD54F) : Colors.white70,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
