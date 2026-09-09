import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/game_colors.dart';
import '../../core/constants/game_constants.dart';
import '../../game/levels/level_catalog.dart';
import '../../game/systems/audio_synthesizer.dart';
import '../../storage/game_storage.dart';

/// Level Map Screen (Screen 6 from Master Reference Mockup)
/// Features Neon Valley Chapter 1, serpentine winding path, glowing circular level nodes with stars, and unlock banner.
class LevelMapScreen extends StatefulWidget {
  final int unlockedLevel;
  final ValueChanged<int> onSelectLevel;

  const LevelMapScreen({
    super.key,
    required this.unlockedLevel,
    required this.onSelectLevel,
  });

  @override
  State<LevelMapScreen> createState() => _LevelMapScreenState();
}

class _LevelMapScreenState extends State<LevelMapScreen> with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _pulseController;
  int _coins = 1250;
  int _gems = 50;

  @override
  void initState() {
    super.initState();
    _coins = GameStorage.instance.getCoins();
    _gems = GameStorage.instance.getGems();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Scroll smoothly to the current level node
      final targetOffset = ((widget.unlockedLevel - 1) * 85.0).clamp(0.0, 2000.0);
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(targetOffset);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090E1D),
      body: Stack(
        children: [
          // Background Gradient & Landscape
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0F1A36),
                    Color(0xFF070B18),
                    Color(0xFF04060E),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // 1. Top Bar: Back, Coins, Gems
                _buildTopBar(),

                // 2. Chapter Title: "Neon Valley - Chapter 1"
                _buildChapterHeader(),

                const SizedBox(height: 6),

                // 3. Winding Path of Level Nodes
                Expanded(
                  child: Stack(
                    children: [
                      // Winding Path Level List
                      ListView.builder(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(top: 20, bottom: 90),
                        itemCount: 40,
                        itemBuilder: (context, index) {
                          final levelNum = index + 1;
                          final isUnlocked = levelNum <= widget.unlockedLevel;
                          final isCurrent = levelNum == widget.unlockedLevel;
                          final stars = GameStorage.instance.getStarsForLevel(levelNum);

                          // Serpentine horizontal offset
                          final sinVal = math.sin(index * 0.85);
                          final horizontalAlign = sinVal * 0.65; // -0.65 to +0.65

                          return _buildLevelNode(
                            levelNum: levelNum,
                            isUnlocked: isUnlocked,
                            isCurrent: isCurrent,
                            stars: stars,
                            horizontalAlign: horizontalAlign,
                          );
                        },
                      ),

                      // Bottom Floating Pill Banner: "Complete levels to unlock new worlds!"
                      Positioned(
                        bottom: 16,
                        left: 24,
                        right: 24,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF131D36).withOpacity(0.95),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xFF2A3D66), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Complete levels to unlock new worlds!',
                            style: TextStyle(
                              color: Color(0xFF8E9EB8),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
      child: Row(
        children: [
          // Back Button
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
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const Spacer(),

          // Coins Pill
          _buildPill(icon: '🪙', value: _coins.toString(), color: const Color(0xFFFFD700)),
          const SizedBox(width: 8),

          // Gems Pill
          _buildPill(icon: '💎', value: _gems.toString(), color: const Color(0xFFE040FB)),
        ],
      ),
    );
  }

  Widget _buildPill({required String icon, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF131D36),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A3D66), width: 1.2),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 5),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.add_circle_rounded, color: color, size: 14),
        ],
      ),
    );
  }

  Widget _buildChapterHeader() {
    return Column(
      children: const [
        Text(
          'Neon Valley',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
          ),
        ),
        SizedBox(height: 2),
        Text(
          'Chapter 1',
          style: TextStyle(
            color: Color(0xFF00E5FF),
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildLevelNode({
    required int levelNum,
    required bool isUnlocked,
    required bool isCurrent,
    required int stars,
    required double horizontalAlign,
  }) {
    return Align(
      alignment: Alignment(horizontalAlign, 0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: GestureDetector(
          onTap: () {
            if (isUnlocked) {
              AudioSynthesizer.instance.playUiClick();
              widget.onSelectLevel(levelNum);
              Navigator.of(context).pop();
            } else {
              AudioSynthesizer.instance.playBombExplosion();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Reach Level $levelNum to unlock!'),
                  duration: const Duration(seconds: 1),
                ),
              );
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Circular Node Badge
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final scale = isCurrent ? 1.0 + (_pulseController.value * 0.08) : 1.0;
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: isCurrent
                            ? const LinearGradient(
                                colors: [Color(0xFFFF9100), Color(0xFFFF5722)],
                              )
                            : isUnlocked
                                ? const LinearGradient(
                                    colors: [Color(0xFF00B0FF), Color(0xFF0081CB)],
                                  )
                                : const LinearGradient(
                                    colors: [Color(0xFF16223B), Color(0xFF0D1526)],
                                  ),
                        border: Border.all(
                          color: isCurrent
                              ? const Color(0xFFFFD54F)
                              : isUnlocked
                                  ? const Color(0xFF80D8FF)
                                  : const Color(0xFF223254),
                          width: isCurrent ? 2.5 : 1.8,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isCurrent
                                ? const Color(0xFFFF9100).withOpacity(0.6)
                                : isUnlocked
                                    ? const Color(0xFF00B0FF).withOpacity(0.4)
                                    : Colors.black.withOpacity(0.3),
                            blurRadius: isCurrent ? 14 : 8,
                            spreadRadius: isCurrent ? 2 : 0,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: isUnlocked
                          ? Text(
                              levelNum.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            )
                          : const Icon(
                              Icons.lock_rounded,
                              color: Color(0xFF53678A),
                              size: 20,
                            ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 4),

              // 3 Stars Underneath Node
              if (isUnlocked)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (starIdx) {
                    final earned = (stars > 0 && starIdx < stars) || isUnlocked;
                    return Icon(
                      Icons.star_rounded,
                      color: earned ? const Color(0xFFFFD700) : const Color(0xFF3B4866),
                      size: 13,
                    );
                  }),
                )
              else
                const SizedBox(height: 13),
            ],
          ),
        ),
      ),
    );
  }
}
