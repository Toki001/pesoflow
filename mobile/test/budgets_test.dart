import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pesoflow/app/app.dart';
import 'package:pesoflow/app/router.dart';
import 'package:pesoflow/features/budgets/application/budgets_provider.dart';
import 'package:pesoflow/features/budgets/data/budget_fixture.dart';
import 'package:pesoflow/features/budgets/domain/budget_plan.dart';
import 'package:pesoflow/features/transactions/domain/transaction.dart';

import 'home_test.dart' show viewport;

Future<void> pumpBudgets(
  WidgetTester tester, {
  ThemeMode theme = ThemeMode.light,
  Future<BudgetPlan> Function()? load,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        routerProvider.overrideWith((ref) {
          final router = createRouter(initialLocation: '/budgets');
          ref.onDispose(router.dispose);
          return router;
        }),
        if (load != null) budgetsProvider.overrideWith((ref) => load()),
      ],
      child: RepaintBoundary(
        key: const ValueKey('budgets-golden'),
        child: PesoFlowApp(themeMode: theme),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('edited limits appear in manual entry and transaction detail', (
    tester,
  ) async {
    viewport(tester, const Size(390, 844));
    await pumpBudgets(tester);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(PesoFlowApp)),
    );
    container
        .read(demoBudgetPlansProvider.notifier)
        .setLimit(2024, 10, TransactionCategory.food, 900000);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('nav-Add')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('₱6,900 / ₱9,000'));
    expect(find.text('₱6,900 / ₱9,000'), findsOneWidget);
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    unawaited(
      container.read(routerProvider).push<void>('/transactions/jollibee'),
    );
    await tester.pumpAndSettle();
    expect(find.text('₱6,900 / ₱9,000 limit'), findsOneWidget);
    expect(find.text('₱2,100 remaining'), findsOneWidget);
  });
  testWidgets('an empty risk filter offers a way back to all allowances', (
    tester,
  ) async {
    viewport(tester, const Size(390, 844));
    await pumpBudgets(tester);
    final controller = ProviderScope.containerOf(
      tester.element(find.byType(PesoFlowApp)),
    ).read(demoBudgetPlansProvider.notifier);
    controller.setLimit(2024, 10, null, 3000000);
    controller.setLimit(2024, 10, TransactionCategory.food, 1000000);
    controller.setLimit(2024, 10, TransactionCategory.transport, 400000);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('At Risk  0'));
    await tester.tap(find.text('At Risk  0'));
    await tester.pumpAndSettle();
    expect(find.text('No budgets in this filter'), findsOneWidget);
    await tester.tap(find.text('Show all budgets'));
    await tester.pumpAndSettle();
    expect(find.text('Food & Dining'), findsOneWidget);
  });
  testWidgets('a first category budget initializes an empty month', (
    tester,
  ) async {
    viewport(tester, const Size(390, 844));
    await pumpBudgets(tester);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(PesoFlowApp)),
    );
    container.read(budgetPeriodProvider.notifier).select(DateTime(2024, 11));
    await tester.pumpAndSettle();
    await tester.tap(find.text('New budget'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('budget-category')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Food & Dining').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('budget-limit-input')),
      '2000',
    );
    await tester.tap(find.text('Save budget'));
    await tester.pumpAndSettle();
    final plan = container.read(demoBudgetPlansProvider)['2024-11']!;
    expect(plan.monthlyLimit, 200000);
    expect(plan.allowances.single.category, TransactionCategory.food);
    expect(find.text('Create your first budget'), findsNothing);
    expect(find.text('Not available yet'), findsOneWidget);
  });
  for (final theme in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('Budgets ${theme.name} full-page golden', (tester) async {
      viewport(tester, const Size(390, 1932));
      await pumpBudgets(tester, theme: theme);
      expect(
        find.text('₱1,171.42 / day safe pace for next 7 days'),
        findsOneWidget,
      );
      expect(find.text('Within limit'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byKey(const ValueKey('budgets-golden')),
        matchesGoldenFile('goldens/budgets_${theme.name}_390x1932.png'),
      );
    });
  }
  testWidgets(
    'risk filters, sorting and dismissed suggestions preserve tab state',
    (tester) async {
      viewport(tester, const Size(390, 844));
      await pumpBudgets(tester);
      await tester.ensureVisible(find.text('At Risk  2'));
      await tester.tap(find.text('At Risk  2'));
      await tester.pumpAndSettle();
      expect(find.text('Food & Dining'), findsOneWidget);
      expect(find.text('Transport'), findsOneWidget);
      expect(find.text('Shopping'), findsNothing);
      await tester.tap(find.text('On Track  4'));
      await tester.pumpAndSettle();
      expect(find.text('Shopping'), findsOneWidget);
      expect(find.text('Food & Dining'), findsNothing);
      await tester.tap(find.text('Sort'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Most used first'));
      await tester.pumpAndSettle();
      expect(
        tester.getTopLeft(find.text('Subscriptions')).dy,
        lessThan(tester.getTopLeft(find.text('Shopping')).dy),
      );
      await tester.ensureVisible(find.text('Dismiss'));
      await tester.tap(find.text('Dismiss'));
      await tester.pumpAndSettle();
      expect(find.text('Adjust Budgets'), findsNothing);
      await tester.tap(find.byKey(const ValueKey('nav-Home')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('nav-Budgets')));
      await tester.pumpAndSettle();
      expect(find.text('Adjust Budgets'), findsNothing);
      expect(find.text('On Track  4'), findsOneWidget);
    },
  );
  testWidgets(
    'adjustment requires explicit apply and updates allowance limits',
    (tester) async {
      viewport(tester, const Size(390, 844));
      await pumpBudgets(tester);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(PesoFlowApp)),
      );
      await tester.ensureVisible(find.text('Adjust Budgets'));
      await tester.tap(find.text('Adjust Budgets'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(
        container
            .read(demoBudgetPlansProvider)['2024-10']!
            .allowances
            .first
            .limit,
        800000,
      );
      await tester.tap(find.text('Adjust Budgets'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apply adjustment'));
      await tester.pumpAndSettle();
      final plan = container.read(demoBudgetPlansProvider)['2024-10']!;
      expect(plan.allowances.first.limit, 850000);
      expect(plan.allowances.last.limit, 150000);
      expect(find.text('Adjust Budgets'), findsNothing);
    },
  );
  testWidgets('edit validates allowances and saves the new category limit', (
    tester,
  ) async {
    viewport(tester, const Size(390, 844));
    await pumpBudgets(tester);
    await tester.ensureVisible(find.text('Food & Dining'));
    await tester.tap(find.text('Food & Dining'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('budget-limit-input')),
      '20000',
    );
    await tester.tap(find.text('Save budget'));
    await tester.pumpAndSettle();
    expect(
      find.text('Category allowances exceed the monthly limit.'),
      findsOneWidget,
    );
    await tester.enterText(
      find.byKey(const ValueKey('budget-limit-input')),
      '9000',
    );
    await tester.tap(find.text('Save budget'));
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(
      tester.element(find.byType(PesoFlowApp)),
    );
    expect(
      container
          .read(demoBudgetPlansProvider)['2024-10']!
          .allowances
          .first
          .limit,
      900000,
    );
  });
  testWidgets(
    'new budget uses approved sheet fields and attaches known spending',
    (tester) async {
      viewport(tester, const Size(390, 844));
      await pumpBudgets(tester);
      await tester.tap(find.text('New'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('budget-category')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Groceries').last);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('budget-limit-input')),
        '3400',
      );
      await tester.tap(find.text('Save budget'));
      await tester.pumpAndSettle();
      final container = ProviderScope.containerOf(
        tester.element(find.byType(PesoFlowApp)),
      );
      expect(
        container
            .read(demoBudgetPlansProvider)['2024-10']!
            .allowances
            .last
            .category,
        TransactionCategory.groceries,
      );
      expect(find.text('7 categorized allowances tracked'), findsOneWidget);
    },
  );
  testWidgets('month picker shows the empty state for an unconfigured period', (
    tester,
  ) async {
    viewport(tester, const Size(390, 844));
    await pumpBudgets(tester);
    await tester.tap(find.text('October 2024 ⌄'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Next month'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1').last);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('November 2024 ⌄'), findsOneWidget);
    expect(find.text('Create your first budget'), findsOneWidget);
  });
  testWidgets('loading and recoverable errors expose no internal messages', (
    tester,
  ) async {
    final pending = Completer<BudgetPlan>();
    await pumpBudgets(tester, load: () => pending.future);
    expect(find.bySemanticsLabel('Loading budgets'), findsOneWidget);
    pending.complete(budgetFixture());
    await tester.pumpAndSettle();
    expect(find.text('Within limit'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    var calls = 0;
    await pumpBudgets(
      tester,
      load: () async {
        if (calls++ == 0) throw Exception('private internal failure');
        return budgetFixture();
      },
    );
    expect(find.text("We couldn't load your budgets."), findsOneWidget);
    expect(find.textContaining('private internal'), findsNothing);
    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();
    expect(find.text('Within limit'), findsOneWidget);
  });
  for (final size in [
    const Size(320, 844),
    const Size(430, 932),
    const Size(844, 390),
  ]) {
    testWidgets('Budgets scrolls at $size', (tester) async {
      viewport(tester, size);
      await pumpBudgets(tester);
      await tester.ensureVisible(find.text('Entertainment & Leisure'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(
        find.byKey(const ValueKey('nav-Add')).hitTestable(),
        findsOneWidget,
      );
    });
  }
  testWidgets(
    'Budgets and editor support 200 percent text, safe insets and keyboard',
    (tester) async {
      viewport(tester, const Size(320, 844));
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      tester.view.padding = const FakeViewPadding(top: 44, bottom: 34);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      addTearDown(tester.view.resetPadding);
      await pumpBudgets(tester);
      await tester.ensureVisible(find.text('Entertainment & Leisure'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('New'));
      await tester.pumpAndSettle();
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Save budget'));
      expect(tester.takeException(), isNull);
    },
  );
}
