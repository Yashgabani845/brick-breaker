import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/game_colors.dart';
import '../models/brick.dart';
import '../models/level_data.dart';
import '../models/powerup.dart';

/// Procedural Level Generator for Infinite Casual Arcade Paddle Levels in Brick Smash
class ProceduralLevelGenerator {
  static LevelData generate({required int levelNumber}) {
    final rand = math.Random(levelNumber * 7919); // Deterministic seed per level
    const int cols = 12;
    const int rows = 16;
    const int dangerRow = 14;

    int id = 1;
    final List<Brick> bricks = [];

    // Scaling base HP with gentle progression
    final int baseHp = (3 + (levelNumber * 0.8)).round().clamp(3, 80);
    final patternType = levelNumber % 6;

    final themeColors = [
      const Color(0xFF00E5FF),
      const Color(0xFFFF9100),
      const Color(0xFFE040FB),
      const Color(0xFFFF2A6D),
      const Color(0xFF00E676),
      const Color(0xFFFFD700),
    ];
    final themeColor = themeColors[levelNumber % themeColors.length];

    switch (patternType) {
      case 0: // Symmetrical Castle Walls
        for (int r = 2; r <= 6; r++) {
          for (int c = 1; c <= 10; c++) {
            if (c == 1 || c == 10 || r == 2 || r == 6 || (c >= 4 && c <= 7 && r == 4)) {
              final isPowerUp = rand.nextDouble() < 0.12;
              final isSpecial = rand.nextDouble() < 0.08;
              bricks.add(Brick(
                id: id++,
                gridX: c,
                gridY: r,
                type: isSpecial ? (rand.nextBool() ? BrickType.clusterBomb : BrickType.crossLaser) : BrickType.standard,
                hp: isSpecial ? 1 : baseHp,
                dropPowerUp: isPowerUp ? _randomPowerUp(rand) : null,
              ));
            }
          }
        }
        break;

      case 1: // Stepped Pyramid
        for (int r = 2; r <= 6; r++) {
          final startC = r;
          final endC = 11 - r;
          for (int c = startC; c <= endC; c++) {
            final isPowerUp = (c == startC || c == endC) && rand.nextDouble() < 0.3;
            bricks.add(Brick(
              id: id++,
              gridX: c,
              gridY: r,
              type: BrickType.standard,
              hp: baseHp + (6 - r) * 3,
              dropPowerUp: isPowerUp ? _randomPowerUp(rand) : null,
            ));
          }
        }
        break;

      case 2: // Diamond Formation
        for (int r = 1; r <= 7; r++) {
          final width = r <= 4 ? (r - 1) : (7 - r);
          for (int dx = -width; dx <= width; dx++) {
            final c = 5 + dx;
            if (c >= 0 && c < cols) {
              final isCenter = (r == 4 && dx == 0);
              bricks.add(Brick(
                id: id++,
                gridX: c,
                gridY: r + 1,
                type: isCenter ? BrickType.horizontalLaser : BrickType.standard,
                hp: isCenter ? 1 : baseHp,
                dropPowerUp: (dx.abs() == width && rand.nextDouble() < 0.25) ? _randomPowerUp(rand) : null,
              ));
            }
          }
        }
        break;

      case 3: // Fortress with Steel Corners
        for (int r = 2; r <= 6; r++) {
          for (int c = 1; c <= 10; c++) {
            final isCorner = (r == 2 || r == 6) && (c == 1 || c == 10);
            final isBomb = (r == 4 && (c == 5 || c == 6));

            if (isCorner) {
              bricks.add(Brick(id: id++, gridX: c, gridY: r, type: BrickType.titaniumShield, hp: 1));
            } else if (isBomb) {
              bricks.add(Brick(id: id++, gridX: c, gridY: r, type: BrickType.clusterBomb, hp: 1));
            } else if ((r + c) % 2 == 0) {
              bricks.add(Brick(
                id: id++,
                gridX: c,
                gridY: r,
                type: BrickType.standard,
                hp: baseHp,
                dropPowerUp: rand.nextDouble() < 0.15 ? _randomPowerUp(rand) : null,
              ));
            }
          }
        }
        break;

      case 4: // Multi-Tier Rows with Laser Highway
        for (int r = 2; r <= 6; r += 2) {
          for (int c = 1; c <= 10; c++) {
            final isLaser = (r == 4 && (c == 3 || c == 8));
            bricks.add(Brick(
              id: id++,
              gridX: c,
              gridY: r,
              type: isLaser ? BrickType.horizontalLaser : BrickType.standard,
              hp: isLaser ? 1 : baseHp,
              dropPowerUp: (c == 5 || c == 6) ? _randomPowerUp(rand) : null,
            ));
          }
        }
        break;

      default: // Cosmic Ring / Arch
        for (int c = 2; c <= 9; c++) {
          bricks.add(Brick(id: id++, gridX: c, gridY: 2, type: BrickType.standard, hp: baseHp));
          bricks.add(Brick(id: id++, gridX: c, gridY: 6, type: BrickType.standard, hp: baseHp));
        }
        for (int r = 3; r <= 5; r++) {
          bricks.add(Brick(id: id++, gridX: 2, gridY: r, type: BrickType.standard, hp: baseHp));
          bricks.add(Brick(id: id++, gridX: 9, gridY: r, type: BrickType.standard, hp: baseHp));
        }
        bricks.add(Brick(id: id++, gridX: 5, gridY: 4, type: BrickType.superNuke, hp: 1));
        bricks.add(Brick(id: id++, gridX: 6, gridY: 4, type: BrickType.superNuke, hp: 1));
        break;
    }

    return LevelData(
      levelNumber: levelNumber,
      title: 'Level $levelNumber',
      archetype: LevelArchetype.values[levelNumber % LevelArchetype.values.length],
      columns: cols,
      rows: rows,
      dangerRow: dangerRow,
      targetScore: 25000 + (levelNumber * 3000),
      initialBricks: bricks,
      themeColor: themeColor,
    );
  }

  static PowerUpType _randomPowerUp(math.Random rand) {
    final types = [
      PowerUpType.multiball,
      PowerUpType.fireball,
      PowerUpType.widePaddle,
      PowerUpType.laserPaddle,
      PowerUpType.bomb,
      PowerUpType.coins,
    ];
    return types[rand.nextInt(types.length)];
  }
}
