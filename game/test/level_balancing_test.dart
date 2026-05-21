import 'package:flutter_test/flutter_test.dart';
import 'package:game/game/balancing_progression_plan.dart';
import 'package:game/game/level_design_config.dart';
import 'package:game/game/wave_spawn_table.dart';

void main() {
  test('level design has enough pacing beats for onboarding, mastery, pressure, and replay', () {
    expect(kLevelDesign.length, greaterThanOrEqualTo(8));
    expect(kLevelTensionBeats.length, kLevelDesign.length);
    expect(kCoreLoopPillars, containsAll(<String>['Start', 'Act', 'Reward', 'Upgrade', 'Return']));
  });

  test('difficulty, waves, and rewards grow without regressions', () {
    for (var i = 1; i < kLevelDesign.length; i += 1) {
      expect(kLevelDesign[i].difficulty, greaterThan(kLevelDesign[i - 1].difficulty));
      expect(kLevelDesign[i].wave, greaterThan(kLevelDesign[i - 1].wave));
      expect(kLevelDesign[i].goldReward, greaterThan(kLevelDesign[i - 1].goldReward));
      expect(kLevelDesign[i].xpReward, greaterThan(kLevelDesign[i - 1].xpReward));
      expect(kWaveSpawnTable[i].enemyCount, greaterThan(kWaveSpawnTable[i - 1].enemyCount));
      expect(kWaveSpawnTable[i].pressureBudget, greaterThan(kWaveSpawnTable[i - 1].pressureBudget));
      expect(kWaveSpawnTable[i].spawnCadenceSeconds, lessThan(kWaveSpawnTable[i - 1].spawnCadenceSeconds));
    }
  });

  test('balancing data stays aligned with the playable level roadmap', () {
    expect(kWaveSpawnTable.length, kLevelDesign.length);
    expect(kDifficultyMilestones.length, kLevelDesign.length);
    expect(kRewardGoldCurve.length, kLevelDesign.length);
    expect(kRewardXpCurve.length, kLevelDesign.length);
    expect(kProgressionUnlockPlan.toSet().length, kProgressionUnlockPlan.length);
    expect(kMetaProgressionSystems.length, greaterThanOrEqualTo(6));
  });
}
