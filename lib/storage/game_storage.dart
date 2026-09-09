import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/game_constants.dart';
import '../game/models/ball.dart';
import '../game/models/paddle.dart';

/// Offline Game Storage System using SharedPreferences
class GameStorage {
  static final GameStorage instance = GameStorage._internal();
  GameStorage._internal();

  late SharedPreferences _prefs;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  // --- Progression ---

  int getHighestLevelUnlocked() => _prefs.getInt('highest_level') ?? 1;
  Future<void> setHighestLevelUnlocked(int level) async {
    final current = getHighestLevelUnlocked();
    if (level > current) {
      await _prefs.setInt('highest_level', level);
    }
  }

  int getStarsForLevel(int level) => _prefs.getInt('stars_level_$level') ?? 0;
  Future<void> setStarsForLevel(int level, int stars) async {
    final current = getStarsForLevel(level);
    if (stars > current) {
      await _prefs.setInt('stars_level_$level', stars);
    }
  }

  int getHighScore() => _prefs.getInt('high_score') ?? 0;
  Future<void> setHighScore(int score) async {
    final current = getHighScore();
    if (score > current) {
      await _prefs.setInt('high_score', score);
    }
  }

  // --- Economy ---

  int getCoins() => _prefs.getInt('coins') ?? 250;
  Future<void> addCoins(int amount) async {
    final current = getCoins();
    await _prefs.setInt('coins', current + amount);
  }

  Future<bool> spendCoins(int amount) async {
    final current = getCoins();
    if (current >= amount) {
      await _prefs.setInt('coins', current - amount);
      return true;
    }
    return false;
  }

  int getGems() => _prefs.getInt('gems') ?? 20;
  Future<void> addGems(int amount) async {
    final current = getGems();
    await _prefs.setInt('gems', current + amount);
  }

  Future<bool> spendGems(int amount) async {
    final current = getGems();
    if (current >= amount) {
      await _prefs.setInt('gems', current - amount);
      return true;
    }
    return false;
  }

  // --- Tutorial & Onboarding ---
  bool hasCompletedTutorial() => _prefs.getBool('has_completed_tutorial') ?? false;
  Future<void> setCompletedTutorial(bool completed) async {
    await _prefs.setBool('has_completed_tutorial', completed);
  }

  // --- Haptics ---
  bool getHapticsEnabled() => _prefs.getBool('haptics_enabled') ?? true;
  Future<void> setHapticsEnabled(bool enabled) async {
    await _prefs.setBool('haptics_enabled', enabled);
  }

  // --- Clear / Reset ---
  Future<void> clearAllData() async {
    await _prefs.clear();
  }

  // --- Ball Cosmetics ---

  List<String> getUnlockedSkins() =>
      _prefs.getStringList('unlocked_skins') ?? [BallSkin.neonWhite.name];

  bool isSkinUnlocked(BallSkin skin) => getUnlockedSkins().contains(skin.name);

  Future<void> unlockSkin(BallSkin skin) async {
    final list = getUnlockedSkins();
    if (!list.contains(skin.name)) {
      list.add(skin.name);
      await _prefs.setStringList('unlocked_skins', list);
    }
  }

  BallSkin getSelectedSkin() {
    final name = _prefs.getString('selected_skin');
    if (name != null) {
      for (final s in BallSkin.values) {
        if (s.name == name) return s;
      }
    }
    return BallSkin.neonWhite;
  }

  Future<void> setSelectedSkin(BallSkin skin) async {
    await _prefs.setString('selected_skin', skin.name);
  }

  // --- Paddle Cosmetics ---

  List<String> getUnlockedPaddleSkins() =>
      _prefs.getStringList('unlocked_paddles') ?? [PaddleSkin.neonBlade.name];

  bool isPaddleSkinUnlocked(PaddleSkin skin) => getUnlockedPaddleSkins().contains(skin.name);

  Future<void> unlockPaddleSkin(PaddleSkin skin) async {
    final list = getUnlockedPaddleSkins();
    if (!list.contains(skin.name)) {
      list.add(skin.name);
      await _prefs.setStringList('unlocked_paddles', list);
    }
  }

  PaddleSkin getSelectedPaddleSkin() {
    final name = _prefs.getString('selected_paddle');
    if (name != null) {
      for (final s in PaddleSkin.values) {
        if (s.name == name) return s;
      }
    }
    return PaddleSkin.neonBlade;
  }

  Future<void> setSelectedPaddleSkin(PaddleSkin skin) async {
    await _prefs.setString('selected_paddle', skin.name);
  }

  // --- Difficulty Mode ---

  DifficultyMode getDifficultyMode() {
    final idx = _prefs.getInt('difficulty_mode');
    if (idx != null && idx >= 0 && idx < DifficultyMode.values.length) {
      return DifficultyMode.values[idx];
    }
    return DifficultyMode.standard;
  }

  Future<void> setDifficultyMode(DifficultyMode mode) async {
    await _prefs.setInt('difficulty_mode', mode.index);
  }

  // --- Sound / Audio ---

  bool getIsMuted() => _prefs.getBool('is_muted') ?? false;
  Future<void> setIsMuted(bool muted) async {
    await _prefs.setBool('is_muted', muted);
  }

  // --- Theme Mode (Dual Black Options) ---
  int getDarkThemeIndex() => _prefs.getInt('dark_theme_index') ?? 0;
  Future<void> setDarkThemeIndex(int index) async {
    await _prefs.setInt('dark_theme_index', index);
  }
}
