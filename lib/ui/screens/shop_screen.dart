import 'package:flutter/material.dart';
import '../../core/constants/game_colors.dart';
import '../../game/models/ball.dart';
import '../../game/models/paddle.dart';
import '../../game/systems/audio_synthesizer.dart';
import '../../storage/game_storage.dart';

/// Master Shop Screen (Screen 12 from Master Reference Mockup)
/// Features 3 Tabs (Balls, Paddles, Themes) with instant preview, equip, and unlock mechanics.
class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  int _selectedTabIndex = 0; // 0: Balls, 1: Paddles, 2: Themes
  int _coins = 1250;
  int _gems = 50;
  BallSkin _selectedBallSkin = BallSkin.neonWhite;
  PaddleSkin _selectedPaddleSkin = PaddleSkin.neonBlade;

  final List<Map<String, dynamic>> _ballItems = [
    {'id': 'default', 'name': 'Pearl White', 'color': Color(0xFF00E5FF), 'skin': BallSkin.neonWhite, 'price': 0, 'currency': 'coins', 'icon': Icons.circle},
    {'id': 'fireball', 'name': 'Solar Fire', 'color': Color(0xFFFF5252), 'skin': BallSkin.solarFlare, 'price': 250, 'currency': 'coins', 'icon': Icons.local_fire_department_rounded},
    {'id': 'ice_orb', 'name': 'Cyan Plasma', 'color': Color(0xFF00B0FF), 'skin': BallSkin.cyanPlasma, 'price': 350, 'currency': 'coins', 'icon': Icons.ac_unit_rounded},
    {'id': 'galaxy', 'name': 'Void Crystal', 'color': Color(0xFFE040FB), 'skin': BallSkin.voidCrystal, 'price': 100, 'currency': 'gems', 'icon': Icons.auto_awesome_rounded},
    {'id': 'neon', 'name': 'Emerald Core', 'color': Color(0xFF00E676), 'skin': BallSkin.emeraldCore, 'price': 500, 'currency': 'coins', 'icon': Icons.wb_sunny_rounded},
    {'id': 'gold', 'name': 'Golden Sun', 'color': Color(0xFFFFD700), 'skin': BallSkin.goldenCrown, 'price': 1000, 'currency': 'coins', 'icon': Icons.monetization_on_rounded},
  ];

  final List<Map<String, dynamic>> _paddleItems = [
    {'id': 'neon_blade', 'name': 'Neon Blade', 'skin': PaddleSkin.neonBlade, 'price': 0, 'currency': 'coins', 'colors': [Color(0xFF00E5FF), Color(0xFF0091EA)]},
    {'id': 'solar_flame', 'name': 'Solar Flame', 'skin': PaddleSkin.solarFlame, 'price': 300, 'currency': 'coins', 'colors': [Color(0xFFFF5252), Color(0xFFFF6D00)]},
    {'id': 'void_prism', 'name': 'Void Prism', 'skin': PaddleSkin.voidPrism, 'price': 500, 'currency': 'coins', 'colors': [Color(0xFFE040FB), Color(0xFF7B1FA2)]},
    {'id': 'emerald_saber', 'name': 'Emerald Saber', 'skin': PaddleSkin.emeraldSaber, 'price': 750, 'currency': 'coins', 'colors': [Color(0xFF00E676), Color(0xFF00C853)]},
    {'id': 'golden_aegis', 'name': 'Golden Aegis', 'skin': PaddleSkin.goldenAegis, 'price': 1200, 'currency': 'coins', 'colors': [Color(0xFFFFD700), Color(0xFFFF9100)]},
    {'id': 'cyber_titan', 'name': 'Cyber Titan', 'skin': PaddleSkin.cyberTitan, 'price': 1500, 'currency': 'coins', 'colors': [Color(0xFF90A4AE), Color(0xFF37474F)]},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _coins = GameStorage.instance.getCoins();
      _gems = GameStorage.instance.getGems();
      _selectedBallSkin = GameStorage.instance.getSelectedSkin();
      _selectedPaddleSkin = GameStorage.instance.getSelectedPaddleSkin();
    });
  }

  void _selectBall(Map<String, dynamic> item) async {
    final BallSkin skin = item['skin'];
    final int price = item['price'];
    final String currency = item['currency'];

    if (price == 0 || GameStorage.instance.isSkinUnlocked(skin)) {
      AudioSynthesizer.instance.playUiClick();
      await GameStorage.instance.setSelectedSkin(skin);
      setState(() => _selectedBallSkin = skin);
      return;
    }

    bool success = false;
    if (currency == 'gems') {
      success = await GameStorage.instance.spendGems(price);
    } else {
      success = await GameStorage.instance.spendCoins(price);
    }

    if (success) {
      AudioSynthesizer.instance.playRewardClaim();
      await GameStorage.instance.unlockSkin(skin);
      await GameStorage.instance.setSelectedSkin(skin);
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Equipped ${item['name']}!')),
        );
      }
    } else {
      AudioSynthesizer.instance.playBombExplosion();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Need $price $currency to unlock!')),
        );
      }
    }
  }

  void _selectPaddle(Map<String, dynamic> item) async {
    final PaddleSkin skin = item['skin'];
    final int price = item['price'];
    final String currency = item['currency'];

    if (price == 0 || GameStorage.instance.isPaddleSkinUnlocked(skin)) {
      AudioSynthesizer.instance.playUiClick();
      await GameStorage.instance.setSelectedPaddleSkin(skin);
      setState(() => _selectedPaddleSkin = skin);
      return;
    }

    bool success = false;
    if (currency == 'gems') {
      success = await GameStorage.instance.spendGems(price);
    } else {
      success = await GameStorage.instance.spendCoins(price);
    }

    if (success) {
      AudioSynthesizer.instance.playRewardClaim();
      await GameStorage.instance.unlockPaddleSkin(skin);
      await GameStorage.instance.setSelectedPaddleSkin(skin);
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Equipped ${item['name']}!')),
        );
      }
    } else {
      AudioSynthesizer.instance.playBombExplosion();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Need $price $currency to unlock!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090E1D),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Bar: Back, Coins, Gems
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      AudioSynthesizer.instance.playUiClick();
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF131D36),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF2A3D66), width: 1.2),
                      ),
                      child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                  const Spacer(),
                  _buildPill('🪙', _coins.toString()),
                  const SizedBox(width: 8),
                  _buildPill('💎', _gems.toString()),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // 2. Tab Selector: Balls | Paddles | Themes
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF131D36),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFF2A3D66), width: 1.2),
                ),
                child: Row(
                  children: [
                    _buildTab('Balls', 0),
                    _buildTab('Paddles', 1),
                    _buildTab('Themes', 2),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 3. Grid of Items
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _selectedTabIndex == 0
                    ? _buildBallsGrid()
                    : _selectedTabIndex == 1
                        ? _buildPaddlesGrid()
                        : _buildThemesGrid(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBallsGrid() {
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.85,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: _ballItems.length,
      itemBuilder: (context, index) {
        final item = _ballItems[index];
        final BallSkin skin = item['skin'];
        final isUnlocked = item['price'] == 0 || GameStorage.instance.isSkinUnlocked(skin);
        final isSelected = _selectedBallSkin == skin;

        return GestureDetector(
          onTap: () => _selectBall(item),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0D162B),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF00E5FF)
                    : isUnlocked
                        ? const Color(0xFF2A3D66)
                        : const Color(0xFF1A2642),
                width: isSelected ? 2.2 : 1.2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF00E5FF).withOpacity(0.4),
                        blurRadius: 10,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Glowing Ball Preview Orb
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (item['color'] as Color).withOpacity(0.15),
                    border: Border.all(color: item['color'] as Color, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: (item['color'] as Color).withOpacity(0.5),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Icon(item['icon'] as IconData, color: item['color'] as Color, size: 26),
                ),
                const SizedBox(height: 8),

                Text(
                  item['name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),

                if (isSelected)
                  const Text(
                    'Equipped',
                    style: TextStyle(
                      color: Color(0xFF00E5FF),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  )
                else if (isUnlocked)
                  const Text(
                    'Use',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(item['currency'] == 'gems' ? '💎' : '🪙', style: const TextStyle(fontSize: 10)),
                      const SizedBox(width: 3),
                      Text(
                        '${item['price']}',
                        style: TextStyle(
                          color: item['currency'] == 'gems' ? const Color(0xFFE040FB) : const Color(0xFFFFD700),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaddlesGrid() {
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.25,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: _paddleItems.length,
      itemBuilder: (context, index) {
        final item = _paddleItems[index];
        final PaddleSkin skin = item['skin'];
        final isUnlocked = item['price'] == 0 || GameStorage.instance.isPaddleSkinUnlocked(skin);
        final isSelected = _selectedPaddleSkin == skin;
        final colors = item['colors'] as List<Color>;

        return GestureDetector(
          onTap: () => _selectPaddle(item),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0D162B),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF00E5FF)
                    : isUnlocked
                        ? const Color(0xFF2A3D66)
                        : const Color(0xFF1A2642),
                width: isSelected ? 2.2 : 1.2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF00E5FF).withOpacity(0.35),
                        blurRadius: 10,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Paddle Preview Pill
                Container(
                  width: 80,
                  height: 14,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: colors),
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.0),
                    boxShadow: [
                      BoxShadow(
                        color: colors.first.withOpacity(0.6),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                Text(
                  item['name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),

                if (isSelected)
                  const Text(
                    'Equipped',
                    style: TextStyle(
                      color: Color(0xFF00E5FF),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  )
                else if (isUnlocked)
                  const Text(
                    'Use',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🪙', style: TextStyle(fontSize: 11)),
                      const SizedBox(width: 4),
                      Text(
                        '${item['price']}',
                        style: const TextStyle(
                          color: Color(0xFFFFD700),
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemesGrid() {
    final themes = [
      {'name': 'Neon Valley', 'colors': [Color(0xFF090E1D), Color(0xFF00E5FF)], 'selected': true},
      {'name': 'Golden Canyon', 'colors': [Color(0xFF1A1208), Color(0xFFFF9100)], 'selected': false},
      {'name': 'Cyber Void', 'colors': [Color(0xFF14081E), Color(0xFFE040FB)], 'selected': false},
      {'name': 'Emerald Citadel', 'colors': [Color(0xFF061A0E), Color(0xFF00E676)], 'selected': false},
    ];

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: themes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final t = themes[index];
        final isSelected = t['selected'] as bool;
        final colors = t['colors'] as List<Color>;

        return Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF0D162B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? const Color(0xFF00E5FF) : const Color(0xFF2A3D66),
              width: isSelected ? 2.0 : 1.2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: colors),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  t['name'] as String,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle_rounded, color: Color(0xFF00E5FF), size: 22),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          AudioSynthesizer.instance.playUiClick();
          setState(() => _selectedTabIndex = index);
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF00B0FF) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF8E9EB8),
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPill(String icon, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF131D36),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A3D66), width: 1.2),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 5),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
