import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants/game_colors.dart';
import 'glass_card.dart';

/// Modal dialog styled with glassmorphism and backdrop blur
class GlassModal extends StatelessWidget {
  final Widget child;
  final String? title;
  final VoidCallback? onClose;
  final double maxWidth;

  const GlassModal({
    super.key,
    required this.child,
    this.title,
    this.onClose,
    this.maxWidth = 420.0,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black.withOpacity(0.65),
      builder: (ctx) => GlassModal(
        title: title,
        onClose: () => Navigator.of(ctx).pop(),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: GlassCard(
              glow: true,
              glowColor: GameColors.neonCyan,
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (title != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title!,
                          style: const TextStyle(
                            fontSize: 22.0,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                        if (onClose != null)
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white70),
                            onPressed: onClose,
                          ),
                      ],
                    ),
                    const Divider(color: Colors.white24, height: 24),
                  ],
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
