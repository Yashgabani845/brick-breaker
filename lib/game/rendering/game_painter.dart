import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/game_colors.dart';
import '../../core/math/vector2.dart';
import '../models/ball.dart';
import '../models/brick.dart';
import '../models/paddle.dart';
import '../models/particle.dart';
import '../models/powerup.dart';
import 'brick_3d_renderer.dart';

/// Master CustomPainter for Paddle-Controlled Brick Smash
class GamePainter extends CustomPainter {
  final List<Brick> bricks;
  final List<Ball> balls;
  final Paddle paddle;
  final List<PowerUp> fallingPowerUps;
  final int columns;
  final int rows;
  final double animationProgress;
  final Color? themeColor;
  final bool isAiming;

  GamePainter({
    required this.bricks,
    required this.balls,
    required this.paddle,
    required this.fallingPowerUps,
    required this.columns,
    required this.rows,
    required this.animationProgress,
    this.themeColor,
    this.isAiming = false,
  });

  static Paint? _cachedBgPaint;
  static Color? _cachedThemeColor;
  static Size? _cachedBgSize;

  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = size.width / columns;
    final cellHeight = (size.height * 0.72) / rows;

    // 1. Deep Dark Royal Navy Background & Subtle Grid
    _renderBackground(canvas, size, cellWidth, cellHeight);

    // 2. 3D Beveled Bricks & Wedges
    _renderBricks(canvas, cellWidth, cellHeight);

    // 3. Falling Power-Up Capsules
    _renderPowerUps(canvas);

    // 4. Player Paddle (Glossy 3D Pill Bar)
    _renderPaddle(canvas);

    // 5. Active Bouncing Balls & Fireballs
    _renderBalls(canvas);

