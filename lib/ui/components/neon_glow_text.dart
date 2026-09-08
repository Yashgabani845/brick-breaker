import 'package:flutter/material.dart';
import '../../core/constants/game_colors.dart';

/// Radiant Cyberpunk Neon Glowing Text
class NeonGlowText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;
  final Color? glowColor;
  final FontWeight fontWeight;
  final double letterSpacing;
  final TextAlign textAlign;

  const NeonGlowText(
    this.text, {
    super.key,
    this.fontSize = 20.0,
    this.color = Colors.white,
    this.glowColor,
    this.fontWeight = FontWeight.w900,
    this.letterSpacing = 1.2,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    final glow = glowColor ?? GameColors.neonCyan;

    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        shadows: [
          Shadow(
            color: glow.withOpacity(0.9),
            blurRadius: 10.0,
          ),
          Shadow(
            color: glow.withOpacity(0.5),
            blurRadius: 22.0,
          ),
          const Shadow(
            color: Colors.black,
            blurRadius: 4.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
    );
  }
}
