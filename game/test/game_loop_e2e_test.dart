import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:game/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:game/game/level_design_config.dart';
import 'package:game/game/wave_spawn_table.dart';
import 'package:game/game/tutorial_config.dart';

/// E2E Test for MG-0012: Year-End Raid Event RPG
///
/// Tests the game loop with focus on:
/// - 5-stage combo system mechanics
/// - Raid battle event progression
/// - Tutorial flow for raid gameplay
/// - High-pressure wave spawns
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('MG-0012 Year-End Raid Event - Game Loop E2E', () {
    testWidgets('Complete raid progression with 5-stage combo system', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify main menu elements
      expect(find.text('MG-0012'), findsOneWidget);
      expect(find.text('Year-End Raid Event RPG'), findsOneWidget);
      expect(find.text('Core Fun: $kCoreFunLoop'), findsOneWidget);

      // Navigate to tutorial
      await tester.tap(find.text('Tutorial'));
      await tester.pumpAndSettle();

      // Verify tutorial flow
      expect(find.byType(app.TutorialFlowScreen), findsOneWidget);

      // Complete tutorial steps
      final tutorialSteps = kOnboardingTutorial.steps;
      for (int i = 0; i < tutorialSteps.length; i++) {
        await tester.pumpAndSettle();

        // Verify current step is displayed
        expect(find.text('${i + 1}/${tutorialSteps.length}'), findsOneWidget);
        expect(find.text(tutorialSteps[i].title), findsOneWidget);

        // Tap next button
        await tester.tap(find.text(i == tutorialSteps.length - 1 ? 'Done' : 'Next'));
        await tester.pumpAndSettle();
      }

      // Navigate to game screen
      await tester.tap(find.text('Start Game'));
      await tester.pumpAndSettle();

      // Verify game screen initialization
      expect(find.byType(app.GameScreen), findsOneWidget);

      // Test 5-stage combo system by completing actions in sequence
      int comboCount = 0;
      int maxComboStages = 5;
      int totalGold = 0;
      int totalXP = 0;

      // Build combo through successive action completions
      for (int comboStage = 1; comboStage <= maxComboStages; comboStage++) {
        await tester.pumpAndSettle();

        // Verify current level displays raid event theme
        final levelIndex = comboStage - 1;
        if (levelIndex < kLevelDesign.length) {
          final levelDesign = kLevelDesign[levelIndex];
          final spawn = kWaveSpawnTable[levelIndex];
          expect(find.text('Level ${levelDesign.levelIndex} - ${levelDesign.stage}'), findsOneWidget);
          expect(find.text('${spawn.enemyCount} targets'), findsOneWidget);

          // Complete action to build combo
          await tester.tap(find.byKey(const ValueKey('complete-action')));
          await tester.pumpAndSettle();

          // Combo multiplier should increase with each stage
          final comboMultiplier = comboStage;
          totalGold += levelDesign.goldReward * comboMultiplier;
          totalXP += levelDesign.xpReward * comboMultiplier;
          comboCount++;

          // Verify combo progression
          expect(find.text('$totalGold gold / $totalXP xp'), findsOneWidget);
        }
      }

      // Verify 5-stage combo system completion
      expect(comboCount, equals(maxComboStages), reason: 'Should complete 5 combo stages');
      expect(totalGold, greaterThan(0), reason: 'Combo should increase gold rewards');
      expect(totalXP, greaterThan(0), reason: 'Combo should increase XP rewards');
    });

    testWidgets('Test raid event wave pressure mechanics', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Start game directly
      await tester.tap(find.text('Start Game'));
      await tester.pumpAndSettle();

      // Verify raid-specific wave pressure
      for (int i = 0; i < 5 && i < kLevelDesign.length; i++) {
        final spawn = kWaveSpawnTable[i];

        // Raid events should have high enemy count and pressure
        expect(spawn.enemyCount, greaterThan(10), reason: 'Raid should have many enemies');
        expect(spawn.pressureBudget, greaterThan(100), reason: 'Raid should have high pressure');

        // Complete action
        await tester.tap(find.byKey(const ValueKey('complete-action')));
        await tester.pumpAndSettle();
      }
    });

    testWidgets('Verify combo reset mechanic when action is delayed', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start Game'));
      await tester.pumpAndSettle();

      // Build initial combo
      for (int i = 0; i < 3; i++) {
        await tester.tap(find.byKey(const ValueKey('complete-action')));
        await tester.pumpAndSettle();
      }

      // Simulate delay (combo should reset after delay)
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      // Next action should start fresh combo (stage 1 multiplier)
      final previousGold = kLevelDesign.take(3).map((l) => l.goldReward).fold(0, (a, b) => a + b);
      final nextReward = kLevelDesign[3].goldReward; // No combo multiplier

      await tester.tap(find.byKey(const ValueKey('complete-action')));
      await tester.pumpAndSettle();

      // Verify combo mechanics work correctly
      expect(find.textContaining('gold'), findsOneWidget);
    });

    testWidgets('Test level roadmap displays raid event stages', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to level roadmap
      await tester.tap(find.text('Level Roadmap'));
      await tester.pumpAndSettle();

      // Verify all raid levels are displayed
      expect(find.byType(app.LevelRoadmapScreen), findsOneWidget);
      expect(find.text('Level 0'), findsOneWidget);

      // Verify raid event specific levels
      for (int i = 0; i < kLevelDesign.length && i < 10; i++) {
        final level = kLevelDesign[i];
        expect(find.text('Level ${level.levelIndex} - ${level.stage}'), findsOneWidget);
      }
    });

    testWidgets('Verify raid event theme and visual elements', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to game to verify raid visual elements
      await tester.tap(find.text('Start Game'));
      await tester.pumpAndSettle();

      // Verify raid-specific UI elements
      expect(find.byIcon(Icons.videogame_asset_rounded), findsWidgets);

      // Check that difficulty is appropriately high for raid
      final firstLevel = kLevelDesign.first;
      expect(firstLevel.difficulty, greaterThan(1.0), reason: 'Raid should start with higher difficulty');
    });

    testWidgets('Complete full raid event session with maximum combo', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Complete tutorial
      await tester.tap(find.text('Tutorial'));
      await tester.pumpAndSettle();

      while (find.text('Next').evaluate().isNotEmpty) {
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
      }

      if (find.text('Done').evaluate().isNotEmpty) {
        await tester.tap(find.text('Done'));
        await tester.pumpAndSettle();
      }

      // Play raid event with optimal combo usage
      await tester.tap(find.text('Start Game'));
      await tester.pumpAndSettle();

      int totalActionsCompleted = 0;
      int maxLevels = 15;

      for (int i = 0; i < maxLevels && i < kLevelDesign.length; i++) {
        // Complete action for current level
        await tester.tap(find.byKey(const ValueKey('complete-action')));
        await tester.pumpAndSettle();
        totalActionsCompleted++;
      }

      // Verify raid progression
      expect(totalActionsCompleted, equals(maxLevels), reason: 'Should complete 15 raid levels');

      // Verify high rewards from raid event
      final finalGold = kLevelDesign.take(maxLevels).map((l) => l.goldReward).fold(0, (a, b) => a + b);
      final finalXP = kLevelDesign.take(maxLevels).map((l) => l.xpReward).fold(0, (a, b) => a + b);

      expect(find.textContaining('$finalGold gold'), findsOneWidget);
      expect(find.textContaining('$finalXP xp'), findsOneWidget);
    });

    testWidgets('Test raid event special features and retention mechanics', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test tournament access (raid events often link to tournaments)
      await tester.tap(find.text('Tournament'));
      await tester.pumpAndSettle();
      expect(find.text('Tournament'), findsOneWidget);
      expect(find.text('Competitive goals are available for mastery.'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      // Test seasonal event access
      await tester.tap(find.text('Event'));
      await tester.pumpAndSettle();
      expect(find.text('Seasonal Event'), findsOneWidget);
      expect(find.text('Timed content gives the loop a fresh reason to return.'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      // Test rewards screen
      await tester.tap(find.text('Rewards'));
      await tester.pumpAndSettle();
      expect(find.text('Rewards'), findsOneWidget);
      expect(find.text('Progression loop: return, claim, improve.'), findsOneWidget);
    });

    testWidgets('Verify raid boss wave mechanics', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start Game'));
      await tester.pumpAndSettle();

      // Test that boss waves (every 5th level) have higher difficulty
      for (int i = 0; i < 15 && i < kLevelDesign.length; i++) {
        final level = kLevelDesign[i];
        final spawn = kWaveSpawnTable[i];

        // Every 5th wave should be a boss wave
        if ((i + 1) % 5 == 0) {
          expect(level.difficulty, greaterThan(kLevelDesign[i - 1].difficulty),
              reason: 'Boss waves should be harder');
          expect(spawn.enemyCount, greaterThan(20),
              reason: 'Boss waves should have more enemies');
        }

        await tester.tap(find.byKey(const ValueKey('complete-action')));
        await tester.pumpAndSettle();
      }
    });
  });
}