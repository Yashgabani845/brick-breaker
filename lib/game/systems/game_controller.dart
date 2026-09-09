import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/game_colors.dart';
import '../../core/constants/game_constants.dart';
import '../../core/math/vector2.dart';
import '../models/ball.dart';
import '../models/brick.dart';
import '../models/level_data.dart';
import '../models/particle.dart';
import '../physics/physics_engine.dart';
import '../physics/trajectory_predictor.dart';
import 'audio_synthesizer.dart';
import 'score_system.dart';

/// Game States
enum GameState {
  aiming,
  firing,
  simulating,
  resolving,
  boardAdvance,
  levelComplete,
  levelFailed,
  paused,
}

/// Central Game Controller and State Manager
class GameController extends ChangeNotifier {
  late LevelData currentLevel;
  GameState state = GameState.aiming;
  DifficultyMode difficulty = DifficultyMode.standard;

  // Geometry
  double playfieldWidth = 360.0;
  double playfieldHeight = 600.0;
  double cellWidth = 30.0;
  double cellHeight = 25.0;

  // Entities
  List<Brick> bricks = [];
  final List<Ball> balls = [];
  final Vector2 launcherPosition = Vector2(180, 540);
  Vector2? firstLandedPosition;

  // Ball Ammunition & Cosmetics
  int permanentBalls = 35;
  int ballsToLaunch = 0;
  double launchTimer = 0.0;
  Vector2 currentAimDirection = Vector2(0, -1);
  List<TrajectoryPoint>? currentTrajectory;
  bool isDraggingAim = false;
  BallSkin currentBallSkin = BallSkin.neonWhite;

  // Systems
  late PhysicsEngine physicsEngine;
  final ScoreSystem scoreSystem = ScoreSystem();

  // Speed & Boosters
  double speedMultiplier = 1.0;
  int lightningBoosterCount = 3;
  int superNukeBoosterCount = 2;
  int turnsPlayed = 0;
  int turnBallsThisTurn = 0; // Extra balls spawned by +BALL TURN powerup this turn

  GameController() {
    _initPhysics();
  }

  void _initPhysics() {
    physicsEngine = PhysicsEngine(
      columns: GameConstants.defaultColumns,
      rows: GameConstants.defaultRows,
      cellWidth: cellWidth,
      cellHeight: cellHeight,
    );
  }

  void setDimensions(double width, double height) {
    playfieldWidth = width;
    // Dedicated playfield height - reserves bottom 18% for the controls dock
    playfieldHeight = height * 0.81;
    cellWidth = width / currentLevel.columns;
    cellHeight = (playfieldHeight * 0.74) / currentLevel.rows;

    physicsEngine = PhysicsEngine(
      columns: currentLevel.columns,
      rows: currentLevel.rows,
      cellWidth: cellWidth,
      cellHeight: cellHeight,
    );

    if (state == GameState.aiming) {
      launcherPosition.set(playfieldWidth / 2, playfieldHeight - 12.0);
    }
    notifyListeners();
  }

  void loadLevel(LevelData level, {DifficultyMode? diff}) {
    currentLevel = level.clone();
    if (diff != null) difficulty = diff;

    // Apply difficulty HP multiplier to initial bricks
    bricks = currentLevel.initialBricks.map((b) {
      final adjustedHp = (b.hp * difficulty.hpMultiplier).round().clamp(1, 9999);
      return b.copyWith(hp: adjustedHp, maxHp: adjustedHp);
    }).toList();

    permanentBalls = currentLevel.startingBalls;
    balls.clear();
    ParticlePool.clear();
    scoreSystem.resetForNewGame();

    state = GameState.aiming;
    speedMultiplier = 1.0;
    firstLandedPosition = null;
    turnsPlayed = 0;

    final defaultY = playfieldHeight > 0 ? (playfieldHeight - 12.0) : 550.0;
    launcherPosition.set(playfieldWidth > 0 ? (playfieldWidth / 2) : 200.0, defaultY);
    _updateTrajectory();
    notifyListeners();
  }

  // --- Aiming and Input ---

  void onAimStart(Offset localPos) {
    if (state != GameState.aiming) return;
    isDraggingAim = true;
    onAimUpdate(localPos);
  }

