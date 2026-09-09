import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/game_colors.dart';
import '../models/brick.dart';
import '../models/level_data.dart';
import 'shape_library.dart';

// =============================================================================
// BRICKS BREAKER 3D — COMPREHENSIVE 1000-LEVEL PROCEDURAL ENGINE v2
// 18 Blueprint Strategies | Psychographic Waves | HP Gradients | Tactical Powerups
// =============================================================================

enum _Blueprint {
  openArch, columnPairs, staircase, invertedV, crossroads,
  diamondRing, waveAssault, battlement, spiderWeb, checkered,
  hourglass, spiralArm, tridentFork, tunnelRun, fortressCore,
  chainReactor, labyrinthal, sectorBoss,
}

enum _DiffTier { tutorial, easy, medium, hard, extreme, impossible }

class _FeatureSet {
  final int level;
  final bool hasPermBall, hasTurnBall, hasSplitter, hasLaser;
  final bool hasCrossLaser, hasBomb, hasDynamite, hasNuke;
  final bool hasArmored, hasTitanium, hasWedge;

  const _FeatureSet({
    required this.level, required this.hasPermBall, required this.hasTurnBall,
    required this.hasSplitter, required this.hasLaser, required this.hasCrossLaser,
    required this.hasBomb, required this.hasDynamite, required this.hasNuke,
    required this.hasArmored, required this.hasTitanium, required this.hasWedge,
  });

  factory _FeatureSet.forLevel(int lvl) => _FeatureSet(
    level: lvl,
    hasPermBall: lvl >= 1,   hasTurnBall: lvl >= 5,   hasSplitter: lvl >= 3,
    hasWedge: lvl >= 4,      hasLaser: lvl >= 7,       hasBomb: lvl >= 10,
    hasDynamite: lvl >= 15,  hasCrossLaser: lvl >= 18, hasNuke: lvl >= 25,
    hasArmored: lvl >= 12,   hasTitanium: lvl >= 35,
  );
}

class ProceduralLevelGenerator {
  static const List<Color> _palettes = [
    GameColors.neonCyan, GameColors.electricAmber, GameColors.neonMagenta,
    GameColors.solarGold, GameColors.crimsonDanger, GameColors.neonPurple,
    Color(0xFF00FF66), Color(0xFF00E5FF), Color(0xFF38BDF8), Color(0xFF10B981),
    Color(0xFFF97316), Color(0xFF8B5CF6), Color(0xFFFF6B6B), Color(0xFF4ECDC4),
    Color(0xFFFFE66D), Color(0xFF95E1D3), Color(0xFFF38181), Color(0xFF3FC1C9),
    Color(0xFFFC5185), Color(0xFF364F6B),
  ];

  static LevelData generate({
    required int levelNumber,
    int columns = 12,
    int rows = 16,
    int dangerRow = 14,
  }) {
    final rand = math.Random(levelNumber * 6571 + levelNumber * levelNumber % 997 + 13);
    final tier       = _tier(levelNumber);
    final wave       = _waveFactor(levelNumber);
    final baseHp     = _baseHp(levelNumber, tier, wave);
    final startBalls = _startingBalls(levelNumber, tier);
    final theme      = _palettes[(levelNumber - 1) % _palettes.length];
    final blueprint  = _chooseBlueprint(levelNumber, rand);
    final features   = _FeatureSet.forLevel(levelNumber);
    int idC = 1;
    final bricks = <Brick>[];

    _buildLayout(blueprint, levelNumber, rand, columns, baseHp, features, bricks, () => idC++);
    if (bricks.isEmpty) {
      _buildWaveAssault(levelNumber, rand, columns, baseHp, features, bricks, () => idC++, dense: false);
    }

    return LevelData(
      levelNumber: levelNumber,
      title: _title(levelNumber, blueprint, ShapeLibrary.getShapeForLevel(levelNumber)),
      archetype: _archetype(levelNumber, blueprint),
      columns: columns, rows: rows, dangerRow: dangerRow,
      startingBalls: startBalls,
      targetScore: levelNumber * 85000 + tier.index * 15000,
      initialBricks: bricks,
      turnLimit: _turnLimit(levelNumber, tier),
      themeColor: theme,
    );
  }

  // ── Blueprint Selector ────────────────────────────────────────────────────
  static _Blueprint _chooseBlueprint(int lvl, math.Random rand) {
    if (lvl % 100 == 0) return _Blueprint.sectorBoss;
    if (lvl % 50  == 0) return _Blueprint.fortressCore;
    if (lvl % 25  == 0) return _Blueprint.chainReactor;
    if (lvl % 10  == 0) return _Blueprint.waveAssault;
    switch (lvl) {
      case 1: return _Blueprint.openArch;
      case 2: return _Blueprint.columnPairs;
      case 3: return _Blueprint.staircase;
      case 4: return _Blueprint.invertedV;
      case 5: return _Blueprint.crossroads;
      case 6: return _Blueprint.diamondRing;
      case 7: return _Blueprint.battlement;
      case 8: return _Blueprint.spiderWeb;
      case 9: return _Blueprint.checkered;
      default: break;
    }
    final pool = _pool(lvl);
    return pool[rand.nextInt(pool.length)];
  }

