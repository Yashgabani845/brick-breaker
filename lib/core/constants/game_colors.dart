import 'package:flutter/material.dart';

/// Rich aesthetic color palette for Bricks Breaker 3D:
/// Deep OLED contrast, glowing neon accents, and specular glassmorphism.
class GameColors {
  // Backgrounds & Dual Black Theme Options
  static const Color oledDark = Color(0xFF000000); // 100% Pure Pitch OLED Black
  static const Color spaceDark = Color(0xFF090D16); // Deep Cyber Space Navy
  static const Color surfaceDark = Color(0xFF111827); // Crisp Dark Slate Surface
  static const Color surfaceCard = Color(0xFF161F30); // Elevated Card Surface
  static const Color surfaceCardHover = Color(0xFF1E293B); // Interactive Hover Surface
  static const Color glassSurface = Color(0xFF131C2E); // Solid Crisp Surface (No Murky Blur)
  static const Color glassSurfaceLight = Color(0xFF1E2B45);
  static const Color glassBorder = Color(0x1FFFFFFF); // Subtle Crisp Border
  static const Color glassBorderGlow = Color(0x6600F0FF); // Clean Cyan Border Accent

  // Radiant Neon Accents (Vibrant & High-Contrast)
  static const Color neonCyan = Color(0xFF00F0FF);
  static const Color neonLime = Color(0xFF39FF14);
  static const Color neonMagenta = Color(0xFFFF007F);
  static const Color neonPurple = Color(0xFFA855F7);
  static const Color electricAmber = Color(0xFFFFB703);
  static const Color emeraldGreen = Color(0xFF00FFA3);
  static const Color crimsonDanger = Color(0xFFFF1744);
  static const Color solarGold = Color(0xFFFFD700);
  static const Color ultraIce = Color(0xFF38BDF8);
  static const Color titaniumSilver = Color(0xFF94A3B8);
  static const Color obsidianBlack = Color(0xFF1E293B);

  // HP Tier Gradients (Enhanced 3D Beveled Blocks)
  static const List<Color> hpLowGradient = [Color(0xFF00F0FF), Color(0xFF0284C7)];
  static const List<Color> hpMedLowGradient = [Color(0xFF00FFA3), Color(0xFF059669)];
  static const List<Color> hpMedGradient = [Color(0xFFFFB703), Color(0xFFEA580C)];
  static const List<Color> hpHighGradient = [Color(0xFFFF007F), Color(0xFFBE185D)];
  static const List<Color> hpExtremeGradient = [Color(0xFFA855F7), Color(0xFF6D28D9)];
  static const List<Color> hpImpossibleGradient = [Color(0xFFFF1744), Color(0xFF991B1B)];
  static const List<Color> hpCosmicPrismGradient = [Color(0xFF8B5CF6), Color(0xFFEC4899), Color(0xFF06B6D4)];
  static const List<Color> armoredGradient = [Color(0xFF94A3B8), Color(0xFF475569)];

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

  /// Helper to get background color based on theme index
  static Color getBackgroundColor(int themeIndex) {
    return themeIndex == 0 ? oledDark : spaceDark;
  }

  /// Helper to get gradient based on brick HP
  static List<Color> getHpGradient(int hp, int maxHp) {
    if (hp > 500) return hpCosmicPrismGradient;
    if (hp > 200) return hpImpossibleGradient;
    if (hp > 100) return hpExtremeGradient;
    if (hp > 50) return hpHighGradient;
    if (hp > 25) return hpMedGradient;
    if (hp > 10) return hpMedLowGradient;
    return hpLowGradient;
  }

  /// Helper to get primary glow color for a given HP
  static Color getHpGlowColor(int hp) {
    if (hp > 500) return neonPurple;
    if (hp > 200) return crimsonDanger;
    if (hp > 100) return neonPurple;
    if (hp > 50) return neonMagenta;
    if (hp > 25) return electricAmber;
    if (hp > 10) return emeraldGreen;
    return neonCyan;
  }
}
