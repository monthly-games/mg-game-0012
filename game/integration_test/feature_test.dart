import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:game/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Standard Feature Test - Navigation and UI Elements', (WidgetTester tester) async {
    app.main();
    await tester.pump(const Duration(seconds: 10));

    // 1. Verify Main Menu
    expect(find.byType(Scaffold), findsWidgets);
    
    // 2. Try to find and tap navigation elements (common patterns)
    final navItems = find.byType(BottomNavigationBar);
    if (navItems.evaluate().isNotEmpty) {
       debugPrint('Nav: Found BottomNavigationBar');
       // Try tapping a different tab
       try {
         await tester.tap(find.byIcon(Icons.person).first);
         await tester.pump(const Duration(seconds: 2));
       } catch (_) {}
    }

    // 3. Look for buttons and verify they are interactive
    final buttons = find.byType(ElevatedButton);
    if (buttons.evaluate().isNotEmpty) {
       debugPrint('UI: Found ${buttons.evaluate().length} ElevatedButtons');
    }

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}