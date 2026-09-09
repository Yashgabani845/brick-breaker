import 'dart:math' as math;
import '../models/brick.dart';
import '../models/powerup.dart';

/// Predefined Geometric Shape Matrix Templates for Brick Smash
class ShapeLibrary {
  static List<Brick> buildShape({
    required String shapeName,
    required int startId,
    required int baseHp,
    int offsetX = 1,
    int offsetY = 2,
  }) {
    int id = startId;
    final List<Brick> bricks = [];
    final matrix = _getShapeMatrix(shapeName);

    for (int r = 0; r < matrix.length; r++) {
      final rowStr = matrix[r];
      for (int c = 0; c < rowStr.length; c++) {
        final char = rowStr[c];
        if (char == ' ') continue;

        final gridX = offsetX + c;
        final gridY = offsetY + r;

        switch (char) {
          case 'X': // Standard Brick
            bricks.add(Brick(id: id++, gridX: gridX, gridY: gridY, type: BrickType.standard, hp: baseHp));
            break;
          case 'B': // Bomb
            bricks.add(Brick(id: id++, gridX: gridX, gridY: gridY, type: BrickType.clusterBomb, hp: 1));
            break;
          case 'L': // Horizontal Laser
            bricks.add(Brick(id: id++, gridX: gridX, gridY: gridY, type: BrickType.horizontalLaser, hp: 1));
            break;
          case 'C': // Cross Laser
            bricks.add(Brick(id: id++, gridX: gridX, gridY: gridY, type: BrickType.crossLaser, hp: 1));
            break;
          case 'S': // Steel Block
            bricks.add(Brick(id: id++, gridX: gridX, gridY: gridY, type: BrickType.titaniumShield, hp: 1));
            break;
          case 'P': // Power-Up Drop (Multiball / Fireball)
            bricks.add(Brick(
              id: id++,
              gridX: gridX,
              gridY: gridY,
              type: BrickType.standard,
              hp: baseHp,
              dropPowerUp: PowerUpType.multiball,
            ));
            break;
          case 'F': // Fireball
            bricks.add(Brick(
              id: id++,
              gridX: gridX,
              gridY: gridY,
              type: BrickType.standard,
              hp: baseHp,
              dropPowerUp: PowerUpType.fireball,
            ));
            break;
          case 'W': // Wide Paddle
            bricks.add(Brick(
              id: id++,
              gridX: gridX,
              gridY: gridY,
              type: BrickType.standard,
              hp: baseHp,
              dropPowerUp: PowerUpType.widePaddle,
            ));
            break;
          default:
            bricks.add(Brick(id: id++, gridX: gridX, gridY: gridY, type: BrickType.standard, hp: baseHp));
        }
      }
    }
    return bricks;
  }

  static List<String> _getShapeMatrix(String name) {
    switch (name.toLowerCase()) {
      case 'pyramid':
        return [
          '    XX    ',
          '   XXXX   ',
          '  XXXXXX  ',
          ' XXXXXXXX ',
          'XXXXXXXXXX',
        ];
      case 'castle':
        return [
          'X X XX X X',
          'XXXXXXXXXX',
          'XX  XX  XX',
          'XXXXXXXXXX',
          'XX  XX  XX',
        ];
      case 'heart':
        return [
          ' XX   XX ',
          'XXXX XXXX',
          'XXXXXXXXX',
          ' XXXXXXX ',
          '  XXXXX  ',
          '   XXX   ',
          '    X    ',
        ];
      case 'diamond':
        return [
          '    XX    ',
          '  XXXXXX  ',
          'XXXXXXXXXX',
          '  XXXXXX  ',
          '    XX    ',
        ];
      case 'invader':
        return [
          '  X     X  ',
          '   X   X   ',
          '  XXXXXXX  ',
          ' XX XXX XX ',
          'XXXXXXXXXXX',
          'X XXXXXXX X',
          'X X     X X',
        ];
      case 'shield':
        return [
          'XXXXXXXXXX',
          'XXXXXXXXXX',
          ' XXXXXXXX ',
          '  XXXXXX  ',
          '   XXXX   ',
          '    XX    ',
        ];
      default:
        return [
          'XXXXXXXXXX',
          'XXXXXXXXXX',
          'XXXXXXXXXX',
        ];
    }
  }
}