  void onAimUpdate(Offset localPos) {
    if (state != GameState.aiming || !isDraggingAim) return;

    // Vector from launcher to touch point
    final touchVec = Vector2(localPos.dx - launcherPosition.x, localPos.dy - launcherPosition.y);

    if (touchVec.y < -15.0) {
      // Direct drag aiming (dragging upward)
      currentAimDirection = touchVec.normalized();
    } else if (touchVec.y > 15.0) {
      // Pull-back sling aiming (dragging downward)
      currentAimDirection = (-touchVec).normalized();
    } else {
      return;
    }

    // Clamp angle to prevent pure horizontal lock-in
    currentAimDirection.clampTrajectoryAngle(minVerticalRatio: 0.15);
    _updateTrajectory();
    notifyListeners();
  }

  void onAimEnd() {
    if (state != GameState.aiming || !isDraggingAim) return;
    isDraggingAim = false;

    // Fire balls!
    _fireSwarm();
  }

  void _updateTrajectory() {
    currentTrajectory = TrajectoryPredictor.predict(
      origin: launcherPosition,
      direction: currentAimDirection,
      playfieldWidth: playfieldWidth,
      playfieldHeight: playfieldHeight,
      cellWidth: cellWidth,
      cellHeight: cellHeight,
      bricks: bricks,
      maxBounces: difficulty.maxAimBounces,
      ballRadius: GameConstants.baseBallRadius,
    );
  }

  void _fireSwarm() {
    state = GameState.firing;
    ballsToLaunch = permanentBalls;
    launchTimer = 0.0;
    firstLandedPosition = null;
    currentTrajectory = null;
    turnsPlayed++;
    turnBallsThisTurn = 0; // Reset turn-ball counter
    scoreSystem.startNewTurn();
    AudioSynthesizer.instance.playUiClick();
    notifyListeners();
  }

  // --- Main Tick Simulation ---

  void update(double dt) {
    if (state == GameState.paused) return;

    // 1. Spawning balls during Firing phase
    if (state == GameState.firing) {
      launchTimer += dt * speedMultiplier;
      while (launchTimer >= GameConstants.ballLaunchIntervalSeconds && ballsToLaunch > 0) {
        launchTimer -= GameConstants.ballLaunchIntervalSeconds;
        ballsToLaunch--;

        // Staggered launch with tiny micro-jitter for organic swarm stream
        final randJitter = (math.Random().nextDouble() - 0.5) * 0.015;
        final launchVel = currentAimDirection.rotated(randJitter) * GameConstants.baseBallSpeed;

        balls.add(
          Ball(
            id: DateTime.now().microsecondsSinceEpoch + balls.length,
            position: launcherPosition,
            velocity: launchVel,
            radius: GameConstants.baseBallRadius,
            skin: currentBallSkin,
          ),
        );
      }

      if (ballsToLaunch <= 0) {
        state = GameState.simulating;
      }
    }

    // 2. Simulating physics for active balls
    if (state == GameState.firing || state == GameState.simulating) {
      physicsEngine.update(
        dt: dt,
        balls: balls,
        bricks: bricks,
        playfieldWidth: playfieldWidth,
        playfieldHeight: playfieldHeight,
        cellWidth: cellWidth,
        cellHeight: cellHeight,
        speedMultiplier: speedMultiplier,
        onBrickHit: (hitEvent) {
          scoreSystem.registerHit(
            brick: hitEvent.brick,
            wasDestroyed: hitEvent.wasDestroyed,
            difficulty: difficulty,
          );
          AudioSynthesizer.instance.playBrickHitChime(scoreSystem.comboCount);
        },
        onPermanentBallCollected: (count) {
          permanentBalls += count;
          scoreSystem.ballsCollectedThisTurn += count;
        },
        onTurnBallSpawned: () {
          // A turn-temporary ball was just spawned by a +BALL TURN powerup.
          // We track it for the HUD and mark it in score. The ball object
          // is already in the balls list via the spawn queue.
          turnBallsThisTurn++;
        },
        onBallLanded: (ball) {
          // First ball to land establishes the new launcher horizontal position
          if (firstLandedPosition == null) {
            firstLandedPosition = Vector2(ball.position.x.clamp(20.0, playfieldWidth - 20.0), launcherPosition.y);
          }
        },
      );

      // Check if all bricks are cleared -> Level Complete
      final remainingBricks = bricks.where((b) => !b.isDestroyed && b.type.isDamageable).length;
      if (remainingBricks == 0) {
        _handleLevelComplete();
        return;
      }

      // Check if all balls have finished their flight
      final activeBalls = balls.where((b) => b.isActive).length;
      if (state == GameState.simulating && activeBalls == 0) {
        _endTurnAndAdvanceBoard();
      }
    }

    // Update Particle Systems
    ParticlePool.update(dt);
    notifyListeners();
  }

