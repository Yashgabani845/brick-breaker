import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/game_colors.dart';
import '../../core/constants/game_constants.dart';
import '../../core/math/vector2.dart';
import '../models/ball.dart';
import '../models/brick.dart';
import '../models/particle.dart';
import '../physics/trajectory_predictor.dart';
import 'brick_3d_renderer.dart';

/// Master 3D & Particle CustomPainter for Bricks Breaker 3D
/// Renders high-tech danger laser barrier, crisp grid, glowing ball swarms, and launch platform.
class GamePainter extends CustomPainter {
  final List<Brick> bricks;
  final List<Ball> balls;
  final List<TrajectoryPoint>? trajectory;
  final Vector2 launcherPosition;
  final int activeBallCount;
  final int permanentBallCount;
  final bool isAiming;
  final int dangerRow;
  final int columns;
  final int rows;
  final double animationProgress; // For pulsating danger line and glowing dots
  final Color? themeColor;

  GamePainter({
    required this.bricks,
    required this.balls,
    required this.trajectory,
    required this.launcherPosition,
    required this.activeBallCount,
    required this.permanentBallCount,
    required this.isAiming,
    required this.dangerRow,
    required this.columns,
    required this.rows,
    required this.animationProgress,
    this.themeColor,
  });

  // Cached background paint (recreated only when theme or size changes)
  static Paint? _cachedBgPaint;
  static Color? _cachedThemeColor;
  static Size? _cachedBgSize;

  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = size.width / columns;
    final cellHeight = (launcherPosition.y * 0.78) / rows;

    // 1. Render Deep OLED Cosmic Background & Grid
    _renderBackground(canvas, size, cellWidth, cellHeight);

    // 2. Render Floor / Recovery Baseline
    _renderFloorBaseline(canvas, size);

    // 3. Render High-Tech Laser Danger Barrier (Threshold row)
    _renderDangerLine(canvas, size, cellHeight);

    // 4. Render 3D Extruded Bricks & Wedges
    _renderBricks(canvas, cellWidth, cellHeight);

    // 5. Render Aim Trajectory (if player is aiming)
    if (isAiming && trajectory != null && trajectory!.isNotEmpty) {
      _renderTrajectory(canvas, trajectory!);
    }

    // 6. Render Glowing Ball Swarms & Additive Trails
    _renderBalls(canvas);

    // 7. Render Dynamic Particle Systems (Shards, Shockwaves, Lasers, Popups)
    _renderParticles(canvas);

