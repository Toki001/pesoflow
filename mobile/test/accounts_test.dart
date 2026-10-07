import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pesoflow/app/app.dart';
import 'package:pesoflow/app/router.dart';
import 'package:pesoflow/features/accounts/application/accounts_provider.dart';
import 'package:pesoflow/features/accounts/data/account_fixture.dart';
import 'package:pesoflow/features/accounts/domain/demo_account.dart';

import 'home_test.dart' show viewport, pumpHome;
import 'accounts_domain_test.dart' show AccountsTestRepository;

Future<void> pumpAccounts(
  WidgetTester tester, {
  ThemeMode theme = ThemeMode.light,
  DemoAccountsRepository? repository,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        routerProvider.overrideWith((ref) {
          final router = createRouter(initialLocation: '/accounts');
          ref.onDispose(router.dispose);
          return router;
        }),
        if (repository != null)
          accountsRepositoryProvider.overrideWithValue(repository),
      ],
      child: RepaintBoundary(
        key: const ValueKey('accounts-golden'),
        child: PesoFlowApp(themeMode: theme),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  for (final theme in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('Connected Accounts ${theme.name} golden', (tester) async {
      viewport(tester, const Size(390, 1632));
      await pumpAccounts(tester, theme: theme);
      expect(find.text('₱12,200.00'), findsOneWidget);
      expect(find.byKey(const ValueKey('nav-Home')), findsNothing);
      expect(find.text('Sample Financial Institutions'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byKey(const ValueKey('accounts-golden')),
        matchesGoldenFile('goldens/accounts_${theme.name}_390x1632.png'),
      );
    });
  }
  testWidgets('Home opens accounts and Back preserves Home scroll', (
    tester,
  ) async {
    viewport(tester, const Size(390, 844));
    await pumpHome(tester);
    await tester.ensureVisible(find.byKey(const ValueKey('open-accounts')));
    final before = tester.getTopLeft(find.text('Net Available Balance')).dy;
    await tester.tap(find.byKey(const ValueKey('open-accounts')));
    await tester.pumpAndSettle();
    expect(find.text('Connected Accounts'), findsOneWidget);
    expect(find.byKey(const ValueKey('nav-Home')), findsNothing);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.text('Net Available Balance')).dy, before);
  });
  testWidgets('direct-link Back falls back to Home', (tester) async {
    viewport(tester, const Size(390, 844));
    await pumpAccounts(tester);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Good morning, Alex'), findsOneWidget);
  });
  testWidgets('disconnect needs confirmation; catalog restores sample once', (
    tester,
  ) async {
    viewport(tester, const Size(390, 844));
    await pumpAccounts(tester);
    await tester.ensureVisible(find.byKey(const ValueKey('disconnect-gcash')));
    await tester.tap(find.byKey(const ValueKey('disconnect-gcash')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('GCash Personal'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('disconnect-gcash')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Disconnect demo'));
    await tester.pumpAndSettle();
    expect(find.text('GCash Personal'), findsNothing);
    await tester.tap(find.text('Link Account'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('catalog-gcash')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const ValueKey('demo-access-acknowledgment')),
    );
    await tester.tap(find.byKey(const ValueKey('demo-access-acknowledgment')));
    await tester.pump();
    await tester.ensureVisible(find.text('Add demo account'));
    await tester.tap(find.text('Add demo account'));
    await tester.pumpAndSettle();
    expect(find.text('Account Detail'), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('GCash Personal'), findsOneWidget);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(PesoFlowApp)),
    );
    expect(container.read(accountsProvider).value!.availableBalance, 3450000);
    expect(container.read(accountsProvider).value!.accounts.length, 4);
  });
  testWidgets(
    'settings expose masked sample provenance and no unverified claims',
    (tester) async {
      viewport(tester, const Size(390, 844));
      await pumpAccounts(tester);
      await tester.ensureVisible(find.byKey(const ValueKey('settings-gcash')));
      await tester.tap(find.byKey(const ValueKey('settings-gcash')));
      await tester.pumpAndSettle();
      expect(find.text('Account Detail'), findsOneWidget);
      expect(find.text('Oct 24, 2024 · 12:30 PM'), findsOneWidget);
      expect(find.textContaining('No provider permissions'), findsOneWidget);
      expect(find.textContaining('256-bit'), findsNothing);
      expect(find.byType(TextField), findsNothing);
    },
  );
  testWidgets(
    'reauthentication cannot promote stale balance into available total',
    (tester) async {
      viewport(tester, const Size(390, 844));
      await pumpAccounts(tester);
      await tester.ensureVisible(find.text('Reconnect Account'));
      await tester.tap(find.text('Reconnect Account'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Real reconnection is not available'),
        findsOneWidget,
      );
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      final container = ProviderScope.containerOf(
        tester.element(find.byType(PesoFlowApp)),
      );
      expect(container.read(accountsProvider).value!.availableBalance, 3450000);
      expect(
        container
            .read(accountsProvider)
            .value!
            .accounts
            .last
            .needsReauthentication,
        true,
      );
    },
  );
  testWidgets(
    'sync checks demo only; failure preserves balances and retry works',
    (tester) async {
      viewport(tester, const Size(390, 844));
      final gate = Completer<void>();
      var calls = 0;
      await pumpAccounts(
        tester,
        repository: AccountsTestRepository(
          refreshData: () {
            calls++;
            return calls == 1 ? gate.future : Future.value();
          },
        ),
      );
      await tester.tap(find.text('Sync All'));
      await tester.pump();
      expect(find.text('Checking demo…'), findsOneWidget);
      gate.completeError(Exception('private provider payload'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining("We couldn't check the demo data"),
        findsOneWidget,
      );
      expect(find.textContaining('private provider'), findsNothing);
      await tester.tap(find.text('Sync All'));
      await tester.pumpAndSettle();
      expect(
        find.text('Sample data checked. No live sync or balance changes.'),
        findsOneWidget,
      );
      final container = ProviderScope.containerOf(
        tester.element(find.byType(PesoFlowApp)),
      );
      expect(container.read(accountsProvider).value!.availableBalance, 3450000);
    },
  );
  testWidgets('loading and load errors provide safe explicit retry', (
    tester,
  ) async {
    final gate = Completer<List<DemoAccount>>();
    await pumpAccounts(
      tester,
      repository: AccountsTestRepository(loadData: () => gate.future),
    );
    expect(find.bySemanticsLabel('Loading connected accounts'), findsOneWidget);
    gate.complete(accountFixture());
    await tester.pumpAndSettle();
    expect(find.text('GCash Personal'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    var calls = 0;
    await pumpAccounts(
      tester,
      repository: AccountsTestRepository(
        loadData: () async {
          if (calls++ == 0) throw Exception('private data');
          return accountFixture();
        },
      ),
    );
    expect(find.text("We couldn't load your sample accounts."), findsOneWidget);
    expect(find.textContaining('private data'), findsNothing);
    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();
    expect(find.text('GCash Personal'), findsOneWidget);
  });
  testWidgets('empty list and docked CTA allow a sample profile', (
    tester,
  ) async {
    viewport(tester, const Size(390, 844));
    await pumpAccounts(
      tester,
      repository: AccountsTestRepository(loadData: () async => []),
    );
    expect(find.text('No sample accounts'), findsOneWidget);
    await tester.tap(find.text('+ Connect Another Institution'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('catalog-gcash')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const ValueKey('demo-access-acknowledgment')),
    );
    await tester.tap(find.byKey(const ValueKey('demo-access-acknowledgment')));
    await tester.pump();
    await tester.ensureVisible(find.text('Add demo account'));
    await tester.tap(find.text('Add demo account'));
    await tester.pumpAndSettle();
    expect(find.text('Account Detail'), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('No sample accounts'), findsNothing);
    expect(find.text('GCash Personal'), findsOneWidget);
  });
  for (final size in [
    const Size(320, 844),
    const Size(430, 932),
    const Size(844, 390),
  ]) {
    testWidgets('accounts remain scrollable at $size', (tester) async {
      viewport(tester, size);
      await pumpAccounts(tester);
      await tester.ensureVisible(find.text('Sample Financial Institutions'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(
        find.text('+ Connect Another Institution').hitTestable(),
        findsOneWidget,
      );
    });
  }
  testWidgets('200 percent text and safe insets support cards and catalog', (
    tester,
  ) async {
    viewport(tester, const Size(320, 844));
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    tester.view.padding = const FakeViewPadding(top: 44, bottom: 34);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    addTearDown(tester.view.resetPadding);
    await pumpAccounts(tester);
    await tester.ensureVisible(find.text('Reconnect Account'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('+ Connect Another Institution'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Close'));
    expect(tester.takeException(), isNull);
  });
}
