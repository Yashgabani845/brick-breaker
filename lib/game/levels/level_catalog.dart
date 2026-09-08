import 'package:flutter/material.dart';
import '../../core/constants/game_colors.dart';
import '../models/brick.dart';
import '../models/level_data.dart';
import 'procedural_generator.dart';

/// Pre-authored Level Catalog featuring 20 distinct architectural archetypes and extreme hardcore stages
class LevelCatalog {
  static final List<LevelData> levels = [
    _createLevel1(),
    _createLevel2(),
    _createLevel3(),
    _createLevel4(),
    _createLevel5(),
    _createLevel6(),
    _createLevel7(),
    _createLevel8(),
    _createLevel9(),
    _createLevel10(),
    _createLevel11(),
    _createLevel12(),
    _createLevel13(),
    _createLevel14(),
    _createLevel15(),
    _createLevel16(),
    _createLevel17(),
    _createLevel18(),
    _createLevel19(),
    _createLevel20(),
  ];

  static LevelData getLevel(int levelNumber) {
    if (levelNumber <= levels.length && levelNumber >= 1) {
      return levels[levelNumber - 1].clone();
    }
    return ProceduralLevelGenerator.generate(levelNumber: levelNumber);
  }

  // --- Level 1: Neon Arch (Intro to Trajectory & +1 Permanent) ---
  static LevelData _createLevel1() {
    int id = 1;
    final List<Brick> bricks = [];

    // Arch Shape
    for (int c = 1; c <= 10; c++) {
      bricks.add(Brick(id: id++, gridX: c, gridY: 2, type: BrickType.standard, hp: 15));
    }
    // Left & Right Pillars
    for (int r = 3; r <= 5; r++) {
      bricks.add(Brick(id: id++, gridX: 1, gridY: r, type: BrickType.standard, hp: 15));
      bricks.add(Brick(id: id++, gridX: 2, gridY: r, type: BrickType.standard, hp: 15));
      bricks.add(Brick(id: id++, gridX: 9, gridY: r, type: BrickType.standard, hp: 15));
      bricks.add(Brick(id: id++, gridX: 10, gridY: r, type: BrickType.standard, hp: 15));
    }
    // Center Floating Rewards
    bricks.add(Brick(id: id++, gridX: 5, gridY: 4, type: BrickType.permanentAdder, hp: 1));
    bricks.add(Brick(id: id++, gridX: 6, gridY: 4, type: BrickType.inAirSplitter, hp: 1));

    return LevelData(
      levelNumber: 1,
      title: 'Neon Archway',
      archetype: LevelArchetype.starterGrid,
      startingBalls: 30,
      targetScore: 25000,
      initialBricks: bricks,
      themeColor: GameColors.neonCyan,
    );
  }

  // --- Level 2: The Hourglass Vortex (45° Wedges & Inverted Funnel) ---
  static LevelData _createLevel2() {
    int id = 1;
    final List<Brick> bricks = [];

    // Top Wide Funnel
    for (int c = 0; c <= 11; c++) {
      bricks.add(Brick(id: id++, gridX: c, gridY: 1, type: BrickType.standard, hp: 20));
    }
    bricks.add(Brick(id: id++, gridX: 1, gridY: 2, type: BrickType.wedgeTopRight, hp: 25));
    bricks.add(Brick(id: id++, gridX: 10, gridY: 2, type: BrickType.wedgeTopLeft, hp: 25));
    bricks.add(Brick(id: id++, gridX: 3, gridY: 3, type: BrickType.wedgeTopRight, hp: 25));
    bricks.add(Brick(id: id++, gridX: 8, gridY: 3, type: BrickType.wedgeTopLeft, hp: 25));

    // Narrow Neck & Inner Treasures
    bricks.add(Brick(id: id++, gridX: 5, gridY: 4, type: BrickType.horizontalLaser, hp: 1));
    bricks.add(Brick(id: id++, gridX: 6, gridY: 4, type: BrickType.clusterBomb, hp: 1));
    bricks.add(Brick(id: id++, gridX: 5, gridY: 5, type: BrickType.permanentAdder, hp: 1));
    bricks.add(Brick(id: id++, gridX: 6, gridY: 5, type: BrickType.inAirSplitter, hp: 1));

    // Bottom Wide Flare
    bricks.add(Brick(id: id++, gridX: 3, gridY: 6, type: BrickType.wedgeBottomRight, hp: 30));
    bricks.add(Brick(id: id++, gridX: 8, gridY: 6, type: BrickType.wedgeBottomLeft, hp: 30));
    for (int c = 2; c <= 9; c++) {
      if (c != 5 && c != 6) {
        bricks.add(Brick(id: id++, gridX: c, gridY: 7, type: BrickType.standard, hp: 30));
      }
    }

    return LevelData(
      levelNumber: 2,
      title: 'Hourglass Funnel',
      archetype: LevelArchetype.invertedFunnel,
      startingBalls: 35,
      targetScore: 45000,
      initialBricks: bricks,
      themeColor: GameColors.electricAmber,
    );
  }

