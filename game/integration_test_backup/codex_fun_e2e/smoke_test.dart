
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:game/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Roadmap Hub Smoke Test', (tester) async {
    try {
       app.main();
    } catch (e) {}
    
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.text('Roadmap Integration Active'), findsOneWidget);
    expect(find.text('MG-0012 STABILIZED'), findsOneWidget);
  });
}
