import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pesoflow/app/app.dart';
import 'package:pesoflow/app/router.dart';
import 'package:pesoflow/features/accounts/application/accounts_provider.dart';
import 'package:pesoflow/features/accounts/data/account_fixture.dart';
import 'package:pesoflow/features/accounts/domain/demo_account.dart';
import 'package:pesoflow/features/financial_connections/application/demo_access_provider.dart';
import 'package:pesoflow/features/financial_connections/domain/demo_access_result.dart';
import 'package:pesoflow/features/transactions/application/transactions_provider.dart';

import 'accounts_domain_test.dart' show AccountsTestRepository;
import 'accounts_test.dart' show pumpAccounts;
import 'home_test.dart' show viewport;

const acknowledgment = ValueKey('demo-access-acknowledgment');

Future<ProviderContainer> pumpReview(
  WidgetTester tester, {
  String id = 'gcash',
  ThemeMode theme = ThemeMode.light,
  DemoAccountsRepository? repository,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        routerProvider.overrideWith((ref) {
          final router = createRouter(initialLocation: '/connections/demo/$id');
          ref.onDispose(router.dispose);
          return router;
        }),
        accountsRepositoryProvider.overrideWithValue(
          repository ?? AccountsTestRepository(loadData: () async => []),
        ),
      ],
      child: RepaintBoundary(
        key: const ValueKey('demo-access-golden'),
        child: PesoFlowApp(themeMode: theme),
      ),
    ),
  );
  // A bounded pump also supports pending repository states.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  return ProviderScope.containerOf(tester.element(find.byType(PesoFlowApp)));
}

Future<void> acknowledge(WidgetTester tester) async {
  await tester.ensureVisible(find.byKey(acknowledgment));
  await tester.tap(find.byKey(acknowledgment));
  await tester.pump();
}

