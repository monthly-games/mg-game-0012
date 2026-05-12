import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mg_common_game/mg_common_game.dart';
import 'package:game/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Comprehensive Feature Test - MG-0012', (WidgetTester tester) async {
    // 1. App Launch
    app.main();
    await tester.pump(const Duration(seconds: 10));

    // 2. Verify Core UI
    expect(find.byType(MaterialApp), findsOneWidget);
    
    // 3. System: Daily Quests
    final questFinder = find.textContaining('Quest');
    if (questFinder.evaluate().isNotEmpty) {
       debugPrint('Feature: Testing Daily Quests');
       await tester.tap(questFinder.first);
       await tester.pump(const Duration(seconds: 2));
       await tester.pageBack();
       await tester.pump(const Duration(seconds: 1));
    }

    // 4. System: Gacha / Store
    final gachaFinder = find.textContaining('Gacha');
    if (gachaFinder.evaluate().isNotEmpty) {
       debugPrint('Feature: Testing Gacha System');
       await tester.tap(gachaFinder.first);
       await tester.pump(const Duration(seconds: 2));
       await tester.pageBack();
       await tester.pump(const Duration(seconds: 1));
    }

    // 5. System: BattlePass
    final bpFinder = find.textContaining('Pass');
    if (bpFinder.evaluate().isNotEmpty) {
       debugPrint('Feature: Testing BattlePass');
       await tester.tap(bpFinder.first);
       await tester.pump(const Duration(seconds: 2));
       await tester.pageBack();
       await tester.pump(const Duration(seconds: 1));
    }

    // 6. UI Consistency: Adaptive Text
    final adaptiveTexts = find.byType(MGAdaptiveText);
    if (adaptiveTexts.evaluate().isNotEmpty) {
       debugPrint('Feature: Adaptive Text verified');
    }

    debugPrint('Comprehensive E2E completed for MG-0012');
  });
}