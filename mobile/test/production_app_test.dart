import 'package:pesoflow/features/settings/domain/appearance.dart';

import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pesoflow/app/app.dart';
import 'package:pesoflow/app/router.dart';
import 'package:pesoflow/app/finance_bootstrap.dart';
import 'package:pesoflow/core/storage/finance_database.dart';
import 'package:pesoflow/core/storage/financial_cipher.dart';
import 'package:pesoflow/core/time/clock.dart';
import 'package:pesoflow/features/accounts/domain/financial_account.dart';
import 'package:pesoflow/features/budgets/domain/spending_budget.dart';
import 'package:pesoflow/features/analytics/domain/analytics_report.dart';
import 'package:pesoflow/features/settings/domain/user_preferences.dart';
import 'package:pesoflow/features/transactions/domain/transaction.dart';
import 'package:pesoflow/features/workspace/application/finance_controller.dart';
import 'package:pesoflow/features/workspace/data/sqlite_finance_repository.dart';
import 'package:pesoflow/features/workspace/domain/finance_workspace.dart';

import 'fixtures/finance_workspace_fixture.dart';
import 'support/finance_fakes.dart';

final clock = DateTime(2024, 10, 24, 12, 35);
void viewport(WidgetTester tester, Size size) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<ProviderContainer> pumpApp(
  WidgetTester tester, {
  String route = '/home',
  FinanceWorkspace? workspace,
  FakeFinanceRepository? repository,
  ThemeMode theme = ThemeMode.light,
}) async {
  final repo = repository ?? FakeFinanceRepository(workspace);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        financeRepositoryProvider.overrideWithValue(repo),
        initialWorkspaceProvider.overrideWithValue(repo.workspace),
        clockProvider.overrideWithValue(() => clock),
        routerProvider.overrideWith((ref) {
          final router = createRouter(initialLocation: route);
          ref.onDispose(router.dispose);
          return router;
        }),
      ],
      child: RepaintBoundary(
        key: const ValueKey('app-golden'),
        child: PesoFlowApp(themeMode: theme),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return ProviderScope.containerOf(tester.element(find.byType(PesoFlowApp)));
}

