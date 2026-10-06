import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pesoflow/app/app.dart';
import 'package:pesoflow/app/router.dart';
import 'package:pesoflow/features/transactions/data/transaction_fixture.dart';
import 'package:pesoflow/features/transactions/domain/transaction.dart';
import 'package:pesoflow/features/transactions/domain/transaction_query.dart';

import 'home_test.dart' show viewport;

Future<void> pumpTransactions(
  WidgetTester tester, {
  ThemeMode theme = ThemeMode.light,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        routerProvider.overrideWith((ref) {
          final router = createRouter(initialLocation: '/transactions');
          ref.onDispose(router.dispose);
          return router;
        }),
      ],
      child: RepaintBoundary(
        key: const ValueKey('transactions-golden'),
        child: PesoFlowApp(themeMode: theme),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  test(
    'search, month and account filters combine; records sort newest first',
    () {
      final records = transactionFixture();
      expect(
        filterTransactions(
          records,
          const TransactionQuery(search: '325'),
        ).single.id,
        'jollibee',
      );
      expect(
        filterTransactions(
          records,
          const TransactionQuery(search: 'chickenjoy'),
        ).single.id,
        'jollibee',
      );
      expect(
        filterTransactions(records, const TransactionQuery(month: 9)),
        isEmpty,
      );
      expect(
        filterTransactions(
          records,
          const TransactionQuery(
            account: 'Maya',
            filter: TransactionFilter.expenses,
          ),
        ).single.id,
        'grab',
      );
      expect(
        filterTransactions(
          records,
          const TransactionQuery(filter: TransactionFilter.pending),
        ).single.id,
        'starbucks',
      );
      expect(
        filterTransactions(records, const TransactionQuery()).first.id,
        'jollibee',
      );
      expect(groupTransactions(records).length, 4);
    },
  );
  test('internal transfers and pending expenses do not inflate cash flow', () {
    final records = transactionFixture();
    final yesterday = records.where((t) => t.occurredAt.day == 23);
    expect(yesterday.fold(0, (sum, t) => sum + t.cashFlowImpact), -18000);
    expect(records.firstWhere((t) => t.id == 'starbucks').expenseImpact, 0);
    final refund = records.firstWhere((t) => t.id == 'refund');
    expect(refund.expenseImpact, -45000);
    expect(refund.cashFlowImpact, 45000);
    expect(TransactionRecord.fromJson(refund.toJson()), refund);
  });
  for (final theme in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('Transactions ${theme.name} golden', (tester) async {
      viewport(tester, const Size(420, 1300));
      await pumpTransactions(tester, theme: theme);
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byKey(const ValueKey('transactions-golden')),
        matchesGoldenFile('goldens/transactions_${theme.name}_420x1300.png'),
      );
    });
  }
  testWidgets('search and reset, month navigation, and pending filter work', (
    tester,
  ) async {
    viewport(tester, const Size(390, 844));
    await pumpTransactions(tester);
    await tester.enterText(find.byType(TextField), 'no such merchant');
    await tester.pumpAndSettle();
    expect(find.text('No transactions found'), findsOneWidget);
    await tester.tap(find.text('Reset filters'));
    await tester.pumpAndSettle();
    expect(find.text('Jollibee'), findsOneWidget);
    await tester.tap(find.byTooltip('Previous month'));
    await tester.pumpAndSettle();
    expect(find.text('September 2024'), findsOneWidget);
    expect(find.text('No transactions found'), findsOneWidget);
    await tester.tap(find.byTooltip('Next month'));
    await tester.pumpAndSettle();
    await tester.drag(find.text('Transfers'), const Offset(-180, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pending'));
    await tester.pumpAndSettle();
    expect(find.text('Starbucks Reserve'), findsOneWidget);
    expect(find.text('Jollibee'), findsNothing);
  });
  testWidgets('account and category selections filter the demo ledger', (
    tester,
  ) async {
    viewport(tester, const Size(420, 1300));
    await pumpTransactions(tester);
    await tester.drag(find.text('Transfers'), const Offset(-500, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Accounts (GCash, BDO, Maya)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Maya'));
    await tester.pumpAndSettle();
    expect(find.text('Jollibee'), findsNothing);
    expect(find.text('Grab Car'), findsOneWidget);
    expect(find.text('Shopee Refund'), findsOneWidget);
    await tester.tap(find.text('Categories'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Refund'));
    await tester.pumpAndSettle();
    expect(find.text('Grab Car'), findsNothing);
    expect(find.text('Shopee Refund'), findsOneWidget);
  });
  testWidgets('Transactions supports narrow screens and enlarged text', (
    tester,
  ) async {
    viewport(tester, const Size(320, 844));
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpTransactions(tester);
    await tester.scrollUntilVisible(
      find.text('Netflix Subscription'),
      350,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
