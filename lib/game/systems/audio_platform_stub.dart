import 'package:flutter/services.dart';

/// Audio platform stub for native / non-web platforms (Android, iOS, Windows, macOS, Linux).
/// Triggers system audio and haptic feedback to ensure tactile responsiveness.
void invokeWebAudioEngine(String method, [List<dynamic>? args]) {
  try {
    switch (method) {
      case 'playClick':
      case 'playRewardDing':
        SystemSound.play(SystemSoundType.click);
        HapticFeedback.lightImpact();
        break;
      case 'playChime':
        HapticFeedback.selectionClick();
        break;
      case 'playLaser':
      case 'playSplitter':
      case 'playTone':
        HapticFeedback.lightImpact();
        break;
      case 'playNoiseExplosion':
      case 'playNuke':
        HapticFeedback.heavyImpact();
        break;
      case 'playVictoryFanfare':
        HapticFeedback.mediumImpact();
        break;
      case 'playSweep':
        HapticFeedback.mediumImpact();
        break;
      default:
        break;
    }
  } catch (_) {
    // Ignore any platform-specific haptic exceptions
  }
}
