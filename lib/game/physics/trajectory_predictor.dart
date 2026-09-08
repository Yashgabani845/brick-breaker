import 'dart:math' as math;
import '../../core/math/vector2.dart';
import '../models/brick.dart';
import 'collision_system.dart';

/// Trajectory prediction raycast segment
class TrajectoryPoint {
  final Vector2 start;
  final Vector2 end;
  final Brick? hitBrick;

  TrajectoryPoint({
    required this.start,
    required this.end,
    this.hitBrick,
  });
}

/// Computes multi-bounce predicted trajectory
class TrajectoryPredictor {
  static List<TrajectoryPoint> predict({
    required Vector2 origin,
    required Vector2 direction,
    required double playfieldWidth,
    required double playfieldHeight,
    required double cellWidth,
    required double cellHeight,
    required List<Brick> bricks,
    int maxBounces = 3,
    double ballRadius = 5.0,
  }) {
    final List<TrajectoryPoint> path = [];
    Vector2 currentPos = Vector2.copy(origin);
    Vector2 currentDir = direction.normalized();

    for (int bounce = 0; bounce < maxBounces; bounce++) {
      double minT = double.infinity;
      Vector2 bestHitNormal = Vector2.zero();
      Brick? bestHitBrick;

      // 1. Raycast against left, right, top walls
      // Left wall (x = ballRadius)
      if (currentDir.x < -0.0001) {
        final t = (ballRadius - currentPos.x) / currentDir.x;
        if (t > 0.001 && t < minT) {
          minT = t;
          bestHitNormal = Vector2(1, 0);
          bestHitBrick = null;
        }
      }
      // Right wall (x = playfieldWidth - ballRadius)
      if (currentDir.x > 0.0001) {
        final t = (playfieldWidth - ballRadius - currentPos.x) / currentDir.x;
        if (t > 0.001 && t < minT) {
          minT = t;
          bestHitNormal = Vector2(-1, 0);
          bestHitBrick = null;
        }
      }
      // Top wall (y = ballRadius)
      if (currentDir.y < -0.0001) {
        final t = (ballRadius - currentPos.y) / currentDir.y;
        if (t > 0.001 && t < minT) {
          minT = t;
          bestHitNormal = Vector2(0, 1);
          bestHitBrick = null;
        }
      }

      // 2. Raycast against active bricks (step-sampled for accuracy)
      final stepDistance = 4.0;
      final maxDistance = minT.isFinite ? minT : playfieldHeight * 1.5;
      double sampledDistance = 0.0;
      bool brickHitFound = false;

      while (sampledDistance < maxDistance) {
        sampledDistance += stepDistance;
        final samplePoint = currentPos + currentDir * sampledDistance;

        if (samplePoint.y < 0 || samplePoint.y > playfieldHeight) break;

        for (int i = 0; i < bricks.length; i++) {
          final brick = bricks[i];
          if (brick.isDestroyed) continue;

          final bx = brick.gridX * cellWidth;
          final by = brick.gridY * cellHeight;

          CollisionResult result;
          if (brick.type.isWedge) {
            result = CollisionSystem.testCircleVsWedge(
              ballPos: samplePoint,
              ballRadius: ballRadius,
              left: bx,
              top: by,
              right: bx + cellWidth,
              bottom: by + cellHeight,
              brick: brick,
            );
          } else {
            result = CollisionSystem.testCircleVsAABB(
              ballPos: samplePoint,
              ballRadius: ballRadius,
              left: bx,
              top: by,
              right: bx + cellWidth,
              bottom: by + cellHeight,
              brick: brick,
            );
          }

          if (result.collided) {
            minT = sampledDistance;
            bestHitNormal = result.normal;
            bestHitBrick = brick;
            brickHitFound = true;
            break;
          }
        }
        if (brickHitFound) break;
      }

      if (!minT.isFinite || minT > playfieldHeight * 2) {
        // Line terminates at bottom or screen edge
        final end = currentPos + currentDir * (playfieldHeight * 1.2);
        path.add(TrajectoryPoint(start: currentPos, end: end));
        break;
      }

      final hitPoint = currentPos + currentDir * minT;
      path.add(TrajectoryPoint(start: currentPos, end: hitPoint, hitBrick: bestHitBrick));

      // Compute bounce reflection
      currentPos = hitPoint + bestHitNormal * 0.5;
      currentDir = currentDir.reflect(bestHitNormal).normalized();
      currentDir.clampTrajectoryAngle(minVerticalRatio: 0.12);

      // Stop predicting if ball bounces towards bottom or hits a laser/bomb
      if (bestHitBrick != null && bestHitBrick.type.isSpecialTrigger) {
        break;
      }
    }

    return path;
  }
}
