import 'package:flutter/material.dart';
import '../../core/constants/game_colors.dart';
import '../../game/models/level_data.dart';
import '../../game/models/brick.dart';

/// Mini Holographic Blueprint Radar showing level brick architecture
class LevelBlueprintPreview extends StatelessWidget {
  final LevelData level;
  final double size;

  const LevelBlueprintPreview({
    super.key,
    required this.level,
    this.size = 54.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0x33000000),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: (level.themeColor ?? GameColors.neonCyan).withOpacity(0.35),
          width: 1.0,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: CustomPaint(
          size: Size(size, size),
          painter: _BlueprintPainter(level: level),
        ),
      ),
    );
  }
}

class _BlueprintPainter extends CustomPainter {
  final LevelData level;
  _BlueprintPainter({required this.level});

  @override
  void paint(Canvas canvas, Size size) {
    final themeColor = level.themeColor ?? GameColors.neonCyan;
    
    // Draw subtle grid
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 0.5;
    for (double i = 0; i < size.width; i += size.width / 4) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);
    }

    if (level.initialBricks.isEmpty) return;

    final cellW = (size.width - 6) / level.columns;
    final cellH = (size.height - 6) / level.rows;

    for (final brick in level.initialBricks) {
      final rect = Rect.fromLTWH(
        3.0 + (brick.gridX * cellW),
        3.0 + (brick.gridY * cellH),
        cellW - 0.8,
        cellH - 0.8,
      );

      Color brickColor = themeColor;
      if (brick.type == BrickType.clusterBomb || brick.type == BrickType.chainDynamite || brick.type == BrickType.superNuke) {
        brickColor = GameColors.solarGold;
      } else if (brick.type == BrickType.horizontalLaser || brick.type == BrickType.verticalLaser || brick.type == BrickType.crossLaser || brick.type == BrickType.diagonalLaser) {
        brickColor = GameColors.crimsonDanger;
      } else if (brick.type == BrickType.inAirSplitter) {
        brickColor = GameColors.neonMagenta;
      } else if (brick.type == BrickType.armoredBrick || brick.type == BrickType.titaniumShield) {
        brickColor = Colors.white70;
      }

      final paint = Paint()
        ..color = brickColor.withOpacity(0.85)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(1.5)), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BlueprintPainter oldDelegate) => false;
}