  static List<_Blueprint> _pool(int lvl) {
    if (lvl <= 50) {
      return [_Blueprint.openArch, _Blueprint.columnPairs, _Blueprint.staircase,
              _Blueprint.invertedV, _Blueprint.crossroads, _Blueprint.diamondRing,
              _Blueprint.battlement, _Blueprint.waveAssault, _Blueprint.checkered];
    } else if (lvl <= 200) {
      return [_Blueprint.diamondRing, _Blueprint.waveAssault, _Blueprint.battlement,
              _Blueprint.spiderWeb, _Blueprint.checkered, _Blueprint.hourglass,
              _Blueprint.spiralArm, _Blueprint.tridentFork, _Blueprint.tunnelRun,
              _Blueprint.staircase, _Blueprint.crossroads];
    } else if (lvl <= 500) {
      return [_Blueprint.hourglass, _Blueprint.spiralArm, _Blueprint.tridentFork,
              _Blueprint.tunnelRun, _Blueprint.fortressCore, _Blueprint.chainReactor,
              _Blueprint.labyrinthal, _Blueprint.waveAssault, _Blueprint.battlement,
              _Blueprint.spiderWeb, _Blueprint.checkered, _Blueprint.diamondRing];
    } else {
      return [_Blueprint.fortressCore, _Blueprint.chainReactor, _Blueprint.labyrinthal,
              _Blueprint.waveAssault, _Blueprint.hourglass, _Blueprint.tridentFork,
              _Blueprint.tunnelRun, _Blueprint.spiralArm, _Blueprint.battlement];
    }
  }

  // ── Layout Dispatcher ─────────────────────────────────────────────────────
  static void _buildLayout(_Blueprint bp, int lvl, math.Random rand, int cols,
      int baseHp, _FeatureSet f, List<Brick> bricks, int Function() id) {
    switch (bp) {
      case _Blueprint.openArch:     _buildOpenArch(lvl, rand, cols, baseHp, f, bricks, id);
      case _Blueprint.columnPairs:  _buildColumnPairs(lvl, rand, cols, baseHp, f, bricks, id);
      case _Blueprint.staircase:    _buildStaircase(lvl, rand, cols, baseHp, f, bricks, id);
      case _Blueprint.invertedV:    _buildInvertedV(lvl, rand, cols, baseHp, f, bricks, id);
      case _Blueprint.crossroads:   _buildCrossroads(lvl, rand, cols, baseHp, f, bricks, id);
      case _Blueprint.diamondRing:  _buildDiamondRing(lvl, rand, cols, baseHp, f, bricks, id);
      case _Blueprint.waveAssault:  _buildWaveAssault(lvl, rand, cols, baseHp, f, bricks, id, dense: lvl >= 50);
      case _Blueprint.battlement:   _buildBattlement(lvl, rand, cols, baseHp, f, bricks, id);
      case _Blueprint.spiderWeb:    _buildSpiderWeb(lvl, rand, cols, baseHp, f, bricks, id);
      case _Blueprint.checkered:    _buildCheckered(lvl, rand, cols, baseHp, f, bricks, id);
      case _Blueprint.hourglass:    _buildHourglass(lvl, rand, cols, baseHp, f, bricks, id);
      case _Blueprint.spiralArm:    _buildSpiralArm(lvl, rand, cols, baseHp, f, bricks, id);
      case _Blueprint.tridentFork:  _buildTridentFork(lvl, rand, cols, baseHp, f, bricks, id);
      case _Blueprint.tunnelRun:    _buildTunnelRun(lvl, rand, cols, baseHp, f, bricks, id);
      case _Blueprint.fortressCore: _buildFortressCore(lvl, rand, cols, baseHp, f, bricks, id);
      case _Blueprint.chainReactor: _buildChainReactor(lvl, rand, cols, baseHp, f, bricks, id);
      case _Blueprint.labyrinthal:  _buildLabyrinthal(lvl, rand, cols, baseHp, f, bricks, id);
      case _Blueprint.sectorBoss:   _buildSectorBoss(lvl, rand, cols, baseHp, f, bricks, id);
    }
  }

  // ==========================================================================
  // 18 BLUEPRINT IMPLEMENTATIONS
  // ==========================================================================

  // Blueprint 1: Open Arch — basic arch shape, all powerups visible
  static void _buildOpenArch(int lvl, math.Random rand, int cols, int baseHp,
      _FeatureSet f, List<Brick> bricks, int Function() id) {
    for (int c = 1; c <= cols - 2; c++) {
      bricks.add(_bk(id(), c, 2, baseHp, f, rand));
    }
    for (int r = 3; r <= 5; r++) {
      for (int c in [1, 2, cols - 3, cols - 2]) {
        bricks.add(_bk(id(), c, r, _grad(baseHp, r, 2, 6), f, rand));
      }
    }
    _cluster(bricks, id, f, 5, 4, cols);
  }

  // Blueprint 2: Column Pairs — 4 pairs of tall columns, teach angle shots
  static void _buildColumnPairs(int lvl, math.Random rand, int cols, int baseHp,
      _FeatureSet f, List<Brick> bricks, int Function() id) {
    final maxRow = (4 + lvl ~/ 15).clamp(4, 10);
    for (int r = 2; r <= maxRow; r++) {
      for (int c in [1, 2, 4, 5, 7, 8, 10, 11]) {
        if (c < cols) bricks.add(_bk(id(), c, r, _grad(baseHp, r, 2, maxRow), f, rand));
      }
    }
    for (int gap in [3, 6, 9]) {
      if (rand.nextDouble() < 0.6 && f.hasTurnBall && gap < cols) {
        bricks.add(Brick(id: id(), gridX: gap, gridY: 3, type: BrickType.turnBallAdder, hp: 1));
      }
    }
  }

