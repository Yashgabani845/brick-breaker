import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/game_colors.dart';
import '../../core/constants/game_constants.dart';
import '../../core/math/vector2.dart';
import '../models/ball.dart';
import '../models/brick.dart';
import '../models/level_data.dart';
import '../models/paddle.dart';
import '../models/particle.dart';
import '../models/powerup.dart';
import '../physics/physics_engine.dart';
import 'audio_synthesizer.dart';
import 'score_system.dart';

enum GameState {
  aiming,       // Ball on paddle, ready to launch
  playing,      // Real-time ball in play
  levelComplete,// All target bricks cleared
  levelFailed,  // 0 lives remaining
  paused,       // Game paused
}

/// Central Controller for Real-Time Paddle-Controlled Brick Smash
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
  late Paddle paddle;
  final List<Ball> balls = [];
  final List<PowerUp> fallingPowerUps = [];
  List<Brick> bricks = [];

  // Lives & Ammunition
  int lives = 3;
  int initialBalls = 1;
  BallSkin currentBallSkin = BallSkin.neonWhite;
  PaddleSkin currentPaddleSkin = PaddleSkin.neonBlade;

  // Systems
  late PhysicsEngine physicsEngine;
  final ScoreSystem scoreSystem = ScoreSystem();

  // Boosters & Stats
  int superNukeBoosterCount = 3;
  int lightningBoosterCount = 3;
  int triBallBoosterCount = 3;
  int coinBoosterCount = 3;
  int turnsPlayed = 0;
  double speedMultiplier = 1.0;

  GameController() {
    paddle = Paddle(position: Vector2(180, 540));
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
    playfieldHeight = height;
    cellWidth = width / currentLevel.columns;
    cellHeight = (playfieldHeight * 0.72) / currentLevel.rows;

    physicsEngine = PhysicsEngine(
      columns: currentLevel.columns,
      rows: currentLevel.rows,
      cellWidth: cellWidth,
      cellHeight: cellHeight,
    );

    paddle.position.set(playfieldWidth / 2, playfieldHeight - 32.0);
    paddle.targetX = paddle.position.x;

    if (state == GameState.aiming && balls.isNotEmpty) {
      balls.first.position.set(paddle.position.x, paddle.position.y - paddle.height / 2 - balls.first.radius - 2);
    }
    notifyListeners();
  }

  void loadLevel(LevelData level, {DifficultyMode? diff}) {
    currentLevel = level.clone();
    if (diff != null) difficulty = diff;

    bricks = currentLevel.initialBricks.map((b) => b.copyWith()).toList();
    fallingPowerUps.clear();
    ParticlePool.clear();
    scoreSystem.reset();

    lives = 3;
    state = GameState.aiming;

    paddle.position.set(playfieldWidth / 2, playfieldHeight - 32.0);
    paddle.targetX = paddle.position.x;
    paddle.isWide = false;
    paddle.isLaserActive = false;
    paddle.width = paddle.baseWidth;
    paddle.skin = currentPaddleSkin;

    // Initialize 1 primary ball stuck to paddle
    balls.clear();
    final startBall = Ball(
      id: 1,
      position: Vector2(paddle.position.x, paddle.position.y - paddle.height / 2 - 9.0),
      isStuckToPaddle: true,
      skin: currentBallSkin,
    );
    balls.add(startBall);

    notifyListeners();
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // INPUT & CONTROLS
  // ═════════════════════════════════════════════════════════════════════════════
  void onPaddleDrag(double touchX) {
    paddle.targetX = touchX;
    if (state == GameState.aiming && balls.isNotEmpty) {
      balls.first.position.set(paddle.position.x, paddle.position.y - paddle.height / 2 - balls.first.radius - 2);
    }
    notifyListeners();
  }

  void launchBall() {
    if (state != GameState.aiming || balls.isEmpty) return;

    final ball = balls.first;
    ball.isStuckToPaddle = false;

    // Launch slightly angled upward towards playfield
    const launchSpeed = 380.0;
    const launchAngle = 15.0 * (math.pi / 180.0); // 15 degrees initial angle
    ball.setVelocity(launchSpeed * math.sin(launchAngle), -launchSpeed * math.cos(launchAngle));

    state = GameState.playing;
    AudioSynthesizer.instance.playCollectPlusBall();
    notifyListeners();
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // MAIN UPDATE LOOP
  // ═════════════════════════════════════════════════════════════════════════════
  void update(double dt) {
    if (state != GameState.playing && state != GameState.aiming) return;

    final scaledDt = dt * speedMultiplier;

    // Update Particles
    ParticlePool.update(scaledDt);

    if (state == GameState.playing) {
      physicsEngine.update(
        dt: scaledDt,
        balls: balls,
        paddle: paddle,
        bricks: bricks,
        fallingPowerUps: fallingPowerUps,
        playfieldWidth: playfieldWidth,
        playfieldHeight: playfieldHeight,
        onBrickHit: _handleBrickHit,
        onPowerUpCollected: _handlePowerUpCollected,
        onBallLost: _handleBallLost,
      );

      // Check level victory condition
      final remainingBricks = bricks.where((b) => !b.isDestroyed && b.type.isDamageable).length;
      if (remainingBricks == 0) {
        state = GameState.levelComplete;
        AudioSynthesizer.instance.playVictory();
        notifyListeners();
      }
    } else {
      // While aiming, smoothly follow paddle
      paddle.update(scaledDt, 0, playfieldWidth);
      if (balls.isNotEmpty) {
        balls.first.position.set(paddle.position.x, paddle.position.y - paddle.height / 2 - balls.first.radius - 2);
      }
    }

    notifyListeners();
  }

  void _handleBrickHit(Brick brick, Ball ball) {
    scoreSystem.recordHit(1, brick.type == BrickType.armoredBrick);
  }

  void _handlePowerUpCollected(PowerUp powerUp) {
    switch (powerUp.type) {
      case PowerUpType.multiball:
        // Spawn 2 extra balls at current primary ball location
        if (balls.length < 5) {
          final refPos = balls.isNotEmpty ? balls.first.position : paddle.position;
          final extra1 = Ball(
            id: DateTime.now().microsecondsSinceEpoch,
            position: Vector2(refPos.x, refPos.y),
            velocity: Vector2(-220, -320),
            skin: currentBallSkin,
          );
          final extra2 = Ball(
            id: DateTime.now().microsecondsSinceEpoch + 1,
            position: Vector2(refPos.x, refPos.y),
            velocity: Vector2(220, -320),
            skin: currentBallSkin,
          );
          balls.addAll([extra1, extra2]);
        }
        break;

      case PowerUpType.fireball:
        for (final b in balls) {
          b.activateFireball(8.0);
        }
        break;

      case PowerUpType.widePaddle:
        paddle.activateWidePaddle(12.0);
        break;

      case PowerUpType.laserPaddle:
        paddle.activateLaserPaddle(10.0);
        break;

      case PowerUpType.slowBall:
        for (final b in balls) {
          b.speed = 280.0;
          b.velocity = b.velocity.normalized() * 280.0;
        }
        break;

      case PowerUpType.bomb:
        useSuperNukeBooster();
        break;

      case PowerUpType.coins:
        scoreSystem.addScore(500);
        break;
    }
  }

  void _handleBallLost(Ball lostBall) {
    balls.remove(lostBall);

    // If active balls remain, player is still in the round!
    if (balls.isNotEmpty) return;

    // All balls lost: lose 1 life
    lives--;
    AudioSynthesizer.instance.playBombExplosion();

    if (lives > 0) {
      // Reset ball on paddle for next life
      state = GameState.aiming;
      final newBall = Ball(
        id: DateTime.now().microsecondsSinceEpoch,
        position: Vector2(paddle.position.x, paddle.position.y - paddle.height / 2 - 9.0),
        isStuckToPaddle: true,
        skin: currentBallSkin,
      );
      balls.add(newBall);
    } else {
      // 0 lives remaining: Game Over
      state = GameState.levelFailed;
    }
    notifyListeners();
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // IN-GAME BOOSTER SKILLS (BOTTOM DOCK)
  // ═════════════════════════════════════════════════════════════════════════════
  void useSuperNukeBooster() {
    if (superNukeBoosterCount <= 0) return;
    superNukeBoosterCount--;

    for (final b in bricks) {
      if (!b.isDestroyed) {
        b.applyDamage(b.hp ~/ 2 + 10);
        final center = Vector2(b.gridX * cellWidth + cellWidth / 2, b.gridY * cellHeight + cellHeight / 2);
        ParticlePool.spawnShardBurst(center, GameColors.neonPurple, count: 5);
      }
    }
    AudioSynthesizer.instance.playBombExplosion();
    notifyListeners();
  }

  void useLightningBooster() {
    if (lightningBoosterCount <= 0) return;
    lightningBoosterCount--;

    // Obliterate bottom-most row of bricks
    int maxRow = 0;
    for (final b in bricks) {
      if (!b.isDestroyed && b.gridY > maxRow) maxRow = b.gridY;
    }

    for (final b in bricks) {
      if (!b.isDestroyed && b.gridY == maxRow) {
        b.isDestroyed = true;
        final center = Vector2(b.gridX * cellWidth + cellWidth / 2, b.gridY * cellHeight + cellHeight / 2);
        ParticlePool.spawnShockwave(center, GameColors.neonCyan, maxRadius: 35.0);
      }
    }
    AudioSynthesizer.instance.playLaserSweep();
    notifyListeners();
  }

  void useTriBallBooster() {
    if (triBallBoosterCount <= 0) return;
    triBallBoosterCount--;

    _handlePowerUpCollected(PowerUp(id: 0, type: PowerUpType.multiball, position: paddle.position));
    AudioSynthesizer.instance.playSplitterSwarm();
    notifyListeners();
  }

  void useCoinBooster() {
    if (coinBoosterCount <= 0) return;
    coinBoosterCount--;
    scoreSystem.addScore(1000);
    AudioSynthesizer.instance.playRewardClaim();
    notifyListeners();
  }

  void toggleSpeed() {
    speedMultiplier = (speedMultiplier == 1.0) ? 1.5 : 1.0;
    notifyListeners();
  }

  void togglePause() {
    if (state == GameState.paused) {
      state = GameState.playing;
    } else if (state == GameState.playing || state == GameState.aiming) {
      state = GameState.paused;
    }
    notifyListeners();
  }

  void triggerRecallMagnet() {
    // Magnet pulls ball back to paddle
    for (final ball in balls) {
      ball.velocity.set(0, 0);
      ball.isStuckToPaddle = true;
      ball.position.set(paddle.position.x, paddle.position.y - paddle.height / 2 - ball.radius - 2);
    }
    state = GameState.aiming;
    AudioSynthesizer.instance.playPowerUpLaser();
    notifyListeners();
  }

  void revive() {
    lives = 3;
    state = GameState.aiming;
    balls.clear();
    final newBall = Ball(
      id: DateTime.now().microsecondsSinceEpoch,
      position: Vector2(paddle.position.x, paddle.position.y - paddle.height / 2 - 9.0),
      isStuckToPaddle: true,
      skin: currentBallSkin,
    );
    balls.add(newBall);
    notifyListeners();
  }

  void pushBricksUp(int rows) {
    revive();
  }
}
