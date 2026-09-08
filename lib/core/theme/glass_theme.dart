import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/game_colors.dart';

/// Glassmorphism Theme and UI Style Helpers
class GlassTheme {
  /// Standard Frosted Glass Box Decoration
  static BoxDecoration glassDecoration({
    Color? surfaceColor,
    Color? borderColor,
    double borderRadius = 18.0,
    double borderWidth = 1.2,
    bool glow = false,
    Color? glowColor,
  }) {
    return BoxDecoration(
      color: surfaceColor ?? GameColors.glassSurface,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? GameColors.glassBorder,
        width: borderWidth,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.35),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
        if (glow)
          BoxShadow(
            color: (glowColor ?? GameColors.neonCyan).withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 1,
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
        color: Colors.white.withOpacity(0.4),
        width: 1.0,
      ),
      boxShadow: [
        BoxShadow(
          color: gradientColors.first.withOpacity(pressed ? 0.3 : 0.6),
          blurRadius: pressed ? 8 : 16,
          offset: pressed ? const Offset(0, 2) : const Offset(0, 4),
        ),
      ],
    );
  }

  /// Frosted Glass Filter
  static ImageFilter get defaultBlurFilter => ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0);
  static ImageFilter get heavyBlurFilter => ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0);
}