  // Blueprint 3: Staircase — diagonal cascades both directions
  static void _buildStaircase(int lvl, math.Random rand, int cols, int baseHp,
      _FeatureSet f, List<Brick> bricks, int Function() id) {
    final steps = (3 + lvl ~/ 10).clamp(3, 9);
    for (int step = 0; step < steps; step++) {
      final cL = 1 + step;
      final cR = cols - 2 - step;
      final rStart = 2 + step;
      for (int r = rStart; r <= (rStart + 2).clamp(rStart, 12); r++) {
        if (cL < cols && r <= 12) bricks.add(_bk(id(), cL, r, _grad(baseHp, r, 2, 12), f, rand));
        if (lvl >= 3 && cR >= 0 && r <= 12) bricks.add(_bk(id(), cR, r, _grad(baseHp, r, 2, 12), f, rand));
      }
    }
    if (f.hasWedge) {
      bricks.add(Brick(id: id(), gridX: 0, gridY: 2, type: BrickType.wedgeBottomRight, hp: baseHp));
      bricks.add(Brick(id: id(), gridX: cols - 1, gridY: 2, type: BrickType.wedgeBottomLeft, hp: baseHp));
    }
  }

  // Blueprint 4: Inverted V — overhead pyramid, teaches under-overhang shots
  static void _buildInvertedV(int lvl, math.Random rand, int cols, int baseHp,
      _FeatureSet f, List<Brick> bricks, int Function() id) {
    final half = cols ~/ 2;
    for (int r = 2; r <= 8; r++) {
      final width = half - (r - 2);
      if (width <= 0) break;
      for (int c = half - width; c <= half + width; c++) {
        if (c >= 0 && c < cols) bricks.add(_bk(id(), c, r, _grad(baseHp, r, 2, 8), f, rand));
      }
    }
    if (f.hasPermBall) {
      bricks.add(Brick(id: id(), gridX: half, gridY: 9, type: BrickType.permanentAdder, hp: 1));
    }
  }

  // Blueprint 5: Crossroads — plus shape, alternating shot angles
  static void _buildCrossroads(int lvl, math.Random rand, int cols, int baseHp,
      _FeatureSet f, List<Brick> bricks, int Function() id) {
    final half = cols ~/ 2;
    for (int c = 0; c < cols; c++) bricks.add(_bk(id(), c, 5, baseHp, f, rand));
    for (int r = 2; r <= 9; r++) {
      if (r != 5) {
        bricks.add(_bk(id(), half - 1, r, _grad(baseHp, r, 2, 9), f, rand));
        bricks.add(_bk(id(), half, r, _grad(baseHp, r, 2, 9), f, rand));
      }
    }
    if (f.hasTurnBall) {
      bricks.add(Brick(id: id(), gridX: 2, gridY: 2, type: BrickType.turnBallAdder, hp: 1));
      bricks.add(Brick(id: id(), gridX: cols - 3, gridY: 2, type: BrickType.turnBallAdder, hp: 1));
    }
    if (f.hasSplitter) {
      bricks.add(Brick(id: id(), gridX: 2, gridY: 8, type: BrickType.inAirSplitter, hp: 1));
      bricks.add(Brick(id: id(), gridX: cols - 3, gridY: 8, type: BrickType.inAirSplitter, hp: 1));
    }
  }

  // Blueprint 6: Diamond Ring — hollow diamond, centre rewards inside shots
  static void _buildDiamondRing(int lvl, math.Random rand, int cols, int baseHp,
      _FeatureSet f, List<Brick> bricks, int Function() id) {
    final cx = cols ~/ 2;
    const cy = 6;
    for (int r = 1; r <= 11; r++) {
      for (int c = 0; c < cols; c++) {
        final dist = (c - cx).abs() + (r - cy).abs();
        if (dist <= 5 && dist >= 3) bricks.add(_bk(id(), c, r, _grad(baseHp, r, 1, 11), f, rand));
      }
    }
    if (f.hasBomb) bricks.add(Brick(id: id(), gridX: cx, gridY: cy, type: BrickType.clusterBomb, hp: 1));
    if (f.hasTurnBall) {
      bricks.add(Brick(id: id(), gridX: cx - 1, gridY: cy, type: BrickType.turnBallAdder, hp: 1));
      bricks.add(Brick(id: id(), gridX: cx + 1, gridY: cy, type: BrickType.turnBallAdder, hp: 1));
    }
  }

  // Blueprint 7: Wave Assault — dense horizontal rows, endurance gauntlet
  static void _buildWaveAssault(int lvl, math.Random rand, int cols, int baseHp,
      _FeatureSet f, List<Brick> bricks, int Function() id, {required bool dense}) {
    final rowCount = dense ? (4 + lvl ~/ 25).clamp(4, 10) : 3;
    for (int r = 2; r < 2 + rowCount; r++) {
      for (int c = 0; c < cols; c++) {
        if (!dense && rand.nextDouble() < 0.12) continue;
        final hp = _grad(baseHp, r, 2, 2 + rowCount - 1);
        final type = _waveType(c, r, cols, f, rand, lvl);
        final brickHp = type == BrickType.standard ? hp : type == BrickType.armoredBrick ? (hp * 1.5).round() : 1;
        bricks.add(Brick(id: id(), gridX: c, gridY: r, type: type, hp: brickHp));
      }
    }
  }

