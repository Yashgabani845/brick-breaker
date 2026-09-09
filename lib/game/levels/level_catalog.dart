import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/game_colors.dart';
import '../models/brick.dart';
import '../models/level_data.dart';
import '../models/powerup.dart';
import 'procedural_generator.dart';

/// Master Level Catalog for Brick Smash
/// 50 Handcrafted Casual Arcade Paddle Levels matching official production specification.
class LevelCatalog {
  static final List<LevelData> levels = _buildAll50Levels();

  static LevelData getLevel(int levelNumber) {
    if (levelNumber >= 1 && levelNumber <= levels.length) {
      return levels[levelNumber - 1].clone();
    }
    return ProceduralLevelGenerator.generate(levelNumber: levelNumber);
  }

  static List<LevelData> _buildAll50Levels() {
    final List<LevelData> list = [];

    for (int i = 1; i <= 50; i++) {
      list.add(_generateHandcraftedLevel(i));
    }
    return list;
  }

  static LevelData _generateHandcraftedLevel(int levelNum) {
    int id = 1;
    final List<Brick> bricks = [];
    const int cols = 12;
    const int rows = 16;
    const int dangerRow = 14;

    // Difficulty scaling
    final baseHp = (2 + (levelNum * 1.2)).round().clamp(2, 60);
    final themeColor = _getLevelThemeColor(levelNum);
    final archetype = _getLevelArchetype(levelNum);
    final title = _getLevelTitle(levelNum);

    switch (levelNum % 10) {
      case 1: // Gateway / Arch
        for (int c = 2; c <= 9; c++) {
          bricks.add(Brick(
            id: id++,
            gridX: c,
            gridY: 2,
            type: BrickType.standard,
            hp: baseHp,
            dropPowerUp: c == 5 ? PowerUpType.multiball : null,
          ));
        }
        for (int r = 3; r <= 5; r++) {
          bricks.add(Brick(id: id++, gridX: 2, gridY: r, type: BrickType.standard, hp: baseHp));
          bricks.add(Brick(id: id++, gridX: 3, gridY: r, type: BrickType.standard, hp: baseHp));
          bricks.add(Brick(id: id++, gridX: 8, gridY: r, type: BrickType.standard, hp: baseHp));
          bricks.add(Brick(id: id++, gridX: 9, gridY: r, type: BrickType.standard, hp: baseHp));
        }
        bricks.add(Brick(id: id++, gridX: 5, gridY: 4, type: BrickType.clusterBomb, hp: 1));
        bricks.add(Brick(id: id++, gridX: 6, gridY: 4, type: BrickType.clusterBomb, hp: 1));
        break;

      case 2: // Stepped Pyramid
        for (int r = 1; r <= 5; r++) {
          final startC = 6 - r;
          final endC = 5 + r;
          for (int c = startC; c <= endC; c++) {
            final isPowerUp = (r == 3 && (c == startC || c == endC));
            bricks.add(Brick(
              id: id++,
              gridX: c,
              gridY: r + 1,
              type: BrickType.standard,
              hp: baseHp + (5 - r) * 2,
              dropPowerUp: isPowerUp ? PowerUpType.fireball : null,
            ));
          }
        }
        break;

      case 3: // Diamond Core
        for (int r = 0; r <= 6; r++) {
          final width = r <= 3 ? r : (6 - r);
          for (int dx = -width; dx <= width; dx++) {
            final c = 5 + dx;
            if (c >= 0 && c < cols) {
              final isCenter = (r == 3 && dx == 0);
              bricks.add(Brick(
                id: id++,
                gridX: c,
                gridY: r + 2,
                type: isCenter ? BrickType.horizontalLaser : BrickType.standard,
                hp: isCenter ? 1 : baseHp,
                dropPowerUp: (r == 3 && dx.abs() == 2) ? PowerUpType.widePaddle : null,
              ));
            }
          }
        }
        break;

      case 4: // Twin Fortress Pillars & Bomb Center
        for (int r = 2; r <= 7; r++) {
          bricks.add(Brick(id: id++, gridX: 1, gridY: r, type: BrickType.standard, hp: baseHp));
          bricks.add(Brick(id: id++, gridX: 2, gridY: r, type: BrickType.standard, hp: baseHp));
          bricks.add(Brick(id: id++, gridX: 9, gridY: r, type: BrickType.standard, hp: baseHp));
          bricks.add(Brick(id: id++, gridX: 10, gridY: r, type: BrickType.standard, hp: baseHp));
        }
        for (int c = 4; c <= 7; c++) {
          bricks.add(Brick(id: id++, gridX: c, gridY: 3, type: BrickType.clusterBomb, hp: 1));
          bricks.add(Brick(id: id++, gridX: c, gridY: 5, type: BrickType.standard, hp: baseHp + 5, dropPowerUp: c == 5 ? PowerUpType.multiball : null));
        }
        break;

      case 5: // Checkerboard Matrix
        for (int r = 2; r <= 6; r++) {
          for (int c = 1; c <= 10; c++) {
            if ((r + c) % 2 == 0) {
              final isLaser = (r == 4 && c == 5);
              bricks.add(Brick(
                id: id++,
                gridX: c,
                gridY: r,
                type: isLaser ? BrickType.crossLaser : BrickType.standard,
                hp: isLaser ? 1 : baseHp,
                dropPowerUp: (r == 3 && c == 3) ? PowerUpType.laserPaddle : null,
              ));
            }
          }
        }
        break;

      case 6: // Laser Highway
        for (int c = 1; c <= 10; c++) {
          bricks.add(Brick(id: id++, gridX: c, gridY: 2, type: BrickType.standard, hp: baseHp));
          bricks.add(Brick(
            id: id++,
            gridX: c,
            gridY: 4,
            type: (c == 3 || c == 8) ? BrickType.horizontalLaser : BrickType.standard,
            hp: (c == 3 || c == 8) ? 1 : baseHp + 4,
          ));
          bricks.add(Brick(id: id++, gridX: c, gridY: 6, type: BrickType.standard, hp: baseHp));
        }
        break;

      case 7: // Hourglass Funnel
        for (int c = 1; c <= 10; c++) {
          bricks.add(Brick(id: id++, gridX: c, gridY: 2, type: BrickType.standard, hp: baseHp));
          bricks.add(Brick(id: id++, gridX: c, gridY: 7, type: BrickType.standard, hp: baseHp));
        }
        for (int r = 3; r <= 6; r++) {
          final offset = (r == 3 || r == 6) ? 2 : 4;
          bricks.add(Brick(id: id++, gridX: offset, gridY: r, type: BrickType.standard, hp: baseHp));
          bricks.add(Brick(id: id++, gridX: cols - 1 - offset, gridY: r, type: BrickType.standard, hp: baseHp));
        }
        bricks.add(Brick(id: id++, gridX: 5, gridY: 4, type: BrickType.superNuke, hp: 1));
        bricks.add(Brick(id: id++, gridX: 6, gridY: 4, type: BrickType.superNuke, hp: 1));
        break;

      case 8: // Cyber Fortress
        for (int c = 1; c <= 10; c++) {
          bricks.add(Brick(id: id++, gridX: c, gridY: 2, type: BrickType.standard, hp: baseHp + 5));
          bricks.add(Brick(id: id++, gridX: c, gridY: 6, type: BrickType.standard, hp: baseHp + 5));
        }
        for (int r = 3; r <= 5; r++) {
          bricks.add(Brick(id: id++, gridX: 1, gridY: r, type: BrickType.titaniumShield, hp: 1));
          bricks.add(Brick(id: id++, gridX: 10, gridY: r, type: BrickType.titaniumShield, hp: 1));
          bricks.add(Brick(
            id: id++,
            gridX: 5,
            gridY: r,
            type: BrickType.standard,
            hp: baseHp,
            dropPowerUp: r == 4 ? PowerUpType.fireball : null,
          ));
          bricks.add(Brick(
            id: id++,
            gridX: 6,
            gridY: r,
            type: BrickType.standard,
            hp: baseHp,
            dropPowerUp: r == 4 ? PowerUpType.multiball : null,
          ));
        }
        break;

      case 9: // Crossfire Matrix
        for (int c = 1; c <= 10; c++) {
          if (c == 5 || c == 6) continue;
          bricks.add(Brick(id: id++, gridX: c, gridY: 4, type: BrickType.standard, hp: baseHp));
        }
        for (int r = 1; r <= 7; r++) {
          if (r == 4) continue;
          bricks.add(Brick(id: id++, gridX: 5, gridY: r, type: BrickType.standard, hp: baseHp));
          bricks.add(Brick(id: id++, gridX: 6, gridY: r, type: BrickType.standard, hp: baseHp));
        }
        bricks.add(Brick(id: id++, gridX: 5, gridY: 4, type: BrickType.crossLaser, hp: 1));
        bricks.add(Brick(id: id++, gridX: 6, gridY: 4, type: BrickType.crossLaser, hp: 1));
        break;

      case 0: // Chapter Boss Formation: Mega Monolith
        for (int c = 2; c <= 9; c++) {
          for (int r = 2; r <= 6; r++) {
            final isCore = (c >= 4 && c <= 7 && r >= 3 && r <= 5);
            bricks.add(Brick(
              id: id++,
              gridX: c,
              gridY: r,
              type: isCore ? BrickType.standard : ((c + r) % 3 == 0 ? BrickType.clusterBomb : BrickType.standard),
              hp: isCore ? baseHp * 2 : baseHp,
              dropPowerUp: (c == 5 && r == 4) ? PowerUpType.fireball : null,
            ));
          }
        }
        break;
    }

    return LevelData(
      levelNumber: levelNum,
      title: title,
      archetype: archetype,
      columns: cols,
      rows: rows,
      dangerRow: dangerRow,
      targetScore: 20000 + (levelNum * 4000),
      initialBricks: bricks,
      themeColor: themeColor,
    );
  }

