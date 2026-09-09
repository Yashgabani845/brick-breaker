import 'package:flutter/material.dart';
import '../../core/constants/game_colors.dart';
import '../../core/constants/game_constants.dart';
import '../../game/levels/level_catalog.dart';
import '../../game/models/brick.dart';
import '../../game/models/level_data.dart';
import '../../game/systems/audio_synthesizer.dart';
import '../../storage/game_storage.dart';
import '../components/glass_button.dart';
import '../components/glass_card.dart';
import '../components/level_blueprint_preview.dart';
import '../components/neon_glow_text.dart';

/// 50 World Sectors spanning Levels 1 to 1000 (20 Levels per Sector)
class WorldSector {
  final int sectorNumber;
  final String name;
  final String description;
  final int startLevel;
  final int endLevel;
  final Color themeColor;
  final IconData icon;

  const WorldSector({
    required this.sectorNumber,
    required this.name,
    required this.description,
    required this.startLevel,
    required this.endLevel,
    required this.themeColor,
    required this.icon,
  });
}

const List<String> _sectorNames = [
  'CYBER GENESIS',
  'NEON CITADEL',
  'QUANTUM VAULT',
  'VOID GAUNTLET',
  'APEX BASTION',
  'TITAN FORGE',
  'SUPERNOVA REACTOR',
  'DRAGON MAW',
  'SOLAR ECLIPSE',
  'HYPERION MATRIX',
  'CHRONO VORTEX',
  'ASTEROID BELT',
  'PULSAR NEBULA',
  'CYBERNETIC HIVE',
  'INFINITY CORE',
  'GLACIAL PERMAFROST',
  'PLASMA INFERNO',
  'DARK MATTER RIFT',
  'OMEGA SINGULARITY',
  'VALHALLA CITADEL',
  'QUANTUM LATTICE',
  'HELIOS APEX',
  'NEURON SYNAPSE',
  'CYBER SHADOWS',
  'COSMIC HORIZON',
];

const List<Color> _sectorColors = [
  GameColors.neonCyan,
  GameColors.electricAmber,
  GameColors.neonMagenta,
  GameColors.solarGold,
  GameColors.crimsonDanger,
  GameColors.neonPurple,
  Color(0xFF00FF66),
  Color(0xFF00E5FF),
  Color(0xFF38BDF8),
  Color(0xFF10B981),
  Color(0xFFF97316),
  Color(0xFF8B5CF6),
];

const List<IconData> _sectorIcons = [
  Icons.hub_rounded,
  Icons.shield_rounded,
  Icons.blur_circular_rounded,
  Icons.electric_bolt_rounded,
  Icons.local_fire_department_rounded,
  Icons.diamond_rounded,
  Icons.auto_awesome_rounded,
  Icons.public_rounded,
  Icons.radar_rounded,
  Icons.all_inclusive_rounded,
];

List<WorldSector> generateAll50Sectors() {
  return List.generate(50, (index) {
    final sectorNum = index + 1;
    final start = (index * 20) + 1;
    final end = (index + 1) * 20;
    final name = _sectorNames[index % _sectorNames.length];
    final color = _sectorColors[index % _sectorColors.length];
    final icon = _sectorIcons[index % _sectorIcons.length];

    return WorldSector(
      sectorNumber: sectorNum,
      name: '$name (LVL $start-$end)',
      description: 'Sector $sectorNum • 20 Handcrafted Geometric Shapes & Boss Core',
      startLevel: start,
      endLevel: end,
      themeColor: color,
      icon: icon,
    );
  });
}

final List<WorldSector> worldSectors = generateAll50Sectors();


/// Next-Gen Sector Map & World Progression Screen
class LevelMapScreen extends StatefulWidget {
  final int unlockedLevel;
  final ValueChanged<int> onSelectLevel;

  const LevelMapScreen({
    super.key,
    required this.unlockedLevel,
    required this.onSelectLevel,
  });

  @override
  State<LevelMapScreen> createState() => _LevelMapScreenState();
}

class _LevelMapScreenState extends State<LevelMapScreen> {
  int _selectedSectorIndex = 0;