  // Blueprint 8: Battlement — castle crenellation, powerups in crenels
  static void _buildBattlement(int lvl, math.Random rand, int cols, int baseHp,
      _FeatureSet f, List<Brick> bricks, int Function() id) {
    for (int c = 0; c < cols; c++) {
      if (c % 3 == 1) continue;
      final height = (c % 6 == 0) ? 5 : 3;
      for (int r = 2; r <= 1 + height; r++) {
        final type = (lvl >= 30 && r == 2 && f.hasArmored) ? BrickType.armoredBrick : BrickType.standard;
        bricks.add(Brick(id: id(), gridX: c, gridY: r, type: type,
            hp: type == BrickType.armoredBrick ? (baseHp * 1.6).round() : _grad(baseHp, r, 2, 7)));
      }
    }
    for (int c = 0; c < cols; c++) {
      final type = (f.hasTitanium && c % 5 == 0) ? BrickType.titaniumShield : BrickType.standard;
      bricks.add(Brick(id: id(), gridX: c, gridY: 7, type: type, hp: type == BrickType.titaniumShield ? 9999 : baseHp));
    }
    for (int c = 1; c < cols; c += 3) {
      if (rand.nextDouble() < 0.5) {
        bricks.add(Brick(id: id(), gridX: c, gridY: 4,
            type: f.hasTurnBall ? BrickType.turnBallAdder : BrickType.permanentAdder, hp: 1));
      }
    }
  }

  // Blueprint 9: Spider Web — radial spokes + concentric rings
  static void _buildSpiderWeb(int lvl, math.Random rand, int cols, int baseHp,
      _FeatureSet f, List<Brick> bricks, int Function() id) {
    final cx = cols / 2.0;
    const cy = 6.0;
    for (int r = 1; r <= 11; r++) {
      for (int c = 0; c < cols; c++) {
        final dx = c - cx;
        final dy = r - cy;
        final dist = math.sqrt(dx * dx + dy * dy);
        final angle = math.atan2(dy, dx);
        final onRing = (dist > 1.8 && dist < 2.2) || (dist > 3.8 && dist < 4.2) || (dist > 5.5 && dist < 6.2);
        final spokeIdx = ((angle + math.pi) / math.pi * 6).round() % 6;
        final onSpoke = dist < 6.5 && (angle - (spokeIdx * math.pi * 2 / 6 - math.pi)).abs() < 0.22;
        if ((onRing || onSpoke) && dist > 0.5) {
          bricks.add(_bk(id(), c, r, _grad(baseHp, (dist * 1.5).round(), 1, 10), f, rand));
        }
      }
    }
    if (f.hasNuke) {
      bricks.add(Brick(id: id(), gridX: cx.round(), gridY: cy.round(), type: BrickType.superNuke, hp: 1));
    }
  }

  // Blueprint 10: Checkered — alternating cells, predictive bounce training
  static void _buildCheckered(int lvl, math.Random rand, int cols, int baseHp,
      _FeatureSet f, List<Brick> bricks, int Function() id) {
    final numRows = (3 + lvl ~/ 15).clamp(3, 9);
    for (int r = 2; r < 2 + numRows; r++) {
      for (int c = 0; c < cols; c++) {
        if ((r + c) % 2 != 0) continue;
        final hp = _grad(baseHp, r, 2, 2 + numRows - 1);
        final type = _selectType(c, r, cols, f, rand, lvl, stdChance: 0.70);
        bricks.add(Brick(id: id(), gridX: c, gridY: r, type: type,
            hp: type == BrickType.standard ? hp : type == BrickType.armoredBrick ? (hp * 1.5).round() : 1));
      }
    }
  }

  // Blueprint 11: Hourglass — wide/narrow/wide, forces shots through waist gap
  static void _buildHourglass(int lvl, math.Random rand, int cols, int baseHp,
      _FeatureSet f, List<Brick> bricks, int Function() id) {
    final cx = cols ~/ 2;
    for (int r = 2; r <= 11; r++) {
      final dist = (r - 6.5).abs();
      final width = (2 + dist * 1.1).round().clamp(1, cx);
      for (int c = cx - width; c <= cx + width; c++) {
        if (c >= 0 && c < cols) {
          final type = _selectType(c, r, cols, f, rand, lvl);
          bricks.add(Brick(id: id(), gridX: c, gridY: r, type: type,
              hp: type == BrickType.standard ? _grad(baseHp, r, 2, 11)
                  : type == BrickType.armoredBrick ? (_grad(baseHp, r, 2, 11) * 1.5).round()
                  : 1));
        }
      }
    }
    if (f.hasTurnBall) {
      bricks.add(Brick(id: id(), gridX: cx, gridY: 6, type: BrickType.turnBallAdder, hp: 1));
      bricks.add(Brick(id: id(), gridX: cx, gridY: 7, type: BrickType.turnBallAdder, hp: 1));
    }
  }