  // --- Level 3: The Stepped Pyramid (Angled Wedge Stairs) ---
  static LevelData _createLevel3() {
    int id = 1;
    final List<Brick> bricks = [];

    // Apex
    bricks.add(Brick(id: id++, gridX: 5, gridY: 2, type: BrickType.clusterBomb, hp: 1));
    bricks.add(Brick(id: id++, gridX: 6, gridY: 2, type: BrickType.permanentAdder, hp: 1));

    // Tier 1
    bricks.add(Brick(id: id++, gridX: 4, gridY: 3, type: BrickType.wedgeTopRight, hp: 35));
    bricks.add(Brick(id: id++, gridX: 5, gridY: 3, type: BrickType.standard, hp: 35));
    bricks.add(Brick(id: id++, gridX: 6, gridY: 3, type: BrickType.standard, hp: 35));
    bricks.add(Brick(id: id++, gridX: 7, gridY: 3, type: BrickType.wedgeTopLeft, hp: 35));

    // Tier 2
    bricks.add(Brick(id: id++, gridX: 3, gridY: 4, type: BrickType.wedgeTopRight, hp: 40));
    for (int c = 4; c <= 7; c++) {
      bricks.add(Brick(id: id++, gridX: c, gridY: 4, type: (c == 5 || c == 6) ? BrickType.inAirSplitter : BrickType.standard, hp: 40));
    }
    bricks.add(Brick(id: id++, gridX: 8, gridY: 4, type: BrickType.wedgeTopLeft, hp: 40));

    // Tier 3
    bricks.add(Brick(id: id++, gridX: 2, gridY: 5, type: BrickType.wedgeTopRight, hp: 45));
    for (int c = 3; c <= 8; c++) {
      bricks.add(Brick(id: id++, gridX: c, gridY: 5, type: BrickType.standard, hp: 45));
    }
    bricks.add(Brick(id: id++, gridX: 9, gridY: 5, type: BrickType.wedgeTopLeft, hp: 45));

    // Base
    for (int c = 1; c <= 10; c++) {
      bricks.add(Brick(id: id++, gridX: c, gridY: 6, type: BrickType.standard, hp: 50));
    }

    return LevelData(
      levelNumber: 3,
      title: 'Stepped Pyramid',
      archetype: LevelArchetype.zigZagLabyrinth,
      startingBalls: 40,
      targetScore: 65000,
      initialBricks: bricks,
      themeColor: GameColors.solarGold,
    );
  }

  // --- Level 4: The Laser Matrix Circuit ---
  static LevelData _createLevel4() {
    int id = 1;
    final List<Brick> bricks = [];

    // Horizontal & Vertical Laser Interlocking Grid
    for (int r = 2; r <= 7; r++) {
      for (int c = 1; c <= 10; c++) {
        if (r == 3 && (c == 3 || c == 8)) {
          bricks.add(Brick(id: id++, gridX: c, gridY: r, type: BrickType.horizontalLaser, hp: 1));
        } else if (r == 6 && (c == 3 || c == 8)) {
          bricks.add(Brick(id: id++, gridX: c, gridY: r, type: BrickType.horizontalLaser, hp: 1));
        } else if (c == 5 && (r == 3 || r == 6)) {
          bricks.add(Brick(id: id++, gridX: c, gridY: r, type: BrickType.verticalLaser, hp: 1));
        } else if (c == 6 && (r == 3 || r == 6)) {
          bricks.add(Brick(id: id++, gridX: c, gridY: r, type: BrickType.crossLaser, hp: 1));
        } else if ((r == 4 || r == 5) && (c == 5 || c == 6)) {
          bricks.add(Brick(id: id++, gridX: c, gridY: r, type: (c == 5) ? BrickType.permanentAdder : BrickType.inAirSplitter, hp: 1));
        } else {
          bricks.add(Brick(id: id++, gridX: c, gridY: r, type: BrickType.standard, hp: 40));
        }
      }
    }

    return LevelData(
      levelNumber: 4,
      title: 'Laser Matrix Circuit',
      archetype: LevelArchetype.laserHighway,
      startingBalls: 45,
      targetScore: 90000,
      initialBricks: bricks,
      themeColor: GameColors.neonMagenta,
    );
  }

