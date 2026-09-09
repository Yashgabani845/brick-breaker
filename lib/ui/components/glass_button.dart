import 'package:flutter/material.dart';
import '../../core/constants/game_colors.dart';
import '../../game/systems/audio_synthesizer.dart';

/// Crisp Neon Gradient Arcade Interactive Button
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
    this.borderRadius = 14.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 20.0, vertical: 13.0),
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
            ? [const Color(0xFF00D4FF), const Color(0xFF0066FF)]
            : [GameColors.surfaceCardHover, GameColors.surfaceCard]);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        AudioSynthesizer.instance.playUiClick();
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: Container(
          width: widget.width,
          height: widget.height,
          padding: widget.padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: Colors.white.withOpacity(widget.isPrimary ? 0.3 : 0.15),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.first.withOpacity(_isPressed ? 0.2 : (widget.isPrimary ? 0.35 : 0.1)),
                blurRadius: _isPressed ? 4 : 10,
                offset: _isPressed ? const Offset(0, 1) : const Offset(0, 3),
              ),
            ],
          ),
          child: Center(child: widget.child),
        ),
      ),
    );
  }
}
