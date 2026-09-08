import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants/game_colors.dart';
import '../../game/systems/audio_synthesizer.dart';

/// Neon Gradient Glassmorphic Interactive Button
class GlassButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final List<Color>? gradient;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final bool isPrimary;
  final double? width;
  final double? height;

  const GlassButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.gradient,
    this.borderRadius = 16.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
    this.isPrimary = true,
    this.width,
    this.height,
  });

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = widget.gradient ??
        (widget.isPrimary
            ? [GameColors.neonCyan, const Color(0xFF0077FF)]
            : [GameColors.glassSurfaceLight, GameColors.glassSurface]);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        AudioSynthesizer.instance.playUiClick();
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.35),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.first.withOpacity(_isPressed ? 0.3 : 0.5),
                blurRadius: _isPressed ? 8 : 16,
                offset: _isPressed ? const Offset(0, 2) : const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Padding(
                padding: widget.padding,
                child: Center(child: widget.child),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
