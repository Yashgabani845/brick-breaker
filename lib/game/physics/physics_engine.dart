import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/game_colors.dart';
import '../../core/math/vector2.dart';
import '../models/ball.dart';
import '../models/brick.dart';
import '../models/paddle.dart';
import '../models/particle.dart';
import '../models/powerup.dart';
import '../systems/audio_synthesizer.dart';

/// Real-Time Arcade Physics Engine for Paddle-Controlled Brick Smash
class PhysicsEngine {
  final int columns;
  final int rows;
  final double cellWidth;
  final double cellHeight;

  PhysicsEngine({
    required this.columns,
    required this.rows,
    required this.cellWidth,
    required this.cellHeight,
  });

  void update({
    required double dt,
    required List<Ball> balls,
    required Paddle paddle,
    required List<Brick> bricks,
    required List<PowerUp> fallingPowerUps,
    required double playfieldWidth,
    required double playfieldHeight,
    required void Function(Brick, Ball) onBrickHit,
    required void Function(PowerUp) onPowerUpCollected,
    required void Function(Ball) onBallLost,
  }) {
    // 1. Update Paddle
    paddle.update(dt, 0, playfieldWidth);

    // 2. Substep Ball Physics (2 sub-steps for crisp anti-tunneling precision)
    const int subSteps = 2;
    final subDt = dt / subSteps;

    for (int step = 0; step < subSteps; step++) {
      for (int i = 0; i < balls.length; i++) {
        final ball = balls[i];
        if (!ball.isActive) continue;

        if (ball.isStuckToPaddle) {
          // Ball follows paddle top center before initial launch
          ball.position.set(paddle.position.x, paddle.position.y - paddle.height / 2 - ball.radius - 2);
          continue;
        }

        ball.update(subDt);

        // Wall Collisions
        _handleWallCollisions(ball, playfieldWidth, playfieldHeight, onBallLost);

        // Paddle Collision
        _handlePaddleCollision(ball, paddle);

        // Brick Collisions
        _handleBrickCollisions(ball, bricks, cellWidth, cellHeight, fallingPowerUps, onBrickHit);
      }
    }

    // 3. Update Falling Power-Ups
    _updatePowerUps(fallingPowerUps, paddle, playfieldHeight, dt, onPowerUpCollected);
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // WALL COLLISIONS
  // ═════════════════════════════════════════════════════════════════════════════
  void _handleWallCollisions(
    Ball ball,
    double playfieldWidth,
    double playfieldHeight,
    void Function(Ball) onBallLost,
  ) {
    // Left Wall
    if (ball.position.x - ball.radius < 0) {
      ball.position.x = ball.radius;
      ball.velocity.x = ball.velocity.x.abs();
      AudioSynthesizer.instance.playBrickHitChime(1);
    }
    // Right Wall
    else if (ball.position.x + ball.radius > playfieldWidth) {
      ball.position.x = playfieldWidth - ball.radius;
      ball.velocity.x = -ball.velocity.x.abs();
      AudioSynthesizer.instance.playBrickHitChime(1);
    }

    // Top Wall
    if (ball.position.y - ball.radius < 0) {
      ball.position.y = ball.radius;
      ball.velocity.y = ball.velocity.y.abs();
      AudioSynthesizer.instance.playBrickHitChime(1);
    }
    // Bottom Out-of-Bounds (Ball lost below paddle)
    else if (ball.position.y - ball.radius > playfieldHeight + 20) {
      ball.isActive = false;
      onBallLost(ball);
    }
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // PADDLE COLLISION & ANGLE DEFLECTION
  // ═════════════════════════════════════════════════════════════════════════════
  void handlePaddleCollision(Ball ball, Paddle paddle) {
    _handlePaddleCollision(ball, paddle);
  }

  void _handlePaddleCollision(Ball ball, Paddle paddle) {
    if (ball.velocity.y <= 0) return; // Only collide when moving downward

    final pTop = paddle.position.y - paddle.height / 2;
    final pBottom = paddle.position.y + paddle.height / 2;
    final pLeft = paddle.position.x - paddle.width / 2;
    final pRight = paddle.position.x + paddle.width / 2;

    // Check if ball circle overlaps paddle rect
    if (ball.position.y + ball.radius >= pTop &&
        ball.position.y - ball.radius <= pBottom &&
        ball.position.x + ball.radius >= pLeft &&
        ball.position.x - ball.radius <= pRight) {

      // Reposition ball atop paddle to prevent sticking
      ball.position.y = pTop - ball.radius;

      // Calculate normalized hit offset: -1.0 (far left) to +1.0 (far right)
      final hitOffset = ((ball.position.x - paddle.position.x) / (paddle.width / 2)).clamp(-0.95, 0.95);

      // Max bounce angle from vertical = ~65 degrees (1.13 radians)
      const maxBounceAngle = 65.0 * (math.pi / 180.0);
      final bounceAngle = hitOffset * maxBounceAngle;

      // Current ball speed (gradually increases per paddle bounce, capped at 540)
      final currentSpeed = (ball.speed * 1.015).clamp(360.0, 540.0);
      ball.speed = currentSpeed;

      // Set new velocity based on deflection angle
      final newVx = currentSpeed * math.sin(bounceAngle);
      final newVy = -currentSpeed * math.cos(bounceAngle);

      ball.velocity.set(newVx, newVy);
      ball.hitStreak = 0; // Reset streak on paddle hit

      // Particle effect & Sound
      ParticlePool.spawnShockwave(Vector2(ball.position.x, pTop), GameColors.neonCyan, maxRadius: 18.0);
      AudioSynthesizer.instance.playCollectPlusBall();
    }
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // BRICK COLLISIONS
  // ═════════════════════════════════════════════════════════════════════════════
  void _handleBrickCollisions(
    Ball ball,
    List<Brick> bricks,
    double cw,
    double ch,
    List<PowerUp> fallingPowerUps,
    void Function(Brick, Ball) onBrickHit,
  ) {
    for (int i = 0; i < bricks.length; i++) {
      final brick = bricks[i];
      if (brick.isDestroyed) continue;

      final brickRect = Rect.fromLTWH(
        brick.gridX * cw + 1.5,
        brick.gridY * ch + 1.5,
        cw - 3.0,
        ch - 3.0,
      );

      // 45-Degree Wedge Reflection
      if (brick.type.isWedge) {
        if (_checkWedgeCollision(ball, brick, brickRect)) {
          _applyDamageAndDrop(brick, ball, fallingPowerUps, onBrickHit, cw, ch, bricks);
          if (!ball.isFireball) break;
        }
      }
      // Standard AABB Brick Collision
      else {
        if (_checkAABBCollision(ball, brickRect)) {
          _applyDamageAndDrop(brick, ball, fallingPowerUps, onBrickHit, cw, ch, bricks);
          if (!ball.isFireball) break;
        }
      }
    }
  }

  bool _checkAABBCollision(Ball ball, Rect rect) {
    final closestX = ball.position.x.clamp(rect.left, rect.right);
    final closestY = ball.position.y.clamp(rect.top, rect.bottom);

    final distX = ball.position.x - closestX;
    final distY = ball.position.y - closestY;
    final distSq = distX * distX + distY * distY;

    if (distSq < ball.radius * ball.radius) {
      if (!ball.isFireball) {
        // Determine collision normal
        final overlapLeft = (ball.position.x + ball.radius) - rect.left;
        final overlapRight = rect.right - (ball.position.x - ball.radius);
        final overlapTop = (ball.position.y + ball.radius) - rect.top;
        final overlapBottom = rect.bottom - (ball.position.y - ball.radius);

        final minOverlapX = math.min(overlapLeft, overlapRight);
        final minOverlapY = math.min(overlapTop, overlapBottom);

        if (minOverlapX < minOverlapY) {
          ball.velocity.x = (distX > 0) ? ball.velocity.x.abs() : -ball.velocity.x.abs();
        } else {
          ball.velocity.y = (distY > 0) ? ball.velocity.y.abs() : -ball.velocity.y.abs();
        }
      }
      return true;
    }
    return false;
  }

  bool _checkWedgeCollision(Ball ball, Brick brick, Rect rect) {
    if (!rect.inflate(ball.radius).contains(Offset(ball.position.x, ball.position.y))) {
      return false;
    }

    if (!ball.isFireball) {
      // 45 degree normal reflection
      switch (brick.type) {
        case BrickType.wedgeTopLeft:
          ball.velocity.set(ball.velocity.y.abs(), ball.velocity.x.abs());
          break;
        case BrickType.wedgeTopRight:
          ball.velocity.set(-ball.velocity.y.abs(), ball.velocity.x.abs());
          break;
        case BrickType.wedgeBottomLeft:
          ball.velocity.set(ball.velocity.y.abs(), -ball.velocity.x.abs());
          break;
        case BrickType.wedgeBottomRight:
          ball.velocity.set(-ball.velocity.y.abs(), -ball.velocity.x.abs());
          break;
        default:
          ball.velocity.y = -ball.velocity.y;
          break;
      }
    }
    return true;
  }

  void _applyDamageAndDrop(
    Brick brick,
    Ball ball,
    List<PowerUp> fallingPowerUps,
    void Function(Brick, Ball) onBrickHit,
    double cw,
    double ch,
    List<Brick> allBricks,
  ) {
    final damage = ball.isFireball ? 5 : 1;
    final isDead = brick.applyDamage(damage);

    ball.hitStreak++;
    AudioSynthesizer.instance.playBrickHitChime(ball.hitStreak);

    final center = Vector2(brick.gridX * cw + cw / 2, brick.gridY * ch + ch / 2);
    ParticlePool.spawnShardBurst(center, GameColors.getHpGlowColor(brick.hp), count: 6);

    if (isDead) {
      onBrickHit(brick, ball);

      // 1. Spawning Falling Power-Up Capsule
      final pType = brick.dropPowerUp ?? _rollRandomPowerUp();
      if (pType != null) {
        fallingPowerUps.add(
          PowerUp(
            id: DateTime.now().microsecondsSinceEpoch,
            type: pType,
            position: Vector2(center.x, center.y),
          ),
        );
      }

      // 2. Special Brick Triggers
      if (brick.type == BrickType.clusterBomb || brick.type == BrickType.chainDynamite) {
        _detonateBomb(brick, allBricks, cw, ch, onBrickHit, ball);
      } else if (brick.type == BrickType.horizontalLaser) {
        _fireHorizontalLaser(brick, allBricks, cw, ch, onBrickHit, ball);
      } else if (brick.type == BrickType.verticalLaser) {
        _fireVerticalLaser(brick, allBricks, cw, ch, onBrickHit, ball);
      }
    }
  }

  PowerUpType? _rollRandomPowerUp() {
    // 25% chance of dropping a power-up on standard brick break
    final rnd = math.Random().nextDouble();
    if (rnd < 0.08) return PowerUpType.multiball;
    if (rnd < 0.14) return PowerUpType.fireball;
    if (rnd < 0.20) return PowerUpType.widePaddle;
    if (rnd < 0.24) return PowerUpType.laserPaddle;
    if (rnd < 0.28) return PowerUpType.coins;
    return null;
  }

  void _detonateBomb(
    Brick bomb,
    List<Brick> allBricks,
    double cw,
    double ch,
    void Function(Brick, Ball) onBrickHit,
    Ball ball,
  ) {
    AudioSynthesizer.instance.playBombExplosion();
    final center = Vector2(bomb.gridX * cw + cw / 2, bomb.gridY * ch + ch / 2);
    ParticlePool.spawnShockwave(center, const Color(0xFFFF9100), maxRadius: 60.0);

    for (final b in allBricks) {
      if (b.isDestroyed) continue;
      if ((b.gridX - bomb.gridX).abs() <= 1 && (b.gridY - bomb.gridY).abs() <= 1) {
        b.isDestroyed = true;
        onBrickHit(b, ball);
        final bCenter = Vector2(b.gridX * cw + cw / 2, b.gridY * ch + ch / 2);
        ParticlePool.spawnShardBurst(bCenter, GameColors.solarGold, count: 5);
      }
    }
  }

  void _fireHorizontalLaser(
    Brick laser,
    List<Brick> allBricks,
    double cw,
    double ch,
    void Function(Brick, Ball) onBrickHit,
    Ball ball,
  ) {
    AudioSynthesizer.instance.playLaserSweep();
    for (final b in allBricks) {
      if (!b.isDestroyed && b.gridY == laser.gridY) {
        b.isDestroyed = true;
        onBrickHit(b, ball);
        final bCenter = Vector2(b.gridX * cw + cw / 2, b.gridY * ch + ch / 2);
        ParticlePool.spawnShardBurst(bCenter, GameColors.neonCyan, count: 4);
      }
    }
  }

  void _fireVerticalLaser(
    Brick laser,
    List<Brick> allBricks,
    double cw,
    double ch,
    void Function(Brick, Ball) onBrickHit,
    Ball ball,
  ) {
    AudioSynthesizer.instance.playLaserSweep();
    for (final b in allBricks) {
      if (!b.isDestroyed && b.gridX == laser.gridX) {
        b.isDestroyed = true;
        onBrickHit(b, ball);
        final bCenter = Vector2(b.gridX * cw + cw / 2, b.gridY * ch + ch / 2);
        ParticlePool.spawnShardBurst(bCenter, GameColors.neonMagenta, count: 4);
      }
    }
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // FALLING POWER-UPS UPDATE & PADDLE CATCH
  // ═════════════════════════════════════════════════════════════════════════════
  void _updatePowerUps(
    List<PowerUp> powerUps,
    Paddle paddle,
    double playfieldHeight,
    double dt,
    void Function(PowerUp) onPowerUpCollected,
  ) {
    for (int i = powerUps.length - 1; i >= 0; i--) {
      final p = powerUps[i];
      p.update(dt);

      // Check if paddle catches the powerup capsule
      if (paddle.rect.inflate(8.0).contains(Offset(p.position.x, p.position.y))) {
        p.isCollected = true;
        onPowerUpCollected(p);
        AudioSynthesizer.instance.playRewardClaim();
        ParticlePool.spawnShockwave(Vector2(p.position.x, p.position.y), p.type.color, maxRadius: 22.0);
        powerUps.removeAt(i);
        continue;
      }

      // Check if fallen below screen
      if (p.position.y > playfieldHeight + 30) {
        p.isExpired = true;
        powerUps.removeAt(i);
      }
    }
  }
}
