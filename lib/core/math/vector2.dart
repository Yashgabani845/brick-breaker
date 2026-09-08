import 'dart:math' as math;

/// Fast, deterministic 2D vector for high-performance physics simulation.
class Vector2 {
  double x;
  double y;

  Vector2(this.x, this.y);

  Vector2.zero() : x = 0.0, y = 0.0;
  Vector2.copy(Vector2 other) : x = other.x, y = other.y;

  static Vector2 fromAngle(double angleRadians, [double length = 1.0]) {
    return Vector2(math.cos(angleRadians) * length, math.sin(angleRadians) * length);
  }

  void set(double newX, double newY) {
    x = newX;
    y = newY;
  }

  void copyFrom(Vector2 other) {
    x = other.x;
    y = other.y;
  }

  double get lengthSquared => x * x + y * y;
  double get length => math.sqrt(x * x + y * y);

  double get angle => math.atan2(y, x);

  Vector2 normalized() {
    final len = length;
    if (len > 0.000001) {
      return Vector2(x / len, y / len);
    }
    return Vector2(0.0, -1.0);
  }

  void normalize() {
    final len = length;
    if (len > 0.000001) {
      x /= len;
      y /= len;
    } else {
      x = 0.0;
      y = -1.0;
    }
  }

  Vector2 operator +(Vector2 other) => Vector2(x + other.x, y + other.y);
  Vector2 operator -(Vector2 other) => Vector2(x - other.x, y - other.y);
  Vector2 operator *(double scalar) => Vector2(x * scalar, y * scalar);
  Vector2 operator /(double scalar) => Vector2(x / scalar, y / scalar);
  Vector2 operator -() => Vector2(-x, -y);

  void add(Vector2 other) {
    x += other.x;
    y += other.y;
  }

  void subtract(Vector2 other) {
    x -= other.x;
    y -= other.y;
  }

  void scale(double scalar) {
    x *= scalar;
    y *= scalar;
  }

  double dot(Vector2 other) => x * other.x + y * other.y;

  double distanceTo(Vector2 other) {
    final dx = x - other.x;
    final dy = y - other.y;
    return math.sqrt(dx * dx + dy * dy);
  }

  double distanceSquaredTo(Vector2 other) {
    final dx = x - other.x;
    final dy = y - other.y;
    return dx * dx + dy * dy;
  }

  /// Calculates reflection: V' = V - 2(V · N)N
  Vector2 reflect(Vector2 normal) {
    final d = dot(normal);
    return Vector2(x - 2.0 * d * normal.x, y - 2.0 * d * normal.y);
  }

  /// In-place reflection
  void reflectInPlace(Vector2 normal) {
    final d = dot(normal);
    x -= 2.0 * d * normal.x;
    y -= 2.0 * d * normal.y;
  }

  /// Rotates vector by angle in radians
  Vector2 rotated(double angleRadians) {
    final c = math.cos(angleRadians);
    final s = math.sin(angleRadians);
    return Vector2(x * c - y * s, x * s + y * c);
  }

  /// Clamps trajectory to avoid purely horizontal locking (ensuring min vertical velocity)
  void clampTrajectoryAngle({double minVerticalRatio = 0.15}) {
    if (y.abs() < minVerticalRatio) {
      y = (y < 0 ? -1 : 1) * minVerticalRatio;
      normalize();
    }
  }

  @override
  String toString() => 'Vector2(${x.toStringAsFixed(2)}, ${y.toStringAsFixed(2)})';
}
