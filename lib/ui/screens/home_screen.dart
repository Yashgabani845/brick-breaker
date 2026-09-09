import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/game_colors.dart';
import '../../core/constants/game_constants.dart';
import '../../game/levels/level_catalog.dart';
import '../../game/levels/procedural_generator.dart';
import '../../game/models/ball.dart';
import '../../game/systems/audio_synthesizer.dart';
import '../../storage/game_storage.dart';
import '../components/glass_button.dart';
import '../components/glass_card.dart';
import '../components/glass_modal.dart';
import '../components/neon_glow_text.dart';
import '../components/swarm_3d_sphere.dart';
import '../modals/sandbox_debug_modal.dart';
import '../modals/settings_modal.dart';
import 'daily_challenge_screen.dart';
import 'gameplay_screen.dart';
import 'level_map_screen.dart';
import 'skins_wardrobe_screen.dart';

/// Next-Gen Cyber-Glassmorphic Home Screen for Android & Mobile
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _floatController;
  int _coins = 250;
  int _gems = 20;
  int _unlockedLevel = 1;
  int _permanentBalls = 35;
  int _totalStars = 0;
  int _highScore = 0;
  int _themeIndex = 0;
  DifficultyMode _difficulty = DifficultyMode.standard;
  BallSkin _currentSkin = BallSkin.neonWhite;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _loadSaveData();
  }

  Future<void> _loadSaveData() async {
    await GameStorage.instance.init();
    int stars = 0;
    for (int i = 1; i <= 20; i++) {
      stars += GameStorage.instance.getStarsForLevel(i);
    }
    if (mounted) {
      setState(() {
        _coins = GameStorage.instance.getCoins();
        _gems = GameStorage.instance.getGems();
        _unlockedLevel = GameStorage.instance.getHighestLevelUnlocked();
        _difficulty = GameStorage.instance.getDifficultyMode();
        _currentSkin = GameStorage.instance.getSelectedSkin();
        _permanentBalls = (30 + (_unlockedLevel * 5)).clamp(30, 500);
        _totalStars = stars;
        _highScore = GameStorage.instance.getHighScore();
        _themeIndex = GameStorage.instance.getDarkThemeIndex();
        _isMuted = AudioSynthesizer.instance.isMuted;
      });
    }
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  void _startLevel(int levelNum, {DifficultyMode? diff}) {
    AudioSynthesizer.instance.playUiClick();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameplayScreen(
          levelData: LevelCatalog.getLevel(levelNum),
          difficulty: diff ?? _difficulty,
          initialBalls: _permanentBalls,
          ballSkin: _currentSkin,
        ),
      ),
    ).then((_) => _loadSaveData());
  }

  void _startEndlessMode() {
    AudioSynthesizer.instance.playUiClick();
    final endlessLevel = ProceduralLevelGenerator.generate(levelNumber: 99);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameplayScreen(
          levelData: endlessLevel.copyWith(title: 'ENDLESS MATRIX SURVIVAL'),
          difficulty: _difficulty,
          initialBalls: _permanentBalls,
          ballSkin: _currentSkin,
        ),
      ),
    ).then((_) => _loadSaveData());
  }

  void _toggleDarkTheme() {
    AudioSynthesizer.instance.playUiClick();
    final nextIndex = (_themeIndex == 0) ? 1 : 0;
    GameStorage.instance.setDarkThemeIndex(nextIndex);
    setState(() => _themeIndex = nextIndex);
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = GameColors.getBackgroundColor(_themeIndex);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // 1. Dynamic Ambient Background
          _buildCosmicBackground(),

          // 2. Main Scrollable Interface
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Column(
                children: [
                  // Top Resource Bar with Theme & Audio Toggles
                  _buildTopBar(),
                  const SizedBox(height: 12),

                  // Hero App Logo & 3D Title Card
                  _buildHeroLogoCard(),
                  const SizedBox(height: 14),

                  // 3D Ball Swarm Interactive Sphere Showcase
                  _build3dSwarmShowcase(),
                  const SizedBox(height: 16),

                  // Giant Primary Play CTA
                  _buildMainPlayCta(),
                  const SizedBox(height: 16),

                  // 4 Game Modes Grid
                  _buildGameModesGrid(),
                  const SizedBox(height: 16),

                  // Stats Ribbon
                  _buildStatsRibbon(),
                  const SizedBox(height: 16),

                  // Quick Action Dock (Wardrobe, Settings, Sandbox)
                  _buildBottomDock(),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCosmicBackground() {
    if (_themeIndex == 0) {
      // OLED Pitch Black Mode
      return Container(color: Colors.black);
    }

    // Cyber Space Dark Mode with subtle ambient pulsing nebula
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        final t = _floatController.value;
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.0, -0.2 + 0.1 * math.sin(t * math.pi)),
              radius: 1.4,
              colors: [
                Color.lerp(const Color(0xFF0F172A), const Color(0xFF1E1B4B), t)!,
                GameColors.spaceDark,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Level & Stars Chip
        GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          borderRadius: 14,
          glow: true,
          glowColor: GameColors.solarGold,
          onTap: () => _openLevelMap(),
          child: Row(
            children: [
              const Icon(Icons.military_tech_rounded, color: GameColors.solarGold, size: 18),
              const SizedBox(width: 4),
              Text(
                'LVL $_unlockedLevel',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.star_rounded, color: GameColors.solarGold, size: 16),
              const SizedBox(width: 2),
              Text(
                '$_totalStars',
                style: const TextStyle(color: GameColors.solarGold, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
        ),

        // Currencies & Toggles
        Row(
          children: [
            // Coins
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              borderRadius: 14,
              child: Row(
                children: [
                  const Text('🪙', style: TextStyle(fontSize: 13)),
                  const SizedBox(width: 4),
                  Text(
                    '$_coins',
                    style: const TextStyle(color: GameColors.electricAmber, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),

            // Gems
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              borderRadius: 14,
              child: Row(
                children: [
                  const Text('💎', style: TextStyle(fontSize: 13)),
                  const SizedBox(width: 4),
                  Text(
                    '$_gems',
                    style: const TextStyle(color: GameColors.neonPurple, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),

            // Dual Black Theme Switcher Button
            GlassCard(
              padding: const EdgeInsets.all(7),
              borderRadius: 14,
              onTap: _toggleDarkTheme,
              child: Icon(
                _themeIndex == 0 ? Icons.dark_mode_rounded : Icons.brightness_4_rounded,
                color: _themeIndex == 0 ? GameColors.neonCyan : GameColors.neonPurple,
                size: 19,
              ),
            ),
            const SizedBox(width: 6),

            // Audio Mute Toggle
            GlassCard(
              padding: const EdgeInsets.all(7),
              borderRadius: 14,
              onTap: () {
                setState(() {
                  AudioSynthesizer.instance.toggleMute();
                  _isMuted = AudioSynthesizer.instance.isMuted;
                  GameStorage.instance.setIsMuted(_isMuted);
                });
                if (!_isMuted) {
                  AudioSynthesizer.instance.playRewardClaim();
                }
              },
              child: Icon(
                _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                color: _isMuted ? Colors.white38 : GameColors.neonCyan,
                size: 19,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroLogoCard() {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        final floatOffset = math.sin(_floatController.value * math.pi) * 3.0;

        return Transform.translate(
          offset: Offset(0, floatOffset),
          child: GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            borderRadius: 22,
            glow: true,
            glowColor: GameColors.neonCyan,
            surfaceColor: const Color(0x1A00F0FF),
            child: Row(
              children: [
                // Glowing App Logo Emblem
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: GameColors.neonCyan.withOpacity(0.6), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: GameColors.neonCyan.withOpacity(0.35),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      'assets/images/app_logo.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.black,
                        child: const Icon(Icons.sports_esports_rounded, color: GameColors.neonCyan, size: 36),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Game Title
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          NeonGlowText(
                            'BRICKS BREAKER',
                            fontSize: 18.0,
                            color: Colors.white,
                            glowColor: GameColors.neonCyan,
                            letterSpacing: 1.2,
                          ),
                          SizedBox(width: 6),
                          NeonGlowText(
                            '3D',
                            fontSize: 20.0,
                            color: GameColors.neonMagenta,
                            glowColor: GameColors.neonMagenta,
                            letterSpacing: 1.5,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '1,000 CYBER LEVELS',
                        style: TextStyle(
                          color: GameColors.neonCyan.withOpacity(0.8),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _build3dSwarmShowcase() {
    return GlassCard(
      glow: true,
      glowColor: _currentSkin.glowColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 22,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const SkinsWardrobeScreen()),
        ).then((_) => _loadSaveData());
      },
      child: Column(
        children: [
          // 3D Swarm Canvas
          SizedBox(
            height: 120,
            child: Center(
              child: Swarm3dSphere(
                ballCount: _permanentBalls,
                skin: _currentSkin,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SkinsWardrobeScreen()),
                  ).then((_) => _loadSaveData());
                },
              ),
            ),
          ),
          const SizedBox(height: 4),

          // Swarm Count & Skin Name
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$_permanentBalls BALLS',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _currentSkin.glowColor.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _currentSkin.glowColor.withOpacity(0.6)),
                ),
                child: Text(
                  _currentSkin.displayName.toUpperCase(),
                  style: TextStyle(
                    color: _currentSkin.glowColor,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainPlayCta() {
    final isMax = _unlockedLevel > 20;
    final lvlTitle = isMax ? 'PLAY ENDLESS' : 'PLAY LEVEL $_unlockedLevel';

    return SizedBox(
      width: double.infinity,
      child: GlassButton(
        onPressed: () {
          if (isMax) {
            _startEndlessMode();
          } else {
            _startLevel(_unlockedLevel);
          }
        },
        gradient: const [GameColors.neonCyan, Color(0xFF0077FF), Color(0xFF8B5CF6)],
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        borderRadius: 20.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 30),
            const SizedBox(width: 8),
            Text(
              lvlTitle,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 17,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameModesGrid() {
    return Column(
      children: [
        Row(
          children: [
            // Sector Campaign Map Card
            Expanded(
              child: GlassCard(
                onTap: _openLevelMap,
                padding: const EdgeInsets.all(12),
                borderRadius: 16,
                glow: true,
                glowColor: GameColors.neonCyan,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.map_rounded, color: GameColors.neonCyan, size: 24),
                    const SizedBox(height: 8),
                    const Text('SECTOR MAP', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 2),
                    Text('1,000 Levels', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10.5)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Daily Challenge Card
            Expanded(
              child: GlassCard(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const DailyChallengeScreen()),
                  ).then((_) => _loadSaveData());
                },
                padding: const EdgeInsets.all(12),
                borderRadius: 16,
                glow: true,
                glowColor: GameColors.electricAmber,
                surfaceColor: const Color(0x22FFB300),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.calendar_month_rounded, color: GameColors.electricAmber, size: 24),
                    const SizedBox(height: 8),
                    const Text('DAILY QUEST', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 2),
                    const Text('Rewards 🔥', style: TextStyle(color: GameColors.electricAmber, fontSize: 10.5, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            // Brutal Hardcore Mode Card
            Expanded(
              child: GlassCard(
                onTap: () => _startLevel(10, diff: DifficultyMode.brutalImpossible),
                padding: const EdgeInsets.all(12),
                borderRadius: 16,
                glow: true,
                glowColor: GameColors.crimsonDanger,
                surfaceColor: const Color(0x33FF1744),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.local_fire_department_rounded, color: GameColors.crimsonDanger, size: 24),
                    const SizedBox(height: 8),
                    const Text('BRUTAL TRIAL', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 2),
                    const Text('5x Challenge', style: TextStyle(color: GameColors.crimsonDanger, fontSize: 10.5, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Endless Mode Card
            Expanded(
              child: GlassCard(
                onTap: _startEndlessMode,
                padding: const EdgeInsets.all(12),
                borderRadius: 16,
                glow: true,
                glowColor: GameColors.neonPurple,
                surfaceColor: const Color(0x229D4EDD),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.all_inclusive_rounded, color: GameColors.neonPurple, size: 24),
                    const SizedBox(height: 8),
                    const Text('ENDLESS', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 2),
                    Text('Infinite Waves', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10.5)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsRibbon() {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      borderRadius: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('BEST', '$_highScore', GameColors.neonCyan),
          _buildStatItem('STARS', '$_totalStars ⭐', GameColors.solarGold),
          _buildStatItem('BALLS', '$_permanentBalls ⚪', GameColors.neonLime),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, Color color) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.8)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _buildBottomDock() {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      borderRadius: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Skins Wardrobe Button
          GestureDetector(
            onTap: () {
              AudioSynthesizer.instance.playUiClick();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SkinsWardrobeScreen()),
              ).then((_) => _loadSaveData());
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.palette_rounded, color: GameColors.neonPurple, size: 24),
                SizedBox(height: 4),
                Text('Skins', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          // Sandbox / Level Debug
          GestureDetector(
            onTap: () {
              AudioSynthesizer.instance.playUiClick();
              GlassModal.show(
                context: context,
                title: 'LEVEL SELECTOR',
                child: SandboxDebugModal(
                  onLoadLevel: (lvl) {
                    Navigator.of(context).pop();
                    _startLevel(lvl);
                  },
                ),
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.science_rounded, color: GameColors.neonCyan, size: 24),
                SizedBox(height: 4),
                Text('Selector', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          // Settings Button
          GestureDetector(
            onTap: () {
              AudioSynthesizer.instance.playUiClick();
              GlassModal.show(
                context: context,
                title: 'SETTINGS',
                child: SettingsModal(
                  currentDifficulty: _difficulty,
                  onDifficultyChanged: (newDiff) {
                    setState(() => _difficulty = newDiff);
                  },
                ),
              ).then((_) => _loadSaveData());
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.settings_rounded, color: Colors.white70, size: 24),
                SizedBox(height: 4),
                Text('Settings', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openLevelMap() {
    AudioSynthesizer.instance.playUiClick();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LevelMapScreen(
          unlockedLevel: _unlockedLevel,
          onSelectLevel: (lvl) => _startLevel(lvl),
        ),
      ),
    ).then((_) => _loadSaveData());
  }
}