  // Blueprint 12: Spiral Arm — Archimedean spiral, tests all shot angles
  static void _buildSpiralArm(int lvl, math.Random rand, int cols, int baseHp,
      _FeatureSet f, List<Brick> bricks, int Function() id) {
    final cx = cols / 2.0;
    const cy = 6.0;
    for (double theta = 0; theta <= math.pi * 4; theta += 0.18) {
      final radius = 0.8 + theta * 0.7;
      final gx = (cx + radius * math.cos(theta)).round();
      final gy = (cy + radius * math.sin(theta)).round();
      if (gx >= 0 && gx < cols && gy >= 1 && gy <= 12 &&
          !bricks.any((b) => b.gridX == gx && b.gridY == gy)) {
        bricks.add(_bk(id(), gx, gy, _grad(baseHp, gy, 1, 12), f, rand));
      }
    }
  }

  // Blueprint 13: Trident Fork — 3 prongs with laser tips trigger chains
  static void _buildTridentFork(int lvl, math.Random rand, int cols, int baseHp,
      _FeatureSet f, List<Brick> bricks, int Function() id) {
    for (int r = 7; r <= 11; r++) {
      for (int c = 4; c <= 7; c++) bricks.add(_bk(id(), c, r, _grad(baseHp, r, 7, 11), f, rand));
    }
    for (int pc in [2, 5, 8]) {
      for (int r = 2; r <= 6; r++) {
        if (pc >= 0 && pc < cols) bricks.add(_bk(id(), pc, r, _grad(baseHp, r, 2, 6), f, rand));
        if (pc + 1 < cols) bricks.add(_bk(id(), pc + 1, r, _grad(baseHp, r, 2, 6), f, rand));
      }
      if (f.hasLaser) bricks.add(Brick(id: id(), gridX: pc, gridY: 2, type: BrickType.horizontalLaser, hp: 1));
    }
    if (f.hasPermBall) bricks.add(Brick(id: id(), gridX: 5, gridY: 12, type: BrickType.permanentAdder, hp: 1));
  }

  // Blueprint 14: Tunnel Run — narrow gaps in walls, extreme precision
  static void _buildTunnelRun(int lvl, math.Random rand, int cols, int baseHp,
      _FeatureSet f, List<Brick> bricks, int Function() id) {
    final tunnelRows = {3, 5, 7, 9, 11}.take((2 + lvl ~/ 60).clamp(2, 5)).toSet();
    for (int r = 2; r <= 11; r++) {
      if (tunnelRows.contains(r)) continue;
      for (int c = 0; c < cols; c++) {
        final gapCentre = (cols / 2 + (r % 3 - 1) * 3).round();
        if (c == gapCentre || c == gapCentre + 1) {
          if (rand.nextDouble() < 0.3 && f.hasTurnBall) {
            bricks.add(Brick(id: id(), gridX: c, gridY: r, type: BrickType.turnBallAdder, hp: 1));
          }
          continue;
        }
        final type = (f.hasTitanium && c % 4 == 0 && lvl >= 100) ? BrickType.titaniumShield : BrickType.standard;
        bricks.add(Brick(id: id(), gridX: c, gridY: r, type: type,
            hp: type == BrickType.titaniumShield ? 9999 : _grad(baseHp, r, 2, 11)));
      }
    }
  }

  // Blueprint 15: Fortress Core — titanium wall + ultra-HP inner core
  static void _buildFortressCore(int lvl, math.Random rand, int cols, int baseHp,
      _FeatureSet f, List<Brick> bricks, int Function() id) {
    final coreHp = (baseHp * 2.5).round().clamp(baseHp, 99999);
    for (int c = 0; c < cols; c++) {
      bricks.add(Brick(id: id(), gridX: c, gridY: 2, type: BrickType.titaniumShield, hp: 9999));
      bricks.add(Brick(id: id(), gridX: c, gridY: 8, type: BrickType.titaniumShield, hp: 9999));
    }
    for (int r = 3; r <= 7; r++) {
      bricks.add(Brick(id: id(), gridX: 0, gridY: r, type: BrickType.titaniumShield, hp: 9999));
      bricks.add(Brick(id: id(), gridX: cols - 1, gridY: r, type: BrickType.titaniumShield, hp: 9999));
    }
    // Entry gaps (2-wide openings in top and bottom wall)
    bricks.removeWhere((b) =>
      (b.gridY == 2 && (b.gridX == 4 || b.gridX == 7)) ||
      (b.gridY == 8 && (b.gridX == 4 || b.gridX == 7)));
    // Inner armored core
    for (int r = 3; r <= 7; r++) {
      for (int c = 1; c <= cols - 2; c++) {
        final shell = (r == 3 || r == 7 || c == 1 || c == cols - 2);
        final type = shell ? BrickType.armoredBrick : BrickType.standard;
        bricks.add(Brick(id: id(), gridX: c, gridY: r, type: type,
            hp: (shell ? coreHp * 1.3 : coreHp.toDouble()).round().clamp(1, 99999)));
      }
    }
    if (f.hasNuke) {
      final cx = cols ~/ 2;
      bricks.add(Brick(id: id(), gridX: cx, gridY: 5, type: BrickType.superNuke, hp: 1));
      bricks.add(Brick(id: id(), gridX: cx - 1, gridY: 5, type: BrickType.permanentAdder, hp: 1));
      bricks.add(Brick(id: id(), gridX: cx + 1, gridY: 5, type: BrickType.permanentAdder, hp: 1));
    }
  }

