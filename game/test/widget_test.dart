import 'package:flutter_test/flutter_test.dart';
import 'package:game/main.dart';

void main() {
  testWidgets('app boots to the main menu', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.textContaining('MG-'), findsWidgets);
    expect(find.text('Start Game'), findsOneWidget);
  });
}
