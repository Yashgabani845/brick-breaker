import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/game_colors.dart';
import '../models/brick.dart';

/// Ultra-Clean 3D Beveled Brick Renderer matching modern casual arcade physics standard
class Brick3DRenderer {
  static final Paint _fillPaint = Paint()..style = PaintingStyle.fill;
  static final Paint _strokePaint = Paint()..style = PaintingStyle.stroke;
  static final Paint _crackPaint = Paint()
    ..color = Colors.black.withOpacity(0.70)
    ..strokeWidth = 1.4
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
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // 1. RECTANGULAR 3D BEVELED BRICK
  // ═════════════════════════════════════════════════════════════════════════════
  static void _render3DRectangle(Canvas canvas, Brick brick, Rect rect, double depth) {
    const bevel = 4.0;
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(5.0));

    // 1. Bottom/Right 3D Drop Shadow
    final shadowRRect = RRect.fromRectAndRadius(
      rect.shift(const Offset(1.5, 2.5)),
      const Radius.circular(5.0),
    );
    _fillPaint.shader = null;
    _fillPaint.color = const Color(0x77000000);
    canvas.drawRRect(shadowRRect, _fillPaint);

    // 2. Base Tile Color Fill
    final gradientColors = _getBrickGradient(brick);
    _fillPaint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: gradientColors,
    ).createShader(rect);
    canvas.drawRRect(rrect, _fillPaint);

    // 3. Crisp 3D Chamfered Bevel Borders
    // Top Bevel (Bright Highlight)
    final topBevel = Path()
      ..moveTo(rect.left, rect.top)
      ..lineTo(rect.right, rect.top)
      ..lineTo(rect.right - bevel, rect.top + bevel)
      ..lineTo(rect.left + bevel, rect.top + bevel)
      ..close();
    _fillPaint.shader = null;
    _fillPaint.color = Colors.white.withOpacity(0.38);
    canvas.drawPath(topBevel, _fillPaint);

    // Left Bevel (Soft Highlight)
    final leftBevel = Path()
      ..moveTo(rect.left, rect.top)
      ..lineTo(rect.left + bevel, rect.top + bevel)
      ..lineTo(rect.left + bevel, rect.bottom - bevel)
      ..lineTo(rect.left, rect.bottom)
      ..close();
    _fillPaint.color = Colors.white.withOpacity(0.20);
    canvas.drawPath(leftBevel, _fillPaint);

    // Right Bevel (Soft Shadow)
    final rightBevel = Path()
      ..moveTo(rect.right, rect.top)
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.right - bevel, rect.bottom - bevel)
      ..lineTo(rect.right - bevel, rect.top + bevel)
      ..close();
    _fillPaint.color = Colors.black.withOpacity(0.22);
    canvas.drawPath(rightBevel, _fillPaint);

    // Bottom Bevel (Deep Shadow)
    final bottomBevel = Path()
      ..moveTo(rect.left, rect.bottom)
      ..lineTo(rect.left + bevel, rect.bottom - bevel)
      ..lineTo(rect.right - bevel, rect.bottom - bevel)
      ..lineTo(rect.right, rect.bottom)
      ..close();
    _fillPaint.color = Colors.black.withOpacity(0.40);
    canvas.drawPath(bottomBevel, _fillPaint);

    // 4. Raised Inner Face
    final innerRect = rect.deflate(bevel);
    final innerRRect = RRect.fromRectAndRadius(innerRect, const Radius.circular(3.0));
    _fillPaint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        gradientColors.first,
        gradientColors.last,
      ],
    ).createShader(innerRect);
    canvas.drawRRect(innerRRect, _fillPaint);

    // 5. Specular Gloss Sheen on Inner Face (Top 45%)
    final sheenPath = Path()
      ..moveTo(innerRect.left, innerRect.top)
      ..lineTo(innerRect.right, innerRect.top)
      ..lineTo(innerRect.right, innerRect.top + innerRect.height * 0.45)
      ..lineTo(innerRect.left, innerRect.top + innerRect.height * 0.45)
      ..close();
    _fillPaint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.white.withOpacity(0.35),
        Colors.white.withOpacity(0.0),
      ],
    ).createShader(innerRect);
    canvas.drawPath(sheenPath, _fillPaint);

    // 6. Outer Border Outline
    _strokePaint.shader = null;
    _strokePaint.color = Colors.black.withOpacity(0.35);
    _strokePaint.strokeWidth = 1.0;
    canvas.drawRRect(rrect, _strokePaint);

    if (brick.hitFlashTimer > 0) {
      final hitGlowPaint = Paint()
        ..color = const Color(0xFF00E5FF).withOpacity((brick.hitFlashTimer * 6.0).clamp(0.0, 1.0))
        ..strokeWidth = 2.8
        ..style = PaintingStyle.stroke;
      canvas.drawRRect(rrect.inflate(1.2), hitGlowPaint);
    }

    // 8. Damage Cracks
    if (brick.crackRatio > 0.15) {
      _renderCracks(canvas, innerRect, brick.crackRatio);
    }

    // 9. HP Label or Entity Glyph
    if (brick.type.isSpecialTrigger || brick.type.isCollectible) {
      _renderSpecialGlyph(canvas, brick, innerRect);
    } else {
      _renderHpText(canvas, brick, innerRect);
    }
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // 2. 45-DEGREE 3D BEVELED WEDGE
  // ═════════════════════════════════════════════════════════════════════════════
  static void _render3DWedge(Canvas canvas, Brick brick, Rect rect, double depth) {
    late Offset vRightAngle, vAcute1, vAcute2;

    switch (brick.type) {
      case BrickType.wedgeTopLeft:
        vRightAngle = rect.topLeft;
        vAcute1 = rect.topRight;
        vAcute2 = rect.bottomLeft;
        break;
      case BrickType.wedgeTopRight:
        vRightAngle = rect.topRight;
        vAcute1 = rect.topLeft;
        vAcute2 = rect.bottomRight;
        break;
      case BrickType.wedgeBottomLeft:
        vRightAngle = rect.bottomLeft;
        vAcute1 = rect.topLeft;
        vAcute2 = rect.bottomRight;
        break;
      case BrickType.wedgeBottomRight:
        vRightAngle = rect.bottomRight;
        vAcute1 = rect.topRight;
        vAcute2 = rect.bottomLeft;
        break;
      default:
        return;
    }

    final path = Path()
      ..moveTo(vRightAngle.dx, vRightAngle.dy)
      ..lineTo(vAcute1.dx, vAcute1.dy)
      ..lineTo(vAcute2.dx, vAcute2.dy)
      ..close();

    // 1. Drop Shadow
    final shadowPath = path.shift(const Offset(1.5, 2.5));
    _fillPaint.shader = null;
    _fillPaint.color = const Color(0x77000000);
    canvas.drawPath(shadowPath, _fillPaint);

    // 2. Base Gradient Fill
    final gradientColors = _getBrickGradient(brick);
    _fillPaint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: gradientColors,
    ).createShader(rect);
    canvas.drawPath(path, _fillPaint);

    // 3. Wedge Highlight Edge (Hypotenuse Deflection Glaze)
    final hypoPaint = Paint()
      ..color = Colors.white.withOpacity(0.65)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(vAcute1, vAcute2, hypoPaint);

    // 4. Wedge Top Glaze
    final glazePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withOpacity(0.35),
          Colors.white.withOpacity(0.0),
        ],
      ).createShader(rect)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, glazePaint);

    // 5. Wedge Border Outline
    _strokePaint.shader = null;
    _strokePaint.color = Colors.black.withOpacity(0.4);
    _strokePaint.strokeWidth = 1.0;
    canvas.drawPath(path, _strokePaint);

    if (brick.hitFlashTimer > 0) {
      final hitGlowPaint = Paint()
        ..color = const Color(0xFF00E5FF).withOpacity((brick.hitFlashTimer * 6.0).clamp(0.0, 1.0))
        ..strokeWidth = 2.8
        ..style = PaintingStyle.stroke;
      canvas.drawPath(path, hitGlowPaint);
    }

    // 7. Wedge HP Text
    _renderHpText(canvas, brick, rect, isWedge: true);
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // 3. COLOR GRADIENTS MATCHING CASUAL ARCADE TIERS
  // ═════════════════════════════════════════════════════════════════════════════
  static List<Color> _getBrickGradient(Brick brick) {
    if (brick.type == BrickType.armoredBrick) {
      return const [Color(0xFF90A4AE), Color(0xFF546E7A)];
    }
    if (brick.type == BrickType.titaniumShield) {
      return const [Color(0xFF37474F), Color(0xFF212121)];
    }

    final hp = brick.hp;
    if (hp > 250) {
      return const [Color(0xFFFF1744), Color(0xFFAD1457)]; // Crimson / Pink Rose
    } else if (hp > 150) {
      return const [Color(0xFFAB47BC), Color(0xFF6A1B9A)]; // Royal Purple / Violet (200, 196)
    } else if (hp > 100) {
      return const [Color(0xFFE53935), Color(0xFFC62828)]; // Ruby Red (130, 150)
    } else if (hp > 50) {
      return const [Color(0xFFFFB300), Color(0xFFF57F17)]; // Warm Amber / Golden Yellow (100, 90, 88)
    } else if (hp > 25) {
      return const [Color(0xFF4CAF50), Color(0xFF2E7D32)]; // Lime Emerald Green (50, 48, 72, 74)
    } else {
      return const [Color(0xFF29B6F6), Color(0xFF0288D1)]; // Sky Blue / Azure Cyan (35, 23, 2)
    }
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // 4. CRACKS, SPECIAL GLYPHS & ICONS
  // ═════════════════════════════════════════════════════════════════════════════
  static void _renderCracks(Canvas canvas, Rect rect, double ratio) {
    final cx = rect.center.dx;
    final cy = rect.center.dy;
    final crackPath = Path();

    crackPath.moveTo(cx, cy);
    crackPath.lineTo(cx - rect.width * 0.32 * ratio, cy - rect.height * 0.36 * ratio);
    crackPath.moveTo(cx, cy);
    crackPath.lineTo(cx + rect.width * 0.36 * ratio, cy + rect.height * 0.32 * ratio);

    if (ratio > 0.45) {
      crackPath.moveTo(cx, cy);
      crackPath.lineTo(cx + rect.width * 0.28 * ratio, cy - rect.height * 0.32 * ratio);
      crackPath.moveTo(cx, cy);
      crackPath.lineTo(cx - rect.width * 0.32 * ratio, cy + rect.height * 0.36 * ratio);
    }

    canvas.drawPath(crackPath, _crackPaint);
  }

  static void _renderSpecialGlyph(Canvas canvas, Brick brick, Rect rect) {
    final center = rect.center;

    switch (brick.type) {
      case BrickType.permanentAdder:
      case BrickType.turnBallAdder:
        // Glowing circular orb pickup with "+5" or "+"
        final orbBg = Paint()
          ..color = const Color(0xFF0D162B)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(center, rect.height * 0.40, orbBg);

        final ringPaint = Paint()
          ..color = const Color(0xFF00E676)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2;
        canvas.drawCircle(center, rect.height * 0.38, ringPaint);

        _drawPlusSign(canvas, center, rect.height * 0.18, Colors.white, strokeWidth: 2.4);
        break;

      case BrickType.clusterBomb:
      case BrickType.chainDynamite:
        // Spherical black bomb with burning fuse
        final bombPaint = Paint()
          ..color = const Color(0xFF212121)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(center, rect.height * 0.34, bombPaint);

        // Bomb highlight
        final bombShine = Paint()
          ..color = Colors.white.withOpacity(0.5)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(center.dx - rect.height * 0.12, center.dy - rect.height * 0.12), rect.height * 0.10, bombShine);

        // Fuse spark
        final sparkPaint = Paint()
          ..color = const Color(0xFFFF9100)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(center.dx + rect.height * 0.22, center.dy - rect.height * 0.24), 3.0, sparkPaint);
        break;

      case BrickType.horizontalLaser:
        final laserPaint = Paint()
          ..color = Colors.white
          ..strokeWidth = 2.6
          ..style = PaintingStyle.stroke;
        canvas.drawLine(Offset(rect.left + 4, center.dy), Offset(rect.right - 4, center.dy), laserPaint);
        _drawArrowHead(canvas, Offset(rect.left + 5, center.dy), -math.pi, 4.5, Colors.white);
        _drawArrowHead(canvas, Offset(rect.right - 5, center.dy), 0, 4.5, Colors.white);
        break;

      case BrickType.verticalLaser:
        final laserPaint = Paint()
          ..color = Colors.white
          ..strokeWidth = 2.6
          ..style = PaintingStyle.stroke;
        canvas.drawLine(Offset(center.dx, rect.top + 4), Offset(center.dx, rect.bottom - 4), laserPaint);
        _drawArrowHead(canvas, Offset(center.dx, rect.top + 5), -math.pi / 2, 4.5, Colors.white);
        _drawArrowHead(canvas, Offset(center.dx, rect.bottom - 5), math.pi / 2, 4.5, Colors.white);
        break;

      case BrickType.crossLaser:
      case BrickType.diagonalLaser:
        final laserPaint = Paint()
          ..color = Colors.white
          ..strokeWidth = 2.4
          ..style = PaintingStyle.stroke;
        canvas.drawLine(Offset(rect.left + 4, center.dy), Offset(rect.right - 4, center.dy), laserPaint);
        canvas.drawLine(Offset(center.dx, rect.top + 4), Offset(center.dx, rect.bottom - 4), laserPaint);
        break;

      case BrickType.armoredBrick:
        // Metallic X-embossed rivet plate
        final xPaint = Paint()
          ..color = Colors.black.withOpacity(0.35)
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke;
        canvas.drawLine(rect.topLeft + const Offset(4, 4), rect.bottomRight - const Offset(4, 4), xPaint);
        canvas.drawLine(rect.topRight + const Offset(-4, 4), rect.bottomLeft - const Offset(-4, 4), xPaint);
        _renderHpText(canvas, brick, rect);
        break;

      default:
        _renderHpText(canvas, brick, rect);
    }
  }

  static void _drawArrowHead(Canvas canvas, Offset tip, double angle, double size, Color color) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(
        tip.dx + size * math.cos(angle + math.pi * 0.8),
        tip.dy + size * math.sin(angle + math.pi * 0.8),
      )
      ..lineTo(
        tip.dx + size * math.cos(angle - math.pi * 0.8),
        tip.dy + size * math.sin(angle - math.pi * 0.8),
      )
      ..close();
    canvas.drawPath(path, p);
  }

  static void _drawPlusSign(Canvas canvas, Offset center, double size, Color color, {double strokeWidth = 2.2}) {
    final p = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(center.dx - size, center.dy), Offset(center.dx + size, center.dy), p);
    canvas.drawLine(Offset(center.dx, center.dy - size), Offset(center.dx, center.dy + size), p);
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // 5. CRISP, HIGH-CONTRAST BOLD HP TYPOGRAPHY
  // ═════════════════════════════════════════════════════════════════════════════
  static void _renderHpText(
    Canvas canvas,
    Brick brick,
    Rect rect, {
    bool isWedge = false,
  }) {
    if (brick.hp <= 0) return;

    final String hpStr;
    final int hp = brick.hp;
    if (hp >= 1000000) {
      hpStr = '${(hp / 1000000).toStringAsFixed(1)}M';
    } else if (hp >= 10000) {
      hpStr = '${(hp / 1000).round()}k';
    } else if (hp >= 1000) {
      hpStr = '${(hp / 1000).toStringAsFixed(1)}k';
    } else {
      hpStr = '$hp';
    }

    final double maxAllowedWidth = isWedge ? rect.width * 0.55 : rect.width * 0.82;
    final double maxAllowedHeight = isWedge ? rect.height * 0.55 : rect.height * 0.78;

    double fontSize = (rect.height * 0.58).clamp(8.0, 16.5);
    if (isWedge) fontSize *= 0.80;

    // Dark contrasting color matching the reference
    final textColor = _getContrastingTextColor(brick);

    TextPainter painter = _buildPainter(hpStr, fontSize, textColor);
    if (painter.width > maxAllowedWidth || painter.height > maxAllowedHeight) {
      final double widthScale = maxAllowedWidth / painter.width;
      final double heightScale = maxAllowedHeight / painter.height;
      final double scaleFactor = math.min(widthScale, heightScale);
      fontSize = (fontSize * scaleFactor).clamp(6.0, 16.5);
      painter = _buildPainter(hpStr, fontSize, textColor);
    }

    Offset center = rect.center;
    if (isWedge) {
      switch (brick.type) {
        case BrickType.wedgeTopLeft:
          center = Offset(rect.left + rect.width * 0.38, rect.top + rect.height * 0.38);
          break;
        case BrickType.wedgeTopRight:
          center = Offset(rect.left + rect.width * 0.62, rect.top + rect.height * 0.38);
          break;
        case BrickType.wedgeBottomLeft:
          center = Offset(rect.left + rect.width * 0.38, rect.top + rect.height * 0.62);
          break;
        case BrickType.wedgeBottomRight:
          center = Offset(rect.left + rect.width * 0.62, rect.top + rect.height * 0.62);
          break;
        default:
          break;
      }
    }

    final double x = (center.dx - painter.width / 2).clamp(rect.left + 0.5, rect.right - painter.width - 0.5);
    final double y = (center.dy - painter.height / 2).clamp(rect.top + 0.5, rect.bottom - painter.height - 0.5);

    painter.paint(canvas, Offset(x, y));
  }

  static Color _getContrastingTextColor(Brick brick) {
    final hp = brick.hp;
    if (hp > 250) {
      return const Color(0xFF2B0010); // Deep dark crimson
    } else if (hp > 150) {
      return const Color(0xFF210033); // Deep dark violet
    } else if (hp > 100) {
      return const Color(0xFF330505); // Deep dark red
    } else if (hp > 50) {
      return const Color(0xFF2A1500); // Deep dark amber brown
    } else if (hp > 25) {
      return const Color(0xFF092906); // Deep dark forest green
    } else {
      return const Color(0xFF02202E); // Deep dark navy cyan
    }
  }

  static TextPainter _buildPainter(String text, double fontSize, Color textColor) {
    return TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: textColor,
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          fontFamily: 'Roboto',
          letterSpacing: -0.3,
          shadows: [
            Shadow(
              color: Colors.white.withOpacity(0.35),
              blurRadius: 1,
              offset: const Offset(0, 1),
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
  }
}
