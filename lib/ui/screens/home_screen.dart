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
import '../components/glass_modal.dart';
import '../components/swarm_3d_sphere.dart';
import '../modals/sandbox_debug_modal.dart';
import '../modals/settings_modal.dart';
import 'daily_challenge_screen.dart';
import 'gameplay_screen.dart';
import 'level_map_screen.dart';
import 'skins_wardrobe_screen.dart';

/// Next-Gen AAA Cyber-Glassmorphic Home Screen for Android & Mobile
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ambientController;
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
    _ambientController = AnimationController(
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
    _ambientController.dispose();
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

  void _toggleDarkTheme() {
    AudioSynthesizer.instance.playUiClick();
    final nextIndex = (_themeIndex == 0) ? 1 : 0;
    GameStorage.instance.setDarkThemeIndex(nextIndex);
    setState(() => _themeIndex = nextIndex);
  }

  void _toggleMute() {
    setState(() {
      AudioSynthesizer.instance.toggleMute();
      _isMuted = AudioSynthesizer.instance.isMuted;
      GameStorage.instance.setIsMuted(_isMuted);
    });
    if (!_isMuted) {
      AudioSynthesizer.instance.playRewardClaim();
    }
  }

  void _openSettings() {
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

  void _openWardrobe() {
    AudioSynthesizer.instance.playUiClick();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SkinsWardrobeScreen()),
    ).then((_) => _loadSaveData());
  }

  void _openDailyQuests() {
    AudioSynthesizer.instance.playUiClick();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const DailyChallengeScreen()),
    ).then((_) => _loadSaveData());
  }

  void _openSandbox() {
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
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = GameColors.getBackgroundColor(_themeIndex);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // 1. Ambient Background with subtle glowing energy
          _buildBackground(),

          // 2. Main Scrollable Interface
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Status Header: Level Capsule, Currency Pills & Quick Actions
                  _buildHeaderHUD(),
                  const SizedBox(height: 14),

                  // Hero Swarm Stage (Branding + 3D Holographic Interactive Sphere)
                  _buildHeroSwarmStage(),
                  const SizedBox(height: 14),

                  // Giant Arcade Primary Play CTA
                  _buildPrimaryPlayCTA(),
                  const SizedBox(height: 14),

                  // 2x2 Bento Mode Grid (Campaign Map, Daily Quest, Armory, Sandbox)
                  _buildBentoModesGrid(),
                  const SizedBox(height: 14),

                  // Career Stats Showcase Ribbon
                  _buildStatsShowcase(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // 1. AMBIENT BACKGROUND
  // ═════════════════════════════════════════════════════════════════════════════
  Widget _buildBackground() {
    if (_themeIndex == 0) {
      // Pure OLED Pitch Black with subtle ambient vignette
      return Container(
        decoration: const BoxDecoration(
          color: Colors.black,
          gradient: RadialGradient(
            center: Alignment(0.0, -0.3),
            radius: 1.2,
            colors: [
              Color(0xFF070B14),
              Colors.black,
            ],
          ),
        ),
      );
    }

    // Cyber Space Deep Dark Mode with animated pulsating nebula
    return AnimatedBuilder(
      animation: _ambientController,
      builder: (context, child) {
        final t = _ambientController.value;
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.0, -0.3 + 0.15 * math.sin(t * math.pi)),
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

  // ═════════════════════════════════════════════════════════════════════════════
  // 2. TOP STATUS HEADER HUD
  // ═════════════════════════════════════════════════════════════════════════════
  Widget _buildHeaderHUD() {
    return Row(
      children: [
        // Level Capsule with Stars & Map Trigger
        Expanded(
          flex: 5,
          child: GestureDetector(
            onTap: _openLevelMap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF121824).withOpacity(0.85),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: GameColors.solarGold.withOpacity(0.4), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: GameColors.solarGold.withOpacity(0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: GameColors.solarGold.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.shield_rounded, color: GameColors.solarGold, size: 16),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'STAGE $_unlockedLevel',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 12.5,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: GameColors.solarGold, size: 12),
                            const SizedBox(width: 2),
                            Text(
                              '$_totalStars Stars',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Currency Counters
        _buildCurrencyPill('🪙', '$_coins', GameColors.electricAmber),
        const SizedBox(width: 6),
        _buildCurrencyPill('💎', '$_gems', GameColors.neonPurple),
        const SizedBox(width: 6),

        // Quick Controls (Sound & Theme & Settings)
        _buildCircleAction(
          icon: _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
          color: _isMuted ? Colors.white38 : GameColors.neonCyan,
          onTap: _toggleMute,
        ),
        const SizedBox(width: 5),
        _buildCircleAction(
          icon: _themeIndex == 0 ? Icons.dark_mode_rounded : Icons.brightness_4_rounded,
          color: _themeIndex == 0 ? GameColors.neonCyan : GameColors.neonPurple,
          onTap: _toggleDarkTheme,
        ),
        const SizedBox(width: 5),
        _buildCircleAction(
          icon: Icons.settings_rounded,
          color: Colors.white70,
          onTap: _openSettings,
        ),
      ],
    );
  }

  Widget _buildCurrencyPill(String emoji, String amount, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF121824).withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withOpacity(0.35), width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            amount,
            style: TextStyle(
              color: accentColor,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleAction({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        AudioSynthesizer.instance.playUiClick();
        onTap();
      },
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: const Color(0xFF121824).withOpacity(0.85),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Icon(icon, color: color, size: 17),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // 3. HERO SWARM ARENA STAGE (Unified Branding & 3D Interactive Showcase)
  // ═════════════════════════════════════════════════════════════════════════════
  Widget _buildHeroSwarmStage() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.7),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: GameColors.neonCyan.withOpacity(0.25), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: _currentSkin.glowColor.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Bar inside Stage: App Emblem & Sleek Title
          Padding(
            padding: const EdgeInsets.only(left: 14, right: 14, top: 12, bottom: 4),
            child: Row(
              children: [
                // App Logo Emblem
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: GameColors.neonCyan.withOpacity(0.4), width: 1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(9),
                    child: Image.asset(
                      'assets/images/app_logo.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.black,
                        child: const Icon(Icons.sports_esports_rounded, color: GameColors.neonCyan, size: 22),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Title & Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Text(
                            'BRICKS BREAKER',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.8,
                            ),
                          ),
                          SizedBox(width: 5),
                          Text(
                            '3D',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: GameColors.neonMagenta,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '1,000 CYBER LEVELS • ULTRA PHYSICS',
                        style: TextStyle(
                          color: GameColors.neonCyan.withOpacity(0.85),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 3D Holographic Swarm Sphere (Touch-interactive)
          GestureDetector(
            onTap: _openWardrobe,
            child: SizedBox(
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Ambient center glow
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _currentSkin.glowColor.withOpacity(0.25),
                          blurRadius: 30,
                          spreadRadius: 6,
                        ),
                      ],
                    ),
                  ),
                  Swarm3dSphere(
                    ballCount: _permanentBalls,
                    skin: _currentSkin,
                    onTap: _openWardrobe,
                  ),
                ],
              ),
            ),
          ),

          // Swarm Status Bar & Customize Pill
          Padding(
            padding: const EdgeInsets.only(left: 14, right: 14, bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Ball Count Badge
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentSkin.glowColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _currentSkin.glowColor,
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$_permanentBalls BALL SWARM',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),

                // Skin Pill / Customize Trigger
                GestureDetector(
                  onTap: _openWardrobe,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _currentSkin.glowColor.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _currentSkin.glowColor.withOpacity(0.5), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _currentSkin.displayName.toUpperCase(),
                          style: TextStyle(
                            color: _currentSkin.glowColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.edit_rounded, color: _currentSkin.glowColor, size: 11),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // 4. GIANT ARCADE PRIMARY PLAY CTA
  // ═════════════════════════════════════════════════════════════════════════════
  Widget _buildPrimaryPlayCTA() {
    final levelData = LevelCatalog.getLevel(_unlockedLevel);
    final stageName = levelData.title.isNotEmpty ? levelData.title : 'STAGE $_unlockedLevel';

    return GlassButton(
      onPressed: () => _startLevel(_unlockedLevel),
      gradient: const [
        Color(0xFF00E5FF),
        Color(0xFF0072FF),
        Color(0xFF0052D4),
      ],
      padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0),
      borderRadius: 18.0,
      child: Row(
        children: [
          // Glowing Play Disc
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.5),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Icon(Icons.play_arrow_rounded, color: Color(0xFF0052D4), size: 30),
          ),
          const SizedBox(width: 14),

          // Main Callout Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'PLAY NOW',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  'LEVEL $_unlockedLevel • ${stageName.toUpperCase()}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    letterSpacing: 0.6,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Forward Arrow
          const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 26),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // 5. 2x2 BENTO MODES GRID (Campaign Map, Daily Quest, Armory, Sandbox)
  // ═════════════════════════════════════════════════════════════════════════════
  Widget _buildBentoModesGrid() {
    return Column(
      children: [
        Row(
          children: [
            // Sector Campaign Map Tile
            Expanded(
              child: _buildBentoTile(
                title: 'SECTOR MAP',
                subtitle: '1,000 Levels',
                icon: Icons.map_rounded,
                accentColor: GameColors.neonCyan,
                badgeText: 'CAMPAIGN',
                onTap: _openLevelMap,
              ),
            ),
            const SizedBox(width: 10),

            // Daily Quests Tile
            Expanded(
              child: _buildBentoTile(
                title: 'DAILY QUEST',
                subtitle: 'Streak & Coins 🔥',
                icon: Icons.local_fire_department_rounded,
                accentColor: GameColors.electricAmber,
                badgeText: 'REWARDS',
                onTap: _openDailyQuests,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            // Armory & Skins Tile
            Expanded(
              child: _buildBentoTile(
                title: 'ARMORY',
                subtitle: 'Ball Skins & Trail',
                icon: Icons.palette_rounded,
                accentColor: GameColors.neonPurple,
                badgeText: 'CUSTOMIZE',
                onTap: _openWardrobe,
              ),
            ),
            const SizedBox(width: 10),

            // Sandbox / Level Selector Tile
            Expanded(
              child: _buildBentoTile(
                title: 'SANDBOX',
                subtitle: 'Level Tester',
                icon: Icons.science_rounded,
                accentColor: GameColors.emeraldGreen,
                badgeText: 'DEBUG',
                onTap: _openSandbox,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBentoTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required String badgeText,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        AudioSynthesizer.instance.playUiClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF101626).withOpacity(0.8),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accentColor.withOpacity(0.3), width: 1.1),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: accentColor, size: 18),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 13,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // 6. CAREER STATS SHOWCASE RIBBON
  // ═════════════════════════════════════════════════════════════════════════════
  Widget _buildStatsShowcase() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatColumn('BEST SCORE', '$_highScore', GameColors.neonCyan),
          Container(width: 1, height: 26, color: Colors.white.withOpacity(0.1)),
          _buildStatColumn('TOTAL STARS', '$_totalStars ⭐', GameColors.solarGold),
          Container(width: 1, height: 26, color: Colors.white.withOpacity(0.1)),
          _buildStatColumn('SWARM POOL', '$_permanentBalls ⚪', GameColors.neonLime),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 13.5,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
