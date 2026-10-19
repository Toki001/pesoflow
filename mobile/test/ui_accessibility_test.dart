import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fixtures/stitch_v7_fixture.dart';
import 'production_app_test.dart' as app;

void main() {
  for (final route in [
    '/home',
    '/transactions',
    '/accounts',
    '/budgets',
    '/analytics',
    '/add',
    '/add?kind=income',
    '/settings',
    '/notifications',
    '/subscriptions',
    '/receipt',
    '/transactions/jollibee',
  ]) {
    testWidgets('$route has labeled accessible touch targets', (tester) async {
      app.viewport(tester, const Size(390, 844));
      final semantics = tester.ensureSemantics();
      try {
        await app.pumpApp(tester, route: route, workspace: stitchV7Fixture());
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      } finally {
        semantics.dispose();
      }
    });
  }
  testWidgets('appearance options remain reachable in large-text landscape', (
    tester,
  ) async {
    app.viewport(tester, const Size(844, 390));
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await app.pumpApp(tester, route: '/settings');
    await tester.ensureVisible(find.text('Appearance'));
    await tester.tap(find.text('Appearance'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('appearance-dark')),
      100,
      scrollable: find.descendant(
        of: find.byType(ListView).last,
        matching: find.byType(Scrollable),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('appearance-dark')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('appearance-dark')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('appearance-dark')), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
