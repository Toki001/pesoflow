import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pesoflow/app/app.dart';
import 'package:pesoflow/app/demo_bootstrap.dart';
import 'package:pesoflow/app/router.dart';
import 'package:pesoflow/features/demo_workspace/application/demo_workspace_providers.dart';
import 'package:pesoflow/features/budgets/application/budgets_provider.dart';
import 'package:pesoflow/features/subscriptions/application/subscriptions_provider.dart';
import 'package:pesoflow/features/transactions/application/transactions_provider.dart';

import 'add_expense_test.dart' show draft;
import 'demo_storage_test.dart' show ControlledWorkspaceRepository;
import 'home_test.dart' show viewport;

Future<ProviderContainer> pumpLocalSettings(
  WidgetTester tester,
  ControlledWorkspaceRepository repository, {
  ThemeMode theme = ThemeMode.light,
  String location = '/settings',
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        demoWorkspaceRepositoryProvider.overrideWithValue(repository),
        initialDemoWorkspaceProvider.overrideWithValue(repository.workspace),
        routerProvider.overrideWith((ref) {
          final router = createRouter(initialLocation: location);
          ref.onDispose(router.dispose);
          return router;
        }),
      ],
      child: RepaintBoundary(
        key: const ValueKey('local-settings-golden'),
        child: PesoFlowApp(themeMode: theme),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return ProviderScope.containerOf(tester.element(find.byType(PesoFlowApp)));
}

void main() {
  testWidgets('plan reset confirms scope and preserves recorded activity', (
    tester,
  ) async {
    viewport(tester, const Size(390, 844));
    final repository = ControlledWorkspaceRepository();
    final container = await pumpLocalSettings(tester, repository);
    container.read(demoLedgerProvider.notifier).createManual(draft());
    container
        .read(demoBudgetPlansProvider.notifier)
        .setLimit(2024, 10, null, 3000000);
    container
        .read(demoSubscriptionsProvider.notifier)
        .setActive('netflix', false);
    await container.read(demoPersistenceProvider.notifier).flush();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Reset demo plans'));
    await tester.tap(find.text('Reset demo plans'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining(
        'Transactions, saved receipts, preferences and alert read markers stay as they are',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(repository.workspace.budgets['2024-10']!.monthlyLimit, 3000000);
    await tester.tap(find.text('Reset demo plans'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reset plans'));
    await tester.pumpAndSettle();
    expect(repository.workspace.ledger, hasLength(10));
    expect(repository.workspace.budgets['2024-10']!.monthlyLimit, 2500000);
    expect(repository.workspace.subscriptions.first.active, true);
    expect(
      find.text('Original demo plans restored on this device.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'persistent budget and subscription editors disclose local storage',
    (tester) async {
      viewport(tester, const Size(390, 844));
      await pumpLocalSettings(
        tester,
        ControlledWorkspaceRepository(),
        location: '/budgets',
      );
      await tester.tap(find.text('MONTHLY BUDGET'));
      await tester.pumpAndSettle();
      expect(
        find.text('Demo budget plans are saved on this device.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await pumpLocalSettings(
        tester,
        ControlledWorkspaceRepository(),
        location: '/subscriptions',
      );
      await tester.tap(find.byKey(const ValueKey('add-subscription')));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Demo tracking is saved on this device. Renewals do not create charges.',
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Settings reset needs confirmation; cancel preserves edits and reset persists samples',
    (tester) async {
      viewport(tester, const Size(390, 844));
      final repository = ControlledWorkspaceRepository();
      final container = await pumpLocalSettings(tester, repository);
      container.read(demoLedgerProvider.notifier).createManual(draft());
      await container.read(demoPersistenceProvider.notifier).flush();
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Reset demo activity'));
      await tester.tap(find.text('Reset demo activity'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(repository.workspace.ledger, hasLength(10));
      await tester.tap(find.text('Reset demo activity'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reset activity'));
      await tester.pumpAndSettle();
      expect(repository.workspace.ledger, hasLength(9));
      expect(container.read(demoLedgerProvider), hasLength(9));
      expect(
        find.text('Original demo activity restored on this device.'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'global write error is safe, preserves memory and retries newest activity',
    (tester) async {
      viewport(tester, const Size(390, 844));
      final repository = ControlledWorkspaceRepository();
      repository.onSave = (_) async => throw Exception('private database path');
      final container = await pumpLocalSettings(
        tester,
        repository,
        location: '/home',
      );
      container.read(demoLedgerProvider.notifier).createManual(draft());
      await container.read(demoPersistenceProvider.notifier).flush();
      await tester.pumpAndSettle();
      expect(
        find.text('Local save failed. Changes are still in memory.'),
        findsOneWidget,
      );
      expect(find.textContaining('private database'), findsNothing);
      repository.onSave = null;
      await tester.tap(find.text('Retry save'));
      await tester.pumpAndSettle();
      expect(find.text('Retry save'), findsNothing);
      expect(repository.workspace.ledger, hasLength(10));
    },
  );

  testWidgets(
    'startup error never silently replaces data; cancel and retry are safe',
    (tester) async {
      viewport(tester, const Size(390, 844));
      final repository = ControlledWorkspaceRepository();
      repository.onLoad = () async => throw Exception('private payload');
      await tester.pumpWidget(DemoBootstrap(repository: repository));
      await tester.pumpAndSettle();
      expect(find.text('Your local demo could not load'), findsOneWidget);
      expect(find.textContaining('private payload'), findsNothing);
      await tester.tap(find.text('Reset stored demo data'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(repository.writes, isEmpty);
      repository.onLoad = null;
      await tester.tap(find.text('Try Again'));
      await tester.pumpAndSettle();
      expect(find.text('Understand your money'), findsOneWidget);
      expect(repository.writes, isEmpty);
    },
  );

  testWidgets('startup confirmed reset restores a usable local demo', (
    tester,
  ) async {
    viewport(tester, const Size(390, 844));
    final repository = ControlledWorkspaceRepository();
    repository.onLoad = () async =>
        throw const FormatException('bad saved data');
    await tester.pumpWidget(DemoBootstrap(repository: repository));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reset stored demo data'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reset demo data'));
    await tester.pumpAndSettle();
    expect(find.text('Understand your money'), findsOneWidget);
    expect(repository.writes.single.ledger, hasLength(9));
  });

  for (final theme in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('local Settings ${theme.name} golden', (tester) async {
      viewport(tester, const Size(390, 1600));
      await pumpLocalSettings(
        tester,
        ControlledWorkspaceRepository(),
        theme: theme,
      );
      expect(find.text('Demo activity saved on this device'), findsOneWidget);
      await expectLater(
        find.byKey(const ValueKey('local-settings-golden')),
        matchesGoldenFile('goldens/settings_local_${theme.name}_390x1600.png'),
      );
    });
  }
  testWidgets(
    'local Settings and disclosure support compact 200% text and safe insets',
    (tester) async {
      viewport(tester, const Size(320, 844));
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      tester.view.padding = const FakeViewPadding(top: 44, bottom: 34);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      addTearDown(tester.view.resetPadding);
      await pumpLocalSettings(tester, ControlledWorkspaceRepository());
      await tester.ensureVisible(find.text('Reset demo activity'));
      expect(find.text('Reset demo activity').hitTestable(), findsOneWidget);
      await tester.ensureVisible(find.text('Reset demo plans'));
      expect(find.text('Reset demo plans').hitTestable(), findsOneWidget);
      await tester.ensureVisible(find.text('Reset demo alerts'));
      expect(find.text('Reset demo alerts').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await pumpLocalSettings(
        tester,
        ControlledWorkspaceRepository(),
        location: '/onboarding',
      );
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();
      expect(find.text('Demo activity stays on this device'), findsOneWidget);
      await tester.ensureVisible(find.text('Explore demo'));
      expect(tester.takeException(), isNull);
    },
  );
}