  // --- Level 5: The Twin Citadel (Dual Chambers & Swarm x2 Multipliers) ---
  static LevelData _createLevel5() {
    int id = 1;
    final List<Brick> bricks = [];

    // Left Tower
    for (int r = 2; r <= 7; r++) {
      for (int c = 1; c <= 4; c++) {
        if (r == 4 && c == 2) {
          bricks.add(Brick(id: id++, gridX: c, gridY: r, type: BrickType.inAirSplitter, hp: 1));
        } else if (r == 5 && c == 3) {
          bricks.add(Brick(id: id++, gridX: c, gridY: r, type: BrickType.clusterBomb, hp: 1));
        } else {
          bricks.add(Brick(id: id++, gridX: c, gridY: r, type: BrickType.armoredBrick, hp: 55));
        }
      }
    }

    // Right Tower
    for (int r = 2; r <= 7; r++) {
      for (int c = 7; c <= 10; c++) {
        if (r == 4 && c == 9) {
          bricks.add(Brick(id: id++, gridX: c, gridY: r, type: BrickType.inAirSplitter, hp: 1));
        } else if (r == 5 && c == 8) {
          bricks.add(Brick(id: id++, gridX: c, gridY: r, type: BrickType.clusterBomb, hp: 1));
        } else {
          bricks.add(Brick(id: id++, gridX: c, gridY: r, type: BrickType.armoredBrick, hp: 55));
        }
      }
    }

    // Center Chokepoint Bonus Bridge
    bricks.add(Brick(id: id++, gridX: 5, gridY: 2, type: BrickType.permanentAdder, hp: 1));
    bricks.add(Brick(id: id++, gridX: 6, gridY: 2, type: BrickType.permanentAdder, hp: 1));
    bricks.add(Brick(id: id++, gridX: 5, gridY: 5, type: BrickType.superNuke, hp: 1));
    bricks.add(Brick(id: id++, gridX: 6, gridY: 5, type: BrickType.crossLaser, hp: 1));

    return LevelData(
      levelNumber: 5,
      title: 'The Twin Citadels',
      archetype: LevelArchetype.walledFortress,
      startingBalls: 55,
      targetScore: 130000,
      initialBricks: bricks,
      themeColor: GameColors.neonPurple,
    );
  }

