import 'package:flutter/material.dart';

/// Rich aesthetic color palette for Bricks Breaker 3D:
/// Deep OLED contrast, glowing neon accents, and specular glassmorphism.
class GameColors {
  // Backgrounds & Surfaces
  static const Color oledDark = Color(0xFF030712);
  static const Color spaceDark = Color(0xFF070D1B);
  static const Color glassSurface = Color(0x221E293B);
  static const Color glassSurfaceLight = Color(0x33334155);
  static const Color glassBorder = Color(0x40FFFFFF);
  static const Color glassBorderGlow = Color(0x8000F0FF);

  // Radiant Neon Accents
  static const Color neonCyan = Color(0xFF00F0FF);
  static const Color neonMagenta = Color(0xFFFF007F);
  static const Color neonPurple = Color(0xFFA855F7);
  static const Color electricAmber = Color(0xFFFFB703);
  static const Color emeraldGreen = Color(0xFF00FFA3);
  static const Color crimsonDanger = Color(0xFFFF1744);
  static const Color solarGold = Color(0xFFFFD700);
  static const Color ultraIce = Color(0xFF67E8F9);
  static const Color titaniumSilver = Color(0xFF94A3B8);

  // HP Tier Gradients (3D Bricks)
  static const List<Color> hpLowGradient = [Color(0xFF00E5FF), Color(0xFF0088FF)];
  static const List<Color> hpMedLowGradient = [Color(0xFF00FFA3), Color(0xFF00B060)];
  static const List<Color> hpMedGradient = [Color(0xFFFFB703), Color(0xFFFF7700)];
  static const List<Color> hpHighGradient = [Color(0xFFFF007F), Color(0xFFD00060)];
  static const List<Color> hpExtremeGradient = [Color(0xFFA855F7), Color(0xFF6B21A8)];
  static const List<Color> hpImpossibleGradient = [Color(0xFFFF1744), Color(0xFF88001B)];
  static const List<Color> armoredGradient = [Color(0xFF64748B), Color(0xFF334155)];

  // Laser & Bomb Effects
  static const Color laserHorizontal = Color(0xFF00F0FF);
  static const Color laserVertical = Color(0xFFFF007F);
  static const Color laserCross = Color(0xFFFFD700);
  static const Color bombExplosion = Color(0xFFFF6B00);
  static const Color nukeShockwave = Color(0xFFE040FB);

  // Ball Skin Colors
  static const Color ballNeonWhite = Color(0xFFFFFFFF);
  static const Color ballCyanPlasma = Color(0xFF00F0FF);
  static const Color ballSolarFlare = Color(0xFFFF9E00);
  static const Color ballEmeraldCore = Color(0xFF00FFB2);
  static const Color ballVoidCrystal = Color(0xFFA855F7);
  static const Color ballGoldenCrown = Color(0xFFFFD700);

  /// Helper to get gradient based on brick HP
  static List<Color> getHpGradient(int hp, int maxHp) {
    if (hp > 200) return hpImpossibleGradient;
    if (hp > 100) return hpExtremeGradient;
    if (hp > 50) return hpHighGradient;
    if (hp > 25) return hpMedGradient;
    if (hp > 10) return hpMedLowGradient;
    return hpLowGradient;
  }

  /// Helper to get primary glow color for a given HP
  static Color getHpGlowColor(int hp) {
    if (hp > 200) return crimsonDanger;
    if (hp > 100) return neonPurple;
    if (hp > 50) return neonMagenta;
    if (hp > 25) return electricAmber;
    if (hp > 10) return emeraldGreen;
    return neonCyan;
  }
}
