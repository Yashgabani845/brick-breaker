import 'package:flutter/material.dart';
import '../../core/constants/game_colors.dart';
import '../../core/constants/game_constants.dart';
import '../../core/math/vector2.dart';
import '../models/brick.dart';
import '../models/particle.dart';

/// Chain Reaction Event Trigger Data
class ChainTriggerEvent {
  final Brick brick;
  final int depth;

  ChainTriggerEvent({required this.brick, this.depth = 0});
}

/// Centralized deterministic manager for lasers, bombs, and explosive chain reactions
class ChainReactionManager {
  final List<ChainTriggerEvent> _queue = [];
  int _currentTurnChains = 0;

  void queueTrigger(Brick brick, {int depth = 0}) {
    if (_currentTurnChains >= GameConstants.maxChainReactionsPerTurn) return;
    _queue.add(ChainTriggerEvent(brick: brick, depth: depth));
  }

  void resetTurn() {
    _queue.clear();
    _currentTurnChains = 0;
  }

  /// Processes all queued chain events deterministically
  /// Returns count of blocks destroyed by the chain
  int processQueue({
    required List<Brick> allBricks,
    required double cellWidth,
    required double cellHeight,
    required void Function(Vector2 pos, Color color) onExplosion,
    required void Function(Vector2 start, Vector2 end, Color color) onLaser,
  }) {
    int totalDestroyed = 0;

    while (_queue.isNotEmpty && _currentTurnChains < GameConstants.maxChainReactionsPerTurn) {
      final event = _queue.removeAt(0);
      _currentTurnChains++;
      final b = event.brick;
      b.isDestroyed = true;
      final bx = b.gridX * cellWidth + cellWidth / 2;
      final by = b.gridY * cellHeight + cellHeight / 2;

      switch (b.type) {
        case BrickType.horizontalLaser:
          totalDestroyed += _triggerLaser(
            allBricks: allBricks,
            targetRow: b.gridY,
            targetCol: null,
            cellWidth: cellWidth,
            cellHeight: cellHeight,
            laserColor: GameColors.laserHorizontal,
            depth: event.depth,
            onLaser: onLaser,
          );
          break;

        case BrickType.verticalLaser:
          totalDestroyed += _triggerLaser(
            allBricks: allBricks,
            targetRow: null,
            targetCol: b.gridX,
            cellWidth: cellWidth,
            cellHeight: cellHeight,
            laserColor: GameColors.laserVertical,
            depth: event.depth,
            onLaser: onLaser,
          );
          break;

        case BrickType.crossLaser:
          totalDestroyed += _triggerLaser(
            allBricks: allBricks,
            targetRow: b.gridY,
            targetCol: null,
            cellWidth: cellWidth,
            cellHeight: cellHeight,
            laserColor: GameColors.laserCross,
            depth: event.depth,
            onLaser: onLaser,
          );
          totalDestroyed += _triggerLaser(
            allBricks: allBricks,
            targetRow: null,
            targetCol: b.gridX,
            cellWidth: cellWidth,
            cellHeight: cellHeight,
            laserColor: GameColors.laserCross,
            depth: event.depth,
            onLaser: onLaser,
          );
          break;

        case BrickType.diagonalLaser:
          totalDestroyed += _triggerDiagonalLaser(
            allBricks: allBricks,
            originX: b.gridX,
            originY: b.gridY,
            cellWidth: cellWidth,
            cellHeight: cellHeight,
            depth: event.depth,
            onLaser: onLaser,
          );
          break;

        case BrickType.clusterBomb:
        case BrickType.chainDynamite:
          totalDestroyed += _triggerBomb(
            allBricks: allBricks,
            centerCol: b.gridX,
            centerRow: b.gridY,
            cellWidth: cellWidth,
            cellHeight: cellHeight,
            depth: event.depth,
            isDynamite: b.type == BrickType.chainDynamite,
            onExplosion: onExplosion,
          );
          break;

        case BrickType.superNuke:
          totalDestroyed += _triggerSuperNuke(
            allBricks: allBricks,
            cellWidth: cellWidth,
            cellHeight: cellHeight,
            depth: event.depth,
            onExplosion: onExplosion,
          );
          break;

        default:
          break;
      }
    }

    return totalDestroyed;
  }

