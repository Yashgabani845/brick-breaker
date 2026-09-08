import 'package:flutter/material.dart';
import '../../core/constants/game_colors.dart';
import '../../game/models/ball.dart';
import '../../game/systems/audio_synthesizer.dart';
import '../../storage/game_storage.dart';
import '../components/glass_button.dart';
import '../components/glass_card.dart';
import '../components/neon_glow_text.dart';

/// Ball Cosmetic Skins Wardrobe Screen
class SkinsWardrobeScreen extends StatefulWidget {
  const SkinsWardrobeScreen({super.key});

  @override
  State<SkinsWardrobeScreen> createState() => _SkinsWardrobeScreenState();
}

class _SkinsWardrobeScreenState extends State<SkinsWardrobeScreen> {
  int _coins = 250;
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Not enough coins! Play levels to earn more.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.oledDark,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 8),
                      const NeonGlowText('BALL WARDROBE', fontSize: 20.0, glowColor: GameColors.neonPurple),
                    ],
                  ),
                  GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    borderRadius: 12,
                    child: Row(
                      children: [
                        const Text('🪙', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Text('$_coins', style: const TextStyle(color: GameColors.electricAmber, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Live 3D Ball Preview Showcase
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: GlassCard(
                glow: true,
                glowColor: _selectedSkin.glowColor,
                padding: const EdgeInsets.symmetric(vertical: 24),
                borderRadius: 24,
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            center: const Alignment(-0.3, -0.3),
                            colors: [Colors.white, _selectedSkin.glowColor, Colors.black87],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _selectedSkin.glowColor.withOpacity(0.7),
                              blurRadius: 32,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _selectedSkin.displayName,
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                      ),
                      Text(
                        'EQUIPPED IN SWARM',
                        style: TextStyle(color: _selectedSkin.glowColor, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Grid of Available Skins
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.95,
                ),
                itemCount: BallSkin.values.length,
                itemBuilder: (context, index) {
                  final skin = BallSkin.values[index];
                  final isUnlocked = _unlockedSkins.contains(skin.name);
                  final isSelected = _selectedSkin == skin;

                  return GestureDetector(
                    onTap: () => _unlockAndEquip(skin),
                    child: GlassCard(
                      glow: isSelected,
                      glowColor: skin.glowColor,
                      padding: const EdgeInsets.all(12),
                      borderRadius: 18,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                center: const Alignment(-0.3, -0.3),
                                colors: [Colors.white, skin.glowColor, Colors.black87],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: skin.glowColor.withOpacity(0.5),
                                  blurRadius: 14,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            skin.displayName,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          if (isSelected)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: GameColors.emeraldGreen.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: GameColors.emeraldGreen),
                              ),
                              child: const Text('EQUIPPED', style: TextStyle(color: GameColors.emeraldGreen, fontSize: 10, fontWeight: FontWeight.w900)),
                            )
                          else if (isUnlocked)
                            const Text('EQUIP', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold))
                          else
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('🪙 ', style: TextStyle(fontSize: 10)),
                                Text(
                                  '${skin.unlockCostCoins}',
                                  style: const TextStyle(color: GameColors.electricAmber, fontSize: 12, fontWeight: FontWeight.w900),
                                ),
                              ],
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
