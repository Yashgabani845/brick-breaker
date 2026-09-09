import 'package:flutter/material.dart';
import '../../core/math/vector2.dart';

/// Types of Falling Power-Ups in Brick Smash
enum PowerUpType {
  multiball,   // Spawns 2 additional balls (max 5 simultaneous)
  fireball,    // Ball becomes fiery and penetrates bricks for 8s
  widePaddle,  // Enlarges paddle width for 12s
  laserPaddle, // Paddle fires dual vertical lasers
  slowBall,    // Reduces ball speed for 10s
  bomb,        // Triggers instant 3x3 blast on random dense brick cluster
  coins,       // Instant +50 coins
}

extension PowerUpTypeExtension on PowerUpType {
  String get displayName {
    switch (this) {
      case PowerUpType.multiball:
        return 'Multi-Ball';
      case PowerUpType.fireball:
        return 'Fireball';
      case PowerUpType.widePaddle:
        return 'Wide Paddle';
      case PowerUpType.laserPaddle:
        return 'Laser Cannon';
      case PowerUpType.slowBall:
        return 'Slow Motion';
      case PowerUpType.bomb:
        return 'Mega Bomb';
      case PowerUpType.coins:
        return '+50 Coins';
    }
  }

  Color get color {
    switch (this) {
      case PowerUpType.multiball:
        return const Color(0xFF00E5FF); // Electric Cyan
      case PowerUpType.fireball:
        return const Color(0xFFFF5722); // Fiery Orange-Red
      case PowerUpType.widePaddle:
        return const Color(0xFF00E676); // Neon Emerald Green
      case PowerUpType.laserPaddle:
        return const Color(0xFFFFD54F); // Solar Yellow
      case PowerUpType.slowBall:
        return const Color(0xFF38BDF8); // Ice Sky Blue
      case PowerUpType.bomb:
        return const Color(0xFFE040FB); // Neon Purple
      case PowerUpType.coins:
        return const Color(0xFFFFB300); // Gold
    }
  }

  String get iconEmoji {
    switch (this) {
      case PowerUpType.multiball:
        return '🔀';
      case PowerUpType.fireball:
        return '🔥';
      case PowerUpType.widePaddle:
        return '↔';
      case PowerUpType.laserPaddle:
        return '⚡';
      case PowerUpType.slowBall:
        return '❄';
      case PowerUpType.bomb:
        return '💣';
      case PowerUpType.coins:
        return '🪙';
    }
  }
}

/// Falling Power-Up Capsule Entity
class PowerUp {
  final int id;
  final PowerUpType type;
  final Vector2 position;
  final Vector2 velocity;
  final double radius;
  bool isCollected;
  bool isExpired;
  double rotation;

  PowerUp({
    required this.id,
    required this.type,
    required this.position,
    Vector2? velocity,
    this.radius = 12.0,
    this.isCollected = false,
    this.isExpired = false,
    this.rotation = 0.0,
  }) : velocity = velocity ?? Vector2(0, 160.0); // Falls at 160 px/s

  void update(double dt) {
    position.x += velocity.x * dt;
    position.y += velocity.y * dt;
    rotation += dt * 2.0;
  }
}