    // 6. Particle Effects & Explosions
    _renderParticles(canvas);
  }

  void _renderBackground(Canvas canvas, Size size, double cw, double ch) {
    final theme = themeColor ?? const Color(0xFF192A56);

    if (_cachedBgPaint == null || _cachedThemeColor != theme || _cachedBgSize != size) {
      _cachedThemeColor = theme;
      _cachedBgSize = size;
      _cachedBgPaint = Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.0, -0.3),
          radius: 1.35,
          colors: const [
            Color(0xFF14203D),
            Color(0xFF090E1D),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    }
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), _cachedBgPaint!);

    // Clean subtle grid lines
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.025)
      ..strokeWidth = 1.0;

    for (int c = 0; c <= columns; c++) {
      canvas.drawLine(Offset(c * cw, 0), Offset(c * cw, size.height), gridPaint);
    }
    for (int r = 0; r <= rows; r++) {
      final y = r * ch;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
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

  void _renderPaddle(Canvas canvas) {
    final pRect = paddle.rect;
    final rrect = RRect.fromRectAndRadius(pRect, const Radius.circular(8.0));

    // 1. Paddle Ambient Glow Shadow
    final glowPaint = Paint()
      ..color = paddle.skin.glowColor.withOpacity(0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0);
    canvas.drawRRect(rrect.inflate(3.0), glowPaint);

    // 2. Paddle Drop Shadow
    final shadowRRect = RRect.fromRectAndRadius(pRect.shift(const Offset(0, 4)), const Radius.circular(8.0));
    final shadowPaint = Paint()..color = const Color(0x88000000);
    canvas.drawRRect(shadowRRect, shadowPaint);

    // 3. Paddle Body Metallic Gradient (From equipped skin)
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: paddle.skin.bodyGradient,
      ).createShader(pRect)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rrect, bodyPaint);

    // 4. Glossy Top Specular Highlight (Upper 45%)
    final shineRect = Rect.fromLTWH(pRect.left + 2, pRect.top + 2, pRect.width - 4, pRect.height * 0.45);
    final shineRRect = RRect.fromRectAndRadius(shineRect, const Radius.circular(4.0));
    final shinePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withOpacity(0.65),
          Colors.white.withOpacity(0.0),
        ],
      ).createShader(shineRect)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(shineRRect, shinePaint);

    // 5. White / Chrome Border Trim
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.85)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(rrect, borderPaint);

    // 6. Center Energy Core / Neon Grip Marker
    final corePaint = Paint()
      ..color = paddle.skin.coreColor.withOpacity(0.95)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(paddle.position.x, paddle.position.y), width: 16, height: 4),
        const Radius.circular(2),
      ),
      corePaint,
    );

    // 7. Left and Right End-Cap Thruster Lights
    final thrusterPaint = Paint()..color = paddle.skin.glowColor;
    canvas.drawCircle(Offset(pRect.left + 6, pRect.center.dy), 2.5, thrusterPaint);
    canvas.drawCircle(Offset(pRect.right - 6, pRect.center.dy), 2.5, thrusterPaint);

    // 8. Laser Cannons when active
    if (paddle.isLaserActive) {
      final cannonPaint = Paint()..color = const Color(0xFFFF1744);
      canvas.drawRect(Rect.fromLTWH(pRect.left + 4, pRect.top - 6, 4, 6), cannonPaint);
      canvas.drawRect(Rect.fromLTWH(pRect.right - 8, pRect.top - 6, 4, 6), cannonPaint);
    }

    // 9. Aiming Trajectory Arrow if ball is stuck to paddle
    if (isAiming && balls.isNotEmpty && balls.first.isStuckToPaddle) {
      final ball = balls.first;
      final aimPaint = Paint()
        ..color = const Color(0xFFFFD54F).withOpacity(0.7)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;

      final start = Offset(ball.position.x, ball.position.y - ball.radius - 2);
      final end = Offset(ball.position.x, ball.position.y - ball.radius - 36);
      canvas.drawLine(start, end, aimPaint);
      canvas.drawCircle(end, 3.5, Paint()..color = const Color(0xFFFFD54F));
    }
  }

  void _renderBalls(Canvas canvas) {
    for (int i = 0; i < balls.length; i++) {
      final ball = balls[i];
      if (!ball.isActive) continue;

      final bx = ball.position.x;
      final by = ball.position.y;
      final r = ball.radius;

      if (ball.isFireball) {
        // Fiery Fireball Core & Trail
        for (int t = 0; t < ball.trail.length; t++) {
          final trailPos = ball.trail[t];
          final trailAlpha = (t / ball.trail.length) * 0.55;
          final trailR = r * (0.4 + (t / ball.trail.length) * 0.7);

          final fireTrail = Paint()
            ..color = const Color(0xFFFF5722).withOpacity(trailAlpha)
            ..style = PaintingStyle.fill;
          canvas.drawCircle(Offset(trailPos.x, trailPos.y), trailR, fireTrail);
        }

        final fireAura = Paint()
          ..color = const Color(0xFFFF9100).withOpacity(0.6)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);
        canvas.drawCircle(Offset(bx, by), r * 1.8, fireAura);

        final fireCore = Paint()
          ..shader = RadialGradient(
            colors: const [
              Color(0xFFFFF9C4),
              Color(0xFFFF9100),
              Color(0xFFD50000),
            ],
          ).createShader(Rect.fromCircle(center: Offset(bx, by), radius: r));
        canvas.drawCircle(Offset(bx, by), r, fireCore);
      } else {
        // Standard Radiant Ball matching equipped BallSkin
        for (int t = 0; t < ball.trail.length; t++) {
          final trailPos = ball.trail[t];
          final trailAlpha = (t / ball.trail.length) * 0.35;
          final trailR = r * (0.35 + (t / ball.trail.length) * 0.55);

          final skinTrail = Paint()
            ..color = ball.skin.glowColor.withOpacity(trailAlpha)
            ..style = PaintingStyle.fill;
          canvas.drawCircle(Offset(trailPos.x, trailPos.y), trailR, skinTrail);
        }

        final haloPaint = Paint()
          ..color = ball.skin.glowColor.withOpacity(0.4)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(bx, by), r * 1.6, haloPaint);

        final spherePaint = Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.35, -0.35),
            radius: 0.85,
            colors: ball.skin.gradientColors,
            stops: const [0.0, 0.35, 0.75, 1.0],
          ).createShader(Rect.fromCircle(center: Offset(bx, by), radius: r))
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(bx, by), r, spherePaint);

        // Specular Shine
        final shinePaint = Paint()..color = ball.skin.coreColor.withOpacity(0.9);
        canvas.drawCircle(Offset(bx - r * 0.32, by - r * 0.32), r * 0.28, shinePaint);
      }
    }
  }

  void _renderPowerUps(Canvas canvas) {
    for (int i = 0; i < fallingPowerUps.length; i++) {
      final p = fallingPowerUps[i];
      final px = p.position.x;
      final py = p.position.y;

      final capsuleRect = Rect.fromCenter(center: Offset(px, py), width: 34, height: 20);
      final capsuleRRect = RRect.fromRectAndRadius(capsuleRect, const Radius.circular(10));

      // 1. Glow Halo
      final haloPaint = Paint()
        ..color = p.type.color.withOpacity(0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);
      canvas.drawRRect(capsuleRRect.inflate(2.0), haloPaint);

      // 2. Capsule Body Fill
      final bodyPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            p.type.color,
            const Color(0xFF0D162B),
          ],
        ).createShader(capsuleRect)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(capsuleRRect, bodyPaint);

      // 3. Capsule Border
      final borderPaint = Paint()
        ..color = Colors.white.withOpacity(0.8)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke;
      canvas.drawRRect(capsuleRRect, borderPaint);

      // 4. Centered Icon Emoji
      final textSpan = TextSpan(
        text: p.type.iconEmoji,
        style: const TextStyle(fontSize: 12.0),
      );
      final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas, Offset(px - tp.width / 2, py - tp.height / 2));
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

  @override
  bool shouldRepaint(covariant GamePainter oldDelegate) => true;
}
