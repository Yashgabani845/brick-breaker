/// Physics and balance tuning parameters for Bricks Breaker 3D.
class GameConstants {
  // Logical Grid Settings
  static const int defaultColumns = 12;
  static const int defaultRows = 16;
  static const int maxColumns = 20;
  static const int maxRows = 35;
  static const int dangerRowThreshold = 14; // If bricks touch or pass this row -> Game Over

  // Ball Settings
  static const double baseBallRadius = 5.0;
  static const double baseBallSpeed = 700.0; // units per second
  static const double maxBallSpeed = 1600.0;
  static const double ballLaunchIntervalSeconds = 0.045; // Staggered stream release
  static const int initialStartingBalls = 40;

  // Trajectory Aiming
  static const double minLaunchAngleDegrees = 12.0; // Prevent flat horizontal lock
  static const double maxLaunchAngleDegrees = 168.0;
  static const int maxTrajectoryReflections = 4;

  // Collision Substepping
  static const int physicsSubSteps = 3; // 3 sub-steps: good anti-tunneling, reasonable CPU
  static const double minSeparationOffset = 0.5;

  // Special Blocks
  static const int bombBlastRadius = 1; // 3x3 cells (1 cell radius around center)
  static const int superNukeMaxHpThreshold = 30;
  static const int maxChainReactionsPerTurn = 40; // Safe recursion cap

  // Audio Voice Limiter
  static const int maxSimultaneousAudioVoices = 12;

  // Economy & Progression
  static const int coinsPerLevelClear = 50;
  static const int gemsPerWorldClear = 10;
  static const int continueCostGems = 15;
}

/// Difficulty modes: balanced for enjoyable and tactical gameplay
enum DifficultyMode {
  relaxed,
  standard,
  hardcore,
}

extension DifficultyModeExtension on DifficultyMode {
  String get displayName {
    switch (this) {
      case DifficultyMode.relaxed:
        return 'Zen Relaxed';
      case DifficultyMode.standard:
        return 'Standard Arcade';
      case DifficultyMode.hardcore:
        return 'Hardcore Master';
    }
  }

  double get hpMultiplier {
    switch (this) {
      case DifficultyMode.relaxed:
        return 0.55;   // Very forgiving
      case DifficultyMode.standard:
        return 0.65;   // Reduced from 0.75 — enjoyable challenge, always beatable
      case DifficultyMode.hardcore:
        return 0.95;    // Reduced from 1.0 — old 'standard'
    }
  }

  int get maxAimBounces {
    switch (this) {
      case DifficultyMode.relaxed:
        return 5;
      case DifficultyMode.standard:
        return 3;
      case DifficultyMode.hardcore:
        return 2;
    }
  }

  double get turnScoreMultiplier {
    switch (this) {
      case DifficultyMode.relaxed:
        return 1.0;
      case DifficultyMode.standard:
        return 1.5;
      case DifficultyMode.hardcore:
        return 2.5;
    }
  }
}
