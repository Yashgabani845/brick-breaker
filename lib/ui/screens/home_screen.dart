import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/game_colors.dart';
import '../../core/constants/game_constants.dart';
import '../../game/levels/level_catalog.dart';
import '../../game/models/ball.dart';
import '../../game/models/paddle.dart';
import '../../game/systems/audio_synthesizer.dart';
import '../../storage/game_storage.dart';
import '../components/glass_modal.dart';
import '../modals/leaderboard_modal.dart';
import '../modals/settings_modal.dart';
import '../modals/shop_modal.dart';
import 'daily_challenge_screen.dart';
import 'gameplay_screen.dart';
import 'leaderboard_screen.dart';
import 'level_map_screen.dart';
import 'settings_screen.dart';
import 'shop_screen.dart';
import 'skins_wardrobe_screen.dart';

/// Exact AAA "Brick Smash" Home Screen matching target visual design
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ambientController;
  int _coins = 1250;
  int _gems = 50;
  int _unlockedLevel = 28;
  int _permanentBalls = 50;
  DifficultyMode _difficulty = DifficultyMode.standard;
  BallSkin _currentSkin = BallSkin.neonWhite;
  PaddleSkin _currentPaddleSkin = PaddleSkin.neonBlade;

  @override
  void initState() {
    super.initState();
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _loadSaveData();
  }

  Future<void> _loadSaveData() async {
    await GameStorage.instance.init();
    if (mounted) {
      setState(() {
        _coins = GameStorage.instance.getCoins();
        _gems = GameStorage.instance.getGems();
        _unlockedLevel = GameStorage.instance.getHighestLevelUnlocked();
        _difficulty = GameStorage.instance.getDifficultyMode();
        _currentSkin = GameStorage.instance.getSelectedSkin();
        _currentPaddleSkin = GameStorage.instance.getSelectedPaddleSkin();
        _permanentBalls = (30 + (_unlockedLevel * 2)).clamp(30, 200);
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
          paddleSkin: _currentPaddleSkin,
        ),
      ),
    ).then((_) => _loadSaveData());
  }

  void _openSettings() {
    AudioSynthesizer.instance.playUiClick();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
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
      MaterialPageRoute(builder: (_) => const ShopScreen()),
    ).then((_) => _loadSaveData());
  }

  void _openDailyQuests() {
    AudioSynthesizer.instance.playUiClick();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const DailyChallengeScreen()),
    ).then((_) => _loadSaveData());
  }

  void _openShop() {
    AudioSynthesizer.instance.playUiClick();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ShopScreen()),
    ).then((_) => _loadSaveData());
  }

  void _openLeaderboard() {
    AudioSynthesizer.instance.playUiClick();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
    ).then((_) => _loadSaveData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B18),
      body: Stack(
        children: [
          // 1. Full-screen background image matching asset
          Positioned.fill(
            child: Image.asset(
              'assets/images/bshomebg.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF0F1A36), Color(0xFF060A17)],
                    ),
                  ),
                );
              },
            ),
          ),

          // 2. Ambient animated dust/glow overlay
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _ambientController,
              builder: (context, child) {
                final opacity = 0.05 + 0.05 * _ambientController.value;
                return Container(
                  color: Colors.blueAccent.withOpacity(opacity),
                );
              },
            ),
          ),

          // 3. UI Structure Layout
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Top Header: Settings, Gold Coins, Gems
                            _buildTopHeaderHUD(),
                            const SizedBox(height: 8),

                            // Hero Logo Section with bstitle.png
                            _buildHeroLogoSection(),
                            const SizedBox(height: 12),

                            // Giant Green Play Button
                            _buildGiantPlayButton(),
                            const SizedBox(height: 12),

                            // Dual Action Cards: Daily Challenge + Level Map
                            _buildDualActionCards(),
                            const SizedBox(height: 12),

                            // 4 Navigation Cards: Shop, Balls, Skins, Leaderboard
                            _buildBottomNavGrid(),
                            const Spacer(),

                            const SizedBox(height: 10),

                            // Bottom Level Pathway + "Smash Your Limits!"
                            _buildBottomPathway(),
                            const SizedBox(height: 4),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // TOP HEADER HUD: Settings, Gold Coin Pill, Diamond Gem Pill
  // ═════════════════════════════════════════════════════════════════════════════
  Widget _buildTopHeaderHUD() {
    return Row(
      children: [
        // Circular Settings Button
        GestureDetector(
          onTap: _openSettings,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF101A36).withOpacity(0.9),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF263868), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.settings_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
        const Spacer(),

        // Gold Coins Pill
        _buildCurrencyPill(
          icon: '🪙',
          amount: _coins.toString(),
          accentColor: const Color(0xFFFFD700),
          onAdd: _openShop,
        ),
        const SizedBox(width: 10),

        // Gems Pill
        _buildCurrencyPill(
          icon: '💎',
          amount: _gems.toString(),
          accentColor: const Color(0xFFE040FB),
          onAdd: _openShop,
        ),
      ],
    );
  }

  Widget _buildCurrencyPill({
    required String icon,
    required String amount,
    required Color accentColor,
    required VoidCallback onAdd,
  }) {
    return Container(
      height: 38,
      padding: const EdgeInsets.only(left: 8, right: 3, top: 2, bottom: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF0D162B).withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF223565), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(
            amount,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 14,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00E5FF), Color(0xFF00B0FF)],
                ),
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withOpacity(0.4),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: const Icon(Icons.add, color: Colors.black, size: 18, weight: 900),
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // HERO TITLE SECTION with bstitle.png
  // ═════════════════════════════════════════════════════════════════════════════
  Widget _buildHeroLogoSection() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _ambientController,
          builder: (context, child) {
            final dy = math.sin(_ambientController.value * math.pi) * 4.0;
            return Transform.translate(
              offset: Offset(0, dy),
              child: child,
            );
          },
          child: Image.asset(
            'assets/images/bstitle.png',
            height: 175,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Text(
                'BRICK SMASH',
                style: TextStyle(
                  color: Color(0xFFFFD54F),
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 4),

        // Slogan: AIM • SHOOT • SMASH • REPEAT
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSloganWord('AIM'),
            _buildSloganDot(),
            _buildSloganWord('SHOOT'),
            _buildSloganDot(),
            _buildSloganWord('SMASH'),
            _buildSloganDot(),
            _buildSloganWord('REPEAT'),
          ],
        ),
      ],
    );
  }

  Widget _buildSloganWord(String word) {
    return Text(
      word,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w900,
        fontSize: 11,
        letterSpacing: 1.5,
        shadows: [
          Shadow(color: Color(0xFF00E5FF), blurRadius: 8),
        ],
      ),
    );
  }

  Widget _buildSloganDot() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.0),
      child: Text(
        '•',
        style: TextStyle(
          color: Color(0xFF00E5FF),
          fontSize: 14,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // GIANT GLOSSY GREEN PLAY BUTTON
  // ═════════════════════════════════════════════════════════════════════════════
  Widget _buildGiantPlayButton() {
    return GestureDetector(
      onTap: () => _startLevel(_unlockedLevel),
      child: Container(
        height: 68,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(36),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF00E676),
              Color(0xFF00C853),
              Color(0xFF009624),
            ],
          ),
          border: Border.all(color: const Color(0xFFB9F6CA), width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00E676).withOpacity(0.55),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(34),
          child: Stack(
            children: [
              // Glossy top glass reflection
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 30,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.35),
                        Colors.white.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),

              // Button Content: Play icon + text + level
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 42,
                    ),
                    const SizedBox(width: 8),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Play',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                            height: 1.0,
                            shadows: [
                              Shadow(color: Color(0xFF004D20), blurRadius: 6, offset: Offset(0, 2)),
                            ],
                          ),
                        ),
                        Text(
                          'Level $_unlockedLevel',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            height: 1.2,
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
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // DUAL ACTION CARDS: Daily Challenge + Level Map
  // ═════════════════════════════════════════════════════════════════════════════
  Widget _buildDualActionCards() {
    return Row(
      children: [
        // Left: Daily Challenge (Purple Card)
        Expanded(
          child: GestureDetector(
            onTap: _openDailyQuests,
            child: Container(
              height: 62,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF7B1FA2),
                    Color(0xFF4A148C),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFBA68C8), width: 1.8),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7B1FA2).withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Card Content
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🏆', style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 8),
                        const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Daily',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                                height: 1.1,
                              ),
                            ),
                            Text(
                              'Challenge',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Red Notification Badge Dot
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF1744),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFFFF1744),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Right: Level Map (Amber/Orange Card)
        Expanded(
          child: GestureDetector(
            onTap: _openLevelMap,
            child: Container(
              height: 62,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFF9100),
                    Color(0xFFFF6D00),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFFD54F), width: 1.8),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF9100).withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('📍', style: TextStyle(fontSize: 22)),
                    SizedBox(width: 8),
                    Text(
                      'Level Map',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // BOTTOM 4 NAVIGATION CARDS: Shop, Balls, Skins, Leaderboard
  // ═════════════════════════════════════════════════════════════════════════════
  Widget _buildBottomNavGrid() {
    return Row(
      children: [
        // 1. Shop
        Expanded(
          child: _buildNavTile(
            label: 'Shop',
            iconWidget: const Icon(Icons.shopping_cart_rounded, color: Color(0xFFFF4081), size: 26),
            onTap: _openShop,
          ),
        ),
        const SizedBox(width: 8),

        // 2. Balls
        Expanded(
          child: _buildNavTile(
            label: 'Balls',
            iconWidget: Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: Alignment(-0.3, -0.3),
                  radius: 0.9,
                  colors: [
                    Color(0xFFFFFFFF),
                    Color(0xFF00E5FF),
                    Color(0xFFE040FB),
                    Color(0xFF304FFE),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF00E5FF),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
            onTap: _openWardrobe,
          ),
        ),
        const SizedBox(width: 8),

        // 3. Skins
        Expanded(
          child: _buildNavTile(
            label: 'Skins',
            iconWidget: const Icon(Icons.brush_rounded, color: Color(0xFF00E5FF), size: 26),
            onTap: _openWardrobe,
          ),
        ),
        const SizedBox(width: 8),

        // 4. Leaderboard
        Expanded(
          child: _buildNavTile(
            label: 'Leaderboard',
            iconWidget: const Icon(Icons.bar_chart_rounded, color: Color(0xFFFFD54F), size: 26),
            onTap: _openLeaderboard,
          ),
        ),
      ],
    );
  }

  Widget _buildNavTile({
    required String label,
    required Widget iconWidget,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 66,
        decoration: BoxDecoration(
          color: const Color(0xFF0D162B).withOpacity(0.92),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF223565), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconWidget,
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 10.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // BOTTOM LEVEL PATHWAY: "Smash Your Limits!" + Level Node Road
  // ═════════════════════════════════════════════════════════════════════════════
  Widget _buildBottomPathway() {
    final cur = _unlockedLevel;
    final prev2 = (cur - 2).clamp(1, 1000);
    final prev1 = (cur - 1).clamp(1, 1000);
    final next1 = (cur + 1).clamp(1, 1000);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // "Smash Your Limits!" badge text
        const Padding(
          padding: EdgeInsets.only(left: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Smash',
                style: TextStyle(
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  height: 1.0,
                ),
              ),
              Text(
                'Your Limits!',
                style: TextStyle(
                  color: Color(0xFFFFD54F),
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),

        // Node prev2
        _buildPathNode(levelNum: prev2, isCurrent: false, isCompleted: cur > prev2),
        const SizedBox(width: 8),

        // Node prev1
        _buildPathNode(levelNum: prev1, isCurrent: false, isCompleted: cur > prev1),
        const SizedBox(width: 8),

        // Node Current (Pulsing glowing orange ring)
        _buildPathNode(levelNum: cur, isCurrent: true, isCompleted: false),
        const SizedBox(width: 8),

        // Node Next
        _buildPathNode(levelNum: next1, isCurrent: false, isCompleted: false, isLocked: true),
      ],
    );
  }

  Widget _buildPathNode({
    required int levelNum,
    required bool isCurrent,
    required bool isCompleted,
    bool isLocked = false,
  }) {
    if (isCurrent) {
      return GestureDetector(
        onTap: () => _startLevel(levelNum),
        child: AnimatedBuilder(
          animation: _ambientController,
          builder: (context, child) {
            final glow = 6.0 + 4.0 * _ambientController.value;
            return Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [
                    Color(0xFFFFAB00),
                    Color(0xFFFF6D00),
                  ],
                ),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF9100).withOpacity(0.8),
                    blurRadius: glow,
                    spreadRadius: 2,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                '$levelNum',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            );
          },
        ),
      );
    }

    return GestureDetector(
      onTap: isLocked ? null : () => _startLevel(levelNum),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF142040).withOpacity(0.9),
          border: Border.all(
            color: isCompleted ? const Color(0xFF42A5F5) : const Color(0xFF263868),
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: isLocked
            ? const Icon(Icons.lock_rounded, color: Colors.white38, size: 16)
            : Text(
                '$levelNum',
                style: TextStyle(
                  color: isCompleted ? Colors.white : Colors.white60,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
      ),
    );
  }
}
