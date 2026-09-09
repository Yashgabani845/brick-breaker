import 'package:flutter/material.dart';
import '../../game/systems/audio_synthesizer.dart';
import '../../storage/game_storage.dart';

/// In-Game Shop Modal for Power-ups, Gems & Coin Bundles
class ShopModal extends StatefulWidget {
  final VoidCallback onStateChanged;

  const ShopModal({super.key, required this.onStateChanged});

  @override
  State<ShopModal> createState() => _ShopModalState();
}

class _ShopModalState extends State<ShopModal> {
  int _coins = 0;
  int _gems = 0;

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  void _loadBalance() {
    setState(() {
      _coins = GameStorage.instance.getCoins();
      _gems = GameStorage.instance.getGems();
    });
  }

  Future<void> _buyWithCoins(int cost, String itemName, VoidCallback onSuccess) async {
    final success = await GameStorage.instance.spendCoins(cost);
    if (success) {
      AudioSynthesizer.instance.playRewardClaim();
      onSuccess();
      _loadBalance();
      widget.onStateChanged();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF00C853),
            content: Text('Purchased $itemName!', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        );
      }
    } else {
      AudioSynthesizer.instance.playBombExplosion();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text('Not enough Coins! Break more bricks to earn coins.'),
          ),
        );
      }
    }
  }

  Future<void> _claimFreeReward() async {
    await GameStorage.instance.addCoins(200);
    await GameStorage.instance.addGems(10);
    AudioSynthesizer.instance.playVictory();
    _loadBalance();
    widget.onStateChanged();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF00C853),
          content: Text('Claimed 200 Coins & 10 Gems!', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Balance Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF0D162B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1E2D56)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                children: [
                  const Text('🪙', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 6),
                  Text('$_coins', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                ],
              ),
              Container(width: 1, height: 20, color: Colors.white24),
              Row(
                children: [
                  const Text('💎', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 6),
                  Text('$_gems', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Free Daily Gift
        GestureDetector(
          onTap: _claimFreeReward,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00C853), Color(0xFF009624)],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00E676).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                const Text('🎁', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('FREE DAILY REWARD', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)),
                      Text('+200 Coins & +10 Gems', style: TextStyle(color: Colors.white70, fontSize: 11)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('CLAIM', style: TextStyle(color: Color(0xFF009624), fontWeight: FontWeight.w900, fontSize: 12)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),

        const Text('POWER-UP BUNDLES', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.8)),
        const SizedBox(height: 8),

        // Power-up 1: Bomb Pack
        _buildShopItem(
          icon: '💣',
          title: 'Mega Nuke Bomb x3',
          subtitle: 'Obliterates surrounding 3x3 bricks',
          cost: 150,
          onBuy: () => _buyWithCoins(150, 'Mega Bomb x3', () {}),
        ),
        const SizedBox(height: 8),

        // Power-up 2: Lightning Pack
        _buildShopItem(
          icon: '⚡',
          title: 'Laser Matrix x3',
          subtitle: 'Clears entire rows and columns instantly',
          cost: 200,
          onBuy: () => _buyWithCoins(200, 'Laser Matrix x3', () {}),
        ),
        const SizedBox(height: 8),

        // Power-up 3: Swarm Split Pack
        _buildShopItem(
          icon: '🔀',
          title: 'Tri-Ball Swarm x3',
          subtitle: 'Splits active balls into 3x swarm',
          cost: 180,
          onBuy: () => _buyWithCoins(180, 'Tri-Ball Swarm x3', () {}),
        ),
      ],
    );
  }

  Widget _buildShopItem({
    required String icon,
    required String title,
    required String subtitle,
    required int cost,
    required VoidCallback onBuy,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0D162B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E2D56)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF142040),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(icon, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 10)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onBuy,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E5FF),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: const Size(60, 32),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🪙', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 2),
                Text('$cost', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
