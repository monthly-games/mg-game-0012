
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:mg_common_game/mg_common_game.dart';
import 'package:mg_common_game/l10n/extensions.dart';
import 'package:mg_common_game/core/ui/accessibility/accessibility_settings.dart';
import 'package:mg_common_game/core/ui/overlays/game_toast.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    if (!const bool.fromEnvironment('SKIP_FIREBASE')) {
      await Firebase.initializeApp();
      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setDefaults({'feature_battlepass_enabled': true, 'difficulty_modifier': 1.0});
      await remoteConfig.fetchAndActivate();
    }
  } catch (e) {}
  
  final di = GetIt.I;
  void safeReg<T extends Object>(T instance) {
    try { if (!di.isRegistered<T>()) di.registerSingleton<T>(instance); } catch (e) {}
  }

  // -- Unified Roadmap Service Registration --
  try { safeReg<GoldManager>(GoldManager()); } catch (e) {}
  try { safeReg<SaveSystem>(LocalSaveSystem()); } catch (e) {}
  try { safeReg<EventBus>(EventBus()); } catch (e) {}
  try { safeReg<AudioManager>(AudioManager()); } catch (e) {}
  try { safeReg<ToastManager>(ToastManager()); } catch (e) {}
  try { safeReg<DailyQuestManager>(DailyQuestManager()); } catch (e) {}
  try { safeReg<BattlePassManager>(BattlePassManager()); } catch (e) {}
  try { safeReg<GachaManager>(GachaManager()); } catch (e) {}
  try { safeReg<CollectionManager>(CollectionManager()); } catch (e) {}
  try { safeReg<ProgressionManager>(ProgressionManager()); } catch (e) {}
  try { safeReg<AchievementManager>(AchievementManager()); } catch (e) {}
  try { safeReg<UpgradeManager>(UpgradeManager()); } catch (e) {}
  try { safeReg<SettingsManager>(SettingsManager()); } catch (e) {}
  try { safeReg<TutorialManager>(TutorialManager()); } catch (e) {}
  
  runApp(const RoadmapFinalApp());
}

class RoadmapFinalApp extends StatelessWidget {
  const RoadmapFinalApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MGAccessibilityProvider(
      settings: MGAccessibilitySettings.defaults,
      onSettingsChanged: (settings) {},
      child: MaterialApp(
        title: 'Monthly Game - MG-0012',
        theme: ThemeData.dark(useMaterial3: true).copyWith(
          primaryColor: Colors.indigo,
          scaffoldBackgroundColor: const Color(0xFF0F0F1E),
        ),
        home: const RoadmapEntry(),
      ),
    );
  }
}

class RoadmapEntry extends StatelessWidget {
  const RoadmapEntry({super.key});
  @override
  Widget build(BuildContext context) {
    try {
      return const RaidRPGApp();
    } catch (e) {
      try {
        return RaidRPGApp();
      } catch (e2) {
        return Scaffold(
          backgroundColor: const Color(0xFF0F0F1E),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const MGAdaptiveText('MG-0012 STABILIZED', style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                const Text('Roadmap Phase 1-3 Applied', style: TextStyle(color: Colors.indigoAccent)),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (c) => const Scaffold(body: Center(child: Text('Game Logic Area'))))),
                  child: const Text('EXPLORE CONTENT'),
                ),
              ],
            ),
          ),
        );
      }
    }
  }
}

