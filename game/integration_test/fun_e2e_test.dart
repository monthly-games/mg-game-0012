import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  Future<void> returnToMenu(WidgetTester tester) async {
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('core-fun-loop')), findsOneWidget);
  }

  testWidgets('fun e2e flow covers play, level progression, rewards, engine, competition, and events', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('game-id')), findsOneWidget);
    expect(find.byKey(const ValueKey('game-title')), findsOneWidget);
    expect(find.text('Core Fun: ${MyApp.coreFunLoop}'), findsOneWidget);
    expect(find.byKey(const ValueKey('engine-loop')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('start-game')));
    await tester.pumpAndSettle();
    expect(find.text('Game Ready'), findsWidgets);
    expect(find.byKey(const ValueKey('primary-loop')), findsOneWidget);
    expect(find.textContaining('Level 1'), findsOneWidget);
    expect(find.byKey(const ValueKey('level-objective')), findsOneWidget);
    expect(find.byKey(const ValueKey('difficulty-label')), findsOneWidget);
    expect(find.byKey(const ValueKey('pressure-label')), findsOneWidget);
    expect(find.text('Reward bank: 0 gold / 0 xp'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('complete-action')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Level 2'), findsOneWidget);
    expect(find.textContaining('Reward bank:'), findsOneWidget);

    await returnToMenu(tester);

    await tester.tap(find.byKey(const ValueKey('level-roadmap')));
    await tester.pumpAndSettle();
    expect(find.text('Level Roadmap'), findsWidgets);
    expect(find.byKey(const ValueKey('level-list')), findsOneWidget);
    await tester.scrollUntilVisible(
      find.textContaining('Level 8'),
      200,
      scrollable: find.byType(Scrollable),
    );
    expect(find.textContaining('Level 8'), findsOneWidget);
    await returnToMenu(tester);

    await tester.tap(find.byKey(const ValueKey('rewards')));
    await tester.pumpAndSettle();
    expect(find.text('Rewards'), findsWidgets);
    expect(find.text('Progression loop: return, claim, improve.'), findsOneWidget);
    await returnToMenu(tester);

    for (final entry in <String, String>{
      'daily-quests': 'Daily Quests',
      'guild-war': 'Guild War',
      'tournament': 'Tournament',
      'seasonal-event': 'Seasonal Event',
    }.entries) {
      await tester.tap(find.byKey(ValueKey(entry.key)));
      await tester.pumpAndSettle();
      expect(find.text(entry.value), findsWidgets);
      await returnToMenu(tester);
    }
  });
}
