import '../../core/constants/game_constants.dart';
import '../models/brick.dart';

/// Manages Score, Combos, and Stars during gameplay
class ScoreSystem {
  int currentScore = 0;
  int comboCount = 0;
  double comboMultiplier = 1.0;
  int turnHits = 0;
  int ballsCollectedThisTurn = 0;

  void resetForNewGame() {
    currentScore = 0;
    comboCount = 0;
    comboMultiplier = 1.0;
    turnHits = 0;
    ballsCollectedThisTurn = 0;
  }

  void startNewTurn() {
    turnHits = 0;
    ballsCollectedThisTurn = 0;
    // Don't completely wipe combo on fresh turn to reward fast play
  }

  /// Registers a brick hit and increments score
  int registerHit({
    required Brick brick,
    required bool wasDestroyed,
    required DifficultyMode difficulty,
  }) {
    turnHits++;
    comboCount++;

    // Exponential combo ramp: 1.0x -> 10.0x
    comboMultiplier = (1.0 + (comboCount / 12.0)).clamp(1.0, 10.0);

    final basePoints = wasDestroyed ? 150 : 30;
    final specialBonus = brick.type.isSpecialTrigger ? 300 : 0;

    final earned = ((basePoints + specialBonus) * comboMultiplier * difficulty.turnScoreMultiplier).round();
    currentScore += earned;
    return earned;
  }

  /// Calculates star rating (1 to 3) based on target score
  int calculateStars(int targetScore) {
    if (targetScore <= 0) return 3;
    final ratio = currentScore / targetScore;
    if (ratio >= 1.0) return 3;
    if (ratio >= 0.65) return 2;
    if (ratio >= 0.35) return 1;
    return 1;
  }
}
