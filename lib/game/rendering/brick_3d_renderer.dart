import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/game_colors.dart';
import '../models/brick.dart';

/// Renders 3D Extruded Beveled Bricks, 45° Wedges, Damage Cracks, and Special Glyphs
class Brick3DRenderer {
  static final Paint _paint = Paint();
  static final Paint _crackPaint = Paint()
    ..color = Colors.black.withOpacity(0.55)
    ..strokeWidth = 1.2
    ..style = PaintingStyle.stroke;

  static void renderBrick({
    required Canvas canvas,
    required Brick brick,
    required Rect rect,
    required double depth,
  }) {
    if (brick.isDestroyed) return;

    if (brick.type.isWedge) {
      _render3DWedge(canvas, brick, rect, depth);
    } else {
      _render3DRectangle(canvas, brick, rect, depth);
    }

    // Render Hit Flash overlay if actively taking damage
    if (brick.hitFlashTimer > 0) {
      final flashPaint = Paint()
        ..color = Colors.white.withOpacity((brick.hitFlashTimer / 0.12).clamp(0.0, 0.8))
        ..style = PaintingStyle.fill;
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(4.0)), flashPaint);
    }
  }

  static void _render3DRectangle(Canvas canvas, Brick brick, Rect rect, double depth) {
    final baseColor = brick.primaryColor;
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(4.0));

    // 1. Bottom/Right 3D Cast Shadow & Extrusion
    final shadowPath = Path()
      ..moveTo(rect.left + 4, rect.bottom)
      ..lineTo(rect.left + 4 + depth, rect.bottom + depth)
      ..lineTo(rect.right + depth, rect.bottom + depth)
      ..lineTo(rect.right + depth, rect.top + 4 + depth)
      ..lineTo(rect.right, rect.top + 4)
      ..lineTo(rect.right, rect.bottom)
      ..close();

    _paint.shader = null;
    _paint.color = Colors.black.withOpacity(0.45);
    _paint.style = PaintingStyle.fill;
    canvas.drawPath(shadowPath, _paint);

    // 2. Front Face with 3D Directional Lighting Gradient
    final lightColor = Color.lerp(baseColor, Colors.white, 0.25)!;
    final darkColor = Color.lerp(baseColor, Colors.black, 0.35)!;

    _paint.shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [lightColor, baseColor, darkColor],
      stops: const [0.0, 0.5, 1.0],
    ).createShader(rect);

    canvas.drawRRect(rrect, _paint);

    // 3. Top-Left Beveled Highlight Border
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(rrect, highlightPaint);

    // 4. Procedural Damage Fracture Lines (when damaged)
    if (brick.crackRatio > 0.15) {
      _renderCracks(canvas, rect, brick.crackRatio);
    }

    // 5. HP Number or Special Entity Glyph
    if (brick.type.isSpecialTrigger || brick.type.isCollectible) {
      _renderSpecialGlyph(canvas, brick, rect);
    } else {
      _renderHpText(canvas, brick, rect);
    }
  }

  static void _render3DWedge(Canvas canvas, Brick brick, Rect rect, double depth) {
    final baseColor = brick.primaryColor;
    final path = Path();
    late Offset v1, v2, v3;

    switch (brick.type) {
      case BrickType.wedgeTopLeft:
        v1 = rect.topLeft;
        v2 = rect.topRight;
        v3 = rect.bottomLeft;
        break;
      case BrickType.wedgeTopRight:
        v1 = rect.topRight;
        v2 = rect.topLeft;
        v3 = rect.bottomRight;
        break;
      case BrickType.wedgeBottomLeft:
        v1 = rect.bottomLeft;
        v2 = rect.topLeft;
        v3 = rect.bottomRight;
        break;
      case BrickType.wedgeBottomRight:
        v1 = rect.bottomRight;
        v2 = rect.topRight;
        v3 = rect.bottomLeft;
        break;
      default:
        return;
    }

    path.moveTo(v1.dx, v1.dy);
    path.lineTo(v2.dx, v2.dy);
    path.lineTo(v3.dx, v3.dy);
    path.close();

    // 3D Shadow extrusion on wedge
    final shadowPath = Path()
      ..moveTo(v2.dx, v2.dy)
      ..lineTo(v2.dx + depth, v2.dy + depth)
      ..lineTo(v3.dx + depth, v3.dy + depth)
      ..lineTo(v3.dx, v3.dy)
      ..close();

    _paint.shader = null;
    _paint.color = Colors.black.withOpacity(0.4);
    _paint.style = PaintingStyle.fill;
    canvas.drawPath(shadowPath, _paint);

    // Front wedge face
    _paint.shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color.lerp(baseColor, Colors.white, 0.3)!, baseColor, Color.lerp(baseColor, Colors.black, 0.4)!],
    ).createShader(rect);

    canvas.drawPath(path, _paint);

    // Bevel outline
    final strokePaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, strokePaint);

    // Angled Reflector Icon
    final center = Offset(rect.left + rect.width / 2, rect.top + rect.height / 2);
    final iconPaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(v2.dx, v2.dy), Offset(v3.dx, v3.dy), iconPaint);

    // HP label
    _renderHpText(canvas, brick, rect, scale: 0.85);
  }

  static void _renderCracks(Canvas canvas, Rect rect, double ratio) {
    final cx = rect.center.dx;
    final cy = rect.center.dy;
    final crackPath = Path();

    crackPath.moveTo(cx, cy);
    crackPath.lineTo(cx - rect.width * 0.3 * ratio, cy - rect.height * 0.35 * ratio);
    crackPath.moveTo(cx, cy);
    crackPath.lineTo(cx + rect.width * 0.35 * ratio, cy + rect.height * 0.3 * ratio);

    if (ratio > 0.5) {
      crackPath.moveTo(cx, cy);
      crackPath.lineTo(cx + rect.width * 0.25 * ratio, cy - rect.height * 0.3 * ratio);
      crackPath.moveTo(cx, cy);
      crackPath.lineTo(cx - rect.width * 0.3 * ratio, cy + rect.height * 0.35 * ratio);
    }

    canvas.drawPath(crackPath, _crackPaint);
  }

  static void _renderSpecialGlyph(Canvas canvas, Brick brick, Rect rect) {
    final center = rect.center;
    final iconPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    switch (brick.type) {
      case BrickType.permanentAdder:
        // Glowing "+" icon with orbit ring
        final ringPaint = Paint()
          ..color = GameColors.emeraldGreen.withOpacity(0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
        canvas.drawCircle(center, rect.height * 0.35, ringPaint);
        _drawPlusSign(canvas, center, rect.height * 0.25, Colors.white);
        break;

      case BrickType.turnBallAdder:
        // Neon lime hexagon shell + plus = "BALL FOR THIS TURN"
        const limeColor = Color(0xFF39FF14);
        final hexPaint = Paint()
          ..color = limeColor.withOpacity(0.35)
          ..style = PaintingStyle.fill;
        final hexStroke = Paint()
          ..color = limeColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
        final hexPath = Path();
        final hr = rect.height * 0.38;
        for (int i = 0; i < 6; i++) {
          final a = (i * math.pi / 3) - math.pi / 6;
          final px = center.dx + hr * math.cos(a);
          final py = center.dy + hr * math.sin(a);
          if (i == 0) { hexPath.moveTo(px, py); } else { hexPath.lineTo(px, py); }
        }
        hexPath.close();
        canvas.drawPath(hexPath, hexPaint);
        canvas.drawPath(hexPath, hexStroke);
        _drawPlusSign(canvas, center, rect.height * 0.22, limeColor);
        break;

      case BrickType.inAirSplitter:
        // Swarm x2 Diamond icon
        final diamondPath = Path()
          ..moveTo(center.dx, center.dy - rect.height * 0.35)
          ..lineTo(center.dx + rect.width * 0.3, center.dy)
          ..lineTo(center.dx, center.dy + rect.height * 0.35)
          ..lineTo(center.dx - rect.width * 0.3, center.dy)
          ..close();
        final diamondPaint = Paint()
          ..color = GameColors.neonCyan.withOpacity(0.4)
          ..style = PaintingStyle.fill;
        canvas.drawPath(diamondPath, diamondPaint);
        _drawPlusSign(canvas, center, rect.height * 0.22, Colors.white);
        break;

      case BrickType.horizontalLaser:
        // Horizontal laser bar with arrows
        final laserPaint = Paint()
          ..color = Colors.white
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke;
        canvas.drawLine(
          Offset(rect.left + 4, center.dy),
          Offset(rect.right - 4, center.dy),
          laserPaint,
        );
        break;

      case BrickType.verticalLaser:
        // Vertical laser bar
        final laserPaint = Paint()
          ..color = Colors.white
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke;
        canvas.drawLine(
          Offset(center.dx, rect.top + 4),
          Offset(center.dx, rect.bottom - 4),
          laserPaint,
        );
        break;

      case BrickType.crossLaser:
      case BrickType.diagonalLaser:
        final laserPaint = Paint()
          ..color = Colors.white
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke;
        canvas.drawLine(Offset(rect.left + 4, center.dy), Offset(rect.right - 4, center.dy), laserPaint);
        canvas.drawLine(Offset(center.dx, rect.top + 4), Offset(center.dx, rect.bottom - 4), laserPaint);
        break;

      case BrickType.clusterBomb:
      case BrickType.chainDynamite:
        // Bomb core with radial warning ticks
        canvas.drawCircle(center, rect.height * 0.25, iconPaint);
        final tickPaint = Paint()
          ..color = (brick.type == BrickType.chainDynamite) ? GameColors.crimsonDanger : GameColors.electricAmber
          ..strokeWidth = 1.5;
        for (int i = 0; i < 4; i++) {
          final angle = i * math.pi / 2;
          canvas.drawLine(
            center + Offset(math.cos(angle) * (rect.height * 0.28), math.sin(angle) * (rect.height * 0.28)),
            center + Offset(math.cos(angle) * (rect.height * 0.42), math.sin(angle) * (rect.height * 0.42)),
            tickPaint,
          );
        }
        break;

      case BrickType.superNuke:
        // Nuclear radiation symbol
        final nukePaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;
        canvas.drawCircle(center, rect.height * 0.15, nukePaint);
        final arcPaint = Paint()
          ..color = GameColors.neonPurple
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5;
        for (int i = 0; i < 3; i++) {
          final startAngle = i * (2 * math.pi / 3);
          canvas.drawArc(
            Rect.fromCircle(center: center, radius: rect.height * 0.32),
            startAngle,
            math.pi / 3,
            false,
            arcPaint,
          );
        }
        break;

      default:
        _renderHpText(canvas, brick, rect);
    }
  }

  static void _drawPlusSign(Canvas canvas, Offset center, double size, Color color) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(center.dx - size, center.dy), Offset(center.dx + size, center.dy), p);
    canvas.drawLine(Offset(center.dx, center.dy - size), Offset(center.dx, center.dy + size), p);
  }

  static void _renderHpText(Canvas canvas, Brick brick, Rect rect, {double scale = 1.0}) {
    final hpStr = brick.hp > 999 ? '${(brick.hp / 1000).toStringAsFixed(1)}k' : '${brick.hp}';
    final fontSize = (rect.height * 0.52 * scale).clamp(9.0, 16.0);

    final textSpan = TextSpan(
      text: hpStr,
      style: TextStyle(
        color: Colors.white,
        fontSize: fontSize,
        fontWeight: FontWeight.w900,
        fontFamily: 'Roboto',
        shadows: const [
          Shadow(color: Colors.black87, blurRadius: 4, offset: Offset(0, 1)),
        ],
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    final center = rect.center;
    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2),
    );
  }
}
