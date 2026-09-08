import 'package:flutter/material.dart';
import 'brick.dart';

/// Level Archetypes defined in the Master Spec
enum LevelArchetype {
  starterGrid,
  invertedFunnel,
  walledFortress,
  zigZagLabyrinth,
  laserHighway,
  orbitalChamber,
  impossibleCitadel,
}

extension LevelArchetypeExtension on LevelArchetype {
  String get displayName {
    switch (this) {
      case LevelArchetype.starterGrid:
        return 'Starter Grid';
      case LevelArchetype.invertedFunnel:
        return 'Inverted Funnel';
      case LevelArchetype.walledFortress:
        return 'Walled Fortress';
      case LevelArchetype.zigZagLabyrinth:
        return 'Zig-Zag Labyrinth';
      case LevelArchetype.laserHighway:
        return 'Laser Highway';
      case LevelArchetype.orbitalChamber:
        return 'Orbital Chamber';
      case LevelArchetype.impossibleCitadel:
        return 'Impossible Citadel';
    }
  }
}

/// Level Schema Data
class LevelData {
  final int levelNumber;
  final String title;
  final LevelArchetype archetype;
  final int columns;
  final int rows;
  final int dangerRow;
  final int startingBalls;
  final int targetScore;
  final List<Brick> initialBricks;
  final int? turnLimit;
  final Color? themeColor;

  LevelData({
    required this.levelNumber,
    required this.title,
    required this.archetype,
    this.columns = 12,
    this.rows = 16,
    this.dangerRow = 14,
    this.startingBalls = 30,
    required this.targetScore,
    required this.initialBricks,
    this.turnLimit,
    this.themeColor,
  });

  LevelData clone() {
    return LevelData(
      levelNumber: levelNumber,
      title: title,
      archetype: archetype,
      columns: columns,
      rows: rows,
      dangerRow: dangerRow,
      startingBalls: startingBalls,
      targetScore: targetScore,
      initialBricks: initialBricks.map((b) => b.copyWith()).toList(),
      turnLimit: turnLimit,
      themeColor: themeColor,
    );
  }

  LevelData copyWith({
    int? levelNumber,
    String? title,
    LevelArchetype? archetype,
    int? columns,
    int? rows,
    int? dangerRow,
    int? startingBalls,
    int? targetScore,
    List<Brick>? initialBricks,
    int? turnLimit,
    Color? themeColor,
  }) {
    return LevelData(
      levelNumber: levelNumber ?? this.levelNumber,
      title: title ?? this.title,
      archetype: archetype ?? this.archetype,
      columns: columns ?? this.columns,
      rows: rows ?? this.rows,
      dangerRow: dangerRow ?? this.dangerRow,
      startingBalls: startingBalls ?? this.startingBalls,
      targetScore: targetScore ?? this.targetScore,
      initialBricks: initialBricks ?? this.initialBricks.map((b) => b.copyWith()).toList(),
      turnLimit: turnLimit ?? this.turnLimit,
      themeColor: themeColor ?? this.themeColor,
    );
  }
}
