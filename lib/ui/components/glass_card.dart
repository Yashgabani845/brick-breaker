import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants/game_colors.dart';
import '../../core/theme/glass_theme.dart';
import '../../game/systems/audio_synthesizer.dart';

/// Ultra-Premium Glassmorphic Card Container with optional tactile tap & sound
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
    this.borderRadius = 20.0,
    this.surfaceColor,
    this.borderColor,
    this.glow = false,
    this.glowColor,
    this.blurSigma = 12.0,
    this.onTap,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      margin: widget.margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: widget.blurSigma, sigmaY: widget.blurSigma),
          child: Container(
            padding: widget.padding,
            decoration: GlassTheme.glassDecoration(
              surfaceColor: widget.surfaceColor ?? GameColors.glassSurface,
              borderColor: widget.borderColor ?? (widget.glow ? (widget.glowColor ?? GameColors.neonCyan) : GameColors.glassBorder),
              borderRadius: widget.borderRadius,
              glow: widget.glow,
              glowColor: widget.glowColor,
            ),
            child: widget.child,
          ),
        ),
      ),
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
          scale: _isPressed ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 90),
          child: card,
        ),
      );
    }

    return card;
  }
}

