import 'dart:math' as math;
import '../../core/math/vector2.dart';
import '../models/ball.dart';
import '../models/brick.dart';

/// Collision Result Data
class CollisionResult {
  final bool collided;
  final Vector2 normal;
  final double penetration;
  final Brick? brick;

  CollisionResult({
    required this.collided,
    Vector2? normal,
    this.penetration = 0.0,
    this.brick,
  }) : normal = normal ?? Vector2.zero();

  static final CollisionResult none = CollisionResult(collided: false);
}

/// Robust continuous collision detection and response system
class CollisionSystem {
  static const double invSqrt2 = 0.7071067811865475; // 1 / sqrt(2) for 45° normals

  /// Tests collision between a circle ball and a rectangular AABB brick
  static CollisionResult testCircleVsAABB({
    required Vector2 ballPos,
    required double ballRadius,
    required double left,
    required double top,
    required double right,
    required double bottom,
    required Brick brick,
  }) {
    // Find closest point on AABB to circle center
    final closestX = ballPos.x.clamp(left, right);
    final closestY = ballPos.y.clamp(top, bottom);

    final dx = ballPos.x - closestX;
    final dy = ballPos.y - closestY;
    final distSq = dx * dx + dy * dy;

    if (distSq <= ballRadius * ballRadius) {
      final dist = math.sqrt(distSq);
      Vector2 normal;
      double penetration;

      if (dist > 0.00001) {
        normal = Vector2(dx / dist, dy / dist);
        penetration = ballRadius - dist;
      } else {
        // Deep penetration inside box, find closest edge to push out
        final dLeft = (ballPos.x - left).abs();
        final dRight = (right - ballPos.x).abs();
        final dTop = (ballPos.y - top).abs();
        final dBottom = (bottom - ballPos.y).abs();

        final minD = math.min(math.min(dLeft, dRight), math.min(dTop, dBottom));
        if (minD == dTop) {
          normal = Vector2(0, -1);
          penetration = ballRadius + dTop;
        } else if (minD == dBottom) {
          normal = Vector2(0, 1);
          penetration = ballRadius + dBottom;
        } else if (minD == dLeft) {
          normal = Vector2(-1, 0);
          penetration = ballRadius + dLeft;
        } else {
          normal = Vector2(1, 0);
          penetration = ballRadius + dRight;
        }
      }

      return CollisionResult(
        collided: true,
        normal: normal,
        penetration: penetration,
        brick: brick,
      );
    }

    return CollisionResult.none;
  }

  /// Tests collision between a circle ball and a 45° triangular wedge
  static CollisionResult testCircleVsWedge({
    required Vector2 ballPos,
    required double ballRadius,
    required double left,
    required double top,
    required double right,
    required double bottom,
    required Brick brick,
  }) {
    final w = right - left;
    final h = bottom - top;

    // First do broad AABB overlap check
    if (ballPos.x + ballRadius < left ||
        ballPos.x - ballRadius > right ||
        ballPos.y + ballRadius < top ||
        ballPos.y - ballRadius > bottom) {
      return CollisionResult.none;
    }

    // Determine wedge vertices and slant normal
    late Vector2 v1, v2, v3; // v1 is right-angle corner, v2 and v3 are acute corners
    late Vector2 slantNormal;

    switch (brick.type) {
      case BrickType.wedgeTopLeft:
        v1 = Vector2(left, top);
        v2 = Vector2(right, top);
        v3 = Vector2(left, bottom);
        slantNormal = Vector2(invSqrt2, invSqrt2); // Hypotenuse faces bottom-right
        break;
      case BrickType.wedgeTopRight:
        v1 = Vector2(right, top);
        v2 = Vector2(left, top);
        v3 = Vector2(right, bottom);
        slantNormal = Vector2(-invSqrt2, invSqrt2); // Hypotenuse faces bottom-left
        break;
      case BrickType.wedgeBottomLeft:
        v1 = Vector2(left, bottom);
        v2 = Vector2(left, top);
        v3 = Vector2(right, bottom);
        slantNormal = Vector2(invSqrt2, -invSqrt2); // Hypotenuse faces top-right
        break;
      case BrickType.wedgeBottomRight:
        v1 = Vector2(right, bottom);
        v2 = Vector2(right, top);
        v3 = Vector2(left, bottom);
        slantNormal = Vector2(-invSqrt2, -invSqrt2); // Hypotenuse faces top-left
        break;
      default:
        return CollisionResult.none;
    }

    // Distance to line segment v2 -> v3 (the hypotenuse)
    final hypDist = _distanceToSegment(ballPos, v2, v3);
    if (hypDist.distance <= ballRadius) {
      return CollisionResult(
        collided: true,
        normal: slantNormal,
        penetration: ballRadius - hypDist.distance,
        brick: brick,
      );
    }

    // Also check orthogonal flat sides (v1->v2 and v1->v3)
    final flat1 = _distanceToSegment(ballPos, v1, v2);
    final flat2 = _distanceToSegment(ballPos, v1, v3);

    if (flat1.distance <= ballRadius) {
      Vector2 n = (v1.y == v2.y)
          ? Vector2(0, (v1.y == top) ? -1 : 1)
          : Vector2((v1.x == left) ? -1 : 1, 0);
      return CollisionResult(
        collided: true,
        normal: n,
        penetration: ballRadius - flat1.distance,
        brick: brick,
      );
    }

    if (flat2.distance <= ballRadius) {
      Vector2 n = (v1.x == v3.x)
          ? Vector2((v1.x == left) ? -1 : 1, 0)
          : Vector2(0, (v1.y == top) ? -1 : 1);
      return CollisionResult(
        collided: true,
        normal: n,
        penetration: ballRadius - flat2.distance,
        brick: brick,
      );
    }

    return CollisionResult.none;
  }

  /// Distance from point P to line segment AB
  static ({double distance, Vector2 closest}) _distanceToSegment(
    Vector2 p,
    Vector2 a,
    Vector2 b,
  ) {
    final ab = b - a;
    final ap = p - a;
    final abLenSq = ab.lengthSquared;

    if (abLenSq <= 0.00001) {
      return (distance: p.distanceTo(a), closest: a);
    }

    final t = (ap.dot(ab) / abLenSq).clamp(0.0, 1.0);
    final closest = Vector2(a.x + ab.x * t, a.y + ab.y * t);
    return (distance: p.distanceTo(closest), closest: closest);
  }

  /// Resolves collision between ball and a brick
  static void resolveBallCollision(Ball ball, CollisionResult result) {
    if (!result.collided) return;

    // Separate ball from obstacle completely
    final separation = (result.penetration > 0 ? result.penetration : 0.0) + 0.5;
    ball.position.x += result.normal.x * separation;
    ball.position.y += result.normal.y * separation;

    // Only reflect velocity if ball is moving into the normal surface (dot < 0)
    final dot = ball.velocity.dot(result.normal);
    if (dot < 0) {
      ball.velocity.reflectInPlace(result.normal);
    }

    // Safeguard: Ensure velocity maintains a minimum vertical ratio so it doesn't get stuck forever horizontally
    ball.velocity.clampTrajectoryAngle(minVerticalRatio: 0.12);
  }
}