  static Color _getLevelThemeColor(int level) {
    if (level <= 10) return const Color(0xFF00E5FF); // Neon Valley Cyan
    if (level <= 20) return const Color(0xFFFF9100); // Golden Canyon Amber
    if (level <= 30) return const Color(0xFFE040FB); // Cyber Void Purple
    if (level <= 40) return const Color(0xFFFF2A6D); // Crimson Core Red
    return const Color(0xFF00E676); // Emerald Citadel Green
  }

  static LevelArchetype _getLevelArchetype(int level) {
    switch (level % 7) {
      case 1:
        return LevelArchetype.starterGrid;
      case 2:
        return LevelArchetype.invertedFunnel;
      case 3:
        return LevelArchetype.walledFortress;
      case 4:
        return LevelArchetype.zigZagLabyrinth;
      case 5:
        return LevelArchetype.laserHighway;
      case 6:
        return LevelArchetype.orbitalChamber;
      default:
        return LevelArchetype.impossibleCitadel;
    }
  }

  static String _getLevelTitle(int level) {
    final names = [
      'Neon Gateway', 'Stepped Pyramid', 'Diamond Vault', 'Twin Fortresses', 'Checker Matrix',
      'Laser Highway', 'Hourglass Void', 'Cyber Citadel', 'Crossfire Core', 'Mega Monolith',
      'Emerald Sanctuary', 'Sunken Pillars', 'Golden Spire', 'Crystal Labyrinth', 'Plasma Arch',
      'Orbital Ring', 'Vortex Bastion', 'Prism Nexus', 'Solar Array', 'Solaris Apex',
      'Cobalt Chamber', 'Shadow Wall', 'Ruby Spire', 'Titan Forge', 'Aether Gateway',
      'Spectral Matrix', 'Hyper Grid', 'Supernova Core', 'Infinity Vault', 'Chrono Titan',
      'Quantum Reef', 'Neon Highway II', 'Dark Citadel', 'Thunder Spire', 'Obsidian Core',
      'Cyber Dragon', 'Astral Horizon', 'Cosmic Matrix', 'Starlight Citadel', 'Galaxy Overlord',
      'Apex Arena', 'Prismatic Grid', 'Void Dominion', 'Radiant Monolith', 'Eclipse Bastion',
      'Infinity Loop', 'Grand Matrix', 'Celestial Gate', 'Omega Citadel', 'Smash Supreme'
    ];
    if (level >= 1 && level <= names.length) {
      return names[level - 1];
    }
    return 'Sector Level $level';
  }
}
