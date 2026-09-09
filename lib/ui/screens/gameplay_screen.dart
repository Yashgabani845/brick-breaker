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
import '../components/glass_card.dart';
import '../components/glass_modal.dart';
import '../modals/game_over_modal.dart';
import '../modals/level_complete_modal.dart';
import '../modals/pause_modal.dart';
import '../modals/sandbox_debug_modal.dart';
import '../modals/settings_modal.dart';

/// Interactive Gameplay Screen for Bricks Breaker 3D
class GameplayScreen extends StatefulWidget {
  final LevelData levelData;
  final DifficultyMode difficulty;
  final int initialBalls;
  final BallSkin ballSkin;

  const GameplayScreen({
    super.key,
    required this.levelData,
    this.difficulty = DifficultyMode.standard,
    this.initialBalls = 35,
    this.ballSkin = BallSkin.neonWhite,
  });

  @override
  State<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends State<GameplayScreen> with SingleTickerProviderStateMixin {
  late final GameController _controller;
  late final AnimationController _ticker;
  double _lastTime = 0.0;
  bool _modalOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = GameController();
    _controller.currentBallSkin = widget.ballSkin;
    _controller.loadLevel(widget.levelData, diff: widget.difficulty);
    _controller.permanentBalls = widget.initialBalls;

    _controller.addListener(_onGameControllerUpdated);

    // High performance continuous render ticker
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

    // Persist progress
    await GameStorage.instance.setHighestLevelUnlocked(_controller.currentLevel.levelNumber + 1);
    await GameStorage.instance.setStarsForLevel(_controller.currentLevel.levelNumber, stars);
    await GameStorage.instance.setHighScore(_controller.scoreSystem.currentScore);
    await GameStorage.instance.addCoins(coins);

    if (!mounted) return;

    await GlassModal.show(
      context: context,
      barrierDismissible: false,
      child: LevelCompleteModal(
        levelNumber: _controller.currentLevel.levelNumber,
        score: _controller.scoreSystem.currentScore,
        stars: stars,
        coinsEarned: coins,
        ballsCollected: _controller.scoreSystem.ballsCollectedThisTurn,
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
              const SnackBar(content: Text('Double Rewards Claimed! +50 Coins 🪙')),
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
        onRetry: () {
          Navigator.of(context).pop();
          _modalOpen = false;
          _controller.loadLevel(_controller.currentLevel);
        },
        onSaveWithGems: () async {
          final success = await GameStorage.instance.spendCoins(10);
          if (success) {
            _controller.pushBricksUp(2);
            if (mounted) {
              Navigator.of(context).pop();
            }
            _modalOpen = false;
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Not enough gems!')),
              );
            }
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
    final bgColor = GameColors.getBackgroundColor(GameStorage.instance.getDarkThemeIndex());
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Dedicated Top HUD Header (Pause, Level Chip, Score & Combo)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
              child: _buildTopHud(),
            ),

            // 2. Clear, Unobstructed Playground Canvas (Starts cleanly AFTER the top HUD)
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  _controller.setDimensions(constraints.maxWidth, constraints.maxHeight);

                  return GestureDetector(
                    onPanStart: (details) => _controller.onAimStart(details.localPosition),
                    onPanUpdate: (details) => _controller.onAimUpdate(details.localPosition),
                    onPanEnd: (_) => _controller.onAimEnd(),
                    child: AnimatedBuilder(
                      animation: _ticker,
                      builder: (context, _) {
                        return CustomPaint(
                          size: Size(constraints.maxWidth, constraints.maxHeight),
                          painter: GamePainter(
                            bricks: _controller.bricks,
                            balls: _controller.balls,
                            trajectory: _controller.currentTrajectory,
                            launcherPosition: _controller.launcherPosition,
                            activeBallCount: _controller.balls.where((b) => b.isActive).length,
                            permanentBallCount: _controller.permanentBalls,
                            isAiming: _controller.isDraggingAim,
                            dangerRow: _controller.currentLevel.dangerRow,
                            columns: _controller.currentLevel.columns,
                            rows: _controller.currentLevel.rows,
                            animationProgress: _ticker.value,
                            themeColor: _controller.currentLevel.themeColor,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),

            // 3. Bottom Booster & Controls Dock
            Padding(
              padding: const EdgeInsets.fromLTRB(14.0, 4.0, 14.0, 10.0),
              child: _buildBottomBoosterDock(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHud() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final score = _controller.scoreSystem.currentScore;
        final combo = _controller.scoreSystem.comboMultiplier;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Compact Glass Pause Button
            GestureDetector(
              onTap: () {
                AudioSynthesizer.instance.playUiClick();
                _controller.togglePause();
                GlassModal.show(
                  context: context,
                  barrierDismissible: false,
                  child: PauseModal(
                    onResume: () {
                      Navigator.of(context).pop();
                      _controller.togglePause();
                    },
                    onRestart: () {
                      Navigator.of(context).pop();
                      _controller.loadLevel(_controller.currentLevel);
                    },
                    onSettings: () {
                      GlassModal.show(
                        context: context,
                        title: 'SETTINGS',
                        child: SettingsModal(
                          currentDifficulty: _controller.difficulty,
                          onDifficultyChanged: (d) => _controller.difficulty = d,
                        ),
                      );
                    },
                    onExit: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                child: const Icon(Icons.pause_rounded, color: Colors.white, size: 20),
              ),
            ),

            // Minimalist Level Chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.45),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: GameColors.neonCyan.withOpacity(0.5)),
              ),
              child: Text(
                'LVL ${_controller.currentLevel.levelNumber}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  letterSpacing: 1.0,
                ),
              ),
            ),

            // Score & Combo Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.45),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$score',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                  if (combo > 1.0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: GameColors.solarGold.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'x${combo.toStringAsFixed(1)}',
                        style: const TextStyle(
                          color: GameColors.solarGold,
                          fontWeight: FontWeight.w900,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                  if (_controller.turnBallsThisTurn > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFF39FF14).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '+${_controller.turnBallsThisTurn}⚪',
                        style: const TextStyle(
                          color: Color(0xFF39FF14),
                          fontWeight: FontWeight.w900,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomBoosterDock() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final isSimulating = _controller.state == GameState.simulating || _controller.state == GameState.firing;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.55),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Lightning
              _buildBoosterButton(
                icon: Icons.bolt_rounded,
                color: GameColors.neonCyan,
                badgeCount: _controller.lightningBoosterCount,
                onTap: () => _controller.useLightningBooster(),
                enabled: _controller.state == GameState.aiming && _controller.lightningBoosterCount > 0,
              ),

              // Super Nuke
              _buildBoosterButton(
                icon: Icons.crisis_alert_rounded,
                color: GameColors.neonPurple,
                badgeCount: _controller.superNukeBoosterCount,
                onTap: () => _controller.useSuperNukeBooster(),
                enabled: _controller.state == GameState.aiming && _controller.superNukeBoosterCount > 0,
              ),

              // Speed (1X, 2X, 3X)
              GestureDetector(
                onTap: () {
                  AudioSynthesizer.instance.playUiClick();
                  _controller.toggleSpeed();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: GameColors.electricAmber.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: GameColors.electricAmber.withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.fast_forward_rounded, color: GameColors.electricAmber, size: 16),
                      const SizedBox(width: 2),
                      Text(
                        '${_controller.speedMultiplier.toInt()}X',
                        style: const TextStyle(color: GameColors.electricAmber, fontSize: 11, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
              ),

              // Recall Magnet
              _buildBoosterButton(
                icon: Icons.download_rounded,
                color: GameColors.emeraldGreen,
                onTap: () => _controller.triggerRecallMagnet(),
                enabled: isSimulating,
              ),

              // Sandbox Lab
              GestureDetector(
                onTap: () {
                  AudioSynthesizer.instance.playUiClick();
                  GlassModal.show(
                    context: context,
                    title: 'SANDBOX',
                    child: SandboxDebugModal(controller: _controller),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: const Icon(Icons.science_rounded, color: Colors.white60, size: 18),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBoosterButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    int? badgeCount,
    bool enabled = true,
  }) {
    return GestureDetector(
      onTap: enabled
          ? () {
              AudioSynthesizer.instance.playUiClick();
              onTap();
            }
          : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.3,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: enabled ? color.withOpacity(0.18) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: enabled ? color.withOpacity(0.6) : Colors.white10,
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, color: enabled ? color : Colors.white38, size: 20),
              if (badgeCount != null && badgeCount > 0)
                Positioned(
                  top: -5,
                  right: -7,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      '$badgeCount',
                      style: const TextStyle(color: Colors.black, fontSize: 7.5, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
