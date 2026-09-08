import '../models/brick.dart';

/// High-Performance Spatial Hash Broad-Phase Partitioning
/// Rapidly filters candidate bricks so 500+ balls do not do O(N*M) distance tests.
class SpatialHashGrid {
  final int columns;
  final int rows;
  final double cellWidth;
  final double cellHeight;

  // 2D bucket array mapped as flat list of lists
  late final List<List<Brick>> _buckets;

  SpatialHashGrid({
    required this.columns,
    required this.rows,
    required this.cellWidth,
    required this.cellHeight,
  }) {
    _buckets = List.generate(columns * rows, (_) => <Brick>[]);
  }

  int _getIndex(int col, int row) {
    if (col < 0 || col >= columns || row < 0 || row >= rows) return -1;
    return row * columns + col;
  }

  void clear() {
    for (int i = 0; i < _buckets.length; i++) {
      _buckets[i].clear();
    }
  }

  void insertBrick(Brick brick) {
    final idx = _getIndex(brick.gridX, brick.gridY);
    if (idx != -1) {
      _buckets[idx].add(brick);
    }
  }

  void populate(List<Brick> bricks) {
    clear();
    for (int i = 0; i < bricks.length; i++) {
      final b = bricks[i];
      if (!b.isDestroyed) {
        insertBrick(b);
      }
    }
  }

  /// Queries neighboring buckets around pixel position (px, py)
  List<Brick> queryCandidates(double px, double py, double radius) {
    final List<Brick> results = [];
    final minCol = ((px - radius) / cellWidth).floor().clamp(0, columns - 1);
    final maxCol = ((px + radius) / cellWidth).floor().clamp(0, columns - 1);
    final minRow = ((py - radius) / cellHeight).floor().clamp(0, rows - 1);
    final maxRow = ((py + radius) / cellHeight).floor().clamp(0, rows - 1);

    for (int r = minRow; r <= maxRow; r++) {
      for (int c = minCol; c <= maxCol; c++) {
        final idx = _getIndex(c, r);
        if (idx != -1) {
          final bucket = _buckets[idx];
          for (int i = 0; i < bucket.length; i++) {
            final b = bucket[i];
            if (!b.isDestroyed && !results.contains(b)) {
              results.add(b);
            }
          }
        }
      }
    }
    return results;
  }
}
