import 'package:flutter/material.dart';
import '../../core/math/vector2.dart';

/// Cosmetic skins for Player Paddle
enum PaddleSkin {
  neonBlade,
  solarFlame,
  voidPrism,
  emeraldSaber,
  goldenAegis,
  cyberTitan,
}

extension PaddleSkinExtension on PaddleSkin {
  String get displayName {
    switch (this) {
      case PaddleSkin.neonBlade:
        return 'Neon Blade';
      case PaddleSkin.solarFlame:
        return 'Solar Flame';
      case PaddleSkin.voidPrism:
        return 'Void Prism';
      case PaddleSkin.emeraldSaber:
        return 'Emerald Saber';
      case PaddleSkin.goldenAegis:
        return 'Golden Aegis';
      case PaddleSkin.cyberTitan:
        return 'Cyber Titan';
    }
  }

  List<Color> get bodyGradient {
    switch (this) {
      case PaddleSkin.neonBlade:
        return const [Color(0xFF00E5FF), Color(0xFF0091EA), Color(0xFF0D47A1)];
      case PaddleSkin.solarFlame:
        return const [Color(0xFFFF5252), Color(0xFFFF6D00), Color(0xFFBF360C)];
      case PaddleSkin.voidPrism:
        return const [Color(0xFFE040FB), Color(0xFF7B1FA2), Color(0xFF4A148C)];
      case PaddleSkin.emeraldSaber:
        return const [Color(0xFF00E676), Color(0xFF00C853), Color(0xFF1B5E20)];
      case PaddleSkin.goldenAegis:
        return const [Color(0xFFFFD700), Color(0xFFFF9100), Color(0xFFE65100)];
      case PaddleSkin.cyberTitan:
        return const [Color(0xFF90A4AE), Color(0xFF37474F), Color(0xFF212121)];
    }
  }

  Color get glowColor {
    switch (this) {
      case PaddleSkin.neonBlade:
        return const Color(0xFF00E5FF);
      case PaddleSkin.solarFlame:
        return const Color(0xFFFF5722);
      case PaddleSkin.voidPrism:
        return const Color(0xFFE040FB);
      case PaddleSkin.emeraldSaber:
        return const Color(0xFF00E676);
      case PaddleSkin.goldenAegis:
        return const Color(0xFFFFD700);
      case PaddleSkin.cyberTitan:
        return const Color(0xFF00E5FF);
    }
  }

  Color get coreColor {
    switch (this) {
      case PaddleSkin.neonBlade:
        return const Color(0xFFE1F5FE);
      case PaddleSkin.solarFlame:
        return const Color(0xFFFFF9C4);
      case PaddleSkin.voidPrism:
        return const Color(0xFFF3E5F5);
      case PaddleSkin.emeraldSaber:
        return const Color(0xFFE8F5E9);
      case PaddleSkin.goldenAegis:
        return const Color(0xFFFFF8E1);
      case PaddleSkin.cyberTitan:
        return const Color(0xFF00E5FF);
    }
  }

  int get unlockCostCoins {
    switch (this) {
      case PaddleSkin.neonBlade:
        return 0;
      case PaddleSkin.solarFlame:
        return 300;
      case PaddleSkin.voidPrism:
        return 500;
      case PaddleSkin.emeraldSaber:
        return 750;
      case PaddleSkin.goldenAegis:
        return 1200;
      case PaddleSkin.cyberTitan:
        return 1500;
    }
  }
}

/// Player Controlled Paddle Entity
class Paddle {
  Vector2 position;
  double width;
  final double height;
  final double baseWidth;
  double targetX;
  bool isWide;
  double wideTimer;
  bool isLaserActive;
  double laserTimer;
  double laserCooldown;
  PaddleSkin skin;

  Paddle({
    required this.position,
    this.width = 94.0,
    this.height = 16.0,
    this.baseWidth = 94.0,
    double? targetX,
    this.isWide = false,
    this.wideTimer = 0.0,
    this.isLaserActive = false,
    this.laserTimer = 0.0,
    this.laserCooldown = 0.0,
    this.skin = PaddleSkin.neonBlade,
  }) : targetX = targetX ?? position.x;

  Color get glowColor => skin.glowColor;

  Rect get rect => Rect.fromCenter(
    center: Offset(position.x, position.y),
    width: width,
    height: height,
  );

  void update(double dt, double minX, double maxX) {
    // Ultra-smooth 60 FPS responsive interpolation to finger touch position
    final diff = targetX - position.x;
    position.x += diff * (dt * 28.0).clamp(0.0, 1.0);

    // Clamp within screen boundaries
    final halfW = width / 2;
    position.x = position.x.clamp(minX + halfW, maxX - halfW);

    // Wide paddle power-up timer
    if (isWide) {
      wideTimer -= dt;
      if (wideTimer <= 0) {
        isWide = false;
        width = baseWidth;
      }
    }

    // Laser paddle power-up timer
    if (isLaserActive) {
      laserTimer -= dt;
      laserCooldown -= dt;
      if (laserTimer <= 0) {
        isLaserActive = false;
      }
    }
  }

  void activateWidePaddle(double duration) {
    isWide = true;
    wideTimer = duration;
    width = baseWidth * 1.5; // 50% wider paddle
  }

  void activateLaserPaddle(double duration) {
    isLaserActive = true;
    laserTimer = duration;
    laserCooldown = 0.0;
  }
}
