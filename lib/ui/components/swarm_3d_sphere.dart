import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/game_colors.dart';
import '../../game/models/ball.dart';
import '../../game/systems/audio_synthesizer.dart';

/// Interactive 3D Orbiting Swarm Sphere with dynamic lighting and specular reflections
class Swarm3dSphere extends StatefulWidget {
  final int ballCount;
  final BallSkin skin;
  final VoidCallback? onTap;

  const Swarm3dSphere({
    super.key,
    required this.ballCount,
    required this.skin,
    this.onTap,
  });

  @override
  State<Swarm3dSphere> createState() => _Swarm3dSphereState();
}

class _Swarm3dSphereState extends State<Swarm3dSphere> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  final List<math.Point<double>> _orbitalNodes = [];
  double _manualYaw = 0;
  double _manualPitch = 0;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    // Generate spherical coordinates (theta, phi) for orbital photon satellites
    final rng = math.Random(42);
    for (int i = 0; i < 36; i++) {
      final theta = rng.nextDouble() * 2 * math.pi;
      final phi = (rng.nextDouble() - 0.5) * math.pi;
      _orbitalNodes.add(math.Point(theta, phi));
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          _manualYaw += details.delta.dx * 0.015;
          _manualPitch = (_manualPitch - details.delta.dy * 0.015).clamp(-0.8, 0.8);
        });
      },
      onTap: () {
        AudioSynthesizer.instance.playSplitterSwarm();
        widget.onTap?.call();
      },
      child: AnimatedBuilder(
        animation: _rotationController,
        builder: (context, child) {
          final autoAngle = _rotationController.value * 2 * math.pi;
          return CustomPaint(
            size: const Size(180, 180),
            painter: _SwarmSpherePainter(
              yaw: autoAngle + _manualYaw,
              pitch: _manualPitch + 0.25 * math.sin(autoAngle * 0.5),
              skinColor: widget.skin.glowColor,
              ballCount: widget.ballCount,
              orbitalNodes: _orbitalNodes,
            ),
          );
        },
      ),
    );
  }
}

class _SwarmSpherePainter extends CustomPainter {
  final double yaw;
  final double pitch;
  final Color skinColor;
  final int ballCount;
  final List<math.Point<double>> orbitalNodes;

  _SwarmSpherePainter({
    required this.yaw,
    required this.pitch,
    required this.skinColor,
    required this.ballCount,
    required this.orbitalNodes,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const radius = 55.0;

    // 1. Ambient outer nebula glow
    final outerGlowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          skinColor.withOpacity(0.35),
          skinColor.withOpacity(0.08),
          Colors.transparent,
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: 95));
    canvas.drawCircle(center, 95, outerGlowPaint);

    // 2. 3D Core Sphere with specular light highlight
    final spherePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.35),
        radius: 0.85,
        colors: [
          Colors.white,
          skinColor,
          Color.lerp(skinColor, Colors.black, 0.75)!,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, spherePaint);

    // 3. Draw 3D Orbiting Photon Satellites
    final cosPitch = math.cos(pitch);
    final sinPitch = math.sin(pitch);

    // Sort orbital nodes by 3D Z-depth for correct occlusion
    final renderedNodes = <_RenderedNode>[];
    for (int i = 0; i < orbitalNodes.length; i++) {
      final node = orbitalNodes[i];
      final r = radius + 22.0 + 8.0 * math.sin(i * 1.3);
      final currentTheta = node.x + yaw + (i * 0.1);
      final currentPhi = node.y;

      // Spherical to 3D Cartesian
      var x = r * math.cos(currentPhi) * math.cos(currentTheta);
      var y = r * math.sin(currentPhi);
      var z = r * math.cos(currentPhi) * math.sin(currentTheta);

      // Rotate around X axis by pitch
      final yRot = y * cosPitch - z * sinPitch;
      final zRot = y * sinPitch + z * cosPitch;

      renderedNodes.add(_RenderedNode(
        screenPos: Offset(center.dx + x, center.dy + yRot),
        depthZ: zRot,
        index: i,
      ));
    }

    renderedNodes.sort((a, b) => a.depthZ.compareTo(b.depthZ));

    for (final node in renderedNodes) {
      final depthFactor = ((node.depthZ + radius + 30) / (2 * (radius + 30))).clamp(0.2, 1.0);
      final nodeRadius = (2.0 + 3.0 * depthFactor);
      final alpha = (0.25 + 0.75 * depthFactor).clamp(0.0, 1.0);

      final nodePaint = Paint()
        ..color = Color.lerp(Colors.white, skinColor, 0.3)!.withOpacity(alpha)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, (1.0 + 2.0 * depthFactor));
      canvas.drawCircle(node.screenPos, nodeRadius + 1.5, nodePaint);

      final corePaint = Paint()
        ..color = Colors.white.withOpacity(alpha);
      canvas.drawCircle(node.screenPos, nodeRadius * 0.7, corePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SwarmSpherePainter oldDelegate) => true;
}

class _RenderedNode {
  final Offset screenPos;
  final double depthZ;
  final int index;
  _RenderedNode({required this.screenPos, required this.depthZ, required this.index});
}

