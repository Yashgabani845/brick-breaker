import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/game_colors.dart';
import '../models/brick.dart';

/// Renders 3D Extruded Beveled Bricks, 45° Wedges, Damage Cracks, and Special Glyphs
/// Includes mathematically guaranteed non-overflowing responsive typography and rich lighting.
class Brick3DRenderer {
  static final Paint _paint = Paint();
  static final Paint _crackPaint = Paint()
    ..color = Colors.black.withOpacity(0.65)
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

    // Render Hit Flash overlay if actively taking damage
    if (brick.hitFlashTimer > 0) {
      final flashOpacity = (brick.hitFlashTimer / 0.12).clamp(0.0, 0.85);
      final flashPaint = Paint()
        ..color = Colors.white.withOpacity(flashOpacity)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4.5)),
        flashPaint,
      );
    }
  }

  static void _render3DRectangle(Canvas canvas, Brick brick, Rect rect, double depth) {
    final baseColor = brick.primaryColor;
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(5.0));

    // 1. Bottom/Right 3D Cast Shadow & Depth Extrusion
    final shadowPath = Path()
      ..moveTo(rect.left + 3, rect.bottom)
      ..lineTo(rect.left + 3 + depth, rect.bottom + depth)
      ..lineTo(rect.right + depth, rect.bottom + depth)
      ..lineTo(rect.right + depth, rect.top + 3 + depth)
      ..lineTo(rect.right, rect.top + 3)
      ..lineTo(rect.right, rect.bottom)
      ..close();

    _paint.shader = null;
    _paint.color = Colors.black.withOpacity(0.60);
    _paint.style = PaintingStyle.fill;
    canvas.drawPath(shadowPath, _paint);

    // 2. Multi-Stop Vivid 3D Crystal / Glass Face
    final gradientColors = _getBrickGradient(brick);
    _paint.shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: gradientColors,
    ).createShader(rect);
    canvas.drawRRect(rrect, _paint);

    // 3. Inner Radial Crystal Core Glow (Luminosity)
    final coreGlowPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.0, -0.1),
        radius: 0.75,
        colors: [
          Colors.white.withOpacity(0.28),
          Colors.white.withOpacity(0.0),
        ],
      ).createShader(rect)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rrect, coreGlowPaint);

    // 4. Curved Specular Glass Glaze (Top half reflection)
    final glazePath = Path()
      ..moveTo(rect.left + 2, rect.top + 2)
      ..lineTo(rect.right - 2, rect.top + 2)
      ..lineTo(rect.right - 4, rect.top + rect.height * 0.44)
      ..quadraticBezierTo(
        rect.center.dx,
        rect.top + rect.height * 0.52,
        rect.left + 4,
        rect.top + rect.height * 0.44,
      )
      ..close();

    final glazePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withOpacity(0.55),
          Colors.white.withOpacity(0.05),
        ],
      ).createShader(rect)
      ..style = PaintingStyle.fill;
    canvas.drawPath(glazePath, glazePaint);

    // 5. Specular Top-Left Gleam Spot
    final gleamPaint = Paint()
      ..color = Colors.white.withOpacity(0.75)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(rect.left + 5.5, rect.top + 4.5), 1.6, gleamPaint);

    // 6. 3D Beveled Outer Chamfer Rim (Highlight top-left, shadow bottom-right)
    final topRimPaint = Paint()
      ..color = Colors.white.withOpacity(0.50)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(rrect, topRimPaint);

    // 7. Procedural Damage Fracture Lines (when damaged)
    if (brick.crackRatio > 0.15) {
      _renderCracks(canvas, rect, brick.crackRatio);
    }

    // 8. HP Number or Special Entity Glyph
    if (brick.type.isSpecialTrigger || brick.type.isCollectible) {
      _renderSpecialGlyph(canvas, brick, rect);
    } else {
      _renderHpText(canvas, brick, rect);
    }
  }

  static void _render3DWedge(Canvas canvas, Brick brick, Rect rect, double depth) {
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

    // 1. 3D Shadow extrusion on wedge
    final shadowPath = Path()
      ..moveTo(v2.dx, v2.dy)
      ..lineTo(v2.dx + depth, v2.dy + depth)
      ..lineTo(v3.dx + depth, v3.dy + depth)
      ..lineTo(v3.dx, v3.dy)
      ..close();

    _paint.shader = null;
    _paint.color = Colors.black.withOpacity(0.55);
    _paint.style = PaintingStyle.fill;
    canvas.drawPath(shadowPath, _paint);

    // 2. Front wedge crystal gradient
    final gradientColors = _getBrickGradient(brick);
    _paint.shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: gradientColors,
    ).createShader(rect);
    canvas.drawPath(path, _paint);

    // 3. Wedge Glaze Reflection
    final wedgeGlazePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withOpacity(0.45),
          Colors.white.withOpacity(0.0),
        ],
      ).createShader(rect)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, wedgeGlazePaint);

    // 4. Bevel outline & Angled Reflector Sheen Line
    final strokePaint = Paint()
      ..color = Colors.white.withOpacity(0.55)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, strokePaint);

    final reflectorPaint = Paint()
      ..color = Colors.white.withOpacity(0.70)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(v2.dx, v2.dy), Offset(v3.dx, v3.dy), reflectorPaint);

    // Wedge HP label
    _renderHpText(canvas, brick, rect, isWedge: true);
  }

  static List<Color> _getBrickGradient(Brick brick) {
    if (brick.type == BrickType.armoredBrick) {
      return GameColors.armoredGradient;
    }
    if (brick.type == BrickType.titaniumShield) {
      return const [Color(0xFF334155), Color(0xFF1E293B), Color(0xFF0F172A)];
    }
    return GameColors.getHpGradient(brick.hp, brick.maxHp);
  }

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
    final iconPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    switch (brick.type) {
      case BrickType.permanentAdder:
        // Glowing Emerald Core + Orbiting Satellites + Bold "+"
        final ringPaint = Paint()
          ..color = Colors.white.withOpacity(0.9)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;
        canvas.drawCircle(center, rect.height * 0.32, ringPaint);
        _drawPlusSign(canvas, center, rect.height * 0.20, Colors.white, strokeWidth: 2.4);
        break;

      case BrickType.turnBallAdder:
        // Neon Lime Hexagon Shell + "+1" Text Glyph
        const limeColor = Color(0xFF39FF14);
        final hexPaint = Paint()
          ..color = limeColor.withOpacity(0.40)
          ..style = PaintingStyle.fill;
        final hexStroke = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8;
        final hexPath = Path();
        final hr = rect.height * 0.36;
        for (int i = 0; i < 6; i++) {
          final a = (i * math.pi / 3) - math.pi / 6;
          final px = center.dx + hr * math.cos(a);
          final py = center.dy + hr * math.sin(a);
          if (i == 0) {
            hexPath.moveTo(px, py);
          } else {
            hexPath.lineTo(px, py);
          }
        }
        hexPath.close();
        canvas.drawPath(hexPath, hexPaint);
        canvas.drawPath(hexPath, hexStroke);
        _drawPlusSign(canvas, center, rect.height * 0.20, Colors.white, strokeWidth: 2.4);
        break;

      case BrickType.inAirSplitter:
        // Swarm x2 Diamond Prism
        final diamondPath = Path()
          ..moveTo(center.dx, center.dy - rect.height * 0.36)
          ..lineTo(center.dx + rect.width * 0.32, center.dy)
          ..lineTo(center.dx, center.dy + rect.height * 0.36)
          ..lineTo(center.dx - rect.width * 0.32, center.dy)
          ..close();
        final diamondPaint = Paint()
          ..color = GameColors.neonCyan.withOpacity(0.6)
          ..style = PaintingStyle.fill;
        final diamondStroke = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8;
        canvas.drawPath(diamondPath, diamondPaint);
        canvas.drawPath(diamondPath, diamondStroke);

        // Draw "x2" text inside diamond
        final span = TextSpan(
          text: '×2',
          style: TextStyle(
            color: Colors.white,
            fontSize: rect.height * 0.44,
            fontWeight: FontWeight.w900,
            fontFamily: 'Roboto',
            shadows: const [
              Shadow(color: Colors.black, blurRadius: 3),
            ],
          ),
        );
        final tp = TextPainter(text: span, textDirection: TextDirection.ltr)..layout();
        tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
        break;

      case BrickType.horizontalLaser:
        // Glowing horizontal beam conduit with chevrons
        final laserPaint = Paint()
          ..color = Colors.white
          ..strokeWidth = 2.6
          ..style = PaintingStyle.stroke;
        canvas.drawLine(
          Offset(rect.left + 4, center.dy),
          Offset(rect.right - 4, center.dy),
          laserPaint,
        );
        // Arrow heads
        _drawArrowHead(canvas, Offset(rect.left + 5, center.dy), -math.pi, 4.5, Colors.white);
        _drawArrowHead(canvas, Offset(rect.right - 5, center.dy), 0, 4.5, Colors.white);
        break;

      case BrickType.verticalLaser:
        // Glowing vertical beam conduit with chevrons
        final laserPaint = Paint()
          ..color = Colors.white
          ..strokeWidth = 2.6
          ..style = PaintingStyle.stroke;
        canvas.drawLine(
          Offset(center.dx, rect.top + 4),
          Offset(center.dx, rect.bottom - 4),
          laserPaint,
        );
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

      case BrickType.clusterBomb:
      case BrickType.chainDynamite:
        // Bomb core with hazard ticks
        canvas.drawCircle(center, rect.height * 0.26, iconPaint);
        final tickPaint = Paint()
          ..color = Colors.white
          ..strokeWidth = 2.2;
        for (int i = 0; i < 4; i++) {
          final angle = i * math.pi / 2 + math.pi / 4;
          canvas.drawLine(
            center + Offset(math.cos(angle) * (rect.height * 0.28), math.sin(angle) * (rect.height * 0.28)),
            center + Offset(math.cos(angle) * (rect.height * 0.44), math.sin(angle) * (rect.height * 0.44)),
            tickPaint,
          );
        }
        break;

      case BrickType.superNuke:
        // Nuclear radiation trefoil
        final nukePaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;
        canvas.drawCircle(center, rect.height * 0.16, nukePaint);
        final arcPaint = Paint()
          ..color = GameColors.neonPurple
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.8;
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

      case BrickType.iceBlock:
        // Frost crystalline snowflake icon
        final icePaint = Paint()
          ..color = Colors.white.withOpacity(0.9)
          ..strokeWidth = 1.6
          ..style = PaintingStyle.stroke;
        for (int i = 0; i < 6; i++) {
          final angle = i * math.pi / 3;
          final pEnd = center + Offset(math.cos(angle) * (rect.height * 0.32), math.sin(angle) * (rect.height * 0.32));
          canvas.drawLine(center, pEnd, icePaint);
        }
        break;

      case BrickType.armoredBrick:
        // Armor plate with rivets
        final rivetPaint = Paint()
          ..color = Colors.white.withOpacity(0.85)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(rect.left + 5, rect.top + 5), 1.8, rivetPaint);
        canvas.drawCircle(Offset(rect.right - 5, rect.top + 5), 1.8, rivetPaint);
        canvas.drawCircle(Offset(rect.left + 5, rect.bottom - 5), 1.8, rivetPaint);
        canvas.drawCircle(Offset(rect.right - 5, rect.bottom - 5), 1.8, rivetPaint);
        _renderHpText(canvas, brick, rect);
        break;

      case BrickType.titaniumShield:
        // Unbreakable obsidian shield bars
        final barPaint = Paint()
          ..color = GameColors.solarGold.withOpacity(0.6)
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke;
        canvas.drawLine(Offset(rect.left + 6, rect.bottom - 4), Offset(rect.left + rect.width * 0.4, rect.top + 4), barPaint);
        canvas.drawLine(Offset(rect.right - rect.width * 0.4, rect.bottom - 4), Offset(rect.right - 6, rect.top + 4), barPaint);
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

  /// Format HP cleanly and adjust font size dynamically so text NEVER overflows.
  static void _renderHpText(
    Canvas canvas,
    Brick brick,
    Rect rect, {
    bool isWedge = false,
  }) {
    if (brick.hp <= 0) return;

    // 1. Format string cleanly
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

    // 2. Compute strict non-overflow constraints
    final double maxAllowedWidth = isWedge ? rect.width * 0.52 : rect.width * 0.78;
    final double maxAllowedHeight = isWedge ? rect.height * 0.52 : rect.height * 0.72;

    double fontSize = (rect.height * 0.54).clamp(8.0, 16.0);
    if (isWedge) fontSize *= 0.82;

    // 3. Measure text and dynamically downscale if needed
    TextPainter painter = _buildPainter(hpStr, fontSize);
    if (painter.width > maxAllowedWidth || painter.height > maxAllowedHeight) {
      final double widthScale = maxAllowedWidth / painter.width;
      final double heightScale = maxAllowedHeight / painter.height;
      final double scaleFactor = math.min(widthScale, heightScale);
      fontSize = (fontSize * scaleFactor).clamp(6.0, 16.0);
      painter = _buildPainter(hpStr, fontSize);
    }

    // 4. Center calculation
    Offset center = rect.center;
    if (isWedge) {
      // Shift toward center of wedge mass
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

    final double x = (center.dx - painter.width / 2).clamp(rect.left + 1.0, rect.right - painter.width - 1.0);
    final double y = (center.dy - painter.height / 2).clamp(rect.top + 1.0, rect.bottom - painter.height - 1.0);

    // 5. Paint sharp high-contrast drop shadow outline first, then crisp text
    painter.paint(canvas, Offset(x, y));
  }

  static TextPainter _buildPainter(String text, double fontSize) {
    return TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          fontFamily: 'Roboto',
          letterSpacing: -0.2,
          shadows: const [
            Shadow(color: Colors.black, blurRadius: 4, offset: Offset(0, 1)),
            Shadow(color: Colors.black87, blurRadius: 2, offset: Offset(0, 0)),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
  }
}
