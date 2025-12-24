import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mg_common_game/core/ui/theme/app_colors.dart';
import 'package:mg_common_game/core/ui/theme/app_text_styles.dart';
import 'package:mg_common_game/core/ui/overlays/pause_game_overlay.dart';
import 'package:mg_common_game/core/ui/overlays/settings_game_overlay.dart';
import 'package:mg_common_game/core/ui/overlays/tutorial_game_overlay.dart';
import '../features/raid/raid_game.dart';
import '../features/raid/raid_manager.dart';
import 'hud/mg_raid_hud.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RaidManager(),
      child: const MainScreenContent(),
    );
  }
}

class MainScreenContent extends StatefulWidget {
  const MainScreenContent({super.key});

  @override
  State<MainScreenContent> createState() => _MainScreenContentState();
}

class _MainScreenContentState extends State<MainScreenContent> {
  late final RaidGame _game;

  @override
  void initState() {
    super.initState();
    _game = RaidGame(raidManager: context.read<RaidManager>());
  }

  @override
  Widget build(BuildContext context) {
    // We don't need to watch RaidManager here for the game instance,
    // but sub-widgets do.

    return Scaffold(
      body: Stack(
        children: [
          // Game Layer
          GameWidget(
            game: _game,
            overlayBuilderMap: {
              'PauseGame': (context, RaidGame game) => PauseGameOverlay(
                game: game,
                onResume: () {
                  game.resumeEngine();
                  game.overlays.remove('PauseGame');
                },
                onSettings: () {
                  game.overlays.add('SettingsGame');
                },
                onQuit: () {
                  game.resumeEngine();
                  game.overlays.remove('PauseGame');
                  // No explicit quit action yet
                },
              ),
              'SettingsGame': (context, RaidGame game) => SettingsGameOverlay(
                game: game,
                onBack: () {
                  game.overlays.remove('SettingsGame');
                },
              ),
              'TutorialGame': (context, RaidGame game) => TutorialGameOverlay(
                game: game,
                pages: const [
                  TutorialPage(
                    title: 'WINTER RAID',
                    content:
                        'Defeat the Ice Golem before time runs out!\n\nYour party attacks automatically.',
                  ),
                  TutorialPage(
                    title: 'UPGRADES',
                    content:
                        'Earn Gold by dealing damage.\n\nUnlock and Upgrade heroes to increase DPS.',
                  ),
                ],
                onComplete: () {
                  game.overlays.remove('TutorialGame');
                  game.resumeEngine();
                },
              ),
            },
          ),

          // MG Raid HUD
          Consumer<RaidManager>(
            builder: (context, rm, _) {
              final totalDps = rm.heroes
                  .where((h) => h.isUnlocked)
                  .fold<double>(0, (sum, h) => sum + h.dps)
                  .toInt();
              return MGRaidHud(
                gold: rm.gold,
                currentTime: rm.currentTime,
                totalTime: rm.totalTime,
                totalDps: totalDps,
                bossHp: rm.bossHp.toInt(),
                bossMaxHp: rm.maxBossHp.toInt(),
                bossName: 'ICE GOLEM',
                onPause: () {
                  _game.pauseEngine();
                  _game.overlays.add('PauseGame');
                },
              );
            },
          ),

          // UI Layer - Bottom Panel Only
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 140), // HUD 공간

                const Spacer(),

                // Bottom Party Status (Placeholder)
                // Upgrade Panel
                Container(
                  height: 160,
                  color: AppColors.panel.withOpacity(0.9),
                  padding: const EdgeInsets.all(8),
                  child: Consumer<RaidManager>(
                    builder: (context, rm, _) {
                      return ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: rm.heroes.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final hero = rm.heroes[index];
                          final isUnlocked = hero.isUnlocked;
                          final cost = isUnlocked
                              ? hero.upgradeCost
                              : hero.unlockCost;
                          final canAfford = rm.gold >= cost;

                          return Container(
                            width: 120,
                            decoration: BoxDecoration(
                              color: isUnlocked
                                  ? AppColors.surface
                                  : AppColors.panel,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isUnlocked
                                    ? hero.color.withOpacity(0.5)
                                    : AppColors.textDisabled,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  hero.name,
                                  style: AppTextStyles.body.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isUnlocked
                                        ? hero.color
                                        : AppColors.textMediumEmphasis,
                                  ),
                                ),
                                if (isUnlocked) ...[
                                  Text(
                                    "Lv.${hero.level}",
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.textMediumEmphasis,
                                    ),
                                  ),
                                  Text(
                                    "${hero.dps.toInt()} DPS",
                                    style: AppTextStyles.body.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textHighEmphasis,
                                    ),
                                  ),
                                ] else ...[
                                  const Icon(
                                    Icons.lock,
                                    color: AppColors.textMediumEmphasis,
                                    size: 24,
                                  ),
                                  const SizedBox(height: 4),
                                ],
                                const Spacer(),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: canAfford
                                        ? (isUnlocked
                                              ? AppColors.secondary
                                              : AppColors.primary)
                                        : AppColors.textDisabled,
                                    foregroundColor: AppColors.textHighEmphasis,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                  ),
                                  onPressed: canAfford
                                      ? () => rm.upgradeHero(hero)
                                      : null,
                                  child: Text(
                                    isUnlocked ? "$cost G" : "Unlock $cost G",
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.background,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