  // --- Level 6: The Diamond Vault (Hexagonal Ring with Orbit Core) ---
  static LevelData _createLevel6() {
    int id = 1;
    final List<Brick> bricks = [];

    // Outer Diamond Perimeter of 45° Wedges
    bricks.add(Brick(id: id++, gridX: 5, gridY: 1, type: BrickType.standard, hp: 60));
    bricks.add(Brick(id: id++, gridX: 6, gridY: 1, type: BrickType.standard, hp: 60));

    bricks.add(Brick(id: id++, gridX: 3, gridY: 2, type: BrickType.wedgeTopRight, hp: 50));
    bricks.add(Brick(id: id++, gridX: 8, gridY: 2, type: BrickType.wedgeTopLeft, hp: 50));

    bricks.add(Brick(id: id++, gridX: 1, gridY: 4, type: BrickType.wedgeTopRight, hp: 50));
    bricks.add(Brick(id: id++, gridX: 10, gridY: 4, type: BrickType.wedgeTopLeft, hp: 50));

    // Center Reactor Core
    bricks.add(Brick(id: id++, gridX: 5, gridY: 4, type: BrickType.clusterBomb, hp: 1));
    bricks.add(Brick(id: id++, gridX: 6, gridY: 4, type: BrickType.clusterBomb, hp: 1));
    bricks.add(Brick(id: id++, gridX: 5, gridY: 5, type: BrickType.inAirSplitter, hp: 1));
    bricks.add(Brick(id: id++, gridX: 6, gridY: 5, type: BrickType.inAirSplitter, hp: 1));

    // Bottom Diamond Slant
    bricks.add(Brick(id: id++, gridX: 1, gridY: 6, type: BrickType.wedgeBottomRight, hp: 50));
    bricks.add(Brick(id: id++, gridX: 10, gridY: 6, type: BrickType.wedgeBottomLeft, hp: 50));

    bricks.add(Brick(id: id++, gridX: 3, gridY: 7, type: BrickType.wedgeBottomRight, hp: 50));
    bricks.add(Brick(id: id++, gridX: 8, gridY: 7, type: BrickType.wedgeBottomLeft, hp: 50));

    for (int c = 4; c <= 7; c++) {
      bricks.add(Brick(id: id++, gridX: c, gridY: 8, type: BrickType.standard, hp: 60));
    }

    return LevelData(
      levelNumber: 6,
      title: 'The Diamond Vault',
      archetype: LevelArchetype.orbitalChamber,
      startingBalls: 65,
      targetScore: 160000,
      initialBricks: bricks,
      themeColor: GameColors.ultraIce,
    );
  }

  // --- Level 7: The Mega Hive (High Density 300+ Ball Chamber) ---
  static LevelData _createLevel7() {
    int id = 1;
    final List<Brick> bricks = [];

    // Dense grid with 6 alternating splitter nodes
    for (int r = 1; r <= 8; r++) {
      for (int c = 0; c <= 11; c++) {
        if ((r == 2 || r == 5) && (c == 2 || c == 5 || c == 8)) {
          bricks.add(Brick(id: id++, gridX: c, gridY: r, type: BrickType.inAirSplitter, hp: 1));
        } else if (r == 4 && (c == 3 || c == 7)) {
          bricks.add(Brick(id: id++, gridX: c, gridY: r, type: BrickType.crossLaser, hp: 1));
        } else if (r == 7 && (c == 4 || c == 6)) {
          bricks.add(Brick(id: id++, gridX: c, gridY: r, type: BrickType.permanentAdder, hp: 1));
        } else {
          bricks.add(Brick(id: id++, gridX: c, gridY: r, type: BrickType.standard, hp: 65));
        }
      }
    }

    return LevelData(
      levelNumber: 7,
      title: 'Mega Swarm Hive',
      archetype: LevelArchetype.orbitalChamber,
      startingBalls: 80,
      targetScore: 240000,
      initialBricks: bricks,
      themeColor: GameColors.emeraldGreen,
    );
  }

  // --- Level 8: The Iron Gate (Hardcore 120 HP Armored Barriers) ---
  static LevelData _createLevel8() {
    int id = 1;
    final List<Brick> bricks = [];

    // Heavy outer wall
    for (int r = 2; r <= 8; r++) {
      for (int c = 0; c <= 11; c++) {
        if (r == 6 && (c == 5 || c == 6)) {
          // Narrow 2-tile entrance gate
          bricks.add(Brick(id: id++, gridX: c, gridY: r, type: BrickType.inAirSplitter, hp: 1));
        } else if (r == 6) {
          bricks.add(Brick(id: id++, gridX: c, gridY: r, type: BrickType.armoredBrick, hp: 150));
        } else if (r == 3 && (c == 2 || c == 9)) {
          bricks.add(Brick(id: id++, gridX: c, gridY: r, type: BrickType.horizontalLaser, hp: 1));
        } else if (r == 4 && (c == 5 || c == 6)) {
          bricks.add(Brick(id: id++, gridX: c, gridY: r, type: BrickType.superNuke, hp: 1));
        } else {
          bricks.add(Brick(id: id++, gridX: c, gridY: r, type: BrickType.standard, hp: 90));
        }
      }
    }

    return LevelData(
      levelNumber: 8,
      title: 'The Iron Gate (Hardcore)',
      archetype: LevelArchetype.walledFortress,
      startingBalls: 100,
      targetScore: 350000,
      initialBricks: bricks,
      turnLimit: 14,
      themeColor: GameColors.titaniumSilver,
    );
  }

