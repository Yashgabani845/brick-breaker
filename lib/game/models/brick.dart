import 'package:flutter/material.dart';
import '../../core/constants/game_colors.dart';

/// Taxonomy of all game brick entities in Bricks Breaker 3D
enum BrickType {
  standard,
  wedgeTopLeft,
  wedgeTopRight,
  wedgeBottomLeft,
  wedgeBottomRight,
  permanentAdder, // +1 permanent ammunition for future turns
  turnBallAdder,  // +1 BALL FOR THIS ENTIRE TURN ("Swarm Expand" mechanic)
  inAirSplitter,  // x2 in-flight swarm duplication (clone lasts only for current ball)
  horizontalLaser,
  verticalLaser,
  crossLaser,
  diagonalLaser,
  clusterBomb,    // 3x3 blast
  chainDynamite,  // Propagates to neighboring explosives
  superNuke,      // Clears all <= 30 HP blocks
  iceBlock,       // Slows danger descent
  armoredBrick,   // Takes 50% damage / extra hits
  titaniumShield, // Unbreakable obstacle
}

extension BrickTypeExtension on BrickType {
  bool get isWedge =>
      this == BrickType.wedgeTopLeft ||
      this == BrickType.wedgeTopRight ||
      this == BrickType.wedgeBottomLeft ||
      this == BrickType.wedgeBottomRight;

  bool get isSpecialTrigger =>
      this == BrickType.permanentAdder ||
      this == BrickType.turnBallAdder ||
      this == BrickType.inAirSplitter ||
      this == BrickType.horizontalLaser ||
      this == BrickType.verticalLaser ||
      this == BrickType.crossLaser ||
      this == BrickType.diagonalLaser ||
      this == BrickType.clusterBomb ||
      this == BrickType.chainDynamite ||
      this == BrickType.superNuke;

  bool get isCollectible =>
      this == BrickType.permanentAdder ||
      this == BrickType.turnBallAdder ||
      this == BrickType.inAirSplitter;

  bool get isDamageable =>
      this != BrickType.titaniumShield &&
      this != BrickType.permanentAdder &&
      this != BrickType.turnBallAdder &&
      this != BrickType.inAirSplitter;
}

/// Brick Entity Data Class
class Brick {
  final int id;
  int gridX;
  int gridY;
  final BrickType type;
  int hp;
  final int maxHp;
  bool isDestroyed;
  double hitFlashTimer; // In seconds, for hit flash shader effect
  double rotation; // In radians for dynamic animations

  Brick({
    required this.id,
    required this.gridX,
    required this.gridY,
    required this.type,
    required this.hp,
    int? maxHp,
    this.isDestroyed = false,
    this.hitFlashTimer = 0.0,
    this.rotation = 0.0,
  }) : maxHp = maxHp ?? hp;

  Brick copyWith({
    int? id,
    int? gridX,
    int? gridY,
    BrickType? type,
    int? hp,
    int? maxHp,
    bool? isDestroyed,
    double? hitFlashTimer,
    double? rotation,
  }) {
    return Brick(
      id: id ?? this.id,
      gridX: gridX ?? this.gridX,
      gridY: gridY ?? this.gridY,
      type: type ?? this.type,
      hp: hp ?? this.hp,
      maxHp: maxHp ?? this.maxHp,
      isDestroyed: isDestroyed ?? this.isDestroyed,
      hitFlashTimer: hitFlashTimer ?? this.hitFlashTimer,
      rotation: rotation ?? this.rotation,
    );
  }

  /// Damage the brick, return true if destroyed
  bool applyDamage(int amount) {
    if (!type.isDamageable) return false;
    if (isDestroyed) return true;

    hitFlashTimer = 0.12; // 120ms flash effect

    if (type == BrickType.armoredBrick) {
      // Armor absorbs 50% damage
      final actualDamage = (amount > 1) ? (amount / 2).ceil() : 1;
      hp -= actualDamage;
    } else {
      hp -= amount;
    }

    if (hp <= 0) {
      hp = 0;
      isDestroyed = true;
      return true;
    }
    return false;
  }

  /// Visual damage crack stage (0.0 to 1.0)
  double get crackRatio {
    if (maxHp <= 0) return 0.0;
    return (1.0 - (hp / maxHp)).clamp(0.0, 1.0);
  }

  /// Visual 3D primary theme color
  Color get primaryColor {
    switch (type) {
      case BrickType.permanentAdder:
        return GameColors.emeraldGreen;
      case BrickType.turnBallAdder:
        return const Color(0xFF39FF14); // Bright neon lime — distinct from permanentAdder
      case BrickType.inAirSplitter:
        return GameColors.neonCyan;
      case BrickType.horizontalLaser:
        return GameColors.neonCyan;
      case BrickType.verticalLaser:
        return GameColors.neonMagenta;
      case BrickType.crossLaser:
      case BrickType.diagonalLaser:
        return GameColors.solarGold;
      case BrickType.clusterBomb:
        return GameColors.electricAmber;
      case BrickType.chainDynamite:
        return GameColors.crimsonDanger;
      case BrickType.superNuke:
        return GameColors.neonPurple;
      case BrickType.iceBlock:
        return GameColors.ultraIce;
      case BrickType.armoredBrick:
        return GameColors.titaniumSilver;
      case BrickType.titaniumShield:
        return const Color(0xFF475569);
      default:
        return GameColors.getHpGlowColor(hp);
    }
  }
}
