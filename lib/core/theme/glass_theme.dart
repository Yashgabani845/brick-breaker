import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/game_colors.dart';

/// Glassmorphism Theme and UI Style Helpers
class GlassTheme {
  /// Standard Crisp Dark Card Box Decoration
  static BoxDecoration glassDecoration({
    Color? surfaceColor,
    Color? borderColor,
    double borderRadius = 16.0,
    double borderWidth = 1.0,
    bool glow = false,
    Color? glowColor,
  }) {
    return BoxDecoration(
      color: surfaceColor ?? GameColors.surfaceCard,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? (glow ? (glowColor ?? GameColors.neonCyan).withOpacity(0.4) : GameColors.glassBorder),
        width: borderWidth,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.4),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
        if (glow)
          BoxShadow(
            color: (glowColor ?? GameColors.neonCyan).withOpacity(0.15),
            blurRadius: 12,
            spreadRadius: 0,
          ),
      ],
    );
  }

  /// Radiant Neon Gradient Button Decoration
  static BoxDecoration neonButtonDecoration({
    required List<Color> gradientColors,
    double borderRadius = 14.0,
    bool pressed = false,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      gradient: LinearGradient(
        colors: gradientColors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      border: Border.all(
        color: Colors.white.withOpacity(0.25),
        width: 1.0,
      ),
      boxShadow: [
        BoxShadow(
          color: gradientColors.first.withOpacity(pressed ? 0.2 : 0.4),
          blurRadius: pressed ? 4 : 10,
          offset: pressed ? const Offset(0, 1) : const Offset(0, 3),
        ),
      ],
    );
  }
}