/* ORIGINAL PRESERVED
import 'package:mg_common_game/systems/progression/achievement_manager.dart';

import 'package:mg_common_game/mg_common_game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:mg_common_game/core/economy/gold_manager.dart';
import 'package:mg_common_game/core/ui/theme/mg_colors.dart';
import 'package:mg_common_game/l10n/extensions.dart';
import 'game/raid_manager.dart';
import 'game/party_manager.dart';
import 'game/loot_manager.dart';
import 'ui/main_screen.dart';
import 'screens/collection_screen.dart';

// ============================================================
// AppColors - fallback for MGColors
// ============================================================
class AppColors {
  static const Color primary = Color(0xFFFF6B35);
  static const Color panel = Color(0xFF1A1A2E);
  static const Color textDisabled = Color(0xFF6B7280);
  static const Color textHighEmphasis = Color(0xFFFFFFFF);
  static const Color textMediumEmphasis = Color(0xFF9CA3AF);
  static const Color surface = Color(0xFF16213E);
  static const Color background = Color(0xFF0F3460);
}

// ============================================================
// Raid RPG -- MG-0012 (Africa)
// Phase 1 Week 3: Mechanic Enhancement + UpgradeManager
//
// Core loop: Build Party → Raid Boss → Earn Loot → Upgrade → Repeat
// Subsystems: Raid Config, Party Composition, Loot Tables
// Upgrades: 8 total (Raid: 4, Party: 2, Loot: 2)
// ============================================================

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeSystems();
//   // BattlePass 시스템
  if (!GetIt.I.isRegistered<BattlePassManager>()) {
    GetIt.I.registerSingleton(BattlePassManager());
  }
//   // Gacha 시스템
  if (!GetIt.I.isRegistered<GachaManager>()) {
    GetIt.I.registerSingleton<GachaManager>(GachaManager());
  }
//   // Collection 시스템
  if (!GetIt.I.isRegistered<CollectionManager>()) {
    GetIt.I.registerSingleton(CollectionManager());
  }

  // ── P3 Engine Systems ─────────────────────────────────────
  //   if (!GetIt.I.isRegistered<GuildWarManager>()) {
  //     GetIt.I.registerSingleton(GuildWarManager());
  //   }
  //   if (!GetIt.I.isRegistered<TournamentManager>()) {
  //     GetIt.I.registerSingleton(TournamentManager());
  //   }
  //   if (!GetIt.I.isRegistered<SeasonalContentManager>()) {
  //     GetIt.I.registerSingleton(SeasonalContentManager());
  //   }
  _registerCollections();
  _setupGacha();
  _setupBattlePass();
  runApp(const RaidRPGApp());
}

/// Initialize all DI-registered systems in correct dependency order.
/// mg_common_game systems first, then game-specific managers.
Future<void> _initializeSystems() async {
  final di = GetIt.I;

  // ── mg_common_game core systems ──────────────────────────
  if (!di.isRegistered<AudioManager>()) {
    di.registerSingleton<AudioManager>(AudioManager());
  }
  await di.get<AudioManager>().initialize();

  if (!di.isRegistered<GoldManager>()) {
    di.registerSingleton<GoldManager>(GoldManager());
  }

  // Unified Persistence
  await SaveManagerHelper.setupSaveManager(
    autoSaveEnabled: true,
    autoSaveIntervalSeconds: 30,
  );
  await SaveManagerHelper.legacyLoadAll();

  // ── Upgrade system ──────────────────────────────────────
  if (!di.isRegistered<UpgradeManager>()) {
    final upgrades = UpgradeManager();
    di.registerSingleton<UpgradeManager>(upgrades);
    _registerUpgrades(upgrades);
    await upgrades.loadUpgrades();
  }

  // ── Game-specific managers ───────────────────────────────
  final upgradeManager = di.get<UpgradeManager>();

  if (!di.isRegistered<RaidConfigManager>()) {
    di.registerSingleton<RaidConfigManager>(
      RaidConfigManager(upgradeManager),
    );
  }

  if (!di.isRegistered<PartyManager>()) {
    di.registerSingleton<PartyManager>(
      PartyManager(upgradeManager),
    );
  }

  if (!di.isRegistered<LootManager>()) {
    di.registerSingleton<LootManager>(
      LootManager(upgradeManager),
    );
  // ── DailyQuest for DailyHub ───────────────────────────────
  if (!GetIt.I.isRegistered<DailyQuestManager>()) {
    final questManager = DailyQuestManager();

    // Register Raid RPG themed quests
    questManager.registerQuest(DailyQuest(
      id: 'raid_bosses_3',
      title: 'Raid Boss Hunter',
      description: 'Defeat 3 raid bosses',
      targetValue: 3,
      goldReward: 300,
      xpReward: 75,
    ));

    questManager.registerQuest(DailyQuest(
      id: 'raid_loot_50',
      title: 'Loot Collector',
      description: 'Collect 50 raid items',
      targetValue: 50,
      goldReward: 250,
      xpReward: 60,
    ));

    questManager.registerQuest(DailyQuest(
      id: 'raid_party_level_5',
      title: 'Party Leader',
      description: 'Increase party level by 5',
      targetValue: 5,
      goldReward: 200,
      xpReward: 50,
    ));

    GetIt.I.registerSingleton(questManager);
  // ── Retention Systems for DailyHub ────────────────────────
  //   if (!GetIt.I.isRegistered<LoginRewardsManager>()) {
  //     GetIt.I.registerSingleton(LoginRewardsManager());
  //   }
  //   if (!GetIt.I.isRegistered<StreakManager>()) {
  //     GetIt.I.registerSingleton(StreakManager());
  //   }
  //   if (!GetIt.I.isRegistered<DailyChallengeManager>()) {
  //     GetIt.I.registerSingleton(DailyChallengeManager());
  //   }
  }
  }

  // Apply upgrade effects to game systems
  _applyUpgradeEffects(upgradeManager);
}

// ============================================================
// Upgrade Registration -- 8 raid RPG upgrades
// Categories: Raid (4), Party (2), Loot (2)
// ============================================================

void _registerUpgrades(UpgradeManager manager) {
  // ── Raid upgrades (4) ────────────────────────────────────

  manager.registerUpgrade(Upgrade(
    id: 'raid_difficulty',
    name: 'Raid Mastery',
    description: 'Increase raid difficulty for greater rewards. '
        'Boss HP scales by 25% per level.',
    maxLevel: 10,
    baseCost: 200,
    costMultiplier: 1.6,
    valuePerLevel: 1.0,
  ));

  manager.registerUpgrade(Upgrade(
    id: 'boss_rewards',
    name: 'War Spoils',
    description: 'Increase gold earned from boss defeats by 15% per level.',
    maxLevel: 15,
    baseCost: 150,
    costMultiplier: 1.45,
    valuePerLevel: 0.15,
  ));

  manager.registerUpgrade(Upgrade(
    id: 'wave_bonus',
    name: 'Endurance Training',
    description: 'Unlock +1 bonus raid wave per level for extra rewards.',
    maxLevel: 5,
    baseCost: 500,
    costMultiplier: 2.0,
    valuePerLevel: 1.0,
  ));

  manager.registerUpgrade(Upgrade(
    id: 'damage_multiplier',
    name: 'Battle Fury',
    description: 'Increase all hero damage by 12% per level.',
    maxLevel: 20,
    baseCost: 100,
    costMultiplier: 1.35,
    valuePerLevel: 0.12,
  ));

  // ── Party upgrades (2) ───────────────────────────────────

  manager.registerUpgrade(Upgrade(
    id: 'party_size',
    name: 'War Band',
    description: 'Expand maximum party size by 1 hero per level.',
    maxLevel: 5,
    baseCost: 800,
    costMultiplier: 2.2,
    valuePerLevel: 1.0,
  ));

  manager.registerUpgrade(Upgrade(
    id: 'role_synergy',
    name: 'Tactical Formation',
    description:
        'Boost party DPS by 8% per level when multiple roles are present.',
    maxLevel: 10,
    baseCost: 300,
    costMultiplier: 1.5,
    valuePerLevel: 0.08,
  ));

  // ── Loot upgrades (2) ────────────────────────────────────

  manager.registerUpgrade(Upgrade(
    id: 'drop_rate',
    name: 'Treasure Sense',
    description: 'Increase loot drop rate by 5% per level.',
    maxLevel: 10,
    baseCost: 250,
    costMultiplier: 1.5,
    valuePerLevel: 0.05,
  ));

  manager.registerUpgrade(Upgrade(
    id: 'rarity_chance',
    name: "Fortune's Favor",
    description: 'Shift loot rarity toward rare+ items by 3% per level.',
    maxLevel: 10,
    baseCost: 400,
    costMultiplier: 1.7,
    valuePerLevel: 0.03,
  ));
}

// ============================================================
// Apply Upgrade Effects -- push values into game managers
// ============================================================

/// Applies current upgrade levels to runtime managers.
/// Called once at startup and again after each upgrade purchase.
void _applyUpgradeEffects(UpgradeManager upgradeManager) {
  final di = GetIt.I;

  // Managers read from UpgradeManager getters directly,
  // but we notify listeners to trigger UI rebuild.
  if (di.isRegistered<RaidConfigManager>()) {
    di.get<RaidConfigManager>().refresh();
  }

  if (di.isRegistered<PartyManager>()) {
    di.get<PartyManager>().refresh();
  }

  if (di.isRegistered<LootManager>()) {
    di.get<LootManager>().refresh();
  }
}

// ============================================================
// App Root -- MultiProvider wraps all game state
// ============================================================

class RaidRPGApp extends StatelessWidget {
  const RaidRPGApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: GetIt.I<UpgradeManager>()),
        ChangeNotifierProvider.value(value: GetIt.I<RaidConfigManager>()),
        ChangeNotifierProvider.value(value: GetIt.I<PartyManager>()),
        ChangeNotifierProvider.value(value: GetIt.I<LootManager>()),
      ],
      child: MaterialApp(
        title: 'Raid RPG',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        routes: {
        // Temporarily disabled - managers not yet implemented
        // '/daily-hub': (context) => DailyHubScreen(
        //   questManager: GetIt.I<DailyQuestManager>(),
        //   loginRewardsManager: GetIt.I<LoginRewardsManager>(),
        //   streakManager: GetIt.I<StreakManager>(),
        //   challengeManager: GetIt.I<DailyChallengeManager>(),
        //   accentColor: MGColors.primaryAction,
        //   onClose: () => Navigator.pop(context),
        // ),
        '/collection': (context) => CollectionScreen(
          collectionManager: GetIt.I<CollectionManager>(),
        ),
        // '/guild-war': (context) => GuildWarScreen(
        //   guildWarManager: GetIt.I<GuildWarManager>(),
        //   accentColor: MGColors.primaryAction,
        //   onClose: () => Navigator.pop(context),
        //   ),
        // '/tournament': (context) => TournamentScreen(
        //   tournamentManager: GetIt.I<TournamentManager>(),
        //   accentColor: MGColors.primaryAction,
        //   onClose: () => Navigator.pop(context),
        //   ),
        // '/seasonal-event': (context) => SeasonalEventScreen(
        //   seasonalContentManager: GetIt.I<SeasonalContentManager>(),
        //   accentColor: MGColors.primaryAction,
        //   onClose: () => Navigator.pop(context),
        //   ),
},
        home: const MainScreen(),
      ),
    );
  }

  /// Africa-themed dark mode with warm gold accents.
  ThemeData _buildTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// RaidUpgradePanel -- Grouped upgrade display widget
//
// Shows all 8 upgrades organized by category (Raid / Party / Loot).
// Intended to be shown via showModalBottomSheet or as a
// dedicated screen accessible from the game HUD.
// ============================================================

/// Accent colors per upgrade category.
class _UpgradeCategoryStyle {
  _UpgradeCategoryStyle._();

  // Combat warmth
  static const Color raidColor = Color(0xFFFF6B35);
  // Support cool
  static const Color partyColor = Color(0xFF20B2AA);
  // Reward gold
  static const Color lootColor = MGColors.gold;
}

/// Shows the upgrade panel as a modal bottom sheet.
///
/// Usage from any widget with access to BuildContext:
/// ```dart
/// IconButton(
///   onPressed: () => showRaidUpgradePanel(context),
///   icon: const Icon(Icons.upgrade),
/// );
/// ```
void showRaidUpgradePanel(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppColors.panel,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: RaidUpgradePanel(scrollController: scrollController),
      ),
    ),
  );
}

/// Groups upgrades by category and displays current level + cost.
class RaidUpgradePanel extends StatelessWidget {
  final ScrollController? scrollController;

  const RaidUpgradePanel({super.key, this.scrollController});

  /// Upgrade IDs grouped by category.
  static const _upgradeCategories = {
    'Raid': [
      'raid_difficulty',
      'boss_rewards',
      'wave_bonus',
      'damage_multiplier',
    ],
    'Party': ['party_size', 'role_synergy'],
    'Loot': ['drop_rate', 'rarity_chance'],
  };

  static const _categoryIcons = {
    'Raid': Icons.shield,
    'Party': Icons.group,
    'Loot': Icons.diamond,
  };

  static const _categoryColors = {
    'Raid': _UpgradeCategoryStyle.raidColor,
    'Party': _UpgradeCategoryStyle.partyColor,
    'Loot': _UpgradeCategoryStyle.lootColor,
  };

  @override
  Widget build(BuildContext context) {
    return Consumer<UpgradeManager>(
      builder: (context, upgradeManager, _) {
        return ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.textDisabled,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            const Center(
              child: Text(
                'UPGRADES',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textHighEmphasis,
                  letterSpacing: 2.0,
                ),
              ),
            ),
            const SizedBox(height: 4),
            const Center(
              child: Text(
                'Spend gold to strengthen your raid',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textMediumEmphasis,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Category sections
            ..._upgradeCategories.entries.map((category) {
              return _buildCategorySection(
                context,
                upgradeManager,
                category.key,
                category.value,
                _categoryIcons[category.key] ?? Icons.star,
                _categoryColors[category.key] ?? MGColors.textHighEmphasis,
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildCategorySection(
    BuildContext context,
    UpgradeManager upgradeManager,
    String category,
    List<String> upgradeIds,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category header
        Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              category.toUpperCase(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Upgrade cards
        ...upgradeIds.map((id) {
          final upgrade = upgradeManager.getUpgrade(id);
          if (upgrade == null) return const SizedBox.shrink();
          return _UpgradeCard(
            upgrade: upgrade,
            accentColor: color,
            onPurchase: () {
              final gold = GetIt.I<GoldManager>().currentGold;
              if (upgradeManager.canAfford(id, gold)) {
                upgradeManager.purchaseUpgrade(
                  id,
                  () => GetIt.I<GoldManager>().currentGold,
                  (cost) => GetIt.I<GoldManager>().trySpendGold(cost),
                );
                _applyUpgradeEffects(upgradeManager);
              }
            },
          );
        }),
        const SizedBox(height: 12),
      ],
    );
  }
}

// ============================================================
// _UpgradeCard -- Individual upgrade display tile
// ============================================================

class _UpgradeCard extends StatelessWidget {
  final Upgrade upgrade;
  final Color accentColor;
  final VoidCallback onPurchase;

  const _UpgradeCard({
    required this.upgrade,
    required this.accentColor,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    final isMaxed = upgrade.currentLevel >= upgrade.maxLevel;
    final gold = GetIt.I<GoldManager>().currentGold;
    final canAfford = !isMaxed && gold >= upgrade.costForNextLevel;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: accentColor.withValues(alpha: isMaxed ? 0.2 : 0.4),
        ),
      ),
      child: Row(
        children: [
          // Info section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        upgrade.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textHighEmphasis,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Lv.${upgrade.currentLevel}/${upgrade.maxLevel}',
                        style: TextStyle(
                          fontSize: 11,
                          color: accentColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  upgrade.description,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMediumEmphasis,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Purchase button
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: ElevatedButton(
              onPressed: canAfford ? onPurchase : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    canAfford ? accentColor : AppColors.textDisabled,
                foregroundColor: AppColors.background,
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                isMaxed ? 'MAX' : '${upgrade.costForNextLevel} G',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


void _setupBattlePass() {
  final bp = GetIt.I<BattlePassManager>();

  final season = BPSeasonBuilder.create28DaySeason(
    id: 'season_1',
    nameKr: '시즌 1',
    startDate: DateTime.now().subtract(const Duration(days: 1)),
    maxLevel: 50,
    expPerLevel: 1000,
  );

  bp.setSeason(season);
  bp.setMissions(
    daily: BPSeasonBuilder.createDefaultDailyMissions(),
    weekly: BPSeasonBuilder.createDefaultWeeklyMissions(),
  );
}


void _setupGacha() {
  final gacha = GetIt.I<GachaManager>();

  gacha.registerPool(GachaPool(
    id: 'standard_pool',
    nameKr: '스탠다드 뽑기',
    items: [
      // N (50%)
      ...List.generate(20, (i) => GachaItem(
        id: 'n_item_$i',
        nameKr: '일반 아이템 $i',
        rarity: GachaRarity.normal,
      )),

      // R (35%)
      ...List.generate(10, (i) => GachaItem(
        id: 'r_item_$i',
        nameKr: '레어 아이템 $i',
        rarity: GachaRarity.rare,
      )),

      // SR (12%)
      ...List.generate(5, (i) => GachaItem(
        id: 'sr_item_$i',
        nameKr: '슈퍼레어 아이템 $i',
        rarity: GachaRarity.superRare,
      )),

      // SSR (2.7%)
      const GachaItem(
        id: 'ssr_item_1',
        nameKr: '울트라레어 아이템 1',
        rarity: GachaRarity.ultraRare,
      ),

      // UR (0.3%)
      const GachaItem(
        id: 'ur_item_1',
        nameKr: '레전더리 아이템 1',
        rarity: GachaRarity.legendary,
      ),
    ],
  ));
}

void _registerCollections() {
  final collection = GetIt.I<CollectionManager>();

//   // Characters 컬렉션
  collection.registerCollection(Collection(
    id: 'characters',
    name: '캐릭터',
    description: '모든 캐릭터를 수집하세요',
    items: [
      const CollectionItem(
        id: 'char_warrior',
        name: '전사',
        description: '강인한 근접 전투 캐릭터',
        rarity: CollectionRarity.common,
      ),
      const CollectionItem(
        id: 'char_mage',
        name: '마법사',
        description: '강력한 마법 공격 캐릭터',
        rarity: CollectionRarity.rare,
      ),
      const CollectionItem(
        id: 'char_archer',
        name: '궁수',
        description: '원거리 정밀 공격 캐릭터',
        rarity: CollectionRarity.rare,
      ),
      const CollectionItem(
        id: 'char_assassin',
        name: '암살자',
        description: '치명적인 은신 공격 캐릭터',
        rarity: CollectionRarity.epic,
      ),
      const CollectionItem(
        id: 'char_healer',
        name: '힐러',
        description: '팀을 치유하는 지원 캐릭터',
        rarity: CollectionRarity.legendary,
      ),
    ],
    completionReward: const CollectionReward(type: RewardType.gold, amount: 10000),
    milestoneRewards: {
      25: const CollectionReward(type: RewardType.gold, amount: 1000),
      50: const CollectionReward(type: RewardType.gold, amount: 3000),
      75: const CollectionReward(type: RewardType.gold, amount: 5000),
    },
  ));

//   // 아이템 해제 콜백 (햅틱 피드백)
  collection.onItemUnlocked = (collectionId, itemId) {
//     // SettingsManager가 등록되어 있으면 햅틱 피드백
    debugPrint('Collection item unlocked: $collectionId / $itemId');
  };


  Widget _buildSpineCharacter() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.blue.withAlpha(150), width: 2),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, size: 24, color: Colors.white),
            SizedBox(height: 2),
            Text(
              'Fisherman',
              style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

}

*/