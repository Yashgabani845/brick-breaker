import 'package:flutter/material.dart';

/// Crisp High-Contrast Arcade Text
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
    this.letterSpacing = 1.0,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
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
            color: Colors.black.withOpacity(0.8),
            offset: const Offset(0, 2),
            blurRadius: 4.0,
          ),
          if (glowColor != null)
            Shadow(
              color: glowColor!.withOpacity(0.4),
              blurRadius: 8.0,
            ),
        ],
      ),
    );
  }
}