  // Blueprint 16: Chain Reactor — laser→bomb adjacency for engineered chains
  static void _buildChainReactor(int lvl, math.Random rand, int cols, int baseHp,
      _FeatureSet f, List<Brick> bricks, int Function() id) {
    for (int r = 4; r <= 11; r++) {
      for (int c = 0; c < cols; c++) {
        if (rand.nextDouble() < 0.65) {
          bricks.add(Brick(id: id(), gridX: c, gridY: r,
              type: BrickType.standard, hp: _grad(baseHp, r, 4, 11)));
        }
      }
    }
    int i = 0;
    for (int c = 1; c < cols - 1; c += 3, i++) {
      if (f.hasLaser) {
        bricks.add(Brick(id: id(), gridX: c, gridY: 2,
            type: i % 2 == 0 ? BrickType.horizontalLaser : BrickType.verticalLaser, hp: 1));
      }
      if (f.hasBomb) bricks.add(Brick(id: id(), gridX: c, gridY: 3, type: BrickType.clusterBomb, hp: 1));
      if (f.hasDynamite && lvl >= 50 && c + 1 < cols) {
        bricks.add(Brick(id: id(), gridX: c + 1, gridY: 3, type: BrickType.chainDynamite, hp: 1));
      }
    }
    if (f.hasPermBall) {
      bricks.add(Brick(id: id(), gridX: 2, gridY: 2, type: BrickType.permanentAdder, hp: 1));
      bricks.add(Brick(id: id(), gridX: cols - 3, gridY: 2, type: BrickType.permanentAdder, hp: 1));
    }
    if (f.hasTurnBall) {
      bricks.add(Brick(id: id(), gridX: cols ~/ 2, gridY: 2, type: BrickType.turnBallAdder, hp: 1));
    }
  }

  // Blueprint 17: Labyrinthal — maze corridors, systematic clearing required
  static void _buildLabyrinthal(int lvl, math.Random rand, int cols, int baseHp,
      _FeatureSet f, List<Brick> bricks, int Function() id) {
    for (int wallCol = 2; wallCol < cols - 1; wallCol += 4) {
      final gapRow = 2 + ((wallCol ~/ 4) * 3) % 8;
      for (int r = 2; r <= 11; r++) {
        if (r == gapRow || r == gapRow + 1) continue;
        final type = (f.hasTitanium && lvl >= 200) ? BrickType.titaniumShield : BrickType.armoredBrick;
        bricks.add(Brick(id: id(), gridX: wallCol, gridY: r, type: type,
            hp: type == BrickType.titaniumShield ? 9999 : (baseHp * 1.4).round()));
      }
    }
    for (int hr = 4; hr <= 10; hr += 3) {
      final gapStart = (hr % 4) + 1;
      for (int c = 0; c < cols; c++) {
        if (c == gapStart || c == gapStart + 1) continue;
        if (!bricks.any((b) => b.gridX == c && b.gridY == hr)) {
          bricks.add(Brick(id: id(), gridX: c, gridY: hr, type: BrickType.standard, hp: baseHp));
        }
      }
    }
    for (int r = 2; r <= 11; r++) {
      for (int c = 0; c < cols; c++) {
        if (!bricks.any((b) => b.gridX == c && b.gridY == r) && rand.nextDouble() < 0.38) {
          bricks.add(Brick(id: id(), gridX: c, gridY: r,
              type: BrickType.standard, hp: _grad(baseHp ~/ 2, r, 2, 11)));
        }
      }
    }
    if (f.hasTurnBall) {
      for (int r = 3; r <= 10; r += 2) {
        final c = (cols / 2 + (r % 3 - 1)).round().clamp(0, cols - 1);
        if (!bricks.any((b) => b.gridX == c && b.gridY == r)) {
          bricks.add(Brick(id: id(), gridX: c, gridY: r, type: BrickType.turnBallAdder, hp: 1));
        }
      }
    }
  }

