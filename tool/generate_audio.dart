import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

/// Generates crisp, high-fidelity 44.1kHz 16-bit Mono WAV audio assets
void main() {
  final outDir = Directory('assets/audio');
  if (!outDir.existsSync()) {
    outDir.createSync(recursive: true);
  }

  // 1. Generate 8 Pentatonic Hit Chimes (C5, D5, E5, G5, A5, C6, D6, E6)
  final pentatonicFreqs = [523.25, 587.33, 659.25, 783.99, 880.00, 1046.50, 1174.66, 1318.51];
  for (int i = 0; i < pentatonicFreqs.length; i++) {
    final freq = pentatonicFreqs[i];
    final samples = _generateBellChime(freq, durationSec: 0.18);
    _writeWavFile(File('assets/audio/hit_chime_${i + 1}.wav'), samples);
  }

  // 2. UI Click (Crisp high-tech click)
  final clickSamples = _generateClick();
  _writeWavFile(File('assets/audio/ui_click.wav'), clickSamples);

  // 3. Laser Sweep (High frequency energy beam)
  final laserSamples = _generateLaserSweep();
  _writeWavFile(File('assets/audio/laser_sweep.wav'), laserSamples);

  // 4. Bomb Explosion (Sub-bass rumble + noise)
  final bombSamples = _generateExplosion(durationSec: 0.35, lowFreq: 90.0);
  _writeWavFile(File('assets/audio/bomb_explosion.wav'), bombSamples);

  // 5. Nuke Detonation (Massive sub-bass detonation)
  final nukeSamples = _generateExplosion(durationSec: 0.65, lowFreq: 50.0, isNuke: true);
  _writeWavFile(File('assets/audio/nuke_detonation.wav'), nukeSamples);

  // 6. Plus Ball Collect (Bright crystal chime)
  final plusBallSamples = _generatePlusBall();
  _writeWavFile(File('assets/audio/plus_ball.wav'), plusBallSamples);

  // 7. Swarm Splitter (Chirp warp)
  final splitterSamples = _generateSplitter();
  _writeWavFile(File('assets/audio/splitter.wav'), splitterSamples);

  // 8. Victory Fanfare (Triumphant ascending arpeggio)
  final victorySamples = _generateVictory();
  _writeWavFile(File('assets/audio/victory.wav'), victorySamples);

  // 9. Game Over (Descending defeat tone)
  final gameOverSamples = _generateGameOver();
  _writeWavFile(File('assets/audio/game_over.wav'), gameOverSamples);

  print('Successfully generated all 16 WAV audio assets in assets/audio/!');
}

const int sampleRate = 44100;

List<double> _generateBellChime(double baseFreq, {double durationSec = 0.18}) {
  final totalSamples = (sampleRate * durationSec).toInt();
  final list = List<double>.filled(totalSamples, 0.0);

  for (int i = 0; i < totalSamples; i++) {
    final t = i / sampleRate;
    final env = math.exp(-t * 22.0); // Fast exponential decay
    // Fundamental + Octave + 3rd harmonic
    final s1 = math.sin(2 * math.pi * baseFreq * t);
    final s2 = 0.35 * math.sin(2 * math.pi * (baseFreq * 2.0) * t);
    final s3 = 0.15 * math.sin(2 * math.pi * (baseFreq * 3.01) * t);
    list[i] = (s1 + s2 + s3) * env * 0.75;
  }
  return list;
}

List<double> _generateClick() {
  const durationSec = 0.035;
  final totalSamples = (sampleRate * durationSec).toInt();
  final list = List<double>.filled(totalSamples, 0.0);

  for (int i = 0; i < totalSamples; i++) {
    final t = i / sampleRate;
    final env = math.exp(-t * 120.0);
    final s = math.sin(2 * math.pi * 1800 * t);
    list[i] = s * env * 0.85;
  }
  return list;
}

List<double> _generateLaserSweep() {
  const durationSec = 0.14;
  final totalSamples = (sampleRate * durationSec).toInt();
  final list = List<double>.filled(totalSamples, 0.0);

  for (int i = 0; i < totalSamples; i++) {
    final t = i / sampleRate;
    final progress = t / durationSec;
    final freq = 2400.0 - (2000.0 * progress);
    final env = (1.0 - progress) * (1.0 - progress);
    final s = math.sin(2 * math.pi * freq * t);
    list[i] = s * env * 0.7;
  }
  return list;
}

