import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:game/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Standard Smoke Test - App Launch and Stability', (WidgetTester tester) async {
    // Start the app
    try {
      app.main();
    } catch (e) {
      debugPrint('App main execution error: $e');
    }

    // Wait for the app to settle
    await tester.pump(const Duration(seconds: 5));

    // Basic verification
    expect(find.byType(MaterialApp), findsOneWidget);

    // Check for common UI layers
    expect(find.byType(Scaffold), findsWidgets);

    debugPrint('Smoke test completed successfully');
  });
}