  // --- Level 9: Laser Crossfire Grid (Hardcore Double Cascades) ---
  static LevelData _createLevel9() {
    int id = 1;
    final List<Brick> bricks = [];

    for (int r = 2; r <= 9; r++) {
      for (int c = 0; c <= 11; c++) {
        if ((r == 3 || r == 7) && (c == 1 || c == 10)) {
          bricks.add(Brick(id: id++, gridX: c, gridY: r, type: BrickType.horizontalLaser, hp: 1));
        } else if ((c == 3 || c == 8) && (r == 2 || r == 8)) {
          bricks.add(Brick(id: id++, gridX: c, gridY: r, type: BrickType.verticalLaser, hp: 1));
        } else if (r == 5 && c == 5) {
          bricks.add(Brick(id: id++, gridX: c, gridY: r, type: BrickType.superNuke, hp: 1));
        } else if (r == 5 && c == 6) {
          bricks.add(Brick(id: id++, gridX: c, gridY: r, type: BrickType.permanentAdder, hp: 1));
        } else {
          bricks.add(Brick(id: id++, gridX: c, gridY: r, type: BrickType.armoredBrick, hp: 120));
        }
      }
    }

    return LevelData(
      levelNumber: 9,
      title: 'Laser Crossfire (Hardcore)',
      archetype: LevelArchetype.laserHighway,
      startingBalls: 120,
      targetScore: 500000,
      initialBricks: bricks,
      turnLimit: 12,
      themeColor: GameColors.neonMagenta,
    );
  }

  // --- Level 10: BRUTAL IMPOSSIBLE - The Impossible Citadel (300 HP Fortress) ---
  static LevelData _createLevel10() {
    int id = 1;
    final List<Brick> bricks = [];

    // Outer Titanium Perimeter
    for (int r = 1; r <= 10; r++) {
      for (int c = 0; c <= 11; c++) {
        if (r == 1 || r == 9 || c == 0 || c == 11) {
          if (r == 9 && c == 6) {
            // The single 1-tile needle eye entrance!
            continue;
          }
          bricks.add(Brick(id: id++, gridX: c, gridY: r, type: BrickType.armoredBrick, hp: 300));
        }
        // Inner Maze Deflector Traps
        else if ((r == 3 && c == 3) || (r == 6 && c == 8)) {
          bricks.add(Brick(id: id++, gridX: c, gridY: r, type: BrickType.wedgeBottomLeft, hp: 250));
        } else if ((r == 3 && c == 8) || (r == 6 && c == 3)) {
          bricks.add(Brick(id: id++, gridX: c, gridY: r, type: BrickType.wedgeBottomRight, hp: 250));
        }
        // Core Reactor Nucleus
        else if (r == 4 && c == 5) {
          bricks.add(Brick(id: id++, gridX: c, gridY: r, type: BrickType.chainDynamite, hp: 1));
        } else if (r == 4 && c == 6) {
          bricks.add(Brick(id: id++, gridX: c, gridY: r, type: BrickType.superNuke, hp: 1));
        } else if (r == 5 && (c == 5 || c == 6)) {
          bricks.add(Brick(id: id++, gridX: c, gridY: r, type: BrickType.inAirSplitter, hp: 1));
        } else {
          bricks.add(Brick(id: id++, gridX: c, gridY: r, type: BrickType.standard, hp: 220));
        }
      }
    }

    return LevelData(
      levelNumber: 10,
      title: 'The Impossible Citadel',
      archetype: LevelArchetype.impossibleCitadel,
      startingBalls: 140,
      targetScore: 900000,
      initialBricks: bricks,
      turnLimit: 8,
      themeColor: GameColors.crimsonDanger,
    );
  }

