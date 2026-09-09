import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/math/vector2.dart';

enum ParticleType {
  shard,     // 3D Brick glass/debris shard
  spark,     // Glowing circular spark
  shockwave, // Expanding radial shockwave ring
  textPopup, // "+1 BALL", "COMBO x4" floating text
  laserBeam, // Visual laser beam line
}

/// Particle instance
class GameParticle {
  ParticleType type;
  final Vector2 position;
  final Vector2 velocity;
  double life;
  double maxLife;
  double size;
  double rotation;
  double rotationSpeed;
  Color color;
  String? text;

  // For laser beams
  Vector2? lineStart;
  Vector2? lineEnd;

  GameParticle({
    this.type = ParticleType.spark,
    Vector2? position,
    Vector2? velocity,
    this.life = 0.5,
    this.maxLife = 0.5,
    this.size = 3.0,
    this.rotation = 0.0,
    this.rotationSpeed = 0.0,
    this.color = Colors.white,
    this.text,
    this.lineStart,
    this.lineEnd,
  })  : position = position != null ? Vector2.copy(position) : Vector2.zero(),
        velocity = velocity != null ? Vector2.copy(velocity) : Vector2.zero();

  bool update(double dt) {
    life -= dt;
    if (life <= 0) return false;

    position.x += velocity.x * dt;
    position.y += velocity.y * dt;
    rotation += rotationSpeed * dt;

    if (type == ParticleType.shockwave) {
      size += 180.0 * dt; // Rapid shockwave expansion
    } else if (type == ParticleType.shard) {
      velocity.y += 400.0 * dt; // Gravity on shards
    } else if (type == ParticleType.textPopup) {
      velocity.y -= 30.0 * dt; // Float up
    }

    return true;
  }

  double get progress => (life / maxLife).clamp(0.0, 1.0);
  double get alpha => progress;
}

/// Fast Particle Pool to eliminate Garbage Collection lag
class ParticlePool {
  static final List<GameParticle> _active = [];
  static final List<GameParticle> _inactive = [];

  static List<GameParticle> get activeParticles => _active;

  static void spawnShardBurst(Vector2 center, Color color, {int count = 8}) {
    final rand = math.Random();
    for (int i = 0; i < count; i++) {
      final angle = rand.nextDouble() * 2 * math.pi;
      final speed = 80.0 + rand.nextDouble() * 220.0;
      final vx = math.cos(angle) * speed;
      final vy = math.sin(angle) * speed - 60.0; // slight upward bias
      final life = 0.4 + rand.nextDouble() * 0.3;

      _spawn(
        type: ParticleType.shard,
        pos: center,
        vel: Vector2(vx, vy),
        life: life,
        size: 3.0 + rand.nextDouble() * 4.0,
        color: color,
        rot: rand.nextDouble() * math.pi,
        rotSpeed: (rand.nextDouble() - 0.5) * 12.0,
      );
    }
  }

  static void spawnSparks(Vector2 center, Color color, {int count = 6}) {
    final rand = math.Random();
    for (int i = 0; i < count; i++) {
      final angle = rand.nextDouble() * 2 * math.pi;
      final speed = 50.0 + rand.nextDouble() * 150.0;
      final life = 0.25 + rand.nextDouble() * 0.25;

      _spawn(
        type: ParticleType.spark,
        pos: center,
        vel: Vector2(math.cos(angle) * speed, math.sin(angle) * speed),
        life: life,
        size: 2.0 + rand.nextDouble() * 3.0,
        color: color,
      );
    }
  }

  static void spawnShockwave(Vector2 center, Color color, {double initialSize = 10.0, double? maxRadius, double life = 0.35}) {
    _spawn(
      type: ParticleType.shockwave,
      pos: center,
      vel: Vector2.zero(),
      life: life,
      size: maxRadius ?? initialSize,
      color: color,
    );
  }

  static void spawnTextPopup(Vector2 center, String text, Color color) {
    _spawn(
      type: ParticleType.textPopup,
      pos: center,
      vel: Vector2(0, -60),
      life: 0.8,
      size: 14.0,
      color: color,
      text: text,
    );
  }

  static void spawnLaserBeam(Vector2 start, Vector2 end, Color color, {double life = 0.22}) {
    _spawn(
      type: ParticleType.laserBeam,
      pos: start,
      vel: Vector2.zero(),
      life: life,
      size: 4.0,
      color: color,
      lineStart: start,
      lineEnd: end,
    );
  }

  static void _spawn({
    required ParticleType type,
    required Vector2 pos,
    required Vector2 vel,
    required double life,
    required double size,
    required Color color,
    double rot = 0.0,
    double rotSpeed = 0.0,
    String? text,
    Vector2? lineStart,
    Vector2? lineEnd,
  }) {
    GameParticle p;
    if (_inactive.isNotEmpty) {
      p = _inactive.removeLast();
      p.type = type;
      p.position.copyFrom(pos);
      p.velocity.copyFrom(vel);
      p.life = life;
      p.maxLife = life;
      p.size = size;
      p.rotation = rot;
      p.rotationSpeed = rotSpeed;
      p.color = color;
      p.text = text;
      p.lineStart = lineStart != null ? Vector2.copy(lineStart) : null;
      p.lineEnd = lineEnd != null ? Vector2.copy(lineEnd) : null;
    } else {
      p = GameParticle(
        type: type,
        position: pos,
        velocity: vel,
        life: life,
        maxLife: life,
        size: size,
        rotation: rot,
        rotationSpeed: rotSpeed,
        color: color,
        text: text,
        lineStart: lineStart,
        lineEnd: lineEnd,
      );
    }
    _active.add(p);
  }

  static void update(double dt) {
    for (int i = _active.length - 1; i >= 0; i--) {
      final p = _active[i];
      if (!p.update(dt)) {
        _active.removeAt(i);
        if (_inactive.length < 200) {
          _inactive.add(p);
        }
      }
    }
  }

  static void clear() {
    _inactive.addAll(_active);
    _active.clear();
  }
}
