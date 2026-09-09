import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/game_colors.dart';
import '../../core/constants/game_constants.dart';
import '../../core/math/vector2.dart';
import '../models/ball.dart';
import '../models/brick.dart';
import '../models/particle.dart';
import '../systems/audio_synthesizer.dart';
import 'chain_reaction_manager.dart';
import 'collision_system.dart';
import 'spatial_hash.dart';

/// Event payload when a ball hits a brick
class BrickHitEvent {
  final Brick brick;
  final Ball ball;
  final bool wasDestroyed;

  BrickHitEvent({
    required this.brick,
    required this.ball,
    required this.wasDestroyed,
  });
}

/// High-Performance Deterministic Physics Engine
class PhysicsEngine {
  final SpatialHashGrid spatialHash;
  final ChainReactionManager chainManager = ChainReactionManager();

  // Temporary spawn queue to avoid mutating the ball list during iteration
  final List<Ball> _spawnQueue = [];

  PhysicsEngine({
    required int columns,
    required int rows,
    required double cellWidth,
    required double cellHeight,
  }) : spatialHash = SpatialHashGrid(
          columns: columns,
          rows: rows,
          cellWidth: cellWidth,
          cellHeight: cellHeight,
        );

  /// Performs a full simulation step with sub-stepping for anti-tunneling
  void update({
    required double dt,
    required List<Ball> balls,
    required List<Brick> bricks,
    required double playfieldWidth,
    required double playfieldHeight,
    required double cellWidth,
    required double cellHeight,
    required void Function(BrickHitEvent) onBrickHit,
    required void Function(int permanentBallsAdded) onPermanentBallCollected,
    required void Function() onTurnBallSpawned,
    required void Function(Ball landedBall) onBallLanded,
    required double speedMultiplier,
  }) {
    final effectiveDt = dt * speedMultiplier;
    final subStepDt = effectiveDt / GameConstants.physicsSubSteps;

    _spawnQueue.clear();

    // Rebuild spatial grid for active bricks
    spatialHash.populate(bricks);

    for (int step = 0; step < GameConstants.physicsSubSteps; step++) {
      for (int i = 0; i < balls.length; i++) {
        final ball = balls[i];
        if (!ball.isActive) continue;

        // Decrement hit cooldown timer
        if (ball.hitCooldown > 0) {
          ball.hitCooldown -= subStepDt;
        }

        // Sub-step movement
        ball.position.x += ball.velocity.x * subStepDt;
        ball.position.y += ball.velocity.y * subStepDt;

        // 1. Boundary / Wall collisions
        // Left wall
        if (ball.position.x - ball.radius < 0) {
          ball.position.x = ball.radius;
          ball.velocity.x = ball.velocity.x.abs();
        }
        // Right wall
        if (ball.position.x + ball.radius > playfieldWidth) {
          ball.position.x = playfieldWidth - ball.radius;
          ball.velocity.x = -ball.velocity.x.abs();
        }
        // Top wall
        if (ball.position.y - ball.radius < 0) {
          ball.position.y = ball.radius;
          ball.velocity.y = ball.velocity.y.abs();
        }
        // Bottom floor (Ball returned)
        if (ball.position.y + ball.radius >= playfieldHeight) {
          ball.position.y = playfieldHeight - ball.radius;
          ball.isActive = false;
          onBallLanded(ball);
          continue;
        }

        // 2. Brick collisions via Spatial Hash broad-phase
        final candidates = spatialHash.queryCandidates(
          ball.position.x,
          ball.position.y,
          ball.radius + math.max(cellWidth, cellHeight),
        );

        for (int c = 0; c < candidates.length; c++) {
          final brick = candidates[c];
          if (brick.isDestroyed) continue;

          final bx = brick.gridX * cellWidth;
          final by = brick.gridY * cellHeight;

          CollisionResult result;
          if (brick.type.isWedge) {
            result = CollisionSystem.testCircleVsWedge(
              ballPos: ball.position,
              ballRadius: ball.radius,
              left: bx,
              top: by,
              right: bx + cellWidth,
              bottom: by + cellHeight,
              brick: brick,
            );
          } else {
            result = CollisionSystem.testCircleVsAABB(
              ballPos: ball.position,
              ballRadius: ball.radius,
              left: bx,
              top: by,
              right: bx + cellWidth,
              bottom: by + cellHeight,
              brick: brick,
            );
          }

          if (result.collided) {
            ball.lastHitBrickId = brick.id;

            // Handle special collectible blocks (no deflection, passed through or collected)
            if (brick.type == BrickType.permanentAdder) {
              brick.isDestroyed = true;
              ParticlePool.spawnTextPopup(
                Vector2(bx + cellWidth / 2, by),
                '+1 PERM BALL',
                GameColors.emeraldGreen,
              );
              ParticlePool.spawnSparks(
                Vector2(bx + cellWidth / 2, by + cellHeight / 2),
                GameColors.emeraldGreen,
                count: 10,
              );
              AudioSynthesizer.instance.playCollectPlusBall();
              onPermanentBallCollected(1);
              continue;
            }

            // ════════════════════════════════════════════════════════════════
            // SWARM EXPAND: +1 Ball persists for the ENTIRE remaining turn
            // ════════════════════════════════════════════════════════════════
            if (brick.type == BrickType.turnBallAdder) {
              brick.isDestroyed = true;
              ParticlePool.spawnTextPopup(
                Vector2(bx + cellWidth / 2, by),
                '⬡ +BALL TURN!',
                const Color(0xFF39FF14),
              );
              ParticlePool.spawnShockwave(
                Vector2(bx + cellWidth / 2, by + cellHeight / 2),
                const Color(0xFF39FF14),
                initialSize: 10.0,
              );
              ParticlePool.spawnSparks(
                Vector2(bx + cellWidth / 2, by + cellHeight / 2),
                const Color(0xFF39FF14),
                count: 14,
              );
              AudioSynthesizer.instance.playCollectPlusBall();

              // Spawn a persistent clone with a fresh upward trajectory
              // so it actively contributes to the current turn instead of 
              // just sitting there.
              final rng = math.Random();
              final launchAngle = -math.pi / 2 + (rng.nextDouble() - 0.5) * (math.pi / 3);
              final spd = ball.velocity.length;
              final turnBall = Ball(
                id: DateTime.now().microsecondsSinceEpoch + _spawnQueue.length + 9999,
                position: Vector2(bx + cellWidth / 2, by + cellHeight / 2),
                velocity: Vector2(math.cos(launchAngle) * spd, math.sin(launchAngle) * spd),
                radius: ball.radius,
                skin: ball.skin,
                generation: 0, // Generation 0 = counts as a full permanent-style ball
              );
              _spawnQueue.add(turnBall);
              onTurnBallSpawned(); // Notify controller so HUD can update
              continue;
            }

            if (brick.type == BrickType.inAirSplitter) {
              brick.isDestroyed = true;
              ParticlePool.spawnTextPopup(
                Vector2(bx + cellWidth / 2, by),
                'SWARM x2',
                GameColors.neonCyan,
              );
              ParticlePool.spawnShockwave(
                Vector2(bx + cellWidth / 2, by + cellHeight / 2),
                GameColors.neonCyan,
                initialSize: 8.0,
              );
              AudioSynthesizer.instance.playSplitterSwarm();

              // Spawn 90° rotated clone ball
              final cloneVel = ball.velocity.rotated(math.pi / 2);
              _spawnQueue.add(
                Ball(
                  id: DateTime.now().microsecondsSinceEpoch + _spawnQueue.length,
                  position: ball.position,
                  velocity: cloneVel,
                  radius: ball.radius,
                  skin: ball.skin,
                  generation: ball.generation + 1,
                ),
              );
              continue;
            }

            // Normal solid deflection
            CollisionSystem.resolveBallCollision(ball, result);

            // Apply damage or trigger special weapon
            if (brick.type.isSpecialTrigger) {
              brick.isDestroyed = true;
              chainManager.queueTrigger(brick);
              AudioSynthesizer.instance.playBombExplosion();
              onBrickHit(BrickHitEvent(brick: brick, ball: ball, wasDestroyed: true));
            } else {
              final destroyed = brick.applyDamage(ball.damageMultiplier);
              onBrickHit(BrickHitEvent(brick: brick, ball: ball, wasDestroyed: destroyed));

              final center = Vector2(bx + cellWidth / 2, by + cellHeight / 2);
              if (destroyed) {
                ParticlePool.spawnShardBurst(center, brick.primaryColor, count: 8);
              } else {
                ParticlePool.spawnSparks(center, brick.primaryColor, count: 4);
              }
            }

            break; // One collision per ball sub-step
          }
        }
      }
    }

    // Append all spawned clone balls
    if (_spawnQueue.isNotEmpty) {
      balls.addAll(_spawnQueue);
      _spawnQueue.clear();
    }

    // Process queued chain reactions (Lasers, Bombs, Nukes)
    chainManager.processQueue(
      allBricks: bricks,
      cellWidth: cellWidth,
      cellHeight: cellHeight,
      onExplosion: (center, color) {
        ParticlePool.spawnShockwave(center, color, initialSize: 15.0);
        ParticlePool.spawnShardBurst(center, color, count: 14);
        AudioSynthesizer.instance.playBombExplosion();
      },
      onLaser: (start, end, color) {
        ParticlePool.spawnLaserBeam(start, end, color);
        AudioSynthesizer.instance.playLaserSweep();
      },
    );

    // Update ball motion trails
    for (int i = 0; i < balls.length; i++) {
      if (balls[i].isActive) {
        balls[i].updateTrail();
      }
    }
  }
}
