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
import '../modals/settings_modal.dart';
import 'daily_challenge_screen.dart';
import 'gameplay_screen.dart';
import 'level_map_screen.dart';
import 'skins_wardrobe_screen.dart';

/// Next-Gen Cyber-Glassmorphic Home Screen
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  int _coins = 250;
  int _gems = 20;
  int _unlockedLevel = 1;
  int _permanentBalls = 35;
  int _totalStars = 0;
  int _highScore = 0;
  DifficultyMode _difficulty = DifficultyMode.standard;
  BallSkin _currentSkin = BallSkin.neonWhite;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _loadSaveData();
  }

  Future<void> _loadSaveData() async {
    await GameStorage.instance.init();
    int stars = 0;
    for (int i = 1; i <= 20; i++) {
      stars += GameStorage.instance.getStarsForLevel(i);
    }
    setState(() {
      _coins = GameStorage.instance.getCoins();
      _gems = GameStorage.instance.getGems();
      _unlockedLevel = GameStorage.instance.getHighestLevelUnlocked();
      _difficulty = GameStorage.instance.getDifficultyMode();
      _currentSkin = GameStorage.instance.getSelectedSkin();
      _permanentBalls = (30 + (_unlockedLevel * 5)).clamp(30, 500);
      _totalStars = stars;
      _highScore = GameStorage.instance.getHighScore();
      _isMuted = AudioSynthesizer.instance.isMuted;
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.oledDark,
      body: Stack(
        children: [
          // 1. Ambient Dynamic Space Nebula Background
          _buildCosmicBackground(),

          // 2. Main Scrollable/Adaptive Viewport
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
              child: Column(
                children: [
                  // Top Resource & Sound Bar
                  _buildTopBar(),
                  const SizedBox(height: 12),

                  // Game Title & Stats Pill
                  _buildTitleSection(),
                  const SizedBox(height: 14),

                  // 3D Interactive Swarm Hero Showcase
                  _build3dSwarmHero(),
                  const SizedBox(height: 20),

                  // Primary Campaign CTA
                  _buildMainPlayCta(),
                  const SizedBox(height: 16),

                  // Game Modes Grid
                  _buildModeCards(),
                  const SizedBox(height: 16),

                  // Quick Action Dock (Wardrobe, Settings, Info)
                  _buildQuickActionDock(),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCosmicBackground() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final t = _pulseController.value;
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.0, -0.3 + 0.15 * math.sin(t * math.pi)),
              radius: 1.5,
              colors: [
                Color.lerp(GameColors.spaceDark, const Color(0xFF1E1B4B), t)!,
                GameColors.oledDark,
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
        // Level & Star Chip
        GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          borderRadius: 14,
          glow: true,
          glowColor: GameColors.solarGold,
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

        // Currency Badges & Sound Toggle
        Row(
          children: [
            // Coins
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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

            // Audio Toggle
            GlassCard(
              padding: const EdgeInsets.all(6),
              borderRadius: 14,
              onTap: () {
                setState(() {
                  AudioSynthesizer.instance.toggleMute();
                  _isMuted = AudioSynthesizer.instance.isMuted;
                });
                if (!_isMuted) {
                  AudioSynthesizer.instance.playCollectPlusBall();
                }
              },
              child: Icon(
                _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                color: _isMuted ? Colors.white38 : GameColors.neonCyan,
                size: 20,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTitleSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            NeonGlowText(
              'BRICKS BREAKER',
              fontSize: 28.0,
              color: Colors.white,
              glowColor: GameColors.neonCyan,
              letterSpacing: 2.0,
            ),
            SizedBox(width: 8),
            NeonGlowText(
              '3D',
              fontSize: 32.0,
              color: GameColors.neonMagenta,
              glowColor: GameColors.neonMagenta,
              letterSpacing: 3.0,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: Text(
            'HIGH SCORE: $_highScore • HARDCORE PHYSICS ENGINE',
            style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.1),
          ),
        ),
      ],
    );
  }

  Widget _build3dSwarmHero() {
    return GlassCard(
      glow: true,
      glowColor: _currentSkin.glowColor,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      borderRadius: 26,
      child: Column(
        children: [
          // 3D Swarm Sphere Canvas
          SizedBox(
            height: 150,
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
          const SizedBox(height: 8),

          // Swarm Status & Skin Tag
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$_permanentBalls BALL SWARM',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _currentSkin.glowColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _currentSkin.glowColor.withOpacity(0.5)),
                ),
                child: Text(
                  _currentSkin.displayName.toUpperCase(),
                  style: TextStyle(
                    color: _currentSkin.glowColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _difficulty == DifficultyMode.brutalImpossible
                ? '🔥 BRUTAL HARDCORE (5X HP APEX OVERCLOCK)'
                : 'DIFFICULTY: ${_difficulty.displayName.toUpperCase()}',
            style: TextStyle(
              color: _difficulty == DifficultyMode.brutalImpossible
                  ? GameColors.crimsonDanger
                  : GameColors.neonCyan,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainPlayCta() {
    final isMax = _unlockedLevel > 20;
    final lvlTitle = isMax ? 'PLAY ENDLESS SURVIVAL' : 'PLAY LEVEL $_unlockedLevel';

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
        gradient: const [GameColors.neonCyan, Color(0xFF0077FF)],
        padding: const EdgeInsets.symmetric(vertical: 18.0),
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
                fontSize: 18,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeCards() {
    return Column(
      children: [
        Row(
          children: [
            // Sector Campaign Map Card
            Expanded(
              child: GlassCard(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => LevelMapScreen(
                        unlockedLevel: _unlockedLevel,
                        onSelectLevel: (lvl) => _startLevel(lvl),
                      ),
                    ),
                  ).then((_) => _loadSaveData());
                },
                padding: const EdgeInsets.all(14),
                borderRadius: 18,
                glow: true,
                glowColor: GameColors.neonCyan,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Icon(Icons.map_rounded, color: GameColors.neonCyan, size: 26),
                        Icon(Icons.chevron_right_rounded, color: Colors.white38, size: 20),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text('SECTOR MAP', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 2),
                    Text('20 Handcrafted Worlds', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Daily Challenge Card
            Expanded(
              child: GlassCard(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const DailyChallengeScreen()),
                  ).then((_) => _loadSaveData());
                },
                padding: const EdgeInsets.all(14),
                borderRadius: 18,
                glow: true,
                glowColor: GameColors.electricAmber,
                surfaceColor: const Color(0x22FFB300),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Icon(Icons.calendar_month_rounded, color: GameColors.electricAmber, size: 26),
                        Icon(Icons.chevron_right_rounded, color: Colors.white38, size: 20),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text('DAILY PUZZLE', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 2),
                    const Text('Streak Bounties', style: TextStyle(color: GameColors.electricAmber, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Brutal Impossible Citadel Card
            Expanded(
              child: GlassCard(
                onTap: () => _startLevel(10, diff: DifficultyMode.brutalImpossible),
                padding: const EdgeInsets.all(14),
                borderRadius: 18,
                glow: true,
                glowColor: GameColors.crimsonDanger,
                surfaceColor: const Color(0x33FF1744),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Icon(Icons.local_fire_department_rounded, color: GameColors.crimsonDanger, size: 26),
                        Text('5x HP', style: TextStyle(color: GameColors.crimsonDanger, fontSize: 10, fontWeight: FontWeight.w900)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text('IMPOSSIBLE', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 2),
                    const Text('Brutal Hardcore', style: TextStyle(color: GameColors.crimsonDanger, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Endless Mode Card
            Expanded(
              child: GlassCard(
                onTap: _startEndlessMode,
                padding: const EdgeInsets.all(14),
                borderRadius: 18,
                glow: true,
                glowColor: GameColors.neonPurple,
                surfaceColor: const Color(0x229D4EDD),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Icon(Icons.all_inclusive_rounded, color: GameColors.neonPurple, size: 26),
                        Text('RISING', style: TextStyle(color: GameColors.neonPurple, fontSize: 10, fontWeight: FontWeight.w900)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text('ENDLESS SURVIVAL', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 2),
                    Text('Infinite Waves', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionDock() {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                Icon(Icons.palette_rounded, color: GameColors.neonPurple, size: 26),
                SizedBox(height: 4),
                Text('Skins', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
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
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.settings_rounded, color: Colors.white70, size: 26),
                SizedBox(height: 4),
                Text('Settings', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

