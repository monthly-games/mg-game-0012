import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:mg_common_game/systems/progression/upgrade_manager.dart';

// ============================================================
// LootManager — Drop rate & rarity system
// MG-0012 Raid RPG · Phase 1 Week 3
//
// Manages loot table probabilities. Upgrade levels increase
// base drop rates and the chance of higher-rarity rewards.
// ============================================================

/// Rarity tiers for loot items.
enum LootRarity { common, uncommon, rare, epic, legendary }

/// Base constants for loot system tuning.
class LootConstants {
  LootConstants._();

  static const double baseDropRate = 0.50;
  static const double maxDropRate = 1.0;
  static const double baseRarityChance = 0.05;
  static const double maxRarityChance = 0.50;

  /// Default rarity distribution weights (must sum to ~1.0).
  static const Map<LootRarity, double> baseRarityWeights = {
    LootRarity.common: 0.60,
    LootRarity.uncommon: 0.25,
    LootRarity.rare: 0.10,
    LootRarity.epic: 0.04,
    LootRarity.legendary: 0.01,
  };

  /// Gold bonus awarded per rarity tier.
  static const Map<LootRarity, int> rarityGoldBonus = {
    LootRarity.common: 10,
    LootRarity.uncommon: 25,
    LootRarity.rare: 75,
    LootRarity.epic: 200,
    LootRarity.legendary: 500,
  };
}

/// Manages loot drop calculations using upgrade-driven probabilities.
///
/// The `drop_rate` upgrade increases the chance any loot drops.
/// The `rarity_chance` upgrade shifts the rarity distribution toward
/// higher tiers by reducing the common weight and boosting rare+.
class LootManager extends ChangeNotifier {
  final UpgradeManager _upgradeManager;
  final math.Random _rng = math.Random();

  LootManager(this._upgradeManager);

  // ── Computed loot parameters ──────────────────────────────

  /// Overall probability that loot drops from a defeated enemy.
  double get dropRate {
    final upgrade = _upgradeManager.getUpgrade('drop_rate');
    if (upgrade == null) return LootConstants.baseDropRate;
    final computed = LootConstants.baseDropRate + upgrade.currentValue;
    return computed.clamp(0.0, LootConstants.maxDropRate);
  }

  /// Additional chance shift toward higher-rarity items.
  double get rarityBonus {
    final upgrade = _upgradeManager.getUpgrade('rarity_chance');
    if (upgrade == null) return 0.0;
    return upgrade.currentValue.clamp(0.0, LootConstants.maxRarityChance);
  }

  /// Roll whether loot drops (true = item dropped).
  bool rollDrop() => _rng.nextDouble() < dropRate;

  /// Roll a rarity tier, shifted by the rarity_chance upgrade.
  ///
  /// The shift is taken from [LootRarity.common] weight and
  /// distributed to rare (40%), epic (35%), and legendary (25%).
  LootRarity rollRarity() {
    final roll = _rng.nextDouble();
    double cumulative = 0.0;

    // Clone base weights and apply rarity shift
    final shiftedWeights = Map<LootRarity, double>.from(
      LootConstants.baseRarityWeights,
    );
    final shift = rarityBonus;

    shiftedWeights[LootRarity.common] =
        (shiftedWeights[LootRarity.common]! - shift).clamp(0.1, 1.0);
    shiftedWeights[LootRarity.rare] =
        shiftedWeights[LootRarity.rare]! + shift * 0.4;
    shiftedWeights[LootRarity.epic] =
        shiftedWeights[LootRarity.epic]! + shift * 0.35;
    shiftedWeights[LootRarity.legendary] =
        shiftedWeights[LootRarity.legendary]! + shift * 0.25;

    for (final entry in shiftedWeights.entries) {
      cumulative += entry.value;
      if (roll < cumulative) return entry.key;
    }
    return LootRarity.common;
  }

  /// Calculate gold bonus based on loot rarity tier.
  int goldBonusForRarity(LootRarity rarity) {
    return LootConstants.rarityGoldBonus[rarity] ?? 10;
  }

  /// Refresh computed values after an upgrade purchase.
  void refresh() => notifyListeners();
}
