class WaveSpawnEntry {
  const WaveSpawnEntry({
    required this.stage,
    required this.wave,
    required this.enemyCount,
    required this.spawnCadenceSeconds,
    required this.pressureBudget,
    required this.winCondition,
  });

  final String stage;
  final int wave;
  final int enemyCount;
  final double spawnCadenceSeconds;
  final int pressureBudget;
  final String winCondition;
}

const kWaveSpawnTable = <WaveSpawnEntry>[
  WaveSpawnEntry(stage: 'Onboarding', wave: 1, enemyCount: 5, spawnCadenceSeconds: 2.82, pressureBudget: 17, winCondition: 'Win the encounter: Learn the core action'),
  WaveSpawnEntry(stage: 'First Choice', wave: 2, enemyCount: 7, spawnCadenceSeconds: 2.64, pressureBudget: 22, winCondition: 'Win the encounter: Choose the first upgrade path'),
  WaveSpawnEntry(stage: 'Combo Lesson', wave: 3, enemyCount: 9, spawnCadenceSeconds: 2.46, pressureBudget: 28, winCondition: 'Win the encounter: Chain two systems for a stronger result'),
  WaveSpawnEntry(stage: 'Pressure Spike', wave: 4, enemyCount: 11, spawnCadenceSeconds: 2.28, pressureBudget: 35, winCondition: 'Win the encounter: React before timer or resource pressure peaks'),
  WaveSpawnEntry(stage: 'Midgame Twist', wave: 5, enemyCount: 13, spawnCadenceSeconds: 2.10, pressureBudget: 42, winCondition: 'Win the encounter: Solve a secondary objective while staying efficient'),
  WaveSpawnEntry(stage: 'Boss Gate', wave: 6, enemyCount: 15, spawnCadenceSeconds: 1.92, pressureBudget: 50, winCondition: 'Win the encounter: Clear the boss wave and protect progress'),
  WaveSpawnEntry(stage: 'Mastery Remix', wave: 7, enemyCount: 17, spawnCadenceSeconds: 1.74, pressureBudget: 59, winCondition: 'Win the encounter: Combine three decisions under higher pressure'),
  WaveSpawnEntry(stage: 'Repeatable Loop', wave: 8, enemyCount: 19, spawnCadenceSeconds: 1.56, pressureBudget: 68, winCondition: 'Win the encounter: Return for a harder run and better reward'),
];
