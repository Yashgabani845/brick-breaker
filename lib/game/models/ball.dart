import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/game_colors.dart';
import '../../core/constants/game_constants.dart';
import '../../core/math/vector2.dart';

/// Cosmetic skins for Ball entities
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
        return 'Pearl White';
      case BallSkin.cyanPlasma:
        return 'Cyan Plasma';
      case BallSkin.solarFlare:
        return 'Solar Fire';
      case BallSkin.emeraldCore:
        return 'Emerald Core';
      case BallSkin.voidCrystal:
        return 'Void Crystal';
      case BallSkin.goldenCrown:
        return 'Golden Sun';
    }
  }

  Color get glowColor {
    switch (this) {
      case BallSkin.neonWhite:
        return const Color(0xFFFFD54F);
      case BallSkin.cyanPlasma:
        return const Color(0xFF00E5FF);
      case BallSkin.solarFlare:
        return const Color(0xFFFF5722);
      case BallSkin.emeraldCore:
        return const Color(0xFF00E676);
      case BallSkin.voidCrystal:
        return const Color(0xFFE040FB);
      case BallSkin.goldenCrown:
        return const Color(0xFFFFB300);
    }
  }

  Color get coreColor {
    switch (this) {
      case BallSkin.neonWhite:
        return Colors.white;
      case BallSkin.cyanPlasma:
        return const Color(0xFFE0F7FA);
      case BallSkin.solarFlare:
        return const Color(0xFFFFF9C4);
      case BallSkin.emeraldCore:
        return const Color(0xFFE8F5E9);
      case BallSkin.voidCrystal:
        return const Color(0xFFF3E5F5);
      case BallSkin.goldenCrown:
        return const Color(0xFFFFF8E1);
    }
  }

  List<Color> get gradientColors {
    switch (this) {
      case BallSkin.neonWhite:
        return const [Color(0xFFFFF9C4), Color(0xFFFFD54F), Color(0xFFFF8F00), Color(0xFFE65100)];
      case BallSkin.cyanPlasma:
        return const [Color(0xFFE0F7FA), Color(0xFF00E5FF), Color(0xFF0091EA), Color(0xFF0D47A1)];
      case BallSkin.solarFlare:
        return const [Color(0xFFFFF9C4), Color(0xFFFF9100), Color(0xFFFF3D00), Color(0xFFB71C1C)];
      case BallSkin.emeraldCore:
        return const [Color(0xFFE8F5E9), Color(0xFF69F0AE), Color(0xFF00E676), Color(0xFF1B5E20)];
      case BallSkin.voidCrystal:
        return const [Color(0xFFF3E5F5), Color(0xFFEA80FC), Color(0xFFAB47BC), Color(0xFF4A148C)];
      case BallSkin.goldenCrown:
        return const [Color(0xFFFFFDE7), Color(0xFFFFEE58), Color(0xFFFFD700), Color(0xFFFF6F00)];
    }
  }

  int get unlockCostCoins {
    switch (this) {
      case BallSkin.neonWhite:
        return 0;
      case BallSkin.cyanPlasma:
        return 100;
      case BallSkin.solarFlare:
        return 250;
      case BallSkin.emeraldCore:
        return 500;
      case BallSkin.voidCrystal:
        return 800;
      case BallSkin.goldenCrown:
        return 1200;
    }
  }
}

/// Ball Entity for Real-Time Paddle Brick Breaker
class Ball {
  final int id;
  Vector2 position;
  Vector2 velocity;
  double radius;
  double speed;
  bool isActive;
  bool isStuckToPaddle; // Initial ball waiting for player launch
  bool isFireball;
  double fireballTimer;
  BallSkin skin;
  final List<Vector2> trail;
  int hitStreak;

  Ball({
    required this.id,
    required this.position,
    Vector2? velocity,
    this.radius = 7.0,
    this.speed = 360.0, // Standard responsive arcade speed (px/s)
    this.isActive = true,
    this.isStuckToPaddle = false,
    this.isFireball = false,
    this.fireballTimer = 0.0,
    this.skin = BallSkin.neonWhite,
    List<Vector2>? trail,
    this.hitStreak = 0,
  })  : velocity = velocity ?? Vector2(0, -360.0),
        trail = trail ?? [];

  void setVelocity(double vx, double vy) {
    velocity.set(vx, vy);
    speed = velocity.length;
  }

  void activateFireball(double duration) {
    isFireball = true;
    fireballTimer = duration;
  }

  void update(double dt) {
    if (!isActive || isStuckToPaddle) return;

    // Fireball timer
    if (isFireball) {
      fireballTimer -= dt;
      if (fireballTimer <= 0) {
        isFireball = false;
      }
    }

    // Record trail position for ultra-smooth visual trailing
    trail.add(Vector2(position.x, position.y));
    if (trail.length > 8) {
      trail.removeAt(0);
    }

    // Step position
    position.x += velocity.x * dt;
    position.y += velocity.y * dt;
  }
}
