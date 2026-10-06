import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pesoflow/app/app.dart';
import 'package:pesoflow/app/router.dart';
import 'package:pesoflow/features/transactions/application/transactions_provider.dart';
import 'package:pesoflow/features/transactions/data/transaction_fixture.dart';
import 'package:pesoflow/features/transactions/domain/month_snapshot.dart';

import 'home_test.dart' show viewport;
import 'transactions_test.dart' show pumpTransactions;

Future<void> pumpDetail(
  WidgetTester tester, {
  ThemeMode theme = ThemeMode.light,
  String id = 'jollibee',
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        routerProvider.overrideWith((ref) {
          final router = createRouter(initialLocation: '/transactions/$id');
          ref.onDispose(router.dispose);
          return router;
        }),
      ],
      child: RepaintBoundary(
        key: const ValueKey('detail-golden'),
        child: PesoFlowApp(themeMode: theme),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  for (final theme in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('Detail ${theme.name} full page golden', (tester) async {
      viewport(tester, const Size(390, 1447));
      await pumpDetail(tester, theme: theme);
      expect(find.byKey(const ValueKey('nav-Home')), findsNothing);
      expect(find.text('Jollibee Megamall Branch'), findsOneWidget);
      await expectLater(
        find.byKey(const ValueKey('detail-golden')),
        matchesGoldenFile('goldens/detail_${theme.name}_390x1447.png'),
      );
    });
  }
  testWidgets('row opens detail and Close preserves transaction search', (
    tester,
  ) async {
    viewport(tester, const Size(390, 844));
    await pumpTransactions(tester);
    await tester.enterText(find.byType(TextField), 'Jollibee');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Jollibee').last);
    await tester.pumpAndSettle();
    expect(find.text('Jollibee Megamall Branch'), findsOneWidget);
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Jollibee'), findsWidgets);
    expect(find.text('Grab Car'), findsNothing);
  });
  testWidgets(
    'notes, category, tags and budget exclusion update session data',
    (tester) async {
      viewport(tester, const Size(390, 1447));
      await pumpDetail(tester);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(PesoFlowApp)),
      );
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('detail-input')),
        'Lunch reviewed',
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 300));
      expect(container.read(demoLedgerProvider).first.note, 'Lunch reviewed');
      await tester.tap(find.text('+ New Tag'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('detail-input')),
        'Reviewed',
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('#Reviewed'), findsOneWidget);
      await tester.ensureVisible(find.text('Exclude from Budget'));
      await tester.tap(find.text('Exclude from Budget'));
      await tester.pumpAndSettle();
      final updated = container.read(demoLedgerProvider).first;
      expect(updated.budgetImpact, 0);
      expect(updated.expenseImpact, 32500);
      expect(updated.cashFlowImpact, -32500);
      expect(
        MonthSnapshot.fromLedger(
          container.read(demoLedgerProvider),
          2024,
          10,
          baseline: transactionFixture(),
        ).spent,
        1680000,
      );
      await tester.scrollUntilVisible(find.text('Food & Dining ⌄'), -400);
      await tester.tap(find.text('Food & Dining ⌄'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, 'Shopping'));
      await tester.pumpAndSettle();
      expect(
        container.read(demoLedgerProvider).first.category.name,
        'shopping',
      );
    },
  );
  testWidgets('unknown transaction has an explicit missing state', (
    tester,
  ) async {
    await pumpDetail(tester, id: 'unknown');
    expect(find.text('Transaction not found'), findsOneWidget);
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(find.text('October 2024'), findsOneWidget);
  });
  testWidgets('detail scrolls at 320px and 200 percent text', (tester) async {
    viewport(tester, const Size(320, 844));
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpDetail(tester);
    await tester.scrollUntilVisible(find.text('Report Issue'), 350);
    expect(tester.takeException(), isNull);
  });
}