  @override
  void initState() {
    super.initState();
    // Auto-focus the sector where the current unlocked level resides
    for (int i = 0; i < worldSectors.length; i++) {
      if (widget.unlockedLevel >= worldSectors[i].startLevel &&
          widget.unlockedLevel <= worldSectors[i].endLevel) {
        _selectedSectorIndex = i;
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentSector = worldSectors[_selectedSectorIndex];
    final sectorLevels = List.generate(
      currentSector.endLevel - currentSector.startLevel + 1,
      (idx) => LevelCatalog.getLevel(currentSector.startLevel + idx),
    );


    int sectorStars = 0;
    for (final lvl in sectorLevels) {
      sectorStars += GameStorage.instance.getStarsForLevel(lvl.levelNumber);
    }
    final maxSectorStars = sectorLevels.length * 3;

    return Scaffold(
      backgroundColor: GameColors.oledDark,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    onPressed: () {
                      AudioSynthesizer.instance.playUiClick();
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'SECTOR MAP',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const Spacer(),
                  // Stars Tracker
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: GameColors.surfaceCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: GameColors.solarGold.withOpacity(0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star_rounded, color: GameColors.solarGold, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '$sectorStars / $maxSectorStars',
                          style: const TextStyle(color: GameColors.solarGold, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Sector Tabs Carousel / Selector
            SizedBox(
              height: 46,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: worldSectors.length,
                itemBuilder: (context, index) {
                  final sector = worldSectors[index];
                  final isSelected = index == _selectedSectorIndex;
                  final isUnlocked = widget.unlockedLevel >= sector.startLevel;

                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        AudioSynthesizer.instance.playUiClick();
                        setState(() => _selectedSectorIndex = index);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? sector.themeColor.withOpacity(0.25)
                              : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? sector.themeColor
                                : (isUnlocked ? Colors.white24 : Colors.white10),
                            width: isSelected ? 1.5 : 1.0,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: sector.themeColor.withOpacity(0.4),
                                    blurRadius: 10,
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              sector.icon,
                              size: 16,
                              color: isSelected
                                  ? sector.themeColor
                                  : (isUnlocked ? Colors.white70 : Colors.white24),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'SECTOR ${sector.sectorNumber}',
                              style: TextStyle(
                                color: isSelected ? Colors.white : (isUnlocked ? Colors.white70 : Colors.white38),
                                fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Sector Banner Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: GlassCard(
                glow: true,
                glowColor: currentSector.themeColor,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                borderRadius: 16,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: currentSector.themeColor.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(currentSector.icon, color: currentSector.themeColor, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentSector.name,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 1.1),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            currentSector.description,
                            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Sector Level Nodes List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 4.0),
                itemCount: sectorLevels.length,
                itemBuilder: (context, index) {
                  final lvl = sectorLevels[index];
                  final isUnlocked = lvl.levelNumber <= widget.unlockedLevel;
                  final isCurrent = lvl.levelNumber == widget.unlockedLevel;
                  final isImpossible = lvl.archetype == LevelArchetype.impossibleCitadel;
                  final stars = GameStorage.instance.getStarsForLevel(lvl.levelNumber);
                  final themeColor = lvl.themeColor ?? currentSector.themeColor;

                  // Analyze mechanics in level
                  final hasLasers = lvl.initialBricks.any((b) => b.type == BrickType.horizontalLaser || b.type == BrickType.verticalLaser || b.type == BrickType.crossLaser || b.type == BrickType.diagonalLaser);
                  final hasBombs = lvl.initialBricks.any((b) => b.type == BrickType.clusterBomb || b.type == BrickType.chainDynamite || b.type == BrickType.superNuke);
                  final hasTitanium = lvl.initialBricks.any((b) => b.type == BrickType.armoredBrick || b.type == BrickType.titaniumShield);
                  final hasSplitter = lvl.initialBricks.any((b) => b.type == BrickType.inAirSplitter);


                  return Container(
                    margin: const EdgeInsets.only(bottom: 12.0),
                    child: GlassCard(
                      borderColor: isCurrent ? themeColor.withOpacity(0.5) : GameColors.glassBorder,
                      padding: const EdgeInsets.all(14.0),
                      borderRadius: 16.0,
                      child: Row(
                        children: [
                          // Holographic Blueprint Radar Preview
                          LevelBlueprintPreview(level: lvl, size: 52),
                          const SizedBox(width: 14),

                          // Level Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isUnlocked ? themeColor.withOpacity(0.25) : Colors.white10,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: isUnlocked ? themeColor : Colors.white24, width: 0.8),
                                      ),
                                      child: Text(
                                        'LVL ${lvl.levelNumber}',
                                        style: TextStyle(
                                          color: isUnlocked ? Colors.white : Colors.white38,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        lvl.title,
                                        style: TextStyle(
                                          color: isUnlocked ? Colors.white : Colors.white38,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 14,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),

                                // Hazard / Mechanics Chips
                                Row(
                                  children: [
                                    if (hasLasers) ...[
                                      const Text('⚡ Laser', style: TextStyle(color: GameColors.crimsonDanger, fontSize: 10, fontWeight: FontWeight.bold)),
                                      const SizedBox(width: 6),
                                    ],
                                    if (hasBombs) ...[
                                      const Text('💣 Nuke', style: TextStyle(color: GameColors.solarGold, fontSize: 10, fontWeight: FontWeight.bold)),
                                      const SizedBox(width: 6),
                                    ],
                                    if (hasTitanium) ...[
                                      const Text('🛡️ Titanium', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                                      const SizedBox(width: 6),
                                    ],
                                    if (hasSplitter) ...[
                                      const Text('🧬 Swarm', style: TextStyle(color: GameColors.neonMagenta, fontSize: 10, fontWeight: FontWeight.bold)),
                                      const SizedBox(width: 6),
                                    ],
                                    Text(
                                      '${lvl.startingBalls} Balls',
                                      style: const TextStyle(color: Colors.white38, fontSize: 10),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),

                                // Star Rating Display
                                Row(
                                  children: List.generate(3, (starIdx) {
                                    final earned = starIdx < stars;
                                    return Icon(
                                      Icons.star_rounded,
                                      size: 16,
                                      color: earned ? GameColors.solarGold : Colors.white24,
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),

                          // Play Button / Lock
                          if (isUnlocked)
                            GlassButton(
                              onPressed: () {
                                AudioSynthesizer.instance.playUiClick();
                                Navigator.of(context).pop();
                                widget.onSelectLevel(lvl.levelNumber);
                              },
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              borderRadius: 12,
                              gradient: [themeColor, themeColor.withOpacity(0.7)],
                              child: const Text(
                                'PLAY',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.0),
                              ),
                            )
                          else
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.0),
                              child: Icon(Icons.lock_outline_rounded, color: Colors.white24, size: 24),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

