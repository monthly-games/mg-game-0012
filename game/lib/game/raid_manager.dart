import 'package:flutter/foundation.dart';
import 'package:mg_common_game/systems/progression/upgrade_manager.dart';

// ============================================================
// RaidConfigManager -- Raid difficulty & boss scaling
// MG-0012 Raid RPG · Phase 1 Week 3
//
// Reads upgrade levels from UpgradeManager and exposes computed
// multipliers that the core RaidManager consumes during gameplay.
// ============================================================

/// Base constants for raid tuning.
class RaidConstants {
  RaidConstants._();

  static const double baseBossHp = 10000.0;
  static const double baseBossRewardGold = 1000.0;
  static const int baseWaveCount = 3;
  static const double baseDamageMultiplier = 1.0;
  static const double bossHpScalePerDifficulty = 0.25;
  static const double rewardScalePerLevel = 0.15;
  static const int waveIncreasePerLevel = 1;
  static const double damageIncreasePerLevel = 0.12;
}

/// Provides raid configuration values derived from upgrade levels.
///
/// Does NOT replace the gameplay [RaidManager] in `features/raid/`.
/// Instead, this manager computes multipliers that scale boss HP,
/// rewards, wave counts, and damage based on purchased upgrades.
class RaidConfigManager extends ChangeNotifier {
  final UpgradeManager _upgradeManager;

  RaidConfigManager(this._upgradeManager);

  // ── Computed raid parameters ──────────────────────────────

  /// Boss HP scales with raid difficulty upgrade.
  /// Higher difficulty = tougher bosses = better rewards.
  double get bossHpMultiplier {
    final upgrade = _upgradeManager.getUpgrade('raid_difficulty');
    if (upgrade == null) return 1.0;
    return 1.0 + upgrade.currentValue * RaidConstants.bossHpScalePerDifficulty;
  }

  /// Scaled boss HP accounting for raid difficulty.
  double get scaledBossHp => RaidConstants.baseBossHp * bossHpMultiplier;

  /// Gold reward multiplier from boss_rewards upgrade.
  double get bossRewardMultiplier {
    final upgrade = _upgradeManager.getUpgrade('boss_rewards');
    if (upgrade == null) return 1.0;
    return 1.0 + upgrade.currentValue;
  }

  /// Scaled boss kill reward in gold.
  double get scaledBossReward =>
      RaidConstants.baseBossRewardGold * bossRewardMultiplier;

  /// Total wave count including bonus waves from upgrade.
  int get totalWaveCount {
    final upgrade = _upgradeManager.getUpgrade('wave_bonus');
    if (upgrade == null) return RaidConstants.baseWaveCount;
    return RaidConstants.baseWaveCount +
        upgrade.currentLevel * RaidConstants.waveIncreasePerLevel;
  }

  /// Global damage multiplier applied to all hero DPS.
  double get damageMultiplier {
    final upgrade = _upgradeManager.getUpgrade('damage_multiplier');
    if (upgrade == null) return RaidConstants.baseDamageMultiplier;
    return RaidConstants.baseDamageMultiplier + upgrade.currentValue;
  }

  /// Refresh computed values after an upgrade purchase.
  void refresh() => notifyListeners();
}