void main() {
  for (final route in [
    '/home',
    '/transactions',
    '/accounts',
    '/budgets',
    '/analytics',
    '/subscriptions',
    '/notifications',
    '/settings',
    '/receipt',
  ]) {
    testWidgets('$route starts without sample financial activity', (
      tester,
    ) async {
      viewport(tester, const Size(390, 844));
      await pumpApp(tester, route: route);
      expect(find.textContaining('Jollibee'), findsNothing);
      expect(find.textContaining('Demo'), findsNothing);
      expect(find.textContaining('30,650'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
  for (final (name, route, height) in [
    ('home', '/home', 1447.0),
    ('transactions', '/transactions', 1300.0),
    ('accounts', '/accounts', 1527.0),
    ('budgets', '/budgets', 1600.0),
    ('analytics', '/analytics', 1600.0),
    ('add', '/add', 1600.0),
    ('detail', '/transactions/jollibee', 1447.0),
  ]) {
    for (final theme in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('$name ${theme.name} production golden', (tester) async {
        viewport(tester, Size(390, height));
        await pumpApp(
          tester,
          route: route,
          workspace: financeFixture(),
          theme: theme,
        );
        expect(tester.takeException(), isNull);
        await expectLater(
          find.byKey(const ValueKey('app-golden')),
          matchesGoldenFile('goldens/production_${name}_${theme.name}.png'),
        );
      });
    }
  }
  for (final route in [
    '/home',
    '/transactions',
    '/accounts',
    '/budgets',
    '/analytics',
    '/add',
  ]) {
    testWidgets('$route compact large-text layout', (tester) async {
      viewport(tester, const Size(320, 760));
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pumpApp(tester, route: route, workspace: financeFixture());
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets(
    'category-only budget never displays a fabricated overall limit',
    (tester) async {
      viewport(tester, const Size(390, 1447));
      final fixture = financeFixture();
      await pumpApp(
        tester,
        workspace: fixture.copyWith(
          budgets: fixture.budgets.where((b) => b.category != null),
        ),
      );
      expect(find.text('No overall limit set'), findsOneWidget);
      expect(find.textContaining('Overall Limit'), findsNothing);
      expect(find.textContaining('Food & Dining'), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'fresh bootstrap completes onboarding and persists entry preference',
    (tester) async {
      final repo = FakeFinanceRepository();
      await tester.pumpWidget(FinanceBootstrap(repository: repo));
      await repo.load();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Get started'));
      await tester.pumpAndSettle();
      expect(repo.workspace.preferences.onboardingCompleted, isTrue);
      expect(find.text('Your financial overview'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(FinanceBootstrap(repository: repo));
      await repo.load();
      await tester.pumpAndSettle();
      expect(find.widgetWithText(FilledButton, 'Get started'), findsNothing);
      expect(find.text('Your financial overview'), findsOneWidget);
    },
  );
  for (final (mode, merchant, amount) in [
    ('Expense', 'Actual lunch', '325.25'),
    ('Income', 'Actual salary', '45000.00'),
    ('Transfer', '', '500.00'),
  ]) {
    testWidgets('$mode form commits a real record', (tester) async {
      viewport(tester, const Size(390, 1600));
      final repo = FakeFinanceRepository(financeFixture().copyWith(ledger: []));
      await pumpApp(tester, route: '/add', repository: repo);
      if (mode != 'Expense') {
        await tester.tap(find.text(mode));
        await tester.pumpAndSettle();
      }
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.first, amount);
      if (merchant.isNotEmpty) await tester.enterText(fields.at(1), merchant);
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Save $mode —'));
      await tester.pumpAndSettle();
      expect(repo.workspace.ledger, hasLength(1));
      expect(repo.workspace.ledger.single.kind.name, mode.toLowerCase());
      expect(
        repo.workspace.ledger.single.amount,
        mode == 'Expense'
            ? 32525
            : mode == 'Income'
            ? 4500000
            : 50000,
      );
      if (mode == 'Transfer') {
        expect(repo.workspace.ledger.single.expenseImpact, 0);
      }
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets(
    'budget editor persists a limit and recalculates actual spending',
    (tester) async {
      viewport(tester, const Size(390, 1200));
      final repo = FakeFinanceRepository(
        financeFixture().copyWith(budgets: []),
      );
      await pumpApp(tester, route: '/budgets', repository: repo);
      await tester.tap(find.text('New'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('budget-limit-input')),
        '5000',
      );
      await tester.tap(find.text('Save budget'));
      await tester.pumpAndSettle();
      expect(repo.workspace.budgets.single.limit, 500000);
      expect(find.textContaining('5,000'), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'file-backed workspace and theme survive full app reconstruction',
    (tester) async {
      await tester.runAsync(() async {
        final dir = await Directory.systemTemp.createTemp(
          'pesoflow-app-restart-',
        );
        final file = File('${dir.path}/finance.sqlite');
        final keys = MemoryEncryptionKeys();
        var repo = SqliteFinanceRepository(
          FinanceDatabase(NativeDatabase(file)),
          FinancialCipher(keys),
        );
        final empty = await repo.load();
        await repo.save(
          empty.copyWith(
            accounts: [
              FinancialAccount(
                id: 'real',
                name: 'My wallet',
                type: AccountType.wallet,
                startingBalance: 100000,
                currency: 'PHP',
                createdAt: clock,
              ),
            ],
            ledger: [
              TransactionRecord(
                id: 'entry',
                merchant: 'Actual lunch',
                metadata: '',
                amount: 32525,
                occurredAt: clock,
                kind: TransactionKind.expense,
                category: TransactionCategory.food,
                account: 'My wallet',
                accountId: 'real',
              ),
            ],
            budgets: [
              SpendingBudget(
                id: 'plan',
                name: 'Monthly',
                limit: 500000,
                period: AnalyticsPeriod.month,
                startDate: DateTime(2024, 10),
              ),
            ],
            preferences: const UserPreferences(
              onboardingCompleted: true,
              appearance: Appearance.dark,
            ),
          ),
          expectedRevision: 0,
        );
        await tester.pumpWidget(FinanceBootstrap(repository: repo));
        await repo.load();
        await tester.pumpAndSettle();
        expect(find.text('Actual lunch'), findsOneWidget);
        await tester.pumpWidget(const SizedBox());
        await repo.close();
        repo = SqliteFinanceRepository(
          FinanceDatabase(NativeDatabase(file)),
          FinancialCipher(keys),
        );
        await tester.pumpWidget(FinanceBootstrap(repository: repo));
        await repo.load();
        await tester.pumpAndSettle();
        expect(find.text('Actual lunch'), findsOneWidget);
        expect((await repo.load()).ledger.single.amount, 32525);
        expect(
          tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
          ThemeMode.dark,
        );
        await tester.pumpWidget(const SizedBox());
        await repo.close();
        await dir.delete(recursive: true);
      });
    },
  );
}
