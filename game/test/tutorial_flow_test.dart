import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game/game/tutorial_config.dart';
import 'package:game/main.dart';

void main() {
  testWidgets('tutorial route advances through every onboarding step', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('tutorial')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('tutorial')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('tutorial-screen')), findsOneWidget);
    expect(find.text(kOnboardingTutorial.steps.first.title), findsOneWidget);

    for (var index = 1; index < kOnboardingTutorial.steps.length; index += 1) {
      await tester.tap(find.byKey(const ValueKey('tutorial-next')));
      await tester.pumpAndSettle();
      expect(find.text(kOnboardingTutorial.steps[index].title), findsOneWidget);
    }

    await tester.tap(find.byKey(const ValueKey('tutorial-next')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('core-fun-loop')), findsOneWidget);
  });
}
