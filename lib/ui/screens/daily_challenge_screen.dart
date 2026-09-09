import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/game_colors.dart';
import '../../core/constants/game_constants.dart';
import '../../game/models/level_data.dart';
import '../../game/levels/procedural_generator.dart';
import '../../game/systems/audio_synthesizer.dart';
import '../../storage/game_storage.dart';
import '../components/glass_button.dart';
import '../components/glass_card.dart';
import '../components/level_blueprint_preview.dart';
import '../components/neon_glow_text.dart';
import 'gameplay_screen.dart';

/// Next-Gen Daily Challenge & Streak Matrix Screen
class DailyChallengeScreen extends StatefulWidget {
  const DailyChallengeScreen({super.key});

  @override
  State<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends State<DailyChallengeScreen> {
  late Timer _countdownTimer;
  Duration _timeUntilMidnight = Duration.zero;
  int _streakDay = 3;
  bool _claimedToday = false;

  @override
  void initState() {
    super.initState();
    _updateRemainingTime();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) => _updateRemainingTime());
  }

  void _updateRemainingTime() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    setState(() {
      _timeUntilMidnight = tomorrow.difference(now);
    });
  }

  @override
  void dispose() {
    _countdownTimer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  void _claimDailyStreak() {
    if (_claimedToday) return;
    AudioSynthesizer.instance.playRewardClaim();
    setState(() {
      _claimedToday = true;
      _streakDay = (_streakDay % 7) + 1;
    });
    GameStorage.instance.addCoins(250);
    GameStorage.instance.addGems(5);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xEE1E1B4B),
        content: Row(
          children: const [
            Icon(Icons.stars_rounded, color: GameColors.solarGold),
            SizedBox(width: 8),
            Text('Claimed +250 Coins & +5 Gems Streak Reward!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dayOfYear = now.year * 365 + now.month * 31 + now.day;
    final dailyLevel = ProceduralLevelGenerator.generate(levelNumber: (dayOfYear % 50) + 1);

    return Scaffold(
      backgroundColor: GameColors.oledDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header & Countdown Chip
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    onPressed: () {
                      AudioSynthesizer.instance.playUiClick();
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'DAILY PUZZLE',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const Spacer(),
                  // Live Countdown Clock
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: GameColors.surfaceCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: GameColors.electricAmber.withOpacity(0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.timer_outlined, color: GameColors.electricAmber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          _formatDuration(_timeUntilMidnight),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Hero Daily Puzzle Card
              GlassCard(
                borderColor: GameColors.electricAmber.withOpacity(0.4),
                padding: const EdgeInsets.all(18.0),
                borderRadius: 18.0,
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Holographic Radar Blueprint Preview of Daily Layout
                        LevelBlueprintPreview(level: dailyLevel, size: 68),
                        const SizedBox(width: 14),

                        // Title & Date Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: GameColors.electricAmber.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: GameColors.electricAmber.withOpacity(0.5)),
                                ),
                                child: Text(
                                  'MISSION ${now.day}.${now.month}.${now.year}',
                                  style: const TextStyle(color: GameColors.electricAmber, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.0),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${dailyLevel.archetype.displayName} Matrix',
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${dailyLevel.startingBalls} Swarm Balls • Special Modifiers',
                                style: const TextStyle(color: Colors.white54, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Daily Mutator Badges
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: const [
                          Row(
                            children: [
                              Icon(Icons.bolt_rounded, color: GameColors.crimsonDanger, size: 16),
                              SizedBox(width: 4),
                              Text('Laser Matrix', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.shield_rounded, color: GameColors.neonCyan, size: 16),
                              SizedBox(width: 4),
                              Text('Titanium Core', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.wifi_protected_setup_rounded, color: GameColors.neonMagenta, size: 16),
                              SizedBox(width: 4),
                              Text('Swarm Splitter', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Bounty Rewards Chip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [GameColors.solarGold.withOpacity(0.2), GameColors.neonPurple.withOpacity(0.2)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: GameColors.solarGold.withOpacity(0.4)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text('🪙 350 COINS', style: TextStyle(color: GameColors.solarGold, fontWeight: FontWeight.w900, fontSize: 12)),
                          SizedBox(width: 16),
                          Text('💎 10 GEMS', style: TextStyle(color: GameColors.neonPurple, fontWeight: FontWeight.w900, fontSize: 12)),
                          SizedBox(width: 16),
                          Text('⭐ 3 STARS', style: TextStyle(color: GameColors.electricAmber, fontWeight: FontWeight.w900, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 7-Day Streak Roadmap Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '7-DAY STREAK HIGHWAY',
                    style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                  ),
                  if (!_claimedToday)
                    GestureDetector(
                      onTap: _claimDailyStreak,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: GameColors.emeraldGreen.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: GameColors.emeraldGreen),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.card_giftcard_rounded, color: GameColors.emeraldGreen, size: 14),
                            SizedBox(width: 4),
                            Text('CLAIM STREAK', style: TextStyle(color: GameColors.emeraldGreen, fontWeight: FontWeight.w900, fontSize: 10)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // 7-Day Streak Node Cards
              SizedBox(
                height: 90,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 7,
                  itemBuilder: (context, index) {
                    final dayNum = index + 1;
                    final isCompleted = dayNum <= _streakDay;
                    final isCurrent = dayNum == _streakDay;
                    final isDay7Mega = dayNum == 7;

                    return Container(
                      width: 72,
                      margin: const EdgeInsets.only(right: 8),
                      child: GlassCard(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        borderRadius: 14,
                        glow: isCurrent || isDay7Mega,
                        glowColor: isDay7Mega
                            ? GameColors.solarGold
                            : (isCompleted ? GameColors.emeraldGreen : null),
                        surfaceColor: isDay7Mega ? const Color(0x33FFB300) : null,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isDay7Mega ? 'DAY 7 👑' : 'DAY $dayNum',
                              style: TextStyle(
                                color: isDay7Mega ? GameColors.solarGold : (isCompleted ? Colors.white : Colors.white38),
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Icon(
                              isCompleted
                                  ? Icons.check_circle_rounded
                                  : (isDay7Mega ? Icons.workspace_premium_rounded : Icons.lock_outline_rounded),
                              color: isCompleted
                                  ? GameColors.emeraldGreen
                                  : (isDay7Mega ? GameColors.solarGold : Colors.white24),
                              size: 20,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isDay7Mega ? '1000 🪙' : '${dayNum * 100} 🪙',
                              style: TextStyle(
                                color: isCompleted ? GameColors.electricAmber : Colors.white30,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Start Challenge Button CTA
              SizedBox(
                width: double.infinity,
                child: GlassButton(
                  onPressed: () {
                    AudioSynthesizer.instance.playUiClick();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => GameplayScreen(
                          levelData: dailyLevel.copyWith(title: 'DAILY CYBER PUZZLE'),
                          difficulty: DifficultyMode.standard,
                          initialBalls: 60,
                        ),
                      ),
                    );
                  },
                  gradient: const [GameColors.electricAmber, Color(0xFFFF5500)],
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  borderRadius: 20,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_arrow_rounded, color: Colors.white, size: 30),
                      SizedBox(width: 8),
                      Text(
                        'START DAILY PUZZLE',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

