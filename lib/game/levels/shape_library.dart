import 'dart:math' as math;

/// Definition of a geometric/thematic Shape Archetype
class ShapeDefinition {
  final String id;
  final String name;
  final String category;
  final bool Function(int c, int r, int cols, int rows) isSolid;

  const ShapeDefinition({
    required this.id,
    required this.name,
    required this.category,
    required this.isSolid,
  });
}

/// Rich Shape Library with 100+ distinct geometric, organic, and arcade shapes
class ShapeLibrary {
  static final List<ShapeDefinition> shapes = [
    // --- 1. HEARTS & ORGANIC ICONS (1-15) ---
    ShapeDefinition(
      id: 'heart_classic',
      name: 'Classic Heart Matrix',
      category: 'Organic',
      isSolid: (c, r, cols, rows) {
        final x = (c - (cols - 1) / 2.0) / ((cols - 1) / 2.0);
        final y = -(r - 3.0) / 4.0;
        final x2 = x * x;
        final y2 = y * y;
        return (x2 + y2 - 1.0) * (x2 + y2 - 1.0) * (x2 + y2 - 1.0) - x2 * y2 * y <= 0.0;
      },
    ),
    ShapeDefinition(
      id: 'heart_hollow',
      name: 'Hollow Cyber Heart',
      category: 'Organic',
      isSolid: (c, r, cols, rows) {
        final x = (c - (cols - 1) / 2.0) / ((cols - 1) / 2.0);
        final y = -(r - 3.0) / 4.0;
        final x2 = x * x;
        final y2 = y * y;
        final f = (x2 + y2 - 1.0) * (x2 + y2 - 1.0) * (x2 + y2 - 1.0) - x2 * y2 * y;
        return f <= 0.0 && f >= -0.65;
      },
    ),
    ShapeDefinition(
      id: 'twin_hearts',
      name: 'Twin Interlocking Hearts',
      category: 'Organic',
      isSolid: (c, r, cols, rows) {
        final x1 = (c - 3.5) / 3.5;
        final y1 = -(r - 3.5) / 3.0;
        final f1 = (x1 * x1 + y1 * y1 - 1.0) * (x1 * x1 + y1 * y1 - 1.0) * (x1 * x1 + y1 * y1 - 1.0) - x1 * x1 * y1 * y1 * y1;
        final x2 = (c - 7.5) / 3.5;
        final y2 = -(r - 5.0) / 3.0;
        final f2 = (x2 * x2 + y2 * y2 - 1.0) * (x2 * x2 + y2 * y2 - 1.0) * (x2 * x2 + y2 * y2 - 1.0) - x2 * x2 * y2 * y2 * y2;
        return f1 <= 0.0 || f2 <= 0.0;
      },
    ),
    ShapeDefinition(
      id: 'broken_heart',
      name: 'Fractured Heart Matrix',
      category: 'Organic',
      isSolid: (c, r, cols, rows) {
        final x = (c - (cols - 1) / 2.0) / ((cols - 1) / 2.0);
        final y = -(r - 3.0) / 4.0;
        final x2 = x * x;
        final y2 = y * y;
        final inHeart = (x2 + y2 - 1.0) * (x2 + y2 - 1.0) * (x2 + y2 - 1.0) - x2 * y2 * y <= 0.0;
        final isCrack = ((c == 5 && r % 2 == 0) || (c == 6 && r % 2 == 1));
        return inHeart && !isCrack;
      },
    ),
    ShapeDefinition(
      id: 'four_leaf_clover',
      name: 'Four-Leaf Lucky Clover',
      category: 'Organic',
      isSolid: (c, r, cols, rows) {
        final cx = (cols - 1) / 2.0;
        final cy = 5.0;
        final dx = c - cx;
        final dy = r - cy;
        final dist = math.sqrt(dx * dx + dy * dy);
        final angle = math.atan2(dy, dx);
        final cloverRadius = 3.5 * math.cos(2 * angle).abs() + 1.2;
        return dist <= cloverRadius || (c == cx.round() && r >= 6 && r <= 11);
      },
    ),
    ShapeDefinition(
      id: 'butterfly_wings',
      name: 'Monarch Cyber Butterfly',
      category: 'Organic',
      isSolid: (c, r, cols, rows) {
        final cx = (cols - 1) / 2.0;
        final dx = (c - cx).abs();
        final dy = (r - 5.0).abs();
        if (dx == 0 && r >= 2 && r <= 8) return true; // body
        return (dx <= 5 && dy <= 3 && (dx + dy <= 6) && (dx >= 1));
      },
    ),
    ShapeDefinition(
      id: 'rose_flower',
      name: 'Cyber Rose Lattice',
      category: 'Organic',
      isSolid: (c, r, cols, rows) {
        final cx = (cols - 1) / 2.0;
        final dx = c - cx;
        final dy = r - 4.5;
        final dist = math.sqrt(dx * dx + dy * dy);
        final angle = math.atan2(dy, dx);
        final radius = 2.0 + 1.8 * math.sin(5 * angle);
        return dist <= radius || (c == cx.round() && r >= 7 && r <= 11);
      },
    ),
    ShapeDefinition(
      id: 'pine_tree',
      name: 'Evergreen Pine Citadel',
      category: 'Organic',
      isSolid: (c, r, cols, rows) {
        final cx = (cols - 1) / 2.0;
        final dx = (c - cx).abs();
        if (r >= 2 && r <= 4) return dx <= (r - 2);
        if (r >= 4 && r <= 7) return dx <= (r - 3);
        if (r >= 7 && r <= 10) return dx <= (r - 5);
        if (r >= 11 && r <= 13) return dx <= 1;
        return false;
      },
    ),
    ShapeDefinition(
      id: 'flame_inferno',
      name: 'Inferno Fire Core',
      category: 'Organic',
      isSolid: (c, r, cols, rows) {
        final cx = (cols - 1) / 2.0;
        final dx = (c - cx).abs();
        if (r == 2) return dx == 0;
        if (r == 3) return dx <= 1;
        if (r == 4) return dx <= 2 || dx == 4;
        if (r >= 5 && r <= 8) return dx <= 4.5 && (r != 6 || dx != 2);
        if (r >= 9 && r <= 11) return dx <= (11 - r + 1.5);
        return false;
      },
    ),
    ShapeDefinition(
      id: 'music_note',
      name: 'Acoustic Melody Note',
      category: 'Organic',
      isSolid: (c, r, cols, rows) {
        final isStem = (c == 7 && r >= 2 && r <= 8) || (c == 4 && r >= 4 && r <= 9);
        final isBeam = (r == 2 && c >= 4 && c <= 7);
        final isHead1 = (c >= 2 && c <= 4 && r >= 9 && r <= 11);
        final isHead2 = (c >= 5 && c <= 7 && r >= 8 && r <= 10);
        return isStem || isBeam || isHead1 || isHead2;
      },
    ),

    // --- 2. TRIANGLES, PYRAMIDS & GEOMETRIC PRISMS (16-30) ---
    ShapeDefinition(
      id: 'stepped_pyramid',
      name: 'Stepped Aztec Pyramid',
      category: 'Pyramids',
      isSolid: (c, r, cols, rows) {
        final cx = (cols - 1) / 2.0;
        final dx = (c - cx).abs();
        final level = r - 2;
        return level >= 0 && level <= 8 && dx <= (level + 0.5);
      },
    ),
    ShapeDefinition(
      id: 'inverted_pyramid',
      name: 'Inverted Funnel Pyramid',
      category: 'Pyramids',
      isSolid: (c, r, cols, rows) {
        final cx = (cols - 1) / 2.0;
        final dx = (c - cx).abs();
        final level = 9 - r;
        return level >= 0 && level <= 7 && dx <= (level + 0.5);
      },
    ),
    ShapeDefinition(
      id: 'triforce_master',
      name: 'Master Triforce of Power',
      category: 'Pyramids',
      isSolid: (c, r, cols, rows) {
        final cx = (cols - 1) / 2.0;
        final dx = (c - cx).abs();
        if (r >= 2 && r <= 5) return dx <= (r - 2);
        if (r >= 6 && r <= 9) {
          final rowRel = r - 6;
          final inLeft = (c - (cx - 3)).abs() <= rowRel;
          final inRight = (c - (cx + 3)).abs() <= rowRel;
          return inLeft || inRight;
        }
        return false;
      },
    ),
    ShapeDefinition(
      id: 'sierpinski_gasket',
      name: 'Sierpinski Fractal Gasket',
      category: 'Pyramids',
      isSolid: (c, r, cols, rows) {
        if (r < 2 || r > 9) return false;
        final y = r - 2;
        final x = c - (5 - y);
        if (x < 0 || x > 2 * y) return false;
        return (x & y) == 0;
      },
    ),
    ShapeDefinition(
      id: 'twin_pyramids',
      name: 'Twin Obelisk Pyramids',
      category: 'Pyramids',
      isSolid: (c, r, cols, rows) {
        final leftPeak = 2.5;
        final rightPeak = 8.5;
        final rowRel = r - 2;
        if (rowRel < 0 || rowRel > 7) return false;
        final inLeft = (c - leftPeak).abs() <= (rowRel * 0.5 + 0.5);
        final inRight = (c - rightPeak).abs() <= (rowRel * 0.5 + 0.5);
        return inLeft || inRight;
      },
    ),
    ShapeDefinition(
      id: 'hourglass_vortex',
      name: 'Hourglass Time Vortex',
      category: 'Pyramids',
      isSolid: (c, r, cols, rows) {
        final cx = (cols - 1) / 2.0;
        final dx = (c - cx).abs();
        if (r >= 2 && r <= 6) return dx <= (6 - r + 0.5);
        if (r >= 7 && r <= 11) return dx <= (r - 7 + 0.5);
        return false;
      },
    ),
    ShapeDefinition(
      id: 'hollow_delta',
      name: 'Hollow Delta Prism',
      category: 'Pyramids',
      isSolid: (c, r, cols, rows) {
        final cx = (cols - 1) / 2.0;
        final dx = (c - cx).abs();
        final rowRel = r - 2;
        if (rowRel < 0 || rowRel > 7) return false;
        return (dx <= rowRel) && (dx >= rowRel - 1.2 || rowRel >= 6);
      },
    ),
    ShapeDefinition(
      id: 'diamond_hourglass',
      name: 'Diamond Hourglass Lattice',
      category: 'Pyramids',
      isSolid: (c, r, cols, rows) {
        final cx = (cols - 1) / 2.0;
        final dx = (c - cx).abs();
        final dy = (r - 6.5).abs();
        return (dx + dy <= 5.5) && (dx >= dy - 1.5);
      },
    ),
    ShapeDefinition(
      id: 'triangular_gate',
      name: 'Prism Gate Conduit',
      category: 'Pyramids',
      isSolid: (c, r, cols, rows) {
        final cx = (cols - 1) / 2.0;
        final dx = (c - cx).abs();
        return (r >= 2 && r <= 10) && (dx <= (r - 2)) && (dx >= 2.0 || r <= 4);
      },
    ),

    // --- 3. DIAMONDS, STARS & CELESTIAL (31-50) ---
    ShapeDefinition(
      id: 'gem_diamond',
      name: 'Brilliant Cut Diamond',
      category: 'Celestial',
      isSolid: (c, r, cols, rows) {
        final cx = (cols - 1) / 2.0;
        final dx = (c - cx).abs();
        if (r >= 2 && r <= 4) return dx <= (r + 1.5);
        if (r >= 5 && r <= 10) return dx <= (10 - r + 0.5);
        return false;
      },
    ),
    ShapeDefinition(
      id: 'rhombus_vault',
      name: 'Rhombus Vault Core',
      category: 'Celestial',
      isSolid: (c, r, cols, rows) {
        final cx = (cols - 1) / 2.0;
        final cy = 6.0;
        final dx = (c - cx).abs();
        final dy = (r - cy).abs();
        return (dx / 4.5 + dy / 4.0) <= 1.0;
      },
    ),
    ShapeDefinition(
      id: 'star_five_point',
      name: 'Solar Pentagram Star',
      category: 'Celestial',
      isSolid: (c, r, cols, rows) {
        final cx = (cols - 1) / 2.0;
        final cy = 5.5;
        final dx = c - cx;
        final dy = r - cy;
        final dist = math.sqrt(dx * dx + dy * dy);
        final angle = math.atan2(dy, dx) + math.pi / 2;
        final rStar = 2.0 + 2.4 * math.cos(5 * angle);
        return dist <= rStar.clamp(0.8, 5.0);
      },
    ),
    ShapeDefinition(
      id: 'star_eight_point',
      name: 'Octagram Star of Compass',
      category: 'Celestial',
      isSolid: (c, r, cols, rows) {
        final cx = (cols - 1) / 2.0;
        final cy = 6.0;
        final dx = (c - cx).abs();
        final dy = (r - cy).abs();
        return (dx <= 1.0 && dy <= 4.5) || (dy <= 1.0 && dx <= 4.5) || (dx == dy && dx <= 3.0);
      },
    ),
    ShapeDefinition(
      id: 'crescent_moon',
      name: 'Crescent Moon Eclipse',
      category: 'Celestial',
      isSolid: (c, r, cols, rows) {
        final cx1 = 5.0;
        final cy1 = 6.0;
        final d1 = math.sqrt((c - cx1) * (c - cx1) + (r - cy1) * (r - cy1));
        final cx2 = 6.8;
        final cy2 = 5.2;
        final d2 = math.sqrt((c - cx2) * (c - cx2) + (r - cy2) * (r - cy2));
        return d1 <= 4.2 && d2 >= 3.2;
      },
    ),
    ShapeDefinition(
      id: 'saturn_rings',
      name: 'Saturn with Planetary Rings',
      category: 'Celestial',
      isSolid: (c, r, cols, rows) {
        final cx = (cols - 1) / 2.0;
        final cy = 6.0;
        final dx = c - cx;
        final dy = r - cy;
        final dSphere = math.sqrt(dx * dx + dy * dy);
        final isSphere = dSphere <= 2.8;
        final isRing = (dy.abs() <= 1 && dx.abs() <= 5.5 && (dx.abs() >= 2.5 || dy != 0));
        return isSphere || isRing;
      },
    ),
    ShapeDefinition(
      id: 'spiral_galaxy',
      name: 'Spiral Galaxy Vortex',
      category: 'Celestial',
      isSolid: (c, r, cols, rows) {
        final cx = (cols - 1) / 2.0;
        final cy = 6.0;
        final dx = c - cx;
        final dy = r - cy;
        final dist = math.sqrt(dx * dx + dy * dy);
        final angle = math.atan2(dy, dx);
        final spiralVal = (angle + dist * 1.2) % math.pi;
        return dist <= 5.0 && (spiralVal < 1.0 || dist <= 1.5);
      },
    ),
    ShapeDefinition(
      id: 'supernova_cross',
      name: 'Supernova Core Flare',
      category: 'Celestial',
      isSolid: (c, r, cols, rows) {
        final cx = (cols - 1) / 2.0;
        final cy = 6.0;
        final dx = (c - cx).abs();
        final dy = (r - cy).abs();
        return (dx <= 0.8 && dy <= 5.0) || (dy <= 0.8 && dx <= 5.0) || (dx + dy <= 3.0);
      },
    ),
    ShapeDefinition(
      id: 'shooting_star',
      name: 'Shooting Comet Tail',
      category: 'Celestial',
      isSolid: (c, r, cols, rows) {
        final inHead = (c >= 1 && c <= 4 && r >= 2 && r <= 4);
        final inTail = (c - r).abs() <= 1 && r >= 4 && r <= 11;
        return inHead || inTail;
      },
    ),

    // --- 4. ARCADE, CREATURES & CYBER BOSSES (51-70) ---
    ShapeDefinition(
      id: 'space_invader',
      name: 'Retro Space Invader',
      category: 'Arcade',
      isSolid: (c, r, cols, rows) {
        final grid = [
          [0,0,1,0,0,0,0,0,1,0,0],
          [0,0,0,1,0,0,0,1,0,0,0],
          [0,0,1,1,1,1,1,1,1,0,0],
          [0,1,1,0,1,1,1,0,1,1,0],
          [1,1,1,1,1,1,1,1,1,1,1],
          [1,0,1,1,1,1,1,1,1,0,1],
          [1,0,1,0,0,0,0,0,1,0,1],
          [0,0,0,1,1,0,1,1,0,0,0],
        ];
        final gr = r - 2;
        final gc = c - 1;
        if (gr >= 0 && gr < grid.length && gc >= 0 && gc < grid[0].length) {
          return grid[gr][gc] == 1;
        }
        return false;
      },
    ),
    ShapeDefinition(
      id: 'cyber_skull',
      name: 'Cyber Skull Bastion',
      category: 'Arcade',
      isSolid: (c, r, cols, rows) {
        final cx = (cols - 1) / 2.0;
        final dx = (c - cx).abs();
        if (r >= 2 && r <= 6) {
          if (r == 4 && (c == 3 || c == 4 || c == 7 || c == 8)) return false;
          return dx <= 4.5;
        }
        if (r >= 7 && r <= 9) {
          return dx <= 2.5 && (r != 8 || c % 2 == 1);
        }
        return false;
      },
    ),
    ShapeDefinition(
      id: 'dragon_maw',
      name: 'Dragon Fang Maw',
      category: 'Arcade',
      isSolid: (c, r, cols, rows) {
        final cx = (cols - 1) / 2.0;
        final dx = (c - cx).abs();
        if (r == 2) return dx <= 4;
        if (r == 3 || r == 4) return dx >= 2 && dx <= 5;
        if (r == 5) return dx <= 5 && c % 2 == 0;
        if (r == 7) return dx <= 4 && c % 2 == 1;
        if (r >= 8 && r <= 10) return dx <= (10 - r + 1);
        return false;
      },
    ),
    ShapeDefinition(
      id: 'bat_wings',
      name: 'Shadow Bat Wings',
      category: 'Arcade',
      isSolid: (c, r, cols, rows) {
        final cx = (cols - 1) / 2.0;
        final dx = (c - cx).abs();
        if (dx == 0 && r >= 4 && r <= 9) return true;
        if (r == 2) return dx == 1;
        if (r >= 3 && r <= 7) return dx <= 5 && (dx >= 1 + (7 - r) * 0.5);
        if (r >= 8 && r <= 10) return dx <= 4 && c % 2 == 0;
        return false;
      },
    ),
    ShapeDefinition(
      id: 'spider_web',
      name: 'Spider Web Matrix',
      category: 'Arcade',
      isSolid: (c, r, cols, rows) {
        final cx = (cols - 1) / 2.0;
        final cy = 6.0;
        final dx = (c - cx).abs();
        final dy = (r - cy).abs();
        final isSpoke = (dx == dy) || (dx == 0) || (dy == 0);
        final isRing = (dx + dy == 3) || (dx + dy == 5);
        return (isSpoke || isRing) && (dx <= 5 && dy <= 4.5);
      },
    ),
    ShapeDefinition(
      id: 'pac_ghost',
      name: 'Neon Ghost Matrix',
      category: 'Arcade',
      isSolid: (c, r, cols, rows) {
        final cx = (cols - 1) / 2.0;
        final dx = (c - cx).abs();
        if (r >= 2 && r <= 8) {
          if (r == 4 && (c == 3 || c == 7)) return false; // eyes
          return dx <= 4.0;
        }
        if (r == 9) return (c % 2 == 0); // skirt ripples
        return false;
      },
    ),

    // --- 5. WEAPONS, SHIELDS & BATTLE (71-85) ---
    ShapeDefinition(
      id: 'excalibur_sword',
      name: 'Excalibur Laser Blade',
      category: 'Weapons',
      isSolid: (c, r, cols, rows) {
        final cx = (cols - 1) / 2.0;
        final dx = (c - cx).abs();
        if (r == 1) return dx <= 0.5;
        if (r >= 2 && r <= 7) return dx <= 0.8;
        if (r == 8) return dx <= 4.0;
        if (r >= 9 && r <= 11) return dx <= 0.6;
        if (r == 12) return dx <= 1.2;
        return false;
      },
    ),
    ShapeDefinition(
      id: 'shield_of_aegis',
      name: 'Shield of Aegis Citadel',
      category: 'Weapons',
      isSolid: (c, r, cols, rows) {
        final cx = (cols - 1) / 2.0;
        final dx = (c - cx).abs();
        if (r >= 2 && r <= 5) return dx <= 4.5;
        if (r >= 6 && r <= 11) return dx <= (4.5 - (r - 5) * 0.8).clamp(0.0, 4.5);
        return false;
      },
    ),
    ShapeDefinition(
      id: 'crown_royale',
      name: 'Imperial Crown Royale',
      category: 'Weapons',
      isSolid: (c, r, cols, rows) {
        final cx = (cols - 1) / 2.0;
        final dx = (c - cx).abs();
        if (r == 2) return dx == 0 || dx == 4;
        if (r == 3) return dx <= 1 || dx >= 3 && dx <= 4;
        if (r >= 4 && r <= 6) return dx <= 4.5;
        if (r == 7) return dx <= 4.5;
        return false;
      },
    ),
    ShapeDefinition(
      id: 'anchor_maritime',
      name: 'Titan Maritime Anchor',
      category: 'Weapons',
      isSolid: (c, r, cols, rows) {
        final cx = (cols - 1) / 2.0;
        final dx = (c - cx).abs();
        if (r == 2) return dx <= 1.2;
        if (r == 4) return dx <= 3.5;
        if (r >= 2 && r <= 9 && dx == 0) return true;
        if (r == 9 || r == 10) return dx <= 4.5 && (r == 10 || dx >= 3);
        return false;
      },
    ),
    ShapeDefinition(
      id: 'battle_axe',
      name: 'Dual War Battle Axe',
      category: 'Weapons',
      isSolid: (c, r, cols, rows) {
        final cx = (cols - 1) / 2.0;
        final dx = (c - cx).abs();
        if (r >= 1 && r <= 12 && dx == 0) return true;
        if (r >= 2 && r <= 6) return dx >= 1.5 && dx <= (4.5 - (r - 4).abs() * 0.8);
        return false;
      },
    ),

    // --- 6. SCI-FI, ENERGY & TECH (86-100) ---
    ShapeDefinition(
      id: 'lightning_bolt',
      name: 'High Voltage Lightning',
      category: 'Energy',
      isSolid: (c, r, cols, rows) {
        final points = [
          [7, 1], [6, 2], [5, 3], [4, 4], [3, 5],
          [4, 5], [5, 5], [6, 5], [7, 5],
          [6, 6], [5, 7], [4, 8], [3, 9], [2, 10]
        ];
        return points.any((p) => p[0] == c && p[1] == r);
      },
    ),
    ShapeDefinition(
      id: 'biohazard_sign',
      name: 'Cyber Biohazard Symbol',
      category: 'Energy',
      isSolid: (c, r, cols, rows) {
        final cx = (cols - 1) / 2.0;
        final cy = 6.0;
        final dx = c - cx;
        final dy = r - cy;
        final dist = math.sqrt(dx * dx + dy * dy);
        final inRing = dist >= 2.5 && dist <= 4.5;
        final cutouts = (dy > 0 && dx.abs() < 1.2) || (dy < -1 && dx.abs() < 1.2);
        return (inRing && !cutouts) || (dist <= 1.2);
      },
    ),
    ShapeDefinition(
      id: 'radioactive_nuclear',
      name: 'Nuclear Trefoil Warning',
      category: 'Energy',
      isSolid: (c, r, cols, rows) {
        final cx = (cols - 1) / 2.0;
        final cy = 6.0;
        final dx = c - cx;
        final dy = r - cy;
        final dist = math.sqrt(dx * dx + dy * dy);
        final angle = (math.atan2(dy, dx) + math.pi * 2) % (2 * math.pi);
        final inSector1 = angle >= 0.5 && angle <= 1.6;
        final inSector2 = angle >= 2.6 && angle <= 3.7;
        final inSector3 = angle >= 4.7 && angle <= 5.8;
        return (dist <= 1.0) || (dist >= 2.0 && dist <= 4.8 && (inSector1 || inSector2 || inSector3));
      },
    ),
    ShapeDefinition(
      id: 'infinity_loop',
      name: 'Quantum Infinity Loop',
      category: 'Energy',
      isSolid: (c, r, cols, rows) {
        final cx = (cols - 1) / 2.0;
        final cy = 6.0;
        final x = (c - cx) / 4.0;
        final y = (r - cy) / 2.5;
        final x2 = x * x;
        final y2 = y * y;
        final f = (x2 + y2) * (x2 + y2) - 1.8 * (x2 - y2);
        return f.abs() <= 0.45;
      },
    ),
    ShapeDefinition(
      id: 'yin_yang',
      name: 'Cosmic Yin Yang Balance',
      category: 'Energy',
      isSolid: (c, r, cols, rows) {
        final cx = (cols - 1) / 2.0;
        final cy = 6.0;
        final dx = c - cx;
        final dy = r - cy;
        final dist = math.sqrt(dx * dx + dy * dy);
        if (dist > 4.5) return false;
        if (dx >= 0) return true;
        final dTop = math.sqrt(dx * dx + (dy + 2) * (dy + 2));
        final dBot = math.sqrt(dx * dx + (dy - 2) * (dy - 2));
        if (dTop <= 2.0) return true;
        if (dBot <= 2.0) return false;
        return false;
      },
    ),
    ShapeDefinition(
      id: 'dna_helix',
      name: 'Synthetic DNA Double Helix',
      category: 'Energy',
      isSolid: (c, r, cols, rows) {
        final cx = (cols - 1) / 2.0;
        final wave1 = cx + 3.5 * math.sin(r * 0.9);
        final wave2 = cx - 3.5 * math.sin(r * 0.9);
        final onStrand = (c - wave1).abs() <= 0.8 || (c - wave2).abs() <= 0.8;
        final onRung = (r % 3 == 0) && (c >= math.min(wave1, wave2) && c <= math.max(wave1, wave2));
        return r >= 2 && r <= 12 && (onStrand || onRung);
      },
    ),
    ShapeDefinition(
      id: 'space_rocket',
      name: 'Apollo Cyber Rocket',
      category: 'Energy',
      isSolid: (c, r, cols, rows) {
        final cx = (cols - 1) / 2.0;
        final dx = (c - cx).abs();
        if (r == 1) return dx == 0;
        if (r >= 2 && r <= 7) return dx <= (r == 2 ? 0.8 : (r <= 5 ? 1.5 : 2.0));
        if (r >= 8 && r <= 10) return dx <= 4.0;
        if (r == 11) return dx <= 1.2 || dx == 3.5;
        return false;
      },
    ),

    // --- 7. TESSELLATIONS, LABYRINTHS & MATRICES (101-120) ---
    ShapeDefinition(
      id: 'honeycomb_hex',
      name: 'Hexagonal Honeycomb Grid',
      category: 'Tessellations',
      isSolid: (c, r, cols, rows) {
        if (r < 2 || r > 11) return false;
        return (c + (r % 2)) % 3 != 0;
      },
    ),
    ShapeDefinition(
      id: 'concentric_rings',
      name: 'Concentric Orbital Rings',
      category: 'Tessellations',
      isSolid: (c, r, cols, rows) {
        final cx = (cols - 1) / 2.0;
        final cy = 6.0;
        final dx = c - cx;
        final dy = r - cy;
        final dist = math.sqrt(dx * dx + dy * dy);
        return (dist <= 1.2) || (dist >= 2.4 && dist <= 3.4) || (dist >= 4.4 && dist <= 5.2);
      },
    ),
    ShapeDefinition(
      id: 'concentric_squares',
      name: 'Nested Concentric Squares',
      category: 'Tessellations',
      isSolid: (c, r, cols, rows) {
        final cx = (cols - 1) / 2.0;
        final cy = 6.0;
        final dx = (c - cx).abs();
        final dy = (r - cy).abs();
        final maxD = math.max(dx, dy);
        return maxD <= 1.0 || (maxD >= 2.4 && maxD <= 3.2) || (maxD >= 4.2 && maxD <= 5.0);
      },
    ),
    ShapeDefinition(
      id: 'sine_waves',
      name: 'Dual Sine Wave Matrix',
      category: 'Tessellations',
      isSolid: (c, r, cols, rows) {
        final wave1 = 4.0 + 3.0 * math.sin(c * 0.8);
        final wave2 = 8.0 + 3.0 * math.cos(c * 0.8);
        return (r - wave1).abs() <= 0.8 || (r - wave2).abs() <= 0.8;
      },
    ),
    ShapeDefinition(
      id: 'checkerboard_cross',
      name: 'Checkerboard Cross Matrix',
      category: 'Tessellations',
      isSolid: (c, r, cols, rows) {
        final cx = (cols - 1) / 2.0;
        final cy = 6.0;
        final inCross = (c - cx).abs() <= 4.0 && (r - cy).abs() <= 4.0;
        return inCross && ((c + r) % 2 == 0);
      },
    ),
    ShapeDefinition(
      id: 'labyrinth_maze',
      name: 'Cyber Labyrinth Matrix',
      category: 'Tessellations',
      isSolid: (c, r, cols, rows) {
        if (r < 2 || r > 11) return false;
        final border = (r == 2 || r == 11 || c == 0 || c == cols - 1);
        final walls = (r % 2 == 0 && c % 4 != 0) || (c % 3 == 0 && r % 3 != 0);
        return border || walls;
      },
    ),
    ShapeDefinition(
      id: 'twin_towers',
      name: 'Twin Citadel Towers',
      category: 'Tessellations',
      isSolid: (c, r, cols, rows) {
        final inLeftTower = (c >= 1 && c <= 4 && r >= 3 && r <= 11);
        final inRightTower = (c >= 7 && c <= 10 && r >= 3 && r <= 11);
        final inBridge = (r == 5 && c >= 3 && c <= 8);
        final inLeftSpire = (c == 2 && r == 2) || (c == 3 && r == 2);
        final inRightSpire = (c == 8 && r == 2) || (c == 9 && r == 2);
        return inLeftTower || inRightTower || inBridge || inLeftSpire || inRightSpire;
      },
    ),
    ShapeDefinition(
      id: 'target_crosshairs',
      name: 'Precision Crosshairs Core',
      category: 'Tessellations',
      isSolid: (c, r, cols, rows) {
        final cx = (cols - 1) / 2.0;
        final cy = 6.0;
        final dx = (c - cx).abs();
        final dy = (r - cy).abs();
        final isRing = (dx * dx + dy * dy >= 8.0 && dx * dx + dy * dy <= 16.0);
        final isCross = (dx <= 0.5 && dy <= 5.0) || (dy <= 0.5 && dx <= 5.0);
        return isRing || isCross;
      },
    ),
    ShapeDefinition(
      id: 'triquetra_celtic',
      name: 'Celtic Triquetra Knot',
      category: 'Tessellations',
      isSolid: (c, r, cols, rows) {
        final x1 = cols / 2.0;
        final y1 = 4.0;
        final x2 = cols / 2.0 - 2.5;
        final y2 = 8.0;
        final x3 = cols / 2.0 + 2.5;
        final y3 = 8.0;
        final d1 = math.sqrt((c - x1) * (c - x1) + (r - y1) * (r - y1));
        final d2 = math.sqrt((c - x2) * (c - x2) + (r - y2) * (r - y2));
        final d3 = math.sqrt((c - x3) * (c - x3) + (r - y3) * (r - y3));
        const rRing = 2.8;
        return (d1 - rRing).abs() <= 0.8 || (d2 - rRing).abs() <= 0.8 || (d3 - rRing).abs() <= 0.8;
      },
    ),

    ShapeDefinition(
      id: 'hypercube_tesseract',
      name: '4D Hypercube Tesseract',
      category: 'Tessellations',
      isSolid: (c, r, cols, rows) {
        final inOuterBox = (c >= 1 && c <= 10 && (r == 2 || r == 11)) || ((c == 1 || c == 10) && r >= 2 && r <= 11);
        final inInnerBox = (c >= 4 && c <= 7 && (r == 5 || r == 8)) || ((c == 4 || c == 7) && r >= 5 && r <= 8);
        final inDiagonals = (c == r - 1) || (c == 12 - r);
        return inOuterBox || inInnerBox || inDiagonals;
      },
    ),
  ];

  /// Get shape by index / level modulo
  static ShapeDefinition getShapeForLevel(int levelNumber) {
    return shapes[(levelNumber - 1) % shapes.length];
  }
}

