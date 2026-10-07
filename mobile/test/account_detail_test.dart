import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pesoflow/app/app.dart';
import 'package:pesoflow/app/router.dart';
import 'package:pesoflow/features/accounts/application/account_detail_provider.dart';
import 'package:pesoflow/features/accounts/application/accounts_provider.dart';
import 'package:pesoflow/features/accounts/domain/account_activity.dart';
import 'package:pesoflow/features/accounts/data/account_fixture.dart';
import 'package:pesoflow/features/accounts/domain/demo_account.dart';
import 'package:pesoflow/features/transactions/application/transactions_provider.dart';
import 'package:pesoflow/features/transactions/data/transaction_fixture.dart';
import 'package:pesoflow/features/transactions/domain/transaction.dart';

import 'accounts_domain_test.dart' show AccountsTestRepository;
import 'accounts_test.dart' show pumpAccounts;
import 'home_test.dart' show viewport;

Future<ProviderContainer> pumpDetail(
  WidgetTester tester, {
  String id = 'gcash',
  ThemeMode theme = ThemeMode.light,
  DemoAccountsRepository? repository,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        routerProvider.overrideWith((ref) {
          final router = createRouter(initialLocation: '/accounts/$id');
          ref.onDispose(router.dispose);
          return router;
        }),
        if (repository != null)
          accountsRepositoryProvider.overrideWithValue(repository),
      ],
      child: RepaintBoundary(
        key: const ValueKey('account-detail-golden'),
        child: PesoFlowApp(themeMode: theme),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return ProviderScope.containerOf(tester.element(find.byType(PesoFlowApp)));
}

void main() {
  test('explicit account IDs exclude unrelated bank products and include both transfer sides once', () {
    final fixture = transactionFixture();
    expect(accountActivity('bdo', fixture).map((t) => t.id), ['salary']);
    expect(accountActivity('maya', fixture).map((t) => t.id), [
      'grab',
      'refund',
    ]);
    expect(accountActivity('gcash', fixture).map((t) => t.id), [
      'jollibee',
      'transfer',
      'seven-eleven',
      'netflix',
    ]);
    expect(accountActivity('bpi', fixture), isEmpty);
    expect(accountActivity('unknown', fixture), isEmpty);
    final transfer = fixture
        .firstWhere((t) => t.kind == TransactionKind.transfer)
        .copyWith(accountId: 'gcash', destinationAccountId: 'gcash');
    final activity = accountActivity('gcash', [transfer]);
    expect(activity, hasLength(1));
    expect(activity.single.expenseImpact, 0);
    expect(() => activity.clear(), throwsUnsupportedError);
  });

  test('detail reacts to ledger edits and account removal without changing reported balances', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(accountsProvider.future);
    final sub = container.listen(accountDetailProvider('gcash'), (_, _) {});
    addTearDown(sub.close);
    final before = container.read(accountDetailProvider('gcash')).value!;
    expect(before.account.balance, 425000);
    expect(() => before.activity.clear(), throwsUnsupportedError);
    final tx = transactionFixture().first.copyWith(
      id: 'manual-test',
      amount: 15000,
      source: TransactionSource.manual,
    );
    container.read(demoLedgerProvider.notifier).add(tx);
    expect(
      container
          .read(accountDetailProvider('gcash'))
          .value!
          .activity
          .map((t) => t.id),
      contains('manual-test'),
    );
    expect(
      container.read(accountDetailProvider('gcash')).value!.account.balance,
      425000,
    );
    container.read(accountsProvider.notifier).disconnect('gcash');
    expect(container.read(accountDetailProvider('gcash')).value, isNull);
    expect(
      container.read(demoLedgerProvider).map((t) => t.id),
      contains('manual-test'),
    );
  });

  testWidgets(
    'account identity opens detail and Back preserves Accounts scroll',
    (tester) async {
      viewport(tester, const Size(390, 844));
      await pumpAccounts(tester);
      await tester.ensureVisible(
        find.byKey(const ValueKey('account-details-bpi')),
      );
      final y = tester.getTopLeft(find.text('BPI Savings')).dy;
      await tester.tap(find.byKey(const ValueKey('account-details-bpi')));
      await tester.pumpAndSettle();
      expect(find.text('Account Detail'), findsOneWidget);
      expect(find.text('Last-known sample balance'), findsOneWidget);
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.text('Connected Accounts'), findsOneWidget);
      expect(tester.getTopLeft(find.text('BPI Savings')).dy, y);
    },
  );

  testWidgets(
    'active detail shows masked provenance, neutral transfer and transaction drilldown',
    (tester) async {
      viewport(tester, const Size(390, 844));
      await pumpDetail(tester);
      expect(find.text('Sample available balance'), findsOneWidget);
      expect(find.text('0917 •••• 892'), findsOneWidget);
      expect(find.text('Oct 24, 2024 · 12:30 PM'), findsOneWidget);
      expect(find.textContaining('No provider permissions'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      await tester.ensureVisible(find.text('BDO Savings → GCash'));
      expect(find.text('₱5,000.00'), findsOneWidget);
      expect(find.text('-₱5,000.00'), findsNothing);
      await tester.ensureVisible(find.text('Jollibee'));
      await tester.tap(find.text('Jollibee'));
      await tester.pumpAndSettle();
      expect(find.text('Transaction Detail'), findsOneWidget);
      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();
      expect(find.text('Account Detail'), findsOneWidget);
    },
  );

  testWidgets('expired detail explains stale balance and cannot reconnect it', (
    tester,
  ) async {
    viewport(tester, const Size(390, 844));
    final container = await pumpDetail(tester, id: 'bpi');
    await tester.ensureVisible(find.text('About reconnection'));
    await tester.tap(find.text('About reconnection'));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.textContaining('Real reconnection is not available'),
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(container.read(accountsProvider).value!.availableBalance, 3450000);
    expect(
      container
          .read(accountDetailProvider('bpi'))
          .value!
          .account
          .needsReauthentication,
      isTrue,
    );
    await tester.ensureVisible(find.text('No related demo transactions'));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'local check supports pending/error/retry and preserves sample amount/timestamp',
    (tester) async {
      viewport(tester, const Size(390, 844));
      final pending = Completer<void>();
      var calls = 0;
      final container = await pumpDetail(
        tester,
        repository: AccountsTestRepository(
          refreshData: () => ++calls == 1 ? pending.future : Future.value(),
        ),
      );
      final before = container
          .read(accountDetailProvider('gcash'))
          .value!
          .account;
      await tester.ensureVisible(find.text('Check demo data'));
      await tester.tap(find.text('Check demo data'));
      await tester.pump();
      expect(find.text('Checking demo…'), findsOneWidget);
      pending.completeError(Exception('private provider secret'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining("We couldn't check the demo data."),
        findsOneWidget,
      );
      expect(find.textContaining('private provider'), findsNothing);
      await tester.tap(find.text('Check demo data'));
      await tester.pumpAndSettle();
      expect(
        find.text('Sample data checked. No live sync or balance changes.'),
        findsOneWidget,
      );
      final after = container
          .read(accountDetailProvider('gcash'))
          .value!
          .account;
      expect(after.balance, before.balance);
      expect(after.balanceAsOf, before.balanceAsOf);
    },
  );

  testWidgets('confirmed removal returns to Accounts and preserves history', (
    tester,
  ) async {
    viewport(tester, const Size(390, 844));
    final container = await pumpDetail(tester);
    final ledger = container.read(demoLedgerProvider);
    await tester.ensureVisible(find.text('Remove demo profile'));
    await tester.tap(find.text('Remove demo profile'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Account Detail'), findsOneWidget);
    await tester.tap(find.text('Remove demo profile'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Disconnect demo'));
    await tester.pumpAndSettle();
    expect(find.text('Connected Accounts'), findsOneWidget);
    expect(find.text('GCash Personal'), findsNothing);
    expect(container.read(demoLedgerProvider), same(ledger));
  });

  testWidgets(
    'unknown and removed profile links are safe and Back falls back to Accounts',
    (tester) async {
      viewport(tester, const Size(390, 844));
      await pumpDetail(tester, id: 'unknown');
      expect(find.text('Sample account unavailable'), findsOneWidget);
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.text('Connected Accounts'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      final container = await pumpDetail(tester);
      container.read(accountsProvider.notifier).disconnect('gcash');
      await tester.pumpAndSettle();
      expect(find.text('Sample account unavailable'), findsOneWidget);
      expect(find.text('₱4,250.00'), findsNothing);
    },
  );

  testWidgets('loading and safe recoverable load error', (tester) async {
    viewport(tester, const Size(390, 844));
    final pending = Completer<List<DemoAccount>>();
    await pumpDetail(
      tester,
      repository: AccountsTestRepository(loadData: () => pending.future),
    );
    expect(find.bySemanticsLabel('Loading sample account'), findsOneWidget);
    pending.complete(accountFixture());
    await tester.pumpAndSettle();
    expect(find.text('GCash Personal'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    var calls = 0;
    await pumpDetail(
      tester,
      repository: AccountsTestRepository(
        loadData: () async {
          if (calls++ == 0) throw Exception('private payload');
          return accountFixture();
        },
      ),
    );
    expect(find.text("We couldn't load this sample account."), findsOneWidget);
    expect(find.textContaining('private payload'), findsNothing);
    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();
    expect(find.text('GCash Personal'), findsOneWidget);
  });

  for (final id in ['gcash', 'bpi']) {
    for (final theme in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('$id account detail ${theme.name} golden', (tester) async {
        final height = id == 'gcash' ? 1700 : 1300;
        viewport(tester, Size(390, height.toDouble()));
        await pumpDetail(tester, id: id, theme: theme);
        await expectLater(
          find.byKey(const ValueKey('account-detail-golden')),
          matchesGoldenFile(
            'goldens/account_detail_${id}_${theme.name}_390x$height.png',
          ),
        );
      });
    }
    for (final size in [
      const Size(320, 640),
      const Size(430, 932),
      const Size(844, 390),
    ]) {
      testWidgets('$id detail scrolls at $size', (tester) async {
        viewport(tester, size);
        await pumpDetail(tester, id: id);
        await tester.ensureVisible(find.text('Remove demo profile'));
        expect(find.text('Remove demo profile').hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
    testWidgets('$id large text and safe insets remain usable', (tester) async {
      viewport(tester, const Size(320, 844));
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      tester.view.padding = const FakeViewPadding(top: 44, bottom: 34);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      addTearDown(tester.view.resetPadding);
      await pumpDetail(tester, id: id);
      expect(
        tester.getTopLeft(find.text('Account Detail')).dy,
        greaterThanOrEqualTo(44),
      );
      await tester.ensureVisible(find.text('Remove demo profile'));
      expect(tester.takeException(), isNull);
    });
  }
}