  int _triggerLaser({
    required List<Brick> allBricks,
    required int? targetRow,
    required int? targetCol,
    required double cellWidth,
    required double cellHeight,
    required Color laserColor,
    required int depth,
    required void Function(Vector2 start, Vector2 end, Color color) onLaser,
  }) {
    int destroyed = 0;

    if (targetRow != null) {
      final y = targetRow * cellHeight + cellHeight / 2;
      onLaser(Vector2(0, y), Vector2(1000, y), laserColor);

      for (final brick in allBricks) {
        if (!brick.isDestroyed && brick.gridY == targetRow) {
          if (brick.type.isSpecialTrigger) {
            queueTrigger(brick, depth: depth + 1);
            brick.isDestroyed = true;
            destroyed++;
          } else if (brick.applyDamage(30)) {
            destroyed++;
          }
        }
      }
    }

    if (targetCol != null) {
      final x = targetCol * cellWidth + cellWidth / 2;
      onLaser(Vector2(x, 0), Vector2(x, 1500), laserColor);

      for (final brick in allBricks) {
        if (!brick.isDestroyed && brick.gridX == targetCol) {
          if (brick.type.isSpecialTrigger) {
            queueTrigger(brick, depth: depth + 1);
            brick.isDestroyed = true;
            destroyed++;
          } else if (brick.applyDamage(30)) {
            destroyed++;
          }
        }
      }
    }

    return destroyed;
  }

  int _triggerDiagonalLaser({
    required List<Brick> allBricks,
    required int originX,
    required int originY,
    required double cellWidth,
    required double cellHeight,
    required int depth,
    required void Function(Vector2 start, Vector2 end, Color color) onLaser,
  }) {
    int destroyed = 0;
    final ox = originX * cellWidth + cellWidth / 2;
    final oy = originY * cellHeight + cellHeight / 2;

    onLaser(Vector2(ox - 500, oy - 500), Vector2(ox + 500, oy + 500), GameColors.solarGold);
    onLaser(Vector2(ox - 500, oy + 500), Vector2(ox + 500, oy - 500), GameColors.solarGold);

    for (final brick in allBricks) {
      if (brick.isDestroyed) continue;
      final dx = (brick.gridX - originX).abs();
      final dy = (brick.gridY - originY).abs();
      if (dx == dy && dx > 0) {
        if (brick.type.isSpecialTrigger) {
          queueTrigger(brick, depth: depth + 1);
          brick.isDestroyed = true;
          destroyed++;
        } else if (brick.applyDamage(25)) {
          destroyed++;
        }
      }
    }

    return destroyed;
  }

  int _triggerBomb({
    required List<Brick> allBricks,
    required int centerCol,
    required int centerRow,
    required double cellWidth,
    required double cellHeight,
    required int depth,
    required bool isDynamite,
    required void Function(Vector2 pos, Color color) onExplosion,
  }) {
    int destroyed = 0;
    final center = Vector2(
      centerCol * cellWidth + cellWidth / 2,
      centerRow * cellHeight + cellHeight / 2,
    );
    onExplosion(center, isDynamite ? GameColors.crimsonDanger : GameColors.bombExplosion);

    for (final brick in allBricks) {
      if (brick.isDestroyed) continue;
      final dx = (brick.gridX - centerCol).abs();
      final dy = (brick.gridY - centerRow).abs();

      if (dx <= 1 && dy <= 1) {
        if (brick.type.isSpecialTrigger) {
          queueTrigger(brick, depth: depth + 1);
          brick.isDestroyed = true;
          destroyed++;
        } else {
          // Inner damage
          final damage = (dx == 0 && dy == 0) ? 60 : 35;
          if (brick.applyDamage(damage)) {
            destroyed++;
          }
        }
      }
    }

    return destroyed;
  }

  int _triggerSuperNuke({
    required List<Brick> allBricks,
    required double cellWidth,
    required double cellHeight,
    required int depth,
    required void Function(Vector2 pos, Color color) onExplosion,
  }) {
    int destroyed = 0;
    onExplosion(Vector2(200, 300), GameColors.nukeShockwave);

    for (final brick in allBricks) {
      if (brick.isDestroyed) continue;
      if (brick.hp <= GameConstants.superNukeMaxHpThreshold || brick.type.isSpecialTrigger) {
        if (brick.type.isSpecialTrigger) {
          queueTrigger(brick, depth: depth + 1);
        }
        brick.isDestroyed = true;
        destroyed++;
      } else {
        // Massive 50% HP damage
        if (brick.applyDamage(brick.hp ~/ 2)) {
          destroyed++;
        }
      }
    }

    return destroyed;
  }
}
