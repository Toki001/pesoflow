import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pesoflow/app/app.dart';
import 'package:pesoflow/app/router.dart';
import 'package:pesoflow/features/analytics/application/analytics_provider.dart';
import 'package:pesoflow/features/analytics/data/analytics_fixture.dart';
import 'package:pesoflow/features/analytics/domain/analytics_report.dart';
import 'package:pesoflow/features/analytics/domain/project_analytics.dart';
import 'package:pesoflow/features/budgets/data/budget_fixture.dart';
import 'package:pesoflow/features/budgets/application/budgets_provider.dart';
import 'package:pesoflow/features/transactions/application/transactions_provider.dart';
import 'package:pesoflow/features/transactions/data/transaction_fixture.dart';
import 'package:pesoflow/features/transactions/domain/transaction.dart';

import 'home_test.dart' show viewport;

AnalyticsReport fixtureReport() => projectAnalytics(
  AnalyticsSelection(demoClock),
  transactionFixture(),
  transactionFixture(),
  {'2024-10': budgetFixture()},
  analyticsFixture(),
);
Future<void> pumpAnalytics(
  WidgetTester tester, {
  ThemeMode theme = ThemeMode.light,
  Future<AnalyticsReport> Function()? load,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        routerProvider.overrideWith((ref) {
          final router = createRouter(initialLocation: '/analytics');
          ref.onDispose(router.dispose);
          return router;
        }),
        if (load != null) analyticsProvider.overrideWith((ref) => load()),
      ],
      child: RepaintBoundary(
        key: const ValueKey('analytics-golden'),
        child: PesoFlowApp(themeMode: theme),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  for (final theme in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('Analytics ${theme.name} full-page golden', (tester) async {
      viewport(tester, const Size(384, 1600));
      await pumpAnalytics(tester, theme: theme);
      expect(find.text('Daily average:'), findsOneWidget);
      expect(find.text('₱541.93 / day'), findsOneWidget);
      expect(find.text('₱5,200.00'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byKey(const ValueKey('analytics-golden')),
        matchesGoldenFile('goldens/analytics_${theme.name}_384x1600.png'),
      );
    });
  }
  testWidgets('periods and category toggle preserve tab state', (tester) async {
    viewport(tester, const Size(390, 844));
    await pumpAnalytics(tester);
    await tester.tap(find.text('Day'));
    await tester.pumpAndSettle();
    expect(find.text('₱535.00 / day'), findsOneWidget);
    await tester.tap(find.text('Week'));
    await tester.pumpAndSettle();
    expect(find.text('₱102.14 / day'), findsOneWidget);
    await tester.tap(find.text('Year'));
    await tester.pumpAndSettle();
    expect(find.text('₱45.90 / day'), findsOneWidget);
    await tester.tap(find.text('Month'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('%'));
    await tester.tap(find.text('%'));
    await tester.pumpAndSettle();
    expect(find.text('₱5,200.00'), findsNothing);
    expect(find.text('31.0%'), findsNWidgets(2));
    await tester.tap(find.byKey(const ValueKey('nav-Home')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('nav-Analytics')));
    await tester.pumpAndSettle();
    expect(find.text('31.0%'), findsNWidgets(2));
    await tester.tap(find.text('Amount'));
    await tester.pumpAndSettle();
    expect(find.text('₱5,200.00'), findsOneWidget);
  });
  testWidgets('calendar selects a different month and empty state recovers', (
    tester,
  ) async {
    viewport(tester, const Size(390, 844));
    await pumpAnalytics(tester);
    await tester.tap(find.byTooltip('Calendar History'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Next month'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1').last);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('November 2024'), findsOneWidget);
    expect(find.text('No spending in this period'), findsOneWidget);
    await tester.tap(find.text('View October demo'));
    await tester.pumpAndSettle();
    expect(find.text('Spending Trajectory'), findsOneWidget);
  });
  testWidgets('session expenses update analytics without budget exclusion', (
    tester,
  ) async {
    viewport(tester, const Size(384, 1600));
    await pumpAnalytics(tester);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(PesoFlowApp)),
    );
    container
        .read(demoLedgerProvider.notifier)
        .add(
          TransactionRecord(
            id: 'new-demo',
            merchant: 'Jollibee',
            metadata: '',
            amount: 10000,
            occurredAt: demoClock,
            kind: TransactionKind.expense,
            category: TransactionCategory.food,
            excludedFromBudget: true,
          ),
        );
    await tester.pumpAndSettle();
    expect(find.text('₱5,300.00'), findsOneWidget);
    expect(find.text('₱1,075.00'), findsOneWidget);
    expect(find.textContaining('decreased by ₱1,200'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('chart details and summary disclose demo limits', (tester) async {
    viewport(tester, const Size(390, 844));
    await pumpAnalytics(tester);
    await tester.tap(find.bySemanticsLabel(RegExp('Spending chart.*')));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('illustrative October trajectory'),
      findsOneWidget,
    );
    expect(find.text('Oct 24, 2024'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Share Analytics'));
    await tester.pumpAndSettle();
    expect(find.text('Analytics summary'), findsOneWidget);
    expect(
      find.textContaining('system sharing are not available'),
      findsOneWidget,
    );
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Notifications'));
    await tester.pumpAndSettle();
    expect(find.text('Demo notifications'), findsOneWidget);
  });
  testWidgets('loading, safe errors and retry preserve shell', (tester) async {
    final pending = Completer<AnalyticsReport>();
    await pumpAnalytics(tester, load: () => pending.future);
    expect(find.bySemanticsLabel('Loading analytics'), findsOneWidget);
    pending.complete(fixtureReport());
    await tester.pumpAndSettle();
    expect(find.text('Spending Trajectory'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    var calls = 0;
    await pumpAnalytics(
      tester,
      load: () async {
        if (calls++ == 0) throw Exception('private financial payload');
        return fixtureReport();
      },
    );
    expect(find.text("We couldn't load your analytics."), findsOneWidget);
    expect(find.textContaining('private financial'), findsNothing);
    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();
    expect(find.text('Spending Trajectory'), findsOneWidget);
  });
  for (final size in [
    const Size(320, 844),
    const Size(430, 932),
    const Size(844, 390),
  ]) {
    testWidgets('Analytics scrolls without overflow at $size', (tester) async {
      viewport(tester, size);
      await pumpAnalytics(tester);
      await tester.ensureVisible(find.text('Meralco Electric'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(
        find.byKey(const ValueKey('nav-Add')).hitTestable(),
        findsOneWidget,
      );
    });
  }
  testWidgets('200 percent text and safe insets remain usable', (tester) async {
    viewport(tester, const Size(320, 844));
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    tester.view.padding = const FakeViewPadding(top: 44, bottom: 34);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    addTearDown(tester.view.resetPadding);
    await pumpAnalytics(tester);
    await tester.ensureVisible(find.text('Meralco Electric'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(
      find.bySemanticsLabel(RegExp('Spending chart.*')),
    );
    await tester.tap(find.bySemanticsLabel(RegExp('Spending chart.*')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Close'));
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Day'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'shared budget edits update category and monthly target context',
    (tester) async {
      viewport(tester, const Size(384, 1600));
      await pumpAnalytics(tester);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(PesoFlowApp)),
      );
      final controller = container.read(demoBudgetPlansProvider.notifier);
      controller.setLimit(2024, 10, null, 3000000);
      controller.setLimit(2024, 10, TransactionCategory.food, 900000);
      await tester.pumpAndSettle();
      expect(find.text('₱9,000 target'), findsOneWidget);
      expect(
        find.textContaining('27% below your monthly target'),
        findsOneWidget,
      );
      expect(find.text('₱5,200.00'), findsOneWidget);
    },
  );
  testWidgets(
    'refund-only periods show signed amounts and no false purchases',
    (tester) async {
      viewport(tester, const Size(384, 1600));
      await pumpAnalytics(tester);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(PesoFlowApp)),
      );
      container
          .read(demoLedgerProvider.notifier)
          .add(
            TransactionRecord(
              id: 'refund-demo',
              merchant: 'Jollibee',
              metadata: '',
              amount: 10000,
              occurredAt: DateTime(2025, 2, 3),
              kind: TransactionKind.refund,
              category: TransactionCategory.food,
            ),
          );
      container
          .read(analyticsSelectionProvider.notifier)
          .selectDate(DateTime(2025, 2, 3));
      await tester.pumpAndSettle();
      expect(find.text('Net refunds vs Jan'), findsOneWidget);
      expect(find.text('-₱100.00'), findsNWidgets(2));
      expect(
        find.text('No positive merchant spending in this period.'),
        findsOneWidget,
      );
      expect(find.text('No spending in this period'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
