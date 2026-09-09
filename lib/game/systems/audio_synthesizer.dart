import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'audio_platform.dart';

/// Low-Latency Polyphonic Sound Engine for Bricks Breaker 3D
/// Plays 44.1kHz WAV sound effects across Android, iOS, Desktop & Web
/// with polyphonic channel pooling, combo harmonics, and haptic feedback.
class AudioSynthesizer {
  static final AudioSynthesizer instance = AudioSynthesizer._internal();
  AudioSynthesizer._internal() {
    _initAudioPool();
  }

  bool isMuted = false;
  double masterVolume = 0.85;

  static const int _poolSize = 16;  // larger pool so hits never stomp each other
  final List<AudioPlayer> _playerPool = [];
  int _nextPlayerIndex = 0;
  int _lastVoiceTimeMs = 0;

  void _initAudioPool() {
    try {
      for (int i = 0; i < _poolSize; i++) {
        final player = AudioPlayer();
        player.setReleaseMode(ReleaseMode.stop);
        // Low-latency mode on Android
        player.setPlayerMode(PlayerMode.lowLatency);
        _playerPool.add(player);
      }
    } catch (e) {
      debugPrint('AudioPool init: $e');
    }
  }

  /// Toggles mute state
  void toggleMute() {
    isMuted = !isMuted;
  }

  /// Fire-and-forget: grab next player slot and play immediately without awaiting.
  /// Stopping then re-playing on the same player is the fastest path on Android.
  void _playWav(String assetPath, {double volume = 0.85}) {
    if (isMuted) return;
    try {
      if (_playerPool.isNotEmpty) {
        final player = _playerPool[_nextPlayerIndex];
        _nextPlayerIndex = (_nextPlayerIndex + 1) % _playerPool.length;
        // Fire-and-forget: do NOT await — prevents frame stalls
        player.stop().whenComplete(() {
          player.setVolume((volume * masterVolume).clamp(0.0, 1.0));
          player.play(AssetSource(assetPath));
        });
      }
    } catch (_) {
      invokeWebAudioEngine('playAsset', [assetPath]);
    }
  }

  /// Plays a pentatonic chime on brick hit. Rate-limited to 30ms to prevent
  /// audio overload during high-density swarm volleys.
  void playBrickHitChime(int combo) {
    if (isMuted) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastVoiceTimeMs < 30) return; // 30ms debounce
    _lastVoiceTimeMs = now;

    // Harmonic pentatonic pitch mapping (1 to 8)
    final chimeIndex = ((combo - 1) % 8) + 1;
    _playWav('audio/hit_chime_$chimeIndex.wav', volume: 0.70);

    try {
      HapticFeedback.selectionClick();
    } catch (_) {}
  }

  /// Plays laser beam high-frequency sweep
  void playLaserSweep() {
    if (isMuted) return;
    _playWav('audio/laser_sweep.wav', volume: 0.8);
    try {
      HapticFeedback.lightImpact();
    } catch (_) {}
  }

  /// Plays bomb low sub-bass explosion
  void playBombExplosion() {
    if (isMuted) return;
    _playWav('audio/bomb_explosion.wav', volume: 0.95);
    try {
      HapticFeedback.heavyImpact();
    } catch (_) {}
  }

  /// Plays Nuke mega-detonation
  void playNukeDetonation() {
    if (isMuted) return;
    _playWav('audio/nuke_detonation.wav', volume: 1.0);
    try {
      HapticFeedback.heavyImpact();
    } catch (_) {}
  }

  /// Plays +1 permanent ball collect ding
  void playCollectPlusBall() {
    if (isMuted) return;
    _playWav('audio/plus_ball.wav', volume: 0.85);
    try {
      HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  /// Plays swarm splitter duplication sound
  void playSplitterSwarm() {
    if (isMuted) return;
    _playWav('audio/splitter.wav', volume: 0.8);
    try {
      HapticFeedback.lightImpact();
    } catch (_) {}
  }

  /// Plays UI click sound
  void playUiClick() {
    if (isMuted) return;
    _playWav('audio/ui_click.wav', volume: 0.7);
    try {
      HapticFeedback.lightImpact();
    } catch (_) {}
  }

  /// Plays reward chime (gems/coins/streak claim)
  void playRewardClaim() {
    if (isMuted) return;
    _playWav('audio/plus_ball.wav', volume: 0.9);
    try {
      HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  /// Plays victory fanfare
  void playVictory() {
    if (isMuted) return;
    _playWav('audio/victory.wav', volume: 0.9);
    try {
      HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  /// Plays defeat / game over sound
  void playDefeat() {
    if (isMuted) return;
    _playWav('audio/game_over.wav', volume: 0.85);
    try {
      HapticFeedback.mediumImpact();
    } catch (_) {}
  }
}
