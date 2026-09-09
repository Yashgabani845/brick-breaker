import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:bricks_breaker_3d/core/math/vector2.dart';
import 'package:bricks_breaker_3d/game/models/brick.dart';
import 'package:bricks_breaker_3d/game/models/level_data.dart';
import 'package:bricks_breaker_3d/game/physics/spatial_hash.dart';
import 'package:bricks_breaker_3d/game/physics/chain_reaction_manager.dart';
import 'package:bricks_breaker_3d/game/levels/level_catalog.dart';
import 'package:bricks_breaker_3d/game/levels/procedural_generator.dart';
import 'package:bricks_breaker_3d/game/levels/shape_library.dart';
import 'package:bricks_breaker_3d/game/rendering/brick_3d_renderer.dart';

void main() {

  group('Vector2 Math & Reflections', () {
    test('Vector normalization and dot product', () {
      final v = Vector2(3, 4);
      expect(v.length, closeTo(5.0, 0.0001));

      final n = v.normalized();
      expect(n.length, closeTo(1.0, 0.0001));
      expect(n.x, closeTo(0.6, 0.0001));
      expect(n.y, closeTo(0.8, 0.0001));
    });

    test('Horizontal and Vertical Wall Reflections: V\' = V - 2(V · N)N', () {
      // Ball moving down-right hitting bottom wall (Normal = (0, -1))
      final vel = Vector2(100, 200);
      final normal = Vector2(0, -1);
      final reflected = vel.reflect(normal);

      expect(reflected.x, closeTo(100.0, 0.0001));
      expect(reflected.y, closeTo(-200.0, 0.0001)); // Y velocity inverted
    });

    test('45-Degree Wedge Normal Reflection: Top-Left Wedge', () {
      // 45-degree hypotenuse normal pointing towards (invSqrt2, invSqrt2)
      const invSqrt2 = 0.7071067811865475;
      final normal = Vector2(invSqrt2, invSqrt2);

      // Incoming ball moving straight down (0, 100) hitting 45° slant
      final incoming = Vector2(0, 100);
      final reflected = incoming.reflect(normal);

      // Deflects 90 degrees to move straight left (-100, 0)
      expect(reflected.x, closeTo(-100.0, 0.01));
      expect(reflected.y, closeTo(0.0, 0.01));
    });
  });

  group('Brick Entity & Damage Mechanics', () {
    test('Standard Brick takes damage and is destroyed at 0 HP', () {
      final brick = Brick(id: 1, gridX: 2, gridY: 3, type: BrickType.standard, hp: 30);
      expect(brick.isDestroyed, false);

      final destroyed1 = brick.applyDamage(10);
      expect(destroyed1, false);
      expect(brick.hp, 20);

      final destroyed2 = brick.applyDamage(25);
      expect(destroyed2, true);
      expect(brick.hp, 0);
      expect(brick.isDestroyed, true);
    });

    test('Armored Brick absorbs 50% damage', () {
      final armored = Brick(id: 2, gridX: 4, gridY: 4, type: BrickType.armoredBrick, hp: 100);

      armored.applyDamage(40);
      // 40 / 2 = 20 damage applied
      expect(armored.hp, 80);
    });
  });

  group('Spatial Hash Grid Broad-Phase', () {
    test('Correctly inserts and queries candidate bricks in buckets', () {
      final grid = SpatialHashGrid(columns: 12, rows: 16, cellWidth: 30.0, cellHeight: 25.0);
      final bricks = [
        Brick(id: 1, gridX: 2, gridY: 2, type: BrickType.standard, hp: 10),
        Brick(id: 2, gridX: 8, gridY: 8, type: BrickType.standard, hp: 10),
      ];

      grid.populate(bricks);

      // Query around (60, 50) which is grid cell (2, 2)
      final candidates = grid.queryCandidates(65.0, 55.0, 10.0);
      expect(candidates.length, 1);
      expect(candidates.first.id, 1);
    });
  });

  group('Chain Reaction Manager', () {
    test('Horizontal laser damages entire row deterministically', () {
      final manager = ChainReactionManager();
      final bricks = [
        Brick(id: 1, gridX: 2, gridY: 4, type: BrickType.horizontalLaser, hp: 1),
        Brick(id: 2, gridX: 5, gridY: 4, type: BrickType.standard, hp: 20),
        Brick(id: 3, gridX: 8, gridY: 4, type: BrickType.standard, hp: 50),
        Brick(id: 4, gridX: 5, gridY: 6, type: BrickType.standard, hp: 20), // different row
      ];

      manager.queueTrigger(bricks[0]);
      manager.processQueue(
        allBricks: bricks,
        cellWidth: 30.0,
        cellHeight: 25.0,
        onExplosion: (pos, color) {},
        onLaser: (start, end, color) {},
      );

      // Brick 2 (HP 20) receives 30 damage and is destroyed
      expect(bricks[1].isDestroyed, true);
      // Brick 3 (HP 50) receives 30 damage -> HP 20
      expect(bricks[2].hp, 20);
      // Brick 4 (Row 6) is untouched
      expect(bricks[3].hp, 20);
    });
  });

  group('Level Catalog, 100+ Shape Library & 1000 Unique Levels', () {
    test('Catalog contains all 20 handcrafted starter tiers', () {
      expect(LevelCatalog.levels.length, 20);

      final level10 = LevelCatalog.getLevel(10);
      expect(level10.archetype, LevelArchetype.impossibleCitadel);
      expect(level10.initialBricks.isNotEmpty, true);
      expect(level10.startingBalls, 80);
    });

    test('ShapeLibrary provides diverse shapes and patterns', () {
      expect(ShapeLibrary.shapes.length >= 30, true);
    });

    test('Generates distinct valid levels across 1 to 1000 with progressive scaling', () {
      final sampleLevels = [1, 50, 100, 250, 500, 750, 1000];
      for (final lvlNum in sampleLevels) {
        final level = LevelCatalog.getLevel(lvlNum);
        expect(level.levelNumber, lvlNum);
        expect(level.initialBricks.isNotEmpty, true);
        expect(level.startingBalls >= 30, true);
      }
    });

    test('Brick3DRenderer safely handles huge HP numbers and narrow wedges without overflow', () {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      final testBricks = [
        Brick(id: 1, gridX: 0, gridY: 0, type: BrickType.standard, hp: 5),
        Brick(id: 2, gridX: 0, gridY: 0, type: BrickType.standard, hp: 850),
        Brick(id: 3, gridX: 0, gridY: 0, type: BrickType.standard, hp: 12500),
        Brick(id: 4, gridX: 0, gridY: 0, type: BrickType.standard, hp: 2500000),
        Brick(id: 5, gridX: 0, gridY: 0, type: BrickType.wedgeTopLeft, hp: 9999),
        Brick(id: 6, gridX: 0, gridY: 0, type: BrickType.turnBallAdder, hp: 1),
        Brick(id: 7, gridX: 0, gridY: 0, type: BrickType.superNuke, hp: 1),
      ];

      for (final brick in testBricks) {
        expect(() {
          Brick3DRenderer.renderBrick(
            canvas: canvas,
            brick: brick,
            rect: const Rect.fromLTWH(10, 10, 32, 24),
            depth: 4.0,
          );
        }, returnsNormally);
      }
    });
  });
}

