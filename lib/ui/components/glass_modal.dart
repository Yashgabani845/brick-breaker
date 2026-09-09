import 'package:flutter/material.dart';
import '../../core/constants/game_colors.dart';
import 'glass_card.dart';

/// Modal dialog styled with clean elevated dark surface
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
      barrierColor: Colors.black.withOpacity(0.80),
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
              surfaceColor: GameColors.surfaceCard,
              borderColor: GameColors.glassBorder,
              borderRadius: 20,
              padding: const EdgeInsets.all(22.0),
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
                            fontSize: 18.0,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1.0,
                          ),
                        ),
                        if (onClose != null)
                          IconButton(
                            icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 20),
                            onPressed: onClose,
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                    const Divider(color: Colors.white12, height: 20),
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
