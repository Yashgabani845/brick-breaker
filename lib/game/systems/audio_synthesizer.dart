import 'package:flutter/foundation.dart';
import 'audio_platform.dart';

/// Procedural ASMR Sound Synthesizer for Bricks Breaker 3D
/// Implements Pentatonic scale collision chimes (C-D-E-G-A), laser sweeps,
/// explosive bass rumbles, UI feedback, streak rewards, and fanfares.
class AudioSynthesizer {
  static final AudioSynthesizer instance = AudioSynthesizer._internal();
  AudioSynthesizer._internal();

  bool isMuted = false;
  double masterVolume = 0.8;

  int _lastVoiceTimeMs = 0;
  int _activeVoiceCount = 0;

  /// Toggles mute state
  void toggleMute() {
    isMuted = !isMuted;
  }

  /// Plays a pentatonic chime based on combo streak / hit count
  void playBrickHitChime(int combo) {
    if (isMuted) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastVoiceTimeMs < 25 && _activeVoiceCount > 8) {
      return;
    }
    _lastVoiceTimeMs = now;

    invokeWebAudioEngine('playChime', [combo, masterVolume * 0.5]);
  }

  /// Plays laser beam high-frequency sweep
  void playLaserSweep() {
    if (isMuted) return;
    invokeWebAudioEngine('playLaser', []);
  }

  /// Plays bomb low sub-bass explosion
  void playBombExplosion() {
    if (isMuted) return;
    invokeWebAudioEngine('playNoiseExplosion', [0.35, 300, masterVolume * 0.6]);
  }

  /// Plays Nuke mega-detonation
  void playNukeDetonation() {
    if (isMuted) return;
    invokeWebAudioEngine('playNuke', []);
  }

  /// Plays +1 permanent ball collect ding
  void playCollectPlusBall() {
    if (isMuted) return;
    invokeWebAudioEngine('playTone', [1046.5, 0.15, 'triangle', masterVolume * 0.4]);
  }

  /// Plays swarm splitter duplication sound
  void playSplitterSwarm() {
    if (isMuted) return;
    invokeWebAudioEngine('playTone', [784.0, 0.12, 'sine', masterVolume * 0.35]);
  }

  /// Plays UI click sound
  void playUiClick() {
    if (isMuted) return;
    invokeWebAudioEngine('playClick', []);
  }

  /// Plays reward chime (gems/coins/streak claim)
  void playRewardClaim() {
    if (isMuted) return;
    invokeWebAudioEngine('playRewardDing', []);
  }

  /// Plays victory fanfare
  void playVictory() {
    if (isMuted) return;
    invokeWebAudioEngine('playVictoryFanfare', []);
  }

  /// Plays defeat / game over sound
  void playDefeat() {
    if (isMuted) return;
    invokeWebAudioEngine('playSweep', [400, 80, 0.45, 'sawtooth', masterVolume * 0.4]);
  }
}

