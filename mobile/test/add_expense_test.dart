import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pesoflow/app/app.dart';
import 'package:pesoflow/app/router.dart';
import 'package:pesoflow/features/dashboard/data/dashboard_fixture.dart';
import 'package:pesoflow/features/dashboard/domain/demo_dashboard_projection.dart';
import 'package:pesoflow/features/transactions/application/transactions_provider.dart';
import 'package:pesoflow/features/transactions/data/transaction_fixture.dart';
import 'package:pesoflow/features/transactions/domain/manual_transaction_draft.dart';
import 'package:pesoflow/features/transactions/domain/month_snapshot.dart';
import 'package:pesoflow/features/transactions/domain/transaction.dart';

import 'home_test.dart' show viewport;

Future<void> pumpAdd(
  WidgetTester tester, {
  ThemeMode theme = ThemeMode.light,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        routerProvider.overrideWith((ref) {
          final router = createRouter(initialLocation: '/add');
          ref.onDispose(router.dispose);
          return router;
        }),
      ],
      child: RepaintBoundary(
        key: const ValueKey('add-golden'),
        child: PesoFlowApp(themeMode: theme),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

ManualTransactionDraft draft({
  TransactionKind kind = TransactionKind.expense,
  String? destination,
  int amount = 32500,
}) => ManualTransactionDraft(
  amount: amount,
  merchant: 'Demo Lunch',
  account: 'GCash',
  destinationAccount: destination,
  occurredAt: demoClock,
  kind: kind,
  category: TransactionCategory.food,
  note: 'Lunch #Team',
);
void main() {
  test('PHP entry is exact and rejects malformed, negative, zero and over-precise amounts', () {
    expect(parsePhpAmount('0.01'), 1);
    expect(parsePhpAmount('325.1'), 32510);
    expect(parsePhpAmount('325.00'), 32500);
    expect(parsePhpAmount('999999999.99'), 99999999999);
    for (final input in [
      '',
      '0',
      '-1',
      '1.234',
      '1..2',
      '1,00',
      'NaN',
      '1000000000',
    ]) {
      expect(parsePhpAmount(input), isNull, reason: input);
    }
  });
  test('expense, income and transfer drafts preserve financial semantics', () {
    final expense = draft().toRecord('expense');
    expect(expense.expenseImpact, 32500);
    expect(expense.source, TransactionSource.manual);
    expect(expense.tags, ['Team']);
    final income = draft(kind: TransactionKind.income).toRecord('income');
    expect(income.expenseImpact, 0);
    expect(income.category, TransactionCategory.income);
    final transfer = draft(
      kind: TransactionKind.transfer,
      destination: 'Maya',
    ).toRecord('transfer');
    expect(transfer.destinationAccount, 'Maya');
    expect(transfer.merchant, 'GCash → Maya');
    expect(transfer.expenseImpact, 0);
    expect(transfer.cashFlowImpact, 0);
    expect(
      () => draft(
        kind: TransactionKind.transfer,
        destination: 'GCash',
      ).toRecord('bad'),
      throwsArgumentError,
    );
    expect(() => draft(amount: 0).toRecord('bad'), throwsArgumentError);
  });
  test(
    'session additions update snapshots once and preserve reported balances',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final baseline = transactionFixture();
      final notifier = container.read(demoLedgerProvider.notifier);
      notifier.createManual(draft());
      notifier.createManual(
        draft(kind: TransactionKind.transfer, destination: 'Maya'),
      );
      final ledger = container.read(demoLedgerProvider);
      expect(ledger.map((t) => t.id).toSet().length, ledger.length);
      final snapshot = MonthSnapshot.fromLedger(
        ledger,
        2024,
        10,
        baseline: baseline,
      );
      expect(snapshot.spent, 1712500);
      expect(snapshot.income, 4500000);
      final home = projectDemoLedger(homeFixture(), ledger, baseline);
      expect(home.outflow, snapshot.spent);
      expect(home.savings, snapshot.netFlow);
      expect(home.balance, 3065000);
      expect(home.budgets.first.spent, 722500);
      expect(home.transactionCount, 40);
      expect(() => notifier.add(ledger.first), throwsArgumentError);
    },
  );
  for (final theme in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('Add Expense ${theme.name} golden', (tester) async {
      viewport(tester, const Size(390, 1600));
      await pumpAdd(tester, theme: theme);
      expect(tester.takeException(), isNull);
      expect(find.byKey(const ValueKey('nav-Home')), findsNothing);
      await expectLater(
        find.byKey(const ValueKey('add-golden')),
        matchesGoldenFile('goldens/add_${theme.name}_390x1600.png'),
      );
    });
  }
  testWidgets('quick amounts and merchants, reset and validation work', (
    tester,
  ) async {
    viewport(tester, const Size(390, 844));
    await pumpAdd(tester);
    await tester.tap(find.text('+₱50'));
    await tester.pumpAndSettle();
    expect(find.text('Save Expense — ₱375.00'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Grab'),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Grab'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TextFormField>(find.byKey(const ValueKey('merchant-input')))
          .controller!
          .text,
      'Grab',
    );
    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save Expense — ₱0.00'));
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(
      tester.element(find.byType(PesoFlowApp)),
    );
    expect(container.read(demoLedgerProvider).length, 9);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('amount-input')),
      -200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(
      find.text('Enter a positive PHP amount with up to 2 decimals.'),
      findsOneWidget,
    );
  });
  testWidgets(
    'saving a valid expense adds one record and navigates to the feed',
    (tester) async {
      viewport(tester, const Size(390, 844));
      await pumpAdd(tester);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(PesoFlowApp)),
      );
      await tester.tap(find.text('Save Expense — ₱325.00'));
      await tester.pumpAndSettle();
      expect(container.read(demoLedgerProvider).length, 10);
      expect(container.read(demoLedgerProvider).first.amount, 32500);
      expect(find.text('October 2024'), findsOneWidget);
      expect(find.text('Expense saved in this demo session.'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('nav-Home')));
      await tester.pumpAndSettle();
      expect(find.text('-₱17.1k'), findsOneWidget);
    },
  );
  testWidgets('income and transfer save with their distinct categories', (
    tester,
  ) async {
    viewport(tester, const Size(390, 844));
    await pumpAdd(tester);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(PesoFlowApp)),
    );
    await tester.tap(find.text('Income'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save Income — ₱325.00'));
    await tester.pumpAndSettle();
    expect(
      container.read(demoLedgerProvider).first.kind,
      TransactionKind.income,
    );
    await tester.tap(find.byKey(const ValueKey('nav-Add')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Transfer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save Transfer — ₱325.00'));
    await tester.pumpAndSettle();
    expect(container.read(demoLedgerProvider).first.destinationAccount, 'Maya');
    expect(container.read(demoLedgerProvider).first.expenseImpact, 0);
  });
  testWidgets('Add Expense supports 320px and enlarged text', (tester) async {
    viewport(tester, const Size(320, 844));
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpAdd(tester);
    await tester.scrollUntilVisible(
      find.text('Scan'),
      350,
      scrollable: find.byType(Scrollable).first,
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets('the save action stays above keyboard and device insets', (
    tester,
  ) async {
    viewport(tester, const Size(390, 844));
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    tester.view.padding = const FakeViewPadding(top: 44, bottom: 34);
    addTearDown(tester.view.resetViewInsets);
    addTearDown(tester.view.resetPadding);
    await pumpAdd(tester);
    final save = find.widgetWithText(FilledButton, 'Save Expense — ₱325.00');
    expect(save.hitTestable(), findsOneWidget);
    expect(tester.getBottomRight(save).dy, lessThanOrEqualTo(544));
    expect(tester.takeException(), isNull);
  });
  testWidgets('offscreen invalid fields cannot bypass draft validation', (
    tester,
  ) async {
    viewport(tester, const Size(390, 844));
    await pumpAdd(tester);
    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Scan'),
      350,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Save Expense — ₱0.00'));
    await tester.pumpAndSettle();
    expect(
      find.text('Enter a positive PHP amount and a merchant or payer.'),
      findsOneWidget,
    );
    final container = ProviderScope.containerOf(
      tester.element(find.byType(PesoFlowApp)),
    );
    expect(container.read(demoLedgerProvider).length, 9);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'account switching preserves provenance and rejects a same-account transfer',
    (tester) async {
      viewport(tester, const Size(390, 844));
      await pumpAdd(tester);
      await tester.tap(find.text('Transfer'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Switch'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Switch'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, 'Maya Wallet'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save Transfer — ₱325.00'));
      await tester.pumpAndSettle();
      expect(
        find.text('Choose two different transfer accounts.'),
        findsOneWidget,
      );
      final container = ProviderScope.containerOf(
        tester.element(find.byType(PesoFlowApp)),
      );
      expect(container.read(demoLedgerProvider).length, 9);
    },
  );
}