  // --- End of Turn & Board Advance ---

  void _endTurnAndAdvanceBoard() {
    state = GameState.boardAdvance;
    balls.clear();

    // Move launcher to new position
    if (firstLandedPosition != null) {
      launcherPosition.x = firstLandedPosition!.x;
    }

    // Advance all bricks downward by 1 row
    bool breachedDanger = false;
    for (int i = 0; i < bricks.length; i++) {
      final b = bricks[i];
      if (!b.isDestroyed) {
        b.gridY += 1;
        if (b.gridY >= currentLevel.dangerRow) {
          breachedDanger = true;
        }
      }
    }

    // Check Turn Limit (if level has one)
    if (currentLevel.turnLimit != null && turnsPlayed >= currentLevel.turnLimit!) {
      breachedDanger = true;
    }

    if (breachedDanger) {
      state = GameState.levelFailed;
      notifyListeners();
    } else {
      state = GameState.aiming;
      _updateTrajectory();
      notifyListeners();
    }
  }

  void _handleLevelComplete() {
    state = GameState.levelComplete;
    balls.clear();
    AudioSynthesizer.instance.playVictory();
    notifyListeners();
  }

  // --- Boosters ---

  void toggleSpeed() {
    if (speedMultiplier == 1.0) {
      speedMultiplier = 2.0;
    } else if (speedMultiplier == 2.0) {
      speedMultiplier = 3.0;
    } else {
      speedMultiplier = 1.0;
    }
    notifyListeners();
  }

  void triggerRecallMagnet() {
    if (state != GameState.simulating && state != GameState.firing) return;
    for (final ball in balls) {
      if (ball.isActive) {
        ball.velocity.set(0, GameConstants.maxBallSpeed); // Pull straight down
      }
    }
    notifyListeners();
  }

  void useLightningBooster() {
    if (lightningBoosterCount <= 0 || state != GameState.aiming) return;
    lightningBoosterCount--;

    // Clears the bottom-most 2 active rows
    int maxActiveRow = 0;
    for (final b in bricks) {
      if (!b.isDestroyed && b.gridY > maxActiveRow) maxActiveRow = b.gridY;
    }

    for (final b in bricks) {
      if (!b.isDestroyed && b.gridY >= maxActiveRow - 1) {
        b.isDestroyed = true;
        final center = Vector2(b.gridX * cellWidth + cellWidth / 2, b.gridY * cellHeight + cellHeight / 2);
        ParticlePool.spawnShockwave(center, GameColors.neonCyan);
      }
    }
    AudioSynthesizer.instance.playLaserSweep();
    notifyListeners();
  }

  void useSuperNukeBooster() {
    if (superNukeBoosterCount <= 0 || state != GameState.aiming) return;
    superNukeBoosterCount--;

    for (final b in bricks) {
      if (!b.isDestroyed) {
        b.applyDamage(b.hp ~/ 2 + 30);
        final center = Vector2(b.gridX * cellWidth + cellWidth / 2, b.gridY * cellHeight + cellHeight / 2);
        ParticlePool.spawnShardBurst(center, GameColors.neonPurple, count: 6);
      }
    }
    AudioSynthesizer.instance.playBombExplosion();
    notifyListeners();
  }

  void setBallSkin(BallSkin skin) {
    currentBallSkin = skin;
    notifyListeners();
  }

  void addPermanentBalls(int count) {
    permanentBalls += count;
    notifyListeners();
  }

  void clearAllBricks() {
    for (final b in bricks) {
      b.isDestroyed = true;
    }
    notifyListeners();
  }

  void pushBricksUp(int rows) {
    for (final b in bricks) {
      if (!b.isDestroyed) {
        b.gridY = (b.gridY - rows).clamp(1, 20);
      }
    }
    state = GameState.aiming;
    notifyListeners();
  }

  void togglePause() {
    if (state == GameState.paused) {
      state = GameState.aiming;
    } else {
      state = GameState.paused;
    }
    notifyListeners();
  }
}
