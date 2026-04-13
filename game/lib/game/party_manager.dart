import 'package:flutter/foundation.dart';
import 'package:mg_common_game/systems/progression/upgrade_manager.dart';

// ============================================================
// PartyManager -- Party size & role synergy buffs
// MG-0012 Raid RPG · Phase 1 Week 3
//
// Controls party composition bonuses and maximum hero slots.
// Party size upgrade unlocks more deployment slots; role synergy
// rewards diverse team composition with a DPS bonus.
// ============================================================

/// Base constants for party system tuning.
class PartyConstants {
  PartyConstants._();

  static const int basePartySize = 3;
  static const int partySizePerLevel = 1;
  static const double baseSynergyBonus = 0.0;
  static const double synergyBonusPerLevel = 0.08;
  static const int maxPartySizeCap = 8;
}

/// Manages party composition rules and synergy bonuses.
///
/// Reads [UpgradeManager] levels for `party_size` and `role_synergy`
/// upgrades to compute maximum party slots and DPS multipliers.
class PartyManager extends ChangeNotifier {
  final UpgradeManager _upgradeManager;

  PartyManager(this._upgradeManager);

  // ── Computed party parameters ─────────────────────────────

  /// Max heroes that can be deployed simultaneously.
  int get maxPartySize {
    final upgrade = _upgradeManager.getUpgrade('party_size');
    if (upgrade == null) return PartyConstants.basePartySize;
    final computed = PartyConstants.basePartySize +
        upgrade.currentLevel * PartyConstants.partySizePerLevel;
    return computed.clamp(
      PartyConstants.basePartySize,
      PartyConstants.maxPartySizeCap,
    );
  }

  /// DPS multiplier when multiple roles are present in the party.
  double get roleSynergyMultiplier {
    final upgrade = _upgradeManager.getUpgrade('role_synergy');
    if (upgrade == null) return 1.0;
    return 1.0 + upgrade.currentValue;
  }

  /// Returns true if the party has room for another hero.
  bool canAddHero(int currentHeroCount) => currentHeroCount < maxPartySize;

  /// Calculate the synergy bonus damage for a given number of unique roles.
  ///
  /// No bonus for single-role parties. Each additional unique role
  /// adds [roleSynergyMultiplier] × 10% to total party DPS.
  double synergyDamageBonus(int uniqueRoles) {
    if (uniqueRoles <= 1) return 0.0;
    return (uniqueRoles - 1) * roleSynergyMultiplier * 0.1;
  }

  /// Refresh computed values after an upgrade purchase.
  void refresh() => notifyListeners();
}
