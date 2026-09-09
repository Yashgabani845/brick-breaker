import 'package:flutter/material.dart';
import '../../core/constants/game_colors.dart';
import '../../game/systems/audio_synthesizer.dart';
import '../../storage/game_storage.dart';

/// Master Leaderboard Screen (Screen 14 from Master Reference Mockup)
/// Features Global & Friends tabs, Gold/Silver/Bronze badges, and highlighted player card ("4 You 124,560").
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  int _selectedTabIndex = 0; // 0: Global, 1: Friends
  int _playerHighScore = 124560;

  final List<Map<String, dynamic>> _globalLeaderboard = [
    {'rank': 1, 'name': 'PlayerOne', 'score': 256480, 'isPlayer': false},
    {'rank': 2, 'name': 'SmashKing', 'score': 201350, 'isPlayer': false},
    {'rank': 3, 'name': 'BrickMaster', 'score': 189720, 'isPlayer': false},
    {'rank': 4, 'name': 'You', 'score': 124560, 'isPlayer': true},
    {'rank': 5, 'name': 'BallBlitz', 'score': 98430, 'isPlayer': false},
    {'rank': 6, 'name': 'NeonNinja', 'score': 87210, 'isPlayer': false},
    {'rank': 7, 'name': 'PixelPro', 'score': 76980, 'isPlayer': false},
    {'rank': 8, 'name': 'VortexStriker', 'score': 64200, 'isPlayer': false},
  ];

  final List<Map<String, dynamic>> _friendsLeaderboard = [
    {'rank': 1, 'name': 'SmashKing', 'score': 201350, 'isPlayer': false},
    {'rank': 2, 'name': 'You', 'score': 124560, 'isPlayer': true},
    {'rank': 3, 'name': 'NeonNinja', 'score': 87210, 'isPlayer': false},
    {'rank': 4, 'name': 'PixelPro', 'score': 76980, 'isPlayer': false},
  ];

  @override
  void initState() {
    super.initState();
    final savedScore = GameStorage.instance.getHighScore();
    if (savedScore > 0) {
      _playerHighScore = savedScore;
      _globalLeaderboard[3]['score'] = _playerHighScore;
      _friendsLeaderboard[1]['score'] = _playerHighScore;
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeList = _selectedTabIndex == 0 ? _globalLeaderboard : _friendsLeaderboard;

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
                        'Leaderboard',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 36),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Tabs: Global | Friends
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF131D36),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFF2A3D66), width: 1.2),
                ),
                child: Row(
                  children: [
                    _buildTab('Global', 0),
                    _buildTab('Friends', 1),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Leaderboard List
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
                itemCount: activeList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final entry = activeList[index];
                  final isPlayer = entry['isPlayer'] as bool;
                  final rank = entry['rank'] as int;

                  return Container(
                    height: 54,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isPlayer ? const Color(0xFF00B0FF) : const Color(0xFF0D162B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isPlayer ? const Color(0xFF80D8FF) : const Color(0xFF2A3D66),
                        width: isPlayer ? 2.0 : 1.2,
                      ),
                      boxShadow: isPlayer
                          ? [
                              BoxShadow(
                                color: const Color(0xFF00B0FF).withOpacity(0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      children: [
                        // Rank Badge
                        _buildRankBadge(rank),
                        const SizedBox(width: 14),

                        // Player Name
                        Expanded(
                          child: Text(
                            entry['name'],
                            style: TextStyle(
                              color: isPlayer ? Colors.white : Colors.white.withOpacity(0.9),
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),

                        // Score
                        Text(
                          _formatScore(entry['score'] as int),
                          style: TextStyle(
                            color: isPlayer ? Colors.white : const Color(0xFF00E5FF),
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          AudioSynthesizer.instance.playUiClick();
          setState(() => _selectedTabIndex = index);
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF00B0FF) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF8E9EB8),
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRankBadge(int rank) {
    if (rank == 1) {
      return Container(
        width: 28,
        height: 28,
        decoration: const BoxDecoration(
          color: Color(0xFFFFD700),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Text('1', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w900, fontSize: 13)),
      );
    } else if (rank == 2) {
      return Container(
        width: 28,
        height: 28,
        decoration: const BoxDecoration(
          color: Color(0xFFB0BEC5),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Text('2', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w900, fontSize: 13)),
      );
    } else if (rank == 3) {
      return Container(
        width: 28,
        height: 28,
        decoration: const BoxDecoration(
          color: Color(0xFFFF8A65),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Text('3', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w900, fontSize: 13)),
      );
    } else {
      return SizedBox(
        width: 28,
        child: Text(
          '$rank',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF8E9EB8), fontWeight: FontWeight.w900, fontSize: 14),
        ),
      );
    }
  }

  String _formatScore(int score) {
    return score.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}