  // Blueprint 18: Sector Boss — every 100 levels, dramatic multi-phase showcase
  static void _buildSectorBoss(int lvl, math.Random rand, int cols, int baseHp,
      _FeatureSet f, List<Brick> bricks, int Function() id) {
    final bossHp = (baseHp * 3.0).round().clamp(baseHp, 99999);
    for (int c = 0; c < cols; c++) {
      bricks.add(Brick(id: id(), gridX: c, gridY: 2, type: BrickType.titaniumShield, hp: 9999));
      bricks.add(Brick(id: id(), gridX: c, gridY: 10, type: BrickType.titaniumShield, hp: 9999));
    }
    for (int r = 3; r <= 9; r++) {
      bricks.add(Brick(id: id(), gridX: 0, gridY: r, type: BrickType.titaniumShield, hp: 9999));
      bricks.add(Brick(id: id(), gridX: cols - 1, gridY: r, type: BrickType.titaniumShield, hp: 9999));
    }
    bricks.removeWhere((b) =>
      (b.gridY == 2 && (b.gridX == cols ~/ 2 - 1 || b.gridX == cols ~/ 2)) ||
      (b.gridY == 10 && (b.gridX == cols ~/ 2 - 1 || b.gridX == cols ~/ 2)));
    final sectorIdx = (lvl ~/ 100) % 5;
    switch (sectorIdx) {
      case 1:
        for (int r = 3; r <= 9; r++) {
          bricks.add(Brick(id: id(), gridX: cols ~/ 2 - 1, gridY: r, type: BrickType.armoredBrick, hp: bossHp));
          bricks.add(Brick(id: id(), gridX: cols ~/ 2, gridY: r, type: BrickType.armoredBrick, hp: bossHp));
        }
        for (int c = 1; c <= cols - 2; c++) {
          bricks.add(Brick(id: id(), gridX: c, gridY: 6, type: BrickType.armoredBrick, hp: bossHp));
        }
        break;
      case 2:
        _buildSpiralArm(lvl, rand, cols, bossHp, f, bricks, id);
        break;
      case 3:
        _buildDiamondRing(lvl, rand, cols, bossHp, f, bricks, id);
        break;
      case 4:
        _buildWaveAssault(lvl, rand, cols, bossHp, f, bricks, id, dense: true);
        break;
      default:
        for (int r = 3; r <= 9; r++) {
          for (int c = 1; c <= cols - 2; c++) {
            final type = c % 4 == 0 ? BrickType.armoredBrick : BrickType.standard;
            bricks.add(Brick(id: id(), gridX: c, gridY: r, type: type, hp: bossHp));
          }
        }
    }
    if (f.hasLaser) {
      for (int c = 2; c < cols - 2; c += 3) {
        if (!bricks.any((b) => b.gridX == c && b.gridY == 3)) {
          bricks.add(Brick(id: id(), gridX: c, gridY: 3, type: BrickType.crossLaser, hp: 1));
        }
      }
    }
    final cx = cols ~/ 2;
    if (!bricks.any((b) => b.gridX == cx && b.gridY == 5)) {
      bricks.add(Brick(id: id(), gridX: cx, gridY: 5, type: BrickType.superNuke, hp: 1));
      bricks.add(Brick(id: id(), gridX: cx - 1, gridY: 5, type: BrickType.permanentAdder, hp: 1));
      bricks.add(Brick(id: id(), gridX: cx + 1, gridY: 5, type: BrickType.permanentAdder, hp: 1));
      bricks.add(Brick(id: id(), gridX: cx, gridY: 6, type: BrickType.turnBallAdder, hp: 1));
    }
  }

  // ==========================================================================
  // HELPER UTILITIES
  // ==========================================================================

  static Brick _bk(int id, int c, int r, int hp, _FeatureSet f, math.Random rand) {
    final type = _selectType(c, r, 12, f, rand, f.level);
    final finalHp = type == BrickType.standard ? hp
        : type == BrickType.armoredBrick ? (hp * 1.5).round()
        : 1;
    return Brick(id: id, gridX: c, gridY: r, type: type, hp: finalHp.clamp(1, 99999));
  }

  /// HP gradient: front rows (small r) easier, back rows harder
  static int _grad(int baseHp, int row, int minRow, int maxRow) {
    if (maxRow == minRow) return baseHp;
    final t = (row - minRow) / (maxRow - minRow); // 0.0 front → 1.0 back
    return (baseHp * (0.55 + 0.90 * t)).round().clamp(1, 99999);
  }

  /// Position-aware brick type selection with feature gating
  static BrickType _selectType(int c, int r, int cols, _FeatureSet f,
      math.Random rand, int lvl, {double stdChance = 0.50}) {
    final roll = rand.nextDouble();
    double cur = stdChance;
    if (roll < cur) return BrickType.standard;
    cur += f.hasArmored ? 0.08 : 0;
    if (roll < cur) return BrickType.armoredBrick;
    cur += f.hasWedge ? 0.08 : 0;
    if (roll < cur) {
      final wedges = [BrickType.wedgeTopLeft, BrickType.wedgeTopRight,
                      BrickType.wedgeBottomLeft, BrickType.wedgeBottomRight];
      return wedges[rand.nextInt(4)];
    }
    cur += f.hasLaser ? 0.06 : 0;
    if (roll < cur) return BrickType.horizontalLaser;
    cur += f.hasLaser ? 0.06 : 0;
    if (roll < cur) return BrickType.verticalLaser;
    cur += f.hasCrossLaser ? 0.04 : 0;
    if (roll < cur) return BrickType.crossLaser;
    cur += f.hasBomb ? 0.05 : 0;
    if (roll < cur) return BrickType.clusterBomb;
    cur += f.hasDynamite ? 0.04 : 0;
    if (roll < cur) return BrickType.chainDynamite;
    cur += f.hasNuke ? 0.025 : 0;
    if (roll < cur) return BrickType.superNuke;
    cur += (f.hasTitanium && r <= 3) ? 0.015 : 0;
    if (roll < cur) return BrickType.titaniumShield;
    return BrickType.standard;
  }

  /// Wave row type: column-position patterns for chain setups
  static BrickType _waveType(int c, int r, int cols, _FeatureSet f,
      math.Random rand, int lvl) {
    if (c % 4 == 0 && f.hasLaser) return r % 2 == 0 ? BrickType.horizontalLaser : BrickType.verticalLaser;
    if (c % 6 == 3 && f.hasBomb && lvl >= 20) return BrickType.clusterBomb;
    if (c % 8 == 5 && f.hasDynamite && lvl >= 40) return BrickType.chainDynamite;
    if (c == cols ~/ 2 && r == 2 && f.hasTurnBall) return BrickType.turnBallAdder;
    if (c == cols ~/ 2 - 1 && r == 2 && f.hasPermBall) return BrickType.permanentAdder;
    if (f.hasArmored && rand.nextDouble() < 0.08) return BrickType.armoredBrick;
    return BrickType.standard;
  }

