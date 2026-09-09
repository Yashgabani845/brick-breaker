import 'package:flutter/material.dart';
import '../../core/constants/game_colors.dart';

/// Modal dialog styled with clean elevated Brick Smash dark surface
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
    this.maxWidth = 400.0,
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
      barrierColor: Colors.black.withOpacity(0.75),
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
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: const Color(0xFF0D162B),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFF263868), width: 1.8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
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
                            icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 22),
                            onPressed: onClose,
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
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
