import 'package:flutter/material.dart';
import '../../core/constants/game_colors.dart';
import '../../game/models/ball.dart';
import '../../game/systems/audio_synthesizer.dart';
import '../../storage/game_storage.dart';

/// Redesigned Ball Cosmetic Skins Wardrobe Screen
class SkinsWardrobeScreen extends StatefulWidget {
  const SkinsWardrobeScreen({super.key});

  @override
  State<SkinsWardrobeScreen> createState() => _SkinsWardrobeScreenState();
}

class _SkinsWardrobeScreenState extends State<SkinsWardrobeScreen> {
  int _coins = 1250;
  List<String> _unlockedSkins = [];
  BallSkin _selectedSkin = BallSkin.neonWhite;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    setState(() {
      _coins = GameStorage.instance.getCoins();
      _unlockedSkins = GameStorage.instance.getUnlockedSkins();
      _selectedSkin = GameStorage.instance.getSelectedSkin();
    });
  }

  Future<void> _unlockAndEquip(BallSkin skin) async {
    if (_unlockedSkins.contains(skin.name)) {
      await GameStorage.instance.setSelectedSkin(skin);
      setState(() => _selectedSkin = skin);
      AudioSynthesizer.instance.playCollectPlusBall();
    } else {
      final cost = skin.unlockCostCoins;
      final success = await GameStorage.instance.spendCoins(cost);
      if (success) {
        await GameStorage.instance.unlockSkin(skin);
        await GameStorage.instance.setSelectedSkin(skin);
        AudioSynthesizer.instance.playVictory();
        _loadState();
      } else {
        AudioSynthesizer.instance.playBombExplosion();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.redAccent,
              content: Text('Not enough coins! Play levels to earn more.'),
            ),
          );
        }
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
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 26),
                    onPressed: () {
                      AudioSynthesizer.instance.playUiClick();
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'BALL WARDROBE',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D162B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFFD54F), width: 1.5),
                    ),
                    child: Row(
                      children: [
                        const Text('🪙', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Text(
                          '$_coins',
                          style: const TextStyle(
                            color: Color(0xFFFFD54F),
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Hero 3D Ball Preview Stage
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _selectedSkin.glowColor.withOpacity(0.2),
                    const Color(0xFF0D162B),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _selectedSkin.glowColor.withOpacity(0.6), width: 1.5),
              ),
              child: Row(
                children: [
                  // Animated 3D Ball
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        center: const Alignment(-0.35, -0.35),
                        radius: 0.9,
                        colors: [
                          Colors.white,
                          _selectedSkin.glowColor,
                          _selectedSkin.glowColor.withOpacity(0.6),
                          Colors.black87,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _selectedSkin.glowColor.withOpacity(0.6),
                          blurRadius: 18,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedSkin.displayName.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'ACTIVE EQUIPPED SKIN',
                          style: TextStyle(
                            color: Color(0xFF00E676),
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Grid of Skins
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.86,
                ),
                itemCount: BallSkin.values.length,
                itemBuilder: (context, index) {
                  final skin = BallSkin.values[index];
                  final isUnlocked = _unlockedSkins.contains(skin.name) || skin == BallSkin.neonWhite;
                  final isSelected = _selectedSkin == skin;

                  return GestureDetector(
                    onTap: () => _unlockAndEquip(skin),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D162B),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF00E676)
                              : (isUnlocked ? const Color(0xFF263868) : const Color(0xFF141F38)),
                          width: isSelected ? 2.2 : 1.2,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF00E676).withOpacity(0.35),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Ball Sphere Icon
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                center: const Alignment(-0.35, -0.35),
                                radius: 0.85,
                                colors: [
                                  Colors.white,
                                  skin.glowColor,
                                  Colors.black87,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: skin.glowColor.withOpacity(0.5),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),

                          Text(
                            skin.displayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),

                          // Status Button / Badge
                          if (isSelected)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00E676),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'EQUIPPED',
                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 10),
                              ),
                            )
                          else if (isUnlocked)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF192A56),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'EQUIP',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10),
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFFD54F), Color(0xFFFF8F00)],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('🪙', style: TextStyle(fontSize: 10)),
                                  const SizedBox(width: 3),
                                  Text(
                                    '${skin.unlockCostCoins}',
                                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 10),
                                  ),
                                ],
                              ),
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