void main() {
  test('acknowledgment gates mutation; restore once preserves ledger and balance provenance', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final subscription = container.listen(
      demoAccessProvider('gcash'),
      (_, _) {},
    );
    addTearDown(subscription.close);
    await container.read(accountsProvider.future);
    container.read(accountsProvider.notifier).disconnect('gcash');
    final ledger = container.read(demoLedgerProvider);
    final controller = container.read(demoAccessProvider('gcash').notifier);
    expect(controller.confirm(), DemoAccessResult.acknowledgmentRequired);
    expect(container.read(accountsProvider).value!.accounts.length, 3);
    controller.acknowledge(true);
    expect(controller.confirm(), DemoAccessResult.added);
    expect(controller.confirm(), DemoAccessResult.alreadyListed);
    final restored = container
        .read(accountsProvider)
        .value!
        .accounts
        .firstWhere((a) => a.id == 'gcash');
    expect(restored.balance, accountFixture().first.balance);
    expect(restored.balanceAsOf, accountFixture().first.balanceAsOf);
    expect(container.read(demoLedgerProvider), same(ledger));
    expect(container.read(accountsProvider).value!.accounts.length, 4);
  });

  test(
    'unknown/ambiguous profile and pending local check cannot mutate',
    () async {
      final pending = Completer<void>();
      final container = ProviderContainer(
        overrides: [
          accountsRepositoryProvider.overrideWithValue(
            AccountsTestRepository(refreshData: () => pending.future),
          ),
        ],
      );
      addTearDown(container.dispose);
      await container.read(accountsProvider.future);
      container.read(accountsProvider.notifier).disconnect('gcash');
      for (final id in ['unknown', 'gcash']) {
        final sub = container.listen(demoAccessProvider(id), (_, _) {});
        addTearDown(sub.close);
        container.read(demoAccessProvider(id).notifier).acknowledge(true);
      }
      expect(
        container.read(demoAccessProvider('unknown').notifier).confirm(),
        DemoAccessResult.unavailable,
      );
      final checking = container.read(accountsProvider.notifier).refreshDemo();
      expect(
        container.read(demoAccessProvider('gcash').notifier).confirm(),
        DemoAccessResult.unavailable,
      );
      pending.complete();
      await checking;
      expect(
        container.read(demoAccessProvider('gcash').notifier).confirm(),
        DemoAccessResult.added,
      );
      final ambiguous = ProviderContainer(
        overrides: [
          demoAccountCatalogProvider.overrideWithValue([
            accountFixture().first,
            accountFixture().first,
          ]),
        ],
      );
      addTearDown(ambiguous.dispose);
      final sub = ambiguous.listen(demoAccessProvider('gcash'), (_, _) {});
      addTearDown(sub.close);
      await ambiguous.read(accountsProvider.future);
      ambiguous.read(accountsProvider.notifier).disconnect('gcash');
      ambiguous.read(demoAccessProvider('gcash').notifier).acknowledge(true);
      expect(
        ambiguous.read(demoAccessProvider('gcash').notifier).confirm(),
        DemoAccessResult.unavailable,
      );
    },
  );

  testWidgets(
    'review requires an accessible unchecked acknowledgment and opens detail',
    (tester) async {
      viewport(tester, const Size(390, 844));
      final semantics = tester.ensureSemantics();
      try {
        final container = await pumpReview(tester);
        final ledger = container.read(demoLedgerProvider);
        expect(find.byKey(const ValueKey('nav-Home')), findsNothing);
        expect(find.byType(TextField), findsNothing);
        expect(find.text('0917 •••• 892'), findsOneWidget);
        expect(find.text('Oct 24, 2024 · 12:30 PM'), findsOneWidget);
        expect(
          tester
              .widget<FilledButton>(
                find.widgetWithText(FilledButton, 'Add demo account'),
              )
              .onPressed,
          isNull,
        );
        await tester.ensureVisible(find.byKey(acknowledgment));
        await tester.pump();
        expect(
          tester.getSemantics(find.byType(Checkbox)),
          matchesSemantics(
            label: 'I understand this adds sample data only.',
            hasCheckedState: true,
            hasSelectedState: true,
            isFocusable: true,
            hasEnabledState: true,
            isEnabled: true,
            hasTapAction: true,
            hasFocusAction: true,
          ),
        );
        await acknowledge(tester);
        await tester.ensureVisible(find.text('Add demo account'));
        await tester.tap(find.text('Add demo account'));
        await tester.pumpAndSettle();
        expect(find.text('Account Detail'), findsOneWidget);
        expect(container.read(accountsProvider).value!.accounts.length, 1);
        expect(container.read(demoLedgerProvider), same(ledger));
        await tester.tap(find.byTooltip('Back'));
        await tester.pumpAndSettle();
        expect(find.text('Connected Accounts'), findsOneWidget);
      } finally {
        semantics.dispose();
      }
    },
  );

  testWidgets(
    'catalog cancel and reentry reset acknowledgment without changing account list',
    (tester) async {
      viewport(tester, const Size(390, 844));
      await pumpAccounts(
        tester,
        repository: AccountsTestRepository(loadData: () async => []),
      );
      final container = ProviderScope.containerOf(
        tester.element(find.byType(PesoFlowApp)),
      );
      for (var attempt = 0; attempt < 2; attempt++) {
        await tester.tap(find.text('Link Account'));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('catalog-gcash')));
        await tester.pumpAndSettle();
        expect(find.text('Review Demo Access'), findsOneWidget);
        expect(container.read(demoAccessProvider('gcash')), false);
        await acknowledge(tester);
        await tester.ensureVisible(find.text('Cancel'));
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        expect(find.text('Connected Accounts'), findsOneWidget);
        expect(container.read(accountsProvider).value!.accounts, isEmpty);
      }
    },
  );

  testWidgets(
    'stale restoration keeps last-known balance excluded and original time',
    (tester) async {
      viewport(tester, const Size(390, 844));
      final container = await pumpReview(tester, id: 'bpi');
      await tester.ensureVisible(find.text('This sample balance is stale'));
      expect(find.text('Last-known sample balance'), findsOneWidget);
      await acknowledge(tester);
      await tester.ensureVisible(find.text('Add demo account'));
      await tester.tap(find.text('Add demo account'));
      await tester.pumpAndSettle();
      final overview = container.read(accountsProvider).value!;
      expect(overview.availableBalance, 0);
      expect(overview.lastKnownBalance, 1220000);
      expect(
        overview.accounts.single.balanceAsOf,
        accountFixture().last.balanceAsOf,
      );
    },
  );

  testWidgets(
    'already-listed direct link offers detail without creating a duplicate',
    (tester) async {
      viewport(tester, const Size(390, 844));
      final container = await pumpReview(
        tester,
        repository: AccountsTestRepository(),
      );
      expect(find.byKey(acknowledgment), findsNothing);
      expect(find.text('Add demo account'), findsNothing);
      await tester.ensureVisible(find.text('View sample profile'));
      await tester.tap(find.text('View sample profile'));
      await tester.pumpAndSettle();
      expect(find.text('Account Detail'), findsOneWidget);
      expect(container.read(accountsProvider).value!.accounts.length, 4);
    },
  );

  testWidgets('unknown link safely returns to Accounts', (tester) async {
    viewport(tester, const Size(390, 844));
    await pumpReview(tester, id: 'unknown');
    expect(find.text('Sample profile unavailable'), findsOneWidget);
    expect(find.byKey(acknowledgment), findsNothing);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Connected Accounts'), findsOneWidget);
  });

  testWidgets(
    'loading then sanitized error can retry without granting access',
    (tester) async {
      viewport(tester, const Size(390, 844));
      final pending = Completer<List<DemoAccount>>();
      var calls = 0;
      final container = await pumpReview(
        tester,
        repository: AccountsTestRepository(
          loadData: () => calls++ == 0 ? pending.future : Future.value([]),
        ),
      );
      expect(
        find.bySemanticsLabel('Loading demo access review'),
        findsOneWidget,
      );
      expect(
        container.read(demoAccessProvider('gcash').notifier).confirm(),
        DemoAccessResult.acknowledgmentRequired,
      );
      pending.completeError(Exception('private provider payload'));
      await tester.pumpAndSettle();
      expect(find.text("We couldn't load the demo review."), findsOneWidget);
      expect(find.textContaining('private provider'), findsNothing);
      await tester.tap(find.text('Try Again'));
      await tester.pumpAndSettle();
      expect(find.byKey(acknowledgment), findsOneWidget);
      expect(container.read(accountsProvider).value!.accounts, isEmpty);
    },
  );

  for (final theme in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('demo review ${theme.name} golden', (tester) async {
      viewport(tester, const Size(390, 1500));
      await pumpReview(tester, theme: theme);
      await expectLater(
        find.byKey(const ValueKey('demo-access-golden')),
        matchesGoldenFile('goldens/demo_access_${theme.name}_390x1500.png'),
      );
    });
  }
  for (final size in [
    const Size(320, 640),
    const Size(430, 932),
    const Size(844, 390),
  ]) {
    testWidgets('demo review and acknowledgment usable at $size', (
      tester,
    ) async {
      viewport(tester, size);
      await pumpReview(tester);
      await acknowledge(tester);
      await tester.ensureVisible(find.text('Add demo account'));
      expect(find.text('Add demo account').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('200% text and safe insets keep review and actions scrollable', (
    tester,
  ) async {
    viewport(tester, const Size(320, 844));
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    tester.view.padding = const FakeViewPadding(top: 44, bottom: 34);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    addTearDown(tester.view.resetPadding);
    await pumpReview(tester, id: 'bpi');
    expect(
      tester.getTopLeft(find.text('Review Demo Access')).dy,
      greaterThanOrEqualTo(44),
    );
    await acknowledge(tester);
    await tester.ensureVisible(find.text('Cancel'));
    expect(find.text('Cancel').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