  // --- Level 11: The Star of Prometheus (8-Point Star Pattern) ---
  static LevelData _createLevel11() {
    int id = 1;
    final List<Brick> bricks = [];

    for (int r = 1; r <= 8; r++) {
      for (int c = 1; c <= 10; c++) {
        final isCenter = (r >= 3 && r <= 6 && c >= 4 && c <= 7);
        final isRay = (c == 5 || c == 6 || r == 4 || r == 5);
        if (isCenter && !isRay) {
          bricks.add(Brick(id: id++, gridX: c, gridY: r, type: BrickType.superNuke, hp: 1));
        } else if (isRay) {
          bricks.add(Brick(id: id++, gridX: c, gridY: r, type: BrickType.crossLaser, hp: 1));
        } else if ((r + c) % 3 == 0) {
          bricks.add(Brick(id: id++, gridX: c, gridY: r, type: BrickType.wedgeTopLeft, hp: 80));
        } else {
          bricks.add(Brick(id: id++, gridX: c, gridY: r, type: BrickType.standard, hp: 95));
        }
      }
    }

    return LevelData(
      levelNumber: 11,
      title: 'Star of Prometheus',
      archetype: LevelArchetype.orbitalChamber,
      startingBalls: 110,
      targetScore: 400000,
      initialBricks: bricks,
      themeColor: GameColors.solarGold,
    );
  }

  // --- Level 12: The Quantum Helix (Double Spiral Funnel) ---
  static LevelData _createLevel12() {
    int id = 1;
    final List<Brick> bricks = [];

    for (int r = 2; r <= 9; r++) {
      for (int c = 0; c <= 11; c++) {
        if ((r % 2 == 0 && c < 9) || (r % 2 == 1 && c > 2)) {
          if (c == 5 && r % 2 == 0) {
            bricks.add(Brick(id: id++, gridX: c, gridY: r, type: BrickType.inAirSplitter, hp: 1));
          } else if (c == 6 && r % 2 == 1) {
            bricks.add(Brick(id: id++, gridX: c, gridY: r, type: BrickType.clusterBomb, hp: 1));
          } else {
            bricks.add(Brick(id: id++, gridX: c, gridY: r, type: BrickType.standard, hp: 110));
          }
        }
      }
    }

    return LevelData(
      levelNumber: 12,
      title: 'Quantum Helix',
      archetype: LevelArchetype.zigZagLabyrinth,
      startingBalls: 120,
      targetScore: 480000,
      initialBricks: bricks,
      themeColor: GameColors.neonCyan,
    );
  }

  // --- Level 13: The Skull Fortress (Menacing Boss Silhouetted Chamber) ---
  static LevelData _createLevel13() {
    int id = 1;
    final List<Brick> bricks = [];

    for (int r = 2; r <= 9; r++) {
      for (int c = 1; c <= 10; c++) {
        // Eye Sockets
        final isEye = (r == 4 && (c == 3 || c == 4 || c == 7 || c == 8));
        // Nose cavity
        final isNose = (r == 6 && (c == 5 || c == 6));
        // Teeth
        final isTeeth = (r == 8 && c % 2 == 1 && c >= 3 && c <= 8);

        if (isEye) {
          bricks.add(Brick(id: id++, gridX: c, gridY: r, type: BrickType.clusterBomb, hp: 1));
        } else if (isNose) {
          bricks.add(Brick(id: id++, gridX: c, gridY: r, type: BrickType.inAirSplitter, hp: 1));
        } else if (!isTeeth) {
          bricks.add(Brick(id: id++, gridX: c, gridY: r, type: BrickType.armoredBrick, hp: 130));
        }
      }
    }

    return LevelData(
      levelNumber: 13,
      title: 'The Skull Bastion',
      archetype: LevelArchetype.walledFortress,
      startingBalls: 130,
      targetScore: 560000,
      initialBricks: bricks,
      themeColor: GameColors.crimsonDanger,
    );
  }

  // --- Level 14: The Laser Gauntlet ---
  static LevelData _createLevel14() {
    int id = 1;
    final List<Brick> bricks = [];

    for (int r = 2; r <= 8; r++) {
      for (int c = 0; c <= 11; c++) {
        if (r % 2 == 0 && (c == 0 || c == 11)) {
          bricks.add(Brick(id: id++, gridX: c, gridY: r, type: BrickType.horizontalLaser, hp: 1));
        } else if (c % 3 == 0 && (r == 2 || r == 8)) {
          bricks.add(Brick(id: id++, gridX: c, gridY: r, type: BrickType.verticalLaser, hp: 1));
        } else {
          bricks.add(Brick(id: id++, gridX: c, gridY: r, type: BrickType.standard, hp: 120));
        }
      }
    }

    return LevelData(
      levelNumber: 14,
      title: 'Laser Gauntlet',
      archetype: LevelArchetype.laserHighway,
      startingBalls: 135,
      targetScore: 620000,
      initialBricks: bricks,
      themeColor: GameColors.electricAmber,
    );
  }

