import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/game_colors.dart';
import '../../core/constants/game_constants.dart';
import '../../game/models/level_data.dart';
import '../../game/levels/procedural_generator.dart';
import '../../game/systems/audio_synthesizer.dart';
import '../../storage/game_storage.dart';
import 'gameplay_screen.dart';

/// Daily Challenge Screen (Screen 11 from Master Reference Mockup)
/// Features timer countdown, 1-life brick arena challenge preview, rewards card, and Play Challenge button.
class DailyChallengeScreen extends StatefulWidget {
  const DailyChallengeScreen({super.key});

  @override
  State<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends State<DailyChallengeScreen> {
  late Timer _countdownTimer;
  Duration _timeUntilMidnight = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateRemainingTime();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) => _updateRemainingTime());
  }

  void _updateRemainingTime() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    if (mounted) {
      setState(() {
        _timeUntilMidnight = tomorrow.difference(now);
      });
    }
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

  void _startChallenge() {
    AudioSynthesizer.instance.playUiClick();
    final now = DateTime.now();
    final dayOfYear = now.year * 365 + now.month * 31 + now.day;
    final dailyLevel = ProceduralLevelGenerator.generate(levelNumber: (dayOfYear % 50) + 1);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameplayScreen(
          levelData: dailyLevel,
          difficulty: DifficultyMode.hardcore,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090E1D),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            children: [
              // Top Bar: Back & Timer Pill
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

                  // Timer Pill (Red/Coral)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF131D36),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFF2A6D), width: 1.2),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time_filled_rounded, color: Color(0xFFFF2A6D), size: 16),
                        const SizedBox(width: 6),
                        Text(
                          _formatDuration(_timeUntilMidnight),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Trophy Icon & Title
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFAB47BC), Color(0xFF7B1FA2)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFAB47BC).withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 30),
              ),
              const SizedBox(height: 8),
              const Text(
                'DAILY\nCHALLENGE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 16),

              // Mini Arena Preview Box
              Container(
                width: 250,
                height: 180,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D162B),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF2A3D66), width: 1.5),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildMiniBrick('%', const Color(0xFFE040FB)),
                        _buildMiniBrick('30', const Color(0xFFFF9100)),
                        _buildMiniBrick('30', const Color(0xFFFF2A6D)),
                        _buildMiniBrick('20', const Color(0xFF7C4DFF)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildMiniBrick('50', const Color(0xFF00B0FF)),
                        _buildMiniBrick('30', const Color(0xFFFF9100)),
                        _buildMiniBrick('30', const Color(0xFFFF9100)),
                        _buildMiniBrick('💣', const Color(0xFFFF5252)),
                        _buildMiniBrick('20', const Color(0xFF00B0FF)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildMiniBrick('40', const Color(0xFF00E676)),
                        _buildMiniBrick('20', const Color(0xFF00B0FF)),
                        _buildMiniBrick('20', const Color(0xFF7C4DFF)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Rule description
              const Text(
                'Clear all bricks with\nonly 1 life!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF8E9EB8),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 16),

              // Rewards Card
              Container(
                width: 260,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF101A36),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF223565), width: 1.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rewards',
                      style: TextStyle(color: Color(0xFF8E9EB8), fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          children: const [
                            Text('🪙', style: TextStyle(fontSize: 14)),
                            SizedBox(width: 4),
                            Text('500', style: TextStyle(color: Color(0xFFFFD700), fontSize: 14, fontWeight: FontWeight.w900)),
                          ],
                        ),
                        Row(
                          children: const [
                            Text('💎', style: TextStyle(fontSize: 14)),
                            SizedBox(width: 4),
                            Text('10', style: TextStyle(color: Color(0xFFE040FB), fontSize: 14, fontWeight: FontWeight.w900)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),

              // Play Challenge Button (Green)
              GestureDetector(
                onTap: _startChallenge,
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00E676), Color(0xFF00C853)],
                    ),
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00E676).withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Play Challenge',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniBrick(String text, Color color) {
    return Container(
      width: 38,
      height: 24,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.white.withOpacity(0.35), width: 1.0),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
