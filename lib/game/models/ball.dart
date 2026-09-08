import 'package:flutter/material.dart';
import '../../core/constants/game_colors.dart';
import '../../core/math/vector2.dart';

/// Available Ball Cosmetic Skins
enum BallSkin {
  neonWhite,
  cyanPlasma,
  solarFlare,
  emeraldCore,
  voidCrystal,
  goldenCrown,
}

extension BallSkinExtension on BallSkin {
  String get displayName {
    switch (this) {
      case BallSkin.neonWhite:
        return 'Pure Neon';
      case BallSkin.cyanPlasma:
        return 'Cyan Plasma';
      case BallSkin.solarFlare:
        return 'Solar Flare';
      case BallSkin.emeraldCore:
        return 'Cyber Emerald';
      case BallSkin.voidCrystal:
        return 'Void Crystal';
      case BallSkin.goldenCrown:
        return 'Golden Crown';
    }
  }

  Color get glowColor {
    switch (this) {
      case BallSkin.neonWhite:
        return Colors.white;
      case BallSkin.cyanPlasma:
        return GameColors.neonCyan;
      case BallSkin.solarFlare:
        return GameColors.electricAmber;
      case BallSkin.emeraldCore:
        return GameColors.emeraldGreen;
      case BallSkin.voidCrystal:
        return GameColors.neonPurple;
      case BallSkin.goldenCrown:
        return GameColors.solarGold;
    }
  }

  int get unlockCostCoins {
    switch (this) {
      case BallSkin.neonWhite:
        return 0;
      case BallSkin.cyanPlasma:
        return 200;
      case BallSkin.solarFlare:
        return 500;
      case BallSkin.emeraldCore:
        return 800;
      case BallSkin.voidCrystal:
        return 1200;
      case BallSkin.goldenCrown:
        return 2000;
    }
  }
}

/// Dynamic Ball Entity simulated in real-time
class Ball {
  final int id;
  final Vector2 position;
  final Vector2 velocity;
  final double radius;
  bool isActive;
  bool isReturning; // Returning to launcher magnet
  int damageMultiplier;
  final BallSkin skin;
  int generation; // Generation 0 = original launched, 1+ = split clones
  int? lastHitBrickId;
  double hitCooldown; // Collision cooldown to prevent multi-hit sticking

  // Circular Trail buffer for zero-garbage motion trails
  static const int maxTrailLength = 5;
  final List<Vector2> trail = [];

  Ball({
    required this.id,
    required Vector2 position,
    required Vector2 velocity,
    this.radius = 5.0,
    this.isActive = true,
    this.isReturning = false,
    this.damageMultiplier = 1,
    this.skin = BallSkin.neonWhite,
    this.generation = 0,
    this.lastHitBrickId,
    this.hitCooldown = 0.0,
  })  : position = Vector2.copy(position),
        velocity = Vector2.copy(velocity);

  void updateTrail() {
    if (trail.length >= maxTrailLength) {
      trail.removeAt(0);
    }
    trail.add(Vector2.copy(position));
  }

  void clearTrail() {
    trail.clear();
  }
}