  // --- Level 15: The Dragon's Maw (Spiked Teeth Chambers) ---
  static LevelData _createLevel15() {
    int id = 1;
    final List<Brick> bricks = [];

    for (int c = 1; c <= 10; c++) {
      // Upper Jaw (Wedges pointing down)
      final wedgeTypeTop = (c % 2 == 0) ? BrickType.wedgeTopRight : BrickType.wedgeTopLeft;
      bricks.add(Brick(id: id++, gridX: c, gridY: 2, type: wedgeTypeTop, hp: 140));

      // Lower Jaw (Wedges pointing up)
      final wedgeTypeBottom = (c % 2 == 0) ? BrickType.wedgeBottomRight : BrickType.wedgeBottomLeft;
      bricks.add(Brick(id: id++, gridX: c, gridY: 7, type: wedgeTypeBottom, hp: 140));
    }

    // Interior Tongue / Fire Core
    for (int c = 3; c <= 8; c++) {
      bricks.add(Brick(id: id++, gridX: c, gridY: 4, type: (c == 5 || c == 6) ? BrickType.superNuke : BrickType.inAirSplitter, hp: 1));
      bricks.add(Brick(id: id++, gridX: c, gridY: 5, type: BrickType.standard, hp: 150));
    }

    return LevelData(
      levelNumber: 15,
      title: "The Dragon's Maw",
      archetype: LevelArchetype.invertedFunnel,
      startingBalls: 140,
      targetScore: 700000,
      initialBricks: bricks,
      themeColor: GameColors.electricAmber,
    );
  }

  // --- Level 16: The Void Singularity ---
  static LevelData _createLevel16() {
    int id = 1;
    final List<Brick> bricks = [];

    for (int r = 2; r <= 8; r++) {
      for (int c = 1; c <= 10; c++) {
        final distToCenter = ((r - 5) * (r - 5) + (c - 5.5) * (c - 5.5));
        if (distToCenter <= 2.5) {
          bricks.add(Brick(id: id++, gridX: c, gridY: r, type: BrickType.chainDynamite, hp: 1));
        } else if (distToCenter <= 10) {
          bricks.add(Brick(id: id++, gridX: c, gridY: r, type: BrickType.armoredBrick, hp: 180));
        } else {
          bricks.add(Brick(id: id++, gridX: c, gridY: r, type: BrickType.standard, hp: 140));
        }
      }
    }

    return LevelData(
      levelNumber: 16,
      title: 'Void Singularity',
      archetype: LevelArchetype.orbitalChamber,
      startingBalls: 150,
      targetScore: 780000,
      initialBricks: bricks,
      themeColor: GameColors.neonPurple,
    );
  }

  // --- Level 17: The Titan's Shield ---
  static LevelData _createLevel17() {
    int id = 1;
    final List<Brick> bricks = [];

    for (int r = 2; r <= 9; r++) {
      for (int c = 0; c <= 11; c++) {
        if ((r == 2 || r == 8) && (c >= 2 && c <= 9)) {
          bricks.add(Brick(id: id++, gridX: c, gridY: r, type: BrickType.armoredBrick, hp: 220));
        } else if ((c == 2 || c == 9) && (r >= 3 && r <= 7)) {
          bricks.add(Brick(id: id++, gridX: c, gridY: r, type: BrickType.armoredBrick, hp: 220));
        } else if (r == 5 && (c == 5 || c == 6)) {
          bricks.add(Brick(id: id++, gridX: c, gridY: r, type: BrickType.superNuke, hp: 1));
        } else if (r >= 4 && r <= 6 && c >= 4 && c <= 7) {
          bricks.add(Brick(id: id++, gridX: c, gridY: r, type: BrickType.inAirSplitter, hp: 1));
        } else {
          bricks.add(Brick(id: id++, gridX: c, gridY: r, type: BrickType.standard, hp: 160));
        }
      }
    }

    return LevelData(
      levelNumber: 17,
      title: "The Titan's Shield",
      archetype: LevelArchetype.walledFortress,
      startingBalls: 160,
      targetScore: 850000,
      initialBricks: bricks,
      themeColor: GameColors.titaniumSilver,
    );
  }