    // 8. Render Launcher Base & Power Indicator
    _renderLauncher(canvas, size);
  }

  void _renderBackground(Canvas canvas, Size size, double cw, double ch) {
    final theme = themeColor ?? GameColors.neonCyan;

    // Cache background paint — recompute only when size or theme changes
    if (_cachedBgPaint == null || _cachedThemeColor != theme || _cachedBgSize != size) {
      _cachedThemeColor = theme;
      _cachedBgSize = size;
      _cachedBgPaint = Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.0, -0.35),
          radius: 1.3,
          colors: [
            Color.lerp(GameColors.spaceDark, theme, 0.15)!,
            GameColors.oledDark,
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    }
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), _cachedBgPaint!);

    // Subtle Sci-Fi Grid Lines within playfield
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.025)
      ..strokeWidth = 1.0;

    for (int c = 0; c <= columns; c++) {
      canvas.drawLine(Offset(c * cw, 0), Offset(c * cw, launcherPosition.y), gridPaint);
    }
    for (int r = 0; r <= rows; r++) {
      final y = r * ch;
      if (y <= launcherPosition.y) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
      }
    }
  }

  void _renderFloorBaseline(Canvas canvas, Size size) {
    final floorY = launcherPosition.y + 12.0;

    // Floor Guideline Glow
    final floorGlow = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          GameColors.neonCyan.withOpacity(0.35),
          GameColors.neonCyan.withOpacity(0.35),
          Colors.transparent,
        ],
        stops: const [0.0, 0.2, 0.8, 1.0],
      ).createShader(Rect.fromLTWH(0, floorY - 1, size.width, 2))
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, floorY), Offset(size.width, floorY), floorGlow);
  }

  void _renderDangerLine(Canvas canvas, Size size, double ch) {
    final dangerY = dangerRow * ch;
    final pulse = 0.5 + 0.5 * math.sin(animationProgress * math.pi * 2);

    // 1. Ambient Warning Hazard Area Glow
    final alertGradient = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          GameColors.crimsonDanger.withOpacity(0.0),
          GameColors.crimsonDanger.withOpacity(0.12 * pulse),
        ],
      ).createShader(Rect.fromLTWH(0, dangerY - 24, size.width, 24));
    canvas.drawRect(Rect.fromLTWH(0, dangerY - 24, size.width, 24), alertGradient);

    // 2. High-Tech Laser Conduit Line (Glowing center + outer bloom)
    final bloomPaint = Paint()
      ..color = GameColors.crimsonDanger.withOpacity(0.4 * pulse)
      ..strokeWidth = 6.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0)
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, dangerY), Offset(size.width, dangerY), bloomPaint);

    final coreLaserPaint = Paint()
      ..color = Color.lerp(GameColors.crimsonDanger, Colors.white, 0.4)!
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, dangerY), Offset(size.width, dangerY), coreLaserPaint);

    // 3. Moving Diagonal Caution Hazard Stripes
    final stripePaint = Paint()
      ..color = GameColors.electricAmber.withOpacity(0.75 * pulse)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final offsetProgress = (animationProgress * 20.0);
    for (double x = -20.0 + offsetProgress; x < size.width + 20.0; x += 18.0) {
      canvas.drawLine(
        Offset(x, dangerY + 4),
        Offset(x + 8, dangerY - 4),
        stripePaint,
      );
    }

    // 4. Sleek Warning Beacon (Right Edge, minimal icon only)
    final beaconPaint = Paint()
      ..color = GameColors.crimsonDanger.withOpacity(pulse)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width - 16, dangerY), 4.0, beaconPaint);
    final ringPaint = Paint()
      ..color = Colors.white.withOpacity(pulse)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(Offset(size.width - 16, dangerY), 7.0, ringPaint);
  }

  void _renderBricks(Canvas canvas, double cw, double ch) {
    const brickDepth = 3.5;
    const padding = 1.5;

    for (int i = 0; i < bricks.length; i++) {
      final b = bricks[i];
      if (b.isDestroyed) continue;

      final rect = Rect.fromLTWH(
        b.gridX * cw + padding,
        b.gridY * ch + padding,
        cw - padding * 2,
        ch - padding * 2,
      );

      Brick3DRenderer.renderBrick(
        canvas: canvas,
        brick: b,
        rect: rect,
        depth: brickDepth,
      );
    }
  }

  void _renderTrajectory(Canvas canvas, List<TrajectoryPoint> points) {
    if (points.isEmpty) return;

    final dotPaint = Paint()
      ..color = GameColors.neonCyan
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      final alpha = (1.0 - (i / points.length)).clamp(0.2, 1.0);
      dotPaint.color = GameColors.neonCyan.withOpacity(alpha);

      // Draw dashed trajectory raycast segment
      final start = Offset(p.start.x, p.start.y);
      final end = Offset(p.end.x, p.end.y);
      canvas.drawLine(start, end, dotPaint);

      // Pulsing indicator at end/bounce point
      final pulseSize = 3.5 + 1.0 * math.sin(animationProgress * math.pi * 4);
      final endPaint = Paint()
        ..color = (p.hitBrick != null) ? GameColors.solarGold : GameColors.neonCyan
        ..style = PaintingStyle.fill;
      canvas.drawCircle(end, pulseSize, endPaint);
    }
  }

  void _renderBalls(Canvas canvas) {
    final glowPaint = Paint()..style = PaintingStyle.fill;
    final corePaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < balls.length; i++) {
      final ball = balls[i];
      if (!ball.isActive) continue;

      final bx = ball.position.x;
      final by = ball.position.y;
      final glowColor = ball.skin.glowColor;

      // 1. Additive Glowing Motion Trails
      for (int t = 0; t < ball.trail.length; t++) {
        final trailPos = ball.trail[t];
        final trailAlpha = (t / ball.trail.length) * 0.35;
        final trailRadius = ball.radius * (0.4 + (t / ball.trail.length) * 0.5);

        glowPaint.color = glowColor.withOpacity(trailAlpha);
        canvas.drawCircle(Offset(trailPos.x, trailPos.y), trailRadius, glowPaint);
      }

      // 2. Ball Ambient Outer Glow Bloom
      glowPaint.color = glowColor.withOpacity(0.45);
      canvas.drawCircle(Offset(bx, by), ball.radius * 1.8, glowPaint);

      // 3. Solid Sphere Core
      corePaint.color = Colors.white;
      canvas.drawCircle(Offset(bx, by), ball.radius, corePaint);

      // 4. 3D Specular Highlight Dot
      final shinePaint = Paint()..color = Colors.white.withOpacity(0.85);
      canvas.drawCircle(Offset(bx - ball.radius * 0.3, by - ball.radius * 0.3), ball.radius * 0.32, shinePaint);
    }
  }

  void _renderParticles(Canvas canvas) {
    final particles = ParticlePool.activeParticles;
    for (int i = 0; i < particles.length; i++) {
      final p = particles[i];
      final pos = Offset(p.position.x, p.position.y);
      final alpha = p.alpha.clamp(0.0, 1.0);

      switch (p.type) {
        case ParticleType.spark:
          final sparkPaint = Paint()
            ..color = p.color.withOpacity(alpha)
            ..style = PaintingStyle.fill;
          canvas.drawCircle(pos, p.size, sparkPaint);
          break;

        case ParticleType.shard:
          final shardPaint = Paint()
            ..color = p.color.withOpacity(alpha)
            ..style = PaintingStyle.fill;
          canvas.save();
          canvas.translate(pos.dx, pos.dy);
          canvas.rotate(p.rotation);
          final shardPath = Path()
            ..moveTo(0, -p.size)
            ..lineTo(p.size * 0.6, p.size * 0.8)
            ..lineTo(-p.size * 0.6, p.size * 0.8)
            ..close();
          canvas.drawPath(shardPath, shardPaint);
          canvas.restore();
          break;

        case ParticleType.shockwave:
          final shockPaint = Paint()
            ..color = p.color.withOpacity(alpha)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5;
          canvas.drawCircle(pos, p.size, shockPaint);
          break;

        case ParticleType.laserBeam:
          if (p.lineStart != null && p.lineEnd != null) {
            final beamPaint = Paint()
              ..color = p.color.withOpacity(alpha)
              ..strokeWidth = p.size
              ..style = PaintingStyle.stroke;
            canvas.drawLine(Offset(p.lineStart!.x, p.lineStart!.y), Offset(p.lineEnd!.x, p.lineEnd!.y), beamPaint);
          }
          break;

        case ParticleType.textPopup:
          if (p.text != null) {
            final textSpan = TextSpan(
              text: p.text,
              style: TextStyle(
                color: p.color.withOpacity(alpha),
                fontSize: p.size,
                fontWeight: FontWeight.w900,
                shadows: [
                  Shadow(color: Colors.black.withOpacity(alpha * 0.8), blurRadius: 4),
                ],
              ),
            );
            final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr)..layout();
            tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
          }
          break;
      }
    }
  }

  void _renderLauncher(Canvas canvas, Size size) {
    final lx = launcherPosition.x;
    final ly = launcherPosition.y;

    // Launch Cannon Platform Base
    final basePaint = Paint()
      ..color = GameColors.neonCyan.withOpacity(0.25)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(lx, ly), 13.0, basePaint);

    final ringPaint = Paint()
      ..color = GameColors.neonCyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(Offset(lx, ly), 13.0, ringPaint);

    final corePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(lx, ly), 4.5, corePaint);

    // Ball Count Pill Badge (rendered ABOVE launcher cannon so it's always clearly visible)
    if (!isAiming || activeBallCount > 0) {
      final countStr = (activeBallCount > 0) ? 'x$activeBallCount' : 'x$permanentBallCount';
      final badgeBg = Paint()
        ..color = Colors.black.withOpacity(0.7)
        ..style = PaintingStyle.fill;
      final badgeBorder = Paint()
        ..color = GameColors.neonCyan.withOpacity(0.6)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;

      final textSpan = TextSpan(
        text: countStr,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11.0,
          fontWeight: FontWeight.w900,
          fontFamily: 'Roboto',
        ),
      );
      final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr)..layout();
      final pillRect = Rect.fromCenter(
        center: Offset(lx, ly - 20),
        width: tp.width + 12,
        height: tp.height + 6,
      );

      final rrect = RRect.fromRectAndRadius(pillRect, const Radius.circular(10.0));
      canvas.drawRRect(rrect, badgeBg);
      canvas.drawRRect(rrect, badgeBorder);
      tp.paint(canvas, Offset(lx - tp.width / 2, ly - 20 - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant GamePainter old) {
    // Only repaint when game state actually changes
    return old.bricks != bricks ||
        old.balls != balls ||
        old.animationProgress != animationProgress ||
        old.isAiming != isAiming ||
        old.activeBallCount != activeBallCount ||
        old.permanentBallCount != permanentBallCount ||
        old.trajectory != trajectory;
  }
}
