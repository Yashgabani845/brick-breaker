import 'package:flutter/material.dart';
import '../../core/constants/game_colors.dart';
import '../../core/theme/glass_theme.dart';
import '../../game/systems/audio_synthesizer.dart';

/// Crisp Dark Surface Card Container with responsive tactile tap & sound
class GlassCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? surfaceColor;
  final Color? borderColor;
  final bool glow;
  final Color? glowColor;
  final double blurSigma;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.margin,
    this.borderRadius = 16.0,
    this.surfaceColor,
    this.borderColor,
    this.glow = false,
    this.glowColor,
    this.blurSigma = 0.0,
    this.onTap,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: widget.margin,
      padding: widget.padding,
      decoration: GlassTheme.glassDecoration(
        surfaceColor: widget.surfaceColor ?? GameColors.surfaceCard,
        borderColor: widget.borderColor ?? (widget.glow ? (widget.glowColor ?? GameColors.neonCyan).withOpacity(0.4) : GameColors.glassBorder),
        borderRadius: widget.borderRadius,
        glow: widget.glow,
        glowColor: widget.glowColor,
      ),
      child: widget.child,
    );

    if (widget.onTap != null) {
      return GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          AudioSynthesizer.instance.playUiClick();
          widget.onTap!();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 80),
          child: card,
        ),
      );
    }

    return card;
  }
}