  // --- Level 18: The Supernova Reactor ---
  static LevelData _createLevel18() {
    int id = 1;
    final List<Brick> bricks = [];

    for (int r = 1; r <= 8; r++) {
      for (int c = 0; c <= 11; c++) {
        if (r == c || r + c == 11) {
          bricks.add(Brick(id: id++, gridX: c, gridY: r, type: BrickType.crossLaser, hp: 1));
        } else if (r % 2 == 0 && c % 2 == 0) {
          bricks.add(Brick(id: id++, gridX: c, gridY: r, type: BrickType.clusterBomb, hp: 1));
        } else {
          bricks.add(Brick(id: id++, gridX: c, gridY: r, type: BrickType.standard, hp: 180));
        }
      }
    }

    return LevelData(
      levelNumber: 18,
      title: 'Supernova Reactor',
      archetype: LevelArchetype.laserHighway,
      startingBalls: 170,
      targetScore: 920000,
      initialBricks: bricks,
      themeColor: GameColors.solarGold,
    );
  }

  // --- Level 19: The Cyber Labyrinth ---
  static LevelData _createLevel19() {
    int id = 1;
    final List<Brick> bricks = [];

    for (int r = 2; r <= 9; r++) {
      for (int c = 0; c <= 11; c++) {
        if (c % 2 == 1 && r % 2 == 1) {
          bricks.add(Brick(id: id++, gridX: c, gridY: r, type: BrickType.wedgeTopLeft, hp: 200));
        } else if (c % 2 == 0 && r % 2 == 0) {
          bricks.add(Brick(id: id++, gridX: c, gridY: r, type: BrickType.wedgeBottomRight, hp: 200));
        } else if (r == 5 && c == 5) {
          bricks.add(Brick(id: id++, gridX: c, gridY: r, type: BrickType.superNuke, hp: 1));
        } else {
          bricks.add(Brick(id: id++, gridX: c, gridY: r, type: BrickType.standard, hp: 190));
        }
      }
    }

    return LevelData(
      levelNumber: 19,
      title: 'The Cyber Labyrinth',
      archetype: LevelArchetype.zigZagLabyrinth,
      startingBalls: 180,
      targetScore: 980000,
      initialBricks: bricks,
      themeColor: GameColors.emeraldGreen,
    );
  }

  // --- Level 20: The Apex Boss Citadel (BRUTAL APEX) ---
  static LevelData _createLevel20() {
    int id = 1;
    final List<Brick> bricks = [];

    for (int r = 1; r <= 11; r++) {
      for (int c = 0; c <= 11; c++) {
        final isPerimeter = (r == 1 || r == 11 || c == 0 || c == 11);
        if (isPerimeter) {
          if (r == 11 && c == 6) continue; // Single 1-tile entrance
          bricks.add(Brick(id: id++, gridX: c, gridY: r, type: BrickType.armoredBrick, hp: 450));
        } else if ((r == 4 && c == 4) || (r == 8 && c == 7)) {
          bricks.add(Brick(id: id++, gridX: c, gridY: r, type: BrickType.wedgeTopRight, hp: 300));
        } else if ((r == 4 && c == 7) || (r == 8 && c == 4)) {
          bricks.add(Brick(id: id++, gridX: c, gridY: r, type: BrickType.wedgeTopLeft, hp: 300));
        } else if (r == 6 && (c == 5 || c == 6)) {
          bricks.add(Brick(id: id++, gridX: c, gridY: r, type: BrickType.chainDynamite, hp: 1));
        } else if (r == 7 && (c == 5 || c == 6)) {
          bricks.add(Brick(id: id++, gridX: c, gridY: r, type: BrickType.superNuke, hp: 1));
        } else {
          bricks.add(Brick(id: id++, gridX: c, gridY: r, type: BrickType.standard, hp: 350));
        }
      }
    }

    return LevelData(
      levelNumber: 20,
      title: 'The Apex Citadel (BOSS)',
      archetype: LevelArchetype.impossibleCitadel,
      startingBalls: 200,
      targetScore: 1500000,
      initialBricks: bricks,
      turnLimit: 10,
      themeColor: GameColors.crimsonDanger,
    );
  }
}
