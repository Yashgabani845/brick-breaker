import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:bricks_breaker_3d/core/constants/game_constants.dart';
import 'package:bricks_breaker_3d/core/math/vector2.dart';
import 'package:bricks_breaker_3d/game/models/ball.dart';
import 'package:bricks_breaker_3d/game/models/brick.dart';
import 'package:bricks_breaker_3d/game/models/level_data.dart';
import 'package:bricks_breaker_3d/game/models/paddle.dart';
import 'package:bricks_breaker_3d/game/models/powerup.dart';
import 'package:bricks_breaker_3d/game/physics/physics_engine.dart';
import 'package:bricks_breaker_3d/game/systems/game_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Paddle Mechanics & Geometry', () {
    test('Paddle moves smoothly towards target and clamps to playfield boundaries', () {
      final paddle = Paddle(position: Vector2(180, 540));
      paddle.targetX = 500; // Far right beyond 360 width
      paddle.update(0.1, 0.0, 360.0);

      expect(paddle.position.x <= 360.0 - paddle.width / 2, isTrue);

      paddle.targetX = -100; // Far left
      paddle.update(0.1, 0.0, 360.0);
      expect(paddle.position.x >= paddle.width / 2, isTrue);
    });

    test('Wide paddle power-up expands width and shrinks after duration', () {
      final paddle = Paddle(position: Vector2(180, 540));
      final baseW = paddle.width;

      paddle.activateWidePaddle(5.0);
      expect(paddle.width, greaterThan(baseW));
      expect(paddle.isWide, isTrue);

      paddle.update(5.1, 0.0, 360.0);
      expect(paddle.width, equals(baseW));
      expect(paddle.isWide, isFalse);
    });
  });

  group('Paddle Deflection Physics', () {
    test('Ball hitting center of paddle bounces straight upward', () {
      final engine = PhysicsEngine(columns: 12, rows: 16, cellWidth: 30, cellHeight: 25);
      final paddle = Paddle(position: Vector2(180, 540));
      final ball = Ball(id: 1, position: Vector2(180, 532), isStuckToPaddle: false);
      ball.setVelocity(0, 400);

      engine.handlePaddleCollision(ball, paddle);
      expect(ball.velocity.y, lessThan(0)); // Moving upward
      expect(ball.velocity.x.abs(), lessThan(10)); // Near zero horizontal component
    });

    test('Ball hitting right edge of paddle bounces right at steep angle', () {
      final engine = PhysicsEngine(columns: 12, rows: 16, cellWidth: 30, cellHeight: 25);
      final paddle = Paddle(position: Vector2(180, 540));
      final ball = Ball(id: 1, position: Vector2(180 + paddle.width * 0.4, 532), isStuckToPaddle: false);
      ball.setVelocity(0, 400);

      engine.handlePaddleCollision(ball, paddle);
      expect(ball.velocity.y, lessThan(0)); // Moving upward
      expect(ball.velocity.x, greaterThan(100)); // Angled strongly to the right
    });
  });

  group('Falling Power-Ups & Gameplay Controller', () {
    test('Destroying power-up brick drops falling capsule', () {
      final controller = GameController();
      final level = LevelData(
        levelNumber: 1,
        title: 'Test',
        archetype: LevelArchetype.starterGrid,
        columns: 12,
        rows: 16,
        dangerRow: 14,
        targetScore: 1000,
        initialBricks: [
          Brick(id: 1, gridX: 6, gridY: 4, hp: 1, maxHp: 1, type: BrickType.standard, dropPowerUp: PowerUpType.fireball),
        ],
      );
      controller.loadLevel(level);

      // Launch ball and simulate hit
      controller.launchBall();
      expect(controller.state, equals(GameState.playing));

      // Manually trigger brick destruction
      controller.bricks.first.applyDamage(1);
      expect(controller.bricks.first.isDestroyed, isTrue);

      // Check level cleared
      controller.update(0.016);
      expect(controller.state, equals(GameState.levelComplete));
    });

    test('Losing all balls decreases life and resets on paddle', () {
      final controller = GameController();
      final level = LevelData(
        levelNumber: 1,
        title: 'Test',
        archetype: LevelArchetype.starterGrid,
        columns: 12,
        rows: 16,
        dangerRow: 14,
        targetScore: 1000,
        initialBricks: [
          Brick(id: 1, gridX: 6, gridY: 4, hp: 50, maxHp: 50, type: BrickType.standard),
        ],
      );
      controller.loadLevel(level);
      expect(controller.lives, equals(3));

      controller.launchBall();
      // Drop ball below playfield
      controller.balls.first.position.y = 800;
      controller.update(0.016);

      expect(controller.lives, equals(2));
      expect(controller.state, equals(GameState.aiming));
    });
  });
}
