import 'package:mg_common_game/systems/balancing/balancing.dart';

/// Default balancing configuration for MG-0012: Year-End Raid Event RPG.
///
/// Placeholder values — override via RemoteConfig using
/// [BalancingManager.loadFromRemote] in production.
const kDefaultBalancingConfig = BalancingConfig(
  gameId: 'mg-0012',
  version: 1,
  currencies: [
    CurrencyConfig(id: 'gold', baseEarnRate: 15.0),
    CurrencyConfig(
      id: 'gems',
      baseEarnRate: 1.0,
      earnCurve: CurveType.logarithmic,
      earnGrowthFactor: 0.5,
    ),
  ],
  xpCurve: XpCurveConfig(baseXp: 100, maxLevel: 100),
  difficultyScaling: DifficultyScalingConfig(scalingFactor: 0.15),
  customParams: {
    'crit_base_chance': 0.05,
    'squad_size_base': 3,
  },
);
