import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/game_colors.dart';
import '../../core/constants/game_constants.dart';
import '../../game/models/ball.dart';
import '../../game/models/level_data.dart';
import '../../game/levels/level_catalog.dart';
import '../../game/rendering/game_painter.dart';
import '../../game/systems/audio_synthesizer.dart';
import '../../game/systems/game_controller.dart';
import '../../storage/game_storage.dart';
import '../components/glass_modal.dart';
import '../modals/game_over_modal.dart';
import '../modals/level_complete_modal.dart';
import '../modals/pause_modal.dart';
import '../modals/settings_modal.dart';

import '../../game/models/paddle.dart';

/// Interactive Gameplay Screen for Brick Smash
/// Matches Screen 7 from Master Mockup with 3D beveled bricks, responsive paddle, lives counter, and 4-slot booster dock.
class GameplayScreen extends StatefulWidget {
  final LevelData levelData;
  final DifficultyMode difficulty;
  final int initialBalls;
  final BallSkin ballSkin;
  final PaddleSkin? paddleSkin;

  const GameplayScreen({
    super.key,
    required this.levelData,
    this.difficulty = DifficultyMode.standard,
    this.initialBalls = 1,
    this.ballSkin = BallSkin.neonWhite,
    this.paddleSkin,
  });

  @override
  State<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends State<GameplayScreen> with SingleTickerProviderStateMixin {
  late final GameController _controller;
  late final AnimationController _ticker;
  double _lastTime = 0.0;
  bool _modalOpen = false;
  int _highScore = 0;

  @override
  void initState() {
    super.initState();
    _controller = GameController();
    _controller.currentBallSkin = widget.ballSkin;
    _controller.currentPaddleSkin = widget.paddleSkin ?? GameStorage.instance.getSelectedPaddleSkin();
    _controller.loadLevel(widget.levelData, diff: widget.difficulty);
    _highScore = GameStorage.instance.getHighScore();

    _controller.addListener(_onGameControllerUpdated);

    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _ticker.addListener(_onTick);
  }

  void _onTick() {
    final now = DateTime.now().microsecondsSinceEpoch / 1000000.0;
    if (_lastTime == 0.0) {
      _lastTime = now;
      return;
    }
    final dt = (now - _lastTime).clamp(0.001, 0.05);
    _lastTime = now;

    _controller.update(dt);
  }

  void _onGameControllerUpdated() {
    if (!mounted || _modalOpen) return;

    if (_controller.state == GameState.levelComplete) {
      _showLevelComplete();
    } else if (_controller.state == GameState.levelFailed) {
      _showGameOver();
    }
  }

  Future<void> _showLevelComplete() async {
    _modalOpen = true;
    final stars = _controller.scoreSystem.calculateStars(_controller.currentLevel.targetScore);
    const coins = GameConstants.coinsPerLevelClear;
    const gems = 5;

    await GameStorage.instance.setHighestLevelUnlocked(_controller.currentLevel.levelNumber + 1);
    await GameStorage.instance.setStarsForLevel(_controller.currentLevel.levelNumber, stars);
    await GameStorage.instance.setHighScore(_controller.scoreSystem.currentScore);
    await GameStorage.instance.addCoins(coins);
    await GameStorage.instance.addGems(gems);

    if (!mounted) return;

    await GlassModal.show(
      context: context,
      barrierDismissible: false,
      child: LevelCompleteModal(
        levelNumber: _controller.currentLevel.levelNumber,
        score: _controller.scoreSystem.currentScore,
        stars: stars,
        coinsEarned: coins,
        gemsEarned: gems,
        onNextLevel: () {
          Navigator.of(context).pop();
          _modalOpen = false;
          final nextLevelNum = _controller.currentLevel.levelNumber + 1;
          _controller.loadLevel(LevelCatalog.getLevel(nextLevelNum));
        },
        onDoubleReward: () async {
          await GameStorage.instance.addCoins(coins);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Double Rewards Claimed! +250 Coins 🪙')),
            );
            Navigator.of(context).pop();
            _modalOpen = false;
            final nextLevelNum = _controller.currentLevel.levelNumber + 1;
            _controller.loadLevel(LevelCatalog.getLevel(nextLevelNum));
          }
        },
        onMenu: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
      ),
    );
    _modalOpen = false;
  }

  Future<void> _showGameOver() async {
    _modalOpen = true;
    if (!mounted) return;

    await GlassModal.show(
      context: context,
      barrierDismissible: false,
      child: GameOverModal(
        score: _controller.scoreSystem.currentScore,
        onSaveWithGems: () async {
          _controller.revive();
          Navigator.of(context).pop();
          _modalOpen = false;
        },
        onRetry: () {
          Navigator.of(context).pop();
          _modalOpen = false;
          _controller.loadLevel(_controller.currentLevel);
        },
        onMenu: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
      ),
    );
    _modalOpen = false;
  }

  void _openPauseModal() {
    AudioSynthesizer.instance.playUiClick();
    _controller.state = GameState.paused;
    _modalOpen = true;

    GlassModal.show(
      context: context,
      barrierDismissible: false,
      child: PauseModal(
        onResume: () {
          Navigator.of(context).pop();
          _modalOpen = false;
          _controller.state = GameState.playing;
        },
        onRestart: () {
          Navigator.of(context).pop();
          _modalOpen = false;
          _controller.loadLevel(_controller.currentLevel);
        },
        onSettings: () {
          Navigator.of(context).pop();
          _openSettings();
        },
        onMenu: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _openSettings() {
    GlassModal.show(
      context: context,
      title: 'SETTINGS',
      child: SettingsModal(
        currentDifficulty: widget.difficulty,
        onDifficultyChanged: (_) {},
      ),
    ).then((_) {
      _modalOpen = false;
      _controller.state = GameState.playing;
    });
  }

  @override
  void dispose() {
    _ticker.removeListener(_onTick);
    _ticker.dispose();
    _controller.removeListener(_onGameControllerUpdated);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090E1D),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top HUD: Pause, Level + Stars, Score, Lives
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
              child: _buildTopHud(),
            ),

            // 2. Playfield Arena with Real-time Paddle
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  _controller.setDimensions(constraints.maxWidth, constraints.maxHeight);

                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanDown: (details) {
                      _controller.onPaddleDrag(details.localPosition.dx);
                    },
                    onPanUpdate: (details) {
                      _controller.onPaddleDrag(details.localPosition.dx);
                    },
                    onTap: () {
                      if (_controller.state == GameState.aiming) {
                        _controller.launchBall();
                      }
                    },
                    child: AnimatedBuilder(
                      animation: _ticker,
                      builder: (context, _) {
                        return CustomPaint(
                          size: Size(constraints.maxWidth, constraints.maxHeight),
                          painter: GamePainter(
                            bricks: _controller.bricks,
                            balls: _controller.balls,
                            paddle: _controller.paddle,
                            fallingPowerUps: _controller.fallingPowerUps,
                            columns: _controller.currentLevel.columns,
                            rows: _controller.currentLevel.rows,
                            animationProgress: _ticker.value,
                            themeColor: _controller.currentLevel.themeColor,
                            isAiming: _controller.state == GameState.aiming,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),

            // 3. Bottom Booster Dock (4 Cards matching mockup)
            Padding(
              padding: const EdgeInsets.fromLTRB(14.0, 4.0, 14.0, 10.0),
              child: _buildBottomBoosterDock(),
            ),
          ],
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // TOP HUD: Pause Pill, Level + Star Bar, Score, Lives Counter
  // ═════════════════════════════════════════════════════════════════════════════
  Widget _buildTopHud() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final score = _controller.scoreSystem.currentScore;
        final levelNum = _controller.currentLevel.levelNumber;
        final lives = _controller.lives;

        return Row(
          children: [
            // Pause Button (Glass Pill)
            GestureDetector(
              onTap: _openPauseModal,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF131D36),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF2A3D66),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.pause_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),

            const SizedBox(width: 10),

            // Level & Stars Info
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF131D36),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF2A3D66),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Level $levelNum',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Row(
                          children: List.generate(3, (index) {
                            return const Icon(
                              Icons.star_rounded,
                              color: Color(0xFFFFD700),
                              size: 14,
                            );
                          }),
                        ),
                      ],
                    ),

                    // 3 Lives indicator (Heart icons)
                    Row(
                      children: List.generate(3, (index) {
                        final isAlive = index < lives;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 1.5),
                          child: Icon(
                            Icons.favorite_rounded,
                            color: isAlive ? const Color(0xFFFF2A6D) : const Color(0xFF3B4866),
                            size: 16,
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 10),

            // Score Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF131D36),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFF2A3D66),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Score',
                    style: TextStyle(
                      color: Color(0xFF8E9EB8),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    score.toString(),
                    style: const TextStyle(
                      color: Color(0xFF00E5FF),
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // BOTTOM BOOSTER DOCK: 4 Cards Matching Mockup
  // ═════════════════════════════════════════════════════════════════════════════
  Widget _buildBottomBoosterDock() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildBoosterItem(
              icon: Icons.brightness_7_rounded,
              color: const Color(0xFFFF5252),
              count: _controller.superNukeBoosterCount,
              onTap: () => _controller.useSuperNukeBooster(),
            ),
            _buildBoosterItem(
              icon: Icons.bolt_rounded,
              color: const Color(0xFF00E5FF),
              count: _controller.lightningBoosterCount,
              onTap: () => _controller.useLightningBooster(),
            ),
            _buildBoosterItem(
              icon: Icons.grain_rounded,
              color: const Color(0xFF7C4DFF),
              count: _controller.triBallBoosterCount,
              onTap: () => _controller.useTriBallBooster(),
            ),
            _buildBoosterItem(
              icon: Icons.monetization_on_rounded,
              color: const Color(0xFFFFD700),
              count: _controller.coinBoosterCount,
              onTap: () => _controller.useCoinBooster(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBoosterItem({
    required IconData icon,
    required Color color,
    required int count,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        AudioSynthesizer.instance.playUiClick();
        onTap();
      },
      child: Container(
        width: 62,
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFF131D36),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            Positioned(
              bottom: 3,
              right: 6,
              child: Text(
                'x$count',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