  /// Guaranteed powerup cluster near (cx, cy)
  static void _cluster(List<Brick> bricks, int Function() id, _FeatureSet f,
      int cx, int cy, int cols) {
    if (f.hasPermBall) {
      bricks.add(Brick(id: id(), gridX: cx, gridY: cy, type: BrickType.permanentAdder, hp: 1));
    }
    if (f.hasTurnBall && cx + 1 < cols) {
      bricks.add(Brick(id: id(), gridX: cx + 1, gridY: cy, type: BrickType.turnBallAdder, hp: 1));
    }
    if (f.hasSplitter && cx - 1 >= 0) {
      bricks.add(Brick(id: id(), gridX: cx - 1, gridY: cy, type: BrickType.inAirSplitter, hp: 1));
    }
  }

  // ==========================================================================
  // DIFFICULTY CURVES
  // ==========================================================================

  static _DiffTier _tier(int lvl) {
    if (lvl <= 50)  return _DiffTier.tutorial;
    if (lvl <= 150) return _DiffTier.easy;
    if (lvl <= 350) return _DiffTier.medium;
    if (lvl <= 600) return _DiffTier.hard;
    if (lvl <= 850) return _DiffTier.extreme;
    return _DiffTier.impossible;
  }

  /// Psychographic wave rhythm: gentle ramp → plateau → relief → boss spike
  static double _waveFactor(int lvl) {
    final pos = (lvl - 1) % 20;
    if (pos <= 7)  return 1.0 + (pos / 7) * 0.15;        // mild ramp (1.00 -> 1.15)
    if (pos <= 12) return 1.15;                           // plateau
    if (pos <= 17) return 1.15 - ((pos - 12) / 5) * 0.15; // relief (1.15 -> 1.00)
    return 1.25;                                          // boss milestone (1.25x)
  }

  static int _baseHp(int lvl, _DiffTier tier, double wave) {
    // Gentled HP curve — every level is beatable with the starting ball pool
    final base = switch (tier) {
      _DiffTier.tutorial   => 3.0   + lvl * 0.35,         // Lvl1=3  Lvl50=20
      _DiffTier.easy       => 20.0  + (lvl - 50)  * 0.5,  // Lvl150=70
      _DiffTier.medium     => 70.0  + (lvl - 150) * 0.65, // Lvl350=200
      _DiffTier.hard       => 200.0 + (lvl - 350) * 0.85, // Lvl600=413
      _DiffTier.extreme    => 413.0 + (lvl - 600) * 1.0,  // Lvl850=663
      _DiffTier.impossible => 663.0 + (lvl - 850) * 1.25, // Lvl1000=850
    };
    return (base * wave).round().clamp(2, 9999);
  }

  static int _startingBalls(int lvl, _DiffTier tier) {
    return switch (tier) {
      _DiffTier.tutorial   => (30 + lvl ~/ 3).clamp(30, 50),
      _DiffTier.easy       => (50 + (lvl - 50) ~/ 4).clamp(50, 75),
      _DiffTier.medium     => (75 + (lvl - 150) ~/ 4).clamp(75, 125),
      _DiffTier.hard       => (125 + (lvl - 350) ~/ 4).clamp(125, 185),
      _DiffTier.extreme    => (185 + (lvl - 600) ~/ 4).clamp(185, 245),
      _DiffTier.impossible => (245 + (lvl - 850) ~/ 3).clamp(245, 300),
    };
  }

  /// Turn limits: null by default (danger line handles loss condition naturally)
  static int? _turnLimit(int lvl, _DiffTier tier) {
    return null;
  }

  static LevelArchetype _archetype(int lvl, _Blueprint bp) {
    if (lvl % 100 == 0 || bp == _Blueprint.sectorBoss)  return LevelArchetype.impossibleCitadel;
    if (bp == _Blueprint.fortressCore || bp == _Blueprint.labyrinthal) return LevelArchetype.walledFortress;
    if (bp == _Blueprint.chainReactor || bp == _Blueprint.tunnelRun)   return LevelArchetype.laserHighway;
    if (bp == _Blueprint.spiderWeb    || bp == _Blueprint.spiralArm)   return LevelArchetype.orbitalChamber;
    if (bp == _Blueprint.waveAssault  || bp == _Blueprint.checkered)   return LevelArchetype.zigZagLabyrinth;
    if (bp == _Blueprint.hourglass    || bp == _Blueprint.diamondRing) return LevelArchetype.invertedFunnel;
    return LevelArchetype.starterGrid;
  }

  static String _title(int lvl, _Blueprint bp, ShapeDefinition shape) {
    if (lvl % 100 == 0) return '⚡ SECTOR BOSS — Level $lvl';
    if (lvl % 50  == 0) return '🏰 CITADEL CORE — Level $lvl';
    if (lvl % 25  == 0) return '💥 CHAIN TRIAL — Level $lvl';
    if (lvl % 10  == 0) return '🌊 WAVE ASSAULT — Level $lvl';
    final label = switch (_tier(lvl)) {
      _DiffTier.tutorial   => 'Genesis',
      _DiffTier.easy       => 'Ascension',
      _DiffTier.medium     => 'Crucible',
      _DiffTier.hard       => 'Inferno',
      _DiffTier.extreme    => 'Abyss',
      _DiffTier.impossible => 'Omega',
    };
    return 'Level $lvl • $label • ${shape.name}';
  }
}
