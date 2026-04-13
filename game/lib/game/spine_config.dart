// import 'package:mg_common_game/core/assets/asset_types.dart'; // SpineAssetMeta not available

/// Spine 통합 플래그. `--dart-define=SPINE_ENABLED=true`로 활성화.
const kSpineEnabled = bool.fromEnvironment(
  'SPINE_ENABLED',
  defaultValue: false,
);

// ── Raid Knight ──────────────────────────────────────────────

// const kRaidKnightMeta = SpineAssetMeta(
//   key: 'raid_knight',
//   path: 'spine/characters/raid_knight',
//   atlasPath: 'assets/spine/characters/raid_knight/raid_knight.atlas',
//   skeletonPath:
//       'assets/spine/characters/raid_knight/raid_knight.json',
//   animations: ['idle', 'walk', 'attack', 'hit'],
//   defaultAnimation: 'idle',
//   defaultMix: 0.2,
// );

// ── Raid Mage ────────────────────────────────────────────────

// const kRaidMageMeta = SpineAssetMeta(
//   key: 'raid_mage',
//   path: 'spine/characters/raid_mage',
//   atlasPath: 'assets/spine/characters/raid_mage/raid_mage.atlas',
//   skeletonPath: 'assets/spine/characters/raid_mage/raid_mage.json',
//   animations: ['idle', 'walk', 'attack', 'hit'],
//   defaultAnimation: 'idle',
//   defaultMix: 0.2,
// );

// ── Raid Priest ──────────────────────────────────────────────

// const kRaidPriestMeta = SpineAssetMeta(
//   key: 'raid_priest',
//   path: 'spine/characters/raid_priest',
//   atlasPath:
//       'assets/spine/characters/raid_priest/raid_priest.atlas',
//   skeletonPath:
//       'assets/spine/characters/raid_priest/raid_priest.json',
//   animations: ['idle', 'walk', 'attack', 'hit'],
//   defaultAnimation: 'idle',
//   defaultMix: 0.2,
// );
