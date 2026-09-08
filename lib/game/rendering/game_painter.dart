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

  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = size.width / columns;
    final cellHeight = (size.height * 0.78) / rows;

    // 1. Render Deep OLED Cosmic Background & Grid
    _renderBackground(canvas, size, cellWidth, cellHeight);

    // 2. Render Danger Line (Threshold row)
    _renderDangerLine(canvas, size, cellHeight);

    // 3. Render 3D Extruded Bricks & Wedges
    _renderBricks(canvas, cellWidth, cellHeight);

    // 4. Render Aim Trajectory (if player is aiming)
    if (isAiming && trajectory != null && trajectory!.isNotEmpty) {
      _renderTrajectory(canvas, trajectory!);
    }

    // 5. Render Glowing Ball Swarms & Additive Trails
    _renderBalls(canvas);

    // 6. Render Dynamic Particle Systems (Shards, Shockwaves, Lasers, Popups)
    _renderParticles(canvas);

    // 7. Render Launcher Base & Power Indicator
    _renderLauncher(canvas, size);
  }

  void _renderBackground(Canvas canvas, Size size, double cw, double ch) {
    final theme = themeColor ?? GameColors.neonCyan;
    // Deep OLED Space Gradient with level atmospheric tint
    final bgPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.0, -0.35),
        radius: 1.3,
        colors: [
          Color.lerp(GameColors.spaceDark, theme, 0.15)!,
          GameColors.oledDark,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Subtle Sci-Fi Grid Lines
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.025)
      ..strokeWidth = 1.0;

    for (int c = 0; c <= columns; c++) {
      canvas.drawLine(Offset(c * cw, 0), Offset(c * cw, size.height), gridPaint);
    }
    for (int r = 0; r <= rows; r++) {
      canvas.drawLine(Offset(0, r * ch), Offset(size.width, r * ch), gridPaint);
    }
  }

  void _renderDangerLine(Canvas canvas, Size size, double ch) {
    final dangerY = dangerRow * ch;
    final pulse = 0.4 + 0.4 * math.sin(animationProgress * math.pi * 2);

    final linePaint = Paint()
      ..color = GameColors.crimsonDanger.withOpacity(pulse)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Dashed Hazard Line
    const dashWidth = 8.0;
    const dashSpace = 6.0;
    double startX = 0.0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, dangerY),
        Offset(startX + dashWidth, dangerY),
        linePaint,
      );
      startX += dashWidth + dashSpace;
    }

    // "DANGER" glowing tag at edge
    final textSpan = TextSpan(
      text: '⚠️ DANGER LINE',
      style: TextStyle(
        color: GameColors.crimsonDanger.withOpacity(pulse),
        fontSize: 9.0,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.5,
      ),
    );
    final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr)..layout();
    tp.paint(canvas, Offset(size.width - tp.width - 8, dangerY - tp.height - 2));
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

  void _renderTrajectory(Canvas canvas, List<TrajectoryPoint> path) {
    final linePaint = Paint()
      ..color = GameColors.neonCyan.withOpacity(0.85)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (int i = 0; i < path.length; i++) {
      final seg = path[i];
      final p1 = Offset(seg.start.x, seg.start.y);
      final p2 = Offset(seg.end.x, seg.end.y);

      // Draw dashed trajectory segment
      final dist = (p2 - p1).distance;
      if (dist > 1.0) {
        final dir = (p2 - p1) / dist;
        const step = 14.0;
        double cur = (animationProgress * step) % step;

        while (cur < dist) {
          final dotPos = p1 + dir * cur;
          canvas.drawCircle(dotPos, 2.2, dotPaint);
          cur += step;
        }
      }

      // Draw landing impact reticle if hitting obstacle
      if (i == path.length - 1 || seg.hitBrick != null) {
        final reticlePaint = Paint()
          ..color = (seg.hitBrick?.type.isSpecialTrigger == true)
              ? GameColors.electricAmber
              : GameColors.neonCyan
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8;
        canvas.drawCircle(p2, 6.0, reticlePaint);
        canvas.drawCircle(p2, 2.0, dotPaint);
      }
    }
  }

  void _renderBalls(Canvas canvas) {
    final ballPaint = Paint()..style = PaintingStyle.fill;
    final glowPaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < balls.length; i++) {
      final ball = balls[i];
      if (!ball.isActive) continue;

      final center = Offset(ball.position.x, ball.position.y);
      final skinColor = ball.skin.glowColor;

      // 1. Motion Trail (Additive glow fading backward)
      for (int t = 0; t < ball.trail.length; t++) {
        final tPos = ball.trail[t];
        final alpha = (t + 1) / (ball.trail.length + 1) * 0.35;
        final tPaint = Paint()
          ..color = skinColor.withOpacity(alpha)
          ..style = PaintingStyle.fill;
        final tRadius = ball.radius * (0.4 + (t / ball.trail.length) * 0.6);
        canvas.drawCircle(Offset(tPos.x, tPos.y), tRadius, tPaint);
      }

      // 2. Outer Radial Glow
      glowPaint.shader = RadialGradient(
        colors: [skinColor.withOpacity(0.6), skinColor.withOpacity(0.0)],
      ).createShader(Rect.fromCircle(center: center, radius: ball.radius * 2.2));
      canvas.drawCircle(center, ball.radius * 2.2, glowPaint);

      // 3. Core Sphere with Specular Highlight
      ballPaint.shader = RadialGradient(
        center: const Alignment(-0.35, -0.35),
        radius: 0.8,
        colors: [Colors.white, skinColor, Color.lerp(skinColor, Colors.black, 0.4)!],
      ).createShader(Rect.fromCircle(center: center, radius: ball.radius));
      canvas.drawCircle(center, ball.radius, ballPaint);
    }
  }

  void _renderParticles(Canvas canvas) {
    final particles = ParticlePool.activeParticles;

    for (int i = 0; i < particles.length; i++) {
      final p = particles[i];
      final alpha = p.alpha;
      final pos = Offset(p.position.x, p.position.y);

      switch (p.type) {
        case ParticleType.shard:
          canvas.save();
          canvas.translate(pos.dx, pos.dy);
          canvas.rotate(p.rotation);
          final shardPaint = Paint()
            ..color = p.color.withOpacity(alpha)
            ..style = PaintingStyle.fill;
          canvas.drawRect(
            Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 1.5),
            shardPaint,
          );
          canvas.restore();
          break;

        case ParticleType.spark:
          final sparkPaint = Paint()
            ..color = p.color.withOpacity(alpha)
            ..style = PaintingStyle.fill;
          canvas.drawCircle(pos, p.size * alpha, sparkPaint);
          break;

        case ParticleType.shockwave:
          final shockPaint = Paint()
            ..color = p.color.withOpacity(alpha)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3.0 * alpha;
          canvas.drawCircle(pos, p.size, shockPaint);
          break;

        case ParticleType.laserBeam:
          if (p.lineStart != null && p.lineEnd != null) {
            final beamGlow = Paint()
              ..color = p.color.withOpacity(alpha * 0.4)
              ..strokeWidth = 10.0 * alpha
              ..style = PaintingStyle.stroke;
            final beamCore = Paint()
              ..color = Colors.white.withOpacity(alpha)
              ..strokeWidth = 3.5 * alpha
              ..style = PaintingStyle.stroke;
            final start = Offset(p.lineStart!.x, p.lineStart!.y);
            final end = Offset(p.lineEnd!.x, p.lineEnd!.y);
            canvas.drawLine(start, end, beamGlow);
            canvas.drawLine(start, end, beamCore);
          }
          break;

        case ParticleType.textPopup:
          if (p.text != null) {
            final textSpan = TextSpan(
              text: p.text!,
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

    // Launch Cannon Platform
    final basePaint = Paint()
      ..color = GameColors.neonCyan.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(lx, ly), 14.0, basePaint);

    final ringPaint = Paint()
      ..color = GameColors.neonCyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(Offset(lx, ly), 14.0, ringPaint);

    final corePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(lx, ly), 5.0, corePaint);

    // Permanent Ball count badge below launcher
    if (!isAiming || activeBallCount > 0) {
      final countStr = (activeBallCount > 0) ? 'x$activeBallCount' : 'x$permanentBallCount';
      final textSpan = TextSpan(
        text: countStr,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12.0,
          fontWeight: FontWeight.w900,
          fontFamily: 'Roboto',
        ),
      );
      final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas, Offset(lx - tp.width / 2, ly + 18));
    }
  }

  @override
  bool shouldRepaint(covariant GamePainter oldDelegate) => true;
}