List<double> _generateExplosion({required double durationSec, required double lowFreq, bool isNuke = false}) {
  final totalSamples = (sampleRate * durationSec).toInt();
  final list = List<double>.filled(totalSamples, 0.0);
  final random = math.Random(42);

  for (int i = 0; i < totalSamples; i++) {
    final t = i / sampleRate;
    final progress = t / durationSec;
    final env = math.exp(-progress * (isNuke ? 4.5 : 7.0));

    // Sub-bass sweep
    final bassFreq = lowFreq * (1.0 - progress * 0.5);
    final bass = math.sin(2 * math.pi * bassFreq * t);

    // Noise burst
    final noise = (random.nextDouble() * 2.0 - 1.0) * math.exp(-progress * 14.0);

    list[i] = (bass * 0.65 + noise * 0.35) * env;
  }
  return list;
}

List<double> _generatePlusBall() {
  const durationSec = 0.22;
  final totalSamples = (sampleRate * durationSec).toInt();
  final list = List<double>.filled(totalSamples, 0.0);

  for (int i = 0; i < totalSamples; i++) {
    final t = i / sampleRate;
    final env = math.exp(-t * 14.0);
    final s1 = math.sin(2 * math.pi * 1046.50 * t); // C6
    final s2 = 0.6 * math.sin(2 * math.pi * 1567.98 * t); // G6
    list[i] = (s1 + s2) * env * 0.6;
  }
  return list;
}

List<double> _generateSplitter() {
  const durationSec = 0.16;
  final totalSamples = (sampleRate * durationSec).toInt();
  final list = List<double>.filled(totalSamples, 0.0);

  for (int i = 0; i < totalSamples; i++) {
    final t = i / sampleRate;
    final progress = t / durationSec;
    final freq = 550.0 + (700.0 * progress);
    final env = math.sin(progress * math.pi);
    final s = math.sin(2 * math.pi * freq * t);
    list[i] = s * env * 0.75;
  }
  return list;
}

List<double> _generateVictory() {
  const durationSec = 0.48;
  final totalSamples = (sampleRate * durationSec).toInt();
  final list = List<double>.filled(totalSamples, 0.0);
  final notes = [523.25, 659.25, 783.99, 1046.50]; // C5, E5, G5, C6
  final noteDur = durationSec / notes.length;

  for (int i = 0; i < totalSamples; i++) {
    final t = i / sampleRate;
    final noteIndex = (t / noteDur).floor().clamp(0, notes.length - 1);
    final noteT = t - (noteIndex * noteDur);
    final env = math.exp(-noteT * 8.0);
    final freq = notes[noteIndex];
    final s = math.sin(2 * math.pi * freq * t);
    list[i] = s * env * 0.7;
  }
  return list;
}

List<double> _generateGameOver() {
  const durationSec = 0.42;
  final totalSamples = (sampleRate * durationSec).toInt();
  final list = List<double>.filled(totalSamples, 0.0);

  for (int i = 0; i < totalSamples; i++) {
    final t = i / sampleRate;
    final progress = t / durationSec;
    final freq = 420.0 * (1.0 - progress * 0.75); // 420Hz down to 105Hz
    final env = math.exp(-progress * 5.0);
    final s = math.sin(2 * math.pi * freq * t);
    list[i] = s * env * 0.75;
  }
  return list;
}

void _writeWavFile(File file, List<double> samples) {
  final numSamples = samples.length;
  final byteRate = sampleRate * 2; // 16-bit mono = 2 bytes per sample
  final dataSize = numSamples * 2;
  final fileSize = 36 + dataSize;

  final bytes = BytesBuilder();

  // RIFF Header
  bytes.add('RIFF'.codeUnits);
  bytes.add(_int32ToBytes(fileSize));
  bytes.add('WAVE'.codeUnits);

  // 'fmt ' Subchunk
  bytes.add('fmt '.codeUnits);
  bytes.add(_int32ToBytes(16)); // Subchunk1Size (16 for PCM)
  bytes.add(_int16ToBytes(1));  // AudioFormat (1 for PCM)
  bytes.add(_int16ToBytes(1));  // NumChannels (1 = Mono)
  bytes.add(_int32ToBytes(sampleRate)); // SampleRate
  bytes.add(_int32ToBytes(byteRate));   // ByteRate
  bytes.add(_int16ToBytes(2));  // BlockAlign
  bytes.add(_int16ToBytes(16)); // BitsPerSample

  // 'data' Subchunk
  bytes.add('data'.codeUnits);
  bytes.add(_int32ToBytes(dataSize));

  // 16-bit PCM Audio Data
  for (int i = 0; i < numSamples; i++) {
    final clamped = samples[i].clamp(-1.0, 1.0);
    final sampleInt = (clamped * 32767).toInt();
    bytes.add(_int16ToBytes(sampleInt));
  }

  file.writeAsBytesSync(bytes.toBytes());
}

List<int> _int16ToBytes(int value) {
  final bd = ByteData(2)..setInt16(0, value, Endian.little);
  return bd.buffer.asUint8List();
}

List<int> _int32ToBytes(int value) {
  final bd = ByteData(4)..setInt32(0, value, Endian.little);
  return bd.buffer.asUint8List();
}
