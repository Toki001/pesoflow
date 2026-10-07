import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pesoflow/core/time/clock.dart';
import 'package:pesoflow/features/accounts/domain/financial_account.dart';
import 'package:pesoflow/features/analytics/domain/analytics_report.dart';
import 'package:pesoflow/features/analytics/domain/financial_analytics.dart';
import 'package:pesoflow/features/budgets/domain/spending_budget.dart';
import 'package:pesoflow/features/notifications/domain/evaluate_notices.dart';
import 'package:pesoflow/features/subscriptions/domain/recurring_detection.dart';
import 'package:pesoflow/features/subscriptions/domain/subscription_plan.dart';
import 'package:pesoflow/features/transactions/domain/categorization.dart';
import 'package:pesoflow/features/transactions/domain/transaction.dart';
import 'package:pesoflow/features/workspace/application/finance_controller.dart';
import 'package:pesoflow/features/workspace/domain/finance_workspace.dart';

import 'support/finance_fakes.dart';

final now = DateTime(2026, 10, 7, 18);
FinancialAccount cash(String id) => FinancialAccount(
  id: id,
  name: id,
  type: AccountType.cash,
  startingBalance: 0,
  currency: 'PHP',
  createdAt: now,
);
TransactionRecord charge(
  String id,
  int amount, {
  DateTime? date,
  String merchant = 'Example merchant',
  TransactionKind kind = TransactionKind.expense,
  TransactionCategory category = TransactionCategory.food,
  String account = 'cash',
  String? destination,
}) => TransactionRecord(
  id: id,
  merchant: merchant,
  metadata: '',
  amount: amount,
  occurredAt: date ?? now,
  kind: kind,
  category: category,
  account: account,
  accountId: account,
  destinationAccountId: destination,
  destinationAccount: destination,
);

void main() {
  group('repository-backed commands', () {
    late FakeFinanceRepository repository;
    late ProviderContainer container;
    late FinanceController controller;
    setUp(() {
      repository = FakeFinanceRepository(
        FinanceWorkspace(accounts: [cash('cash'), cash('wallet')]),
      );
      container = ProviderContainer(
        overrides: [
          financeRepositoryProvider.overrideWithValue(repository),
          initialWorkspaceProvider.overrideWithValue(repository.workspace),
          clockProvider.overrideWithValue(() => now),
        ],
      );
      controller = container.read(financeControllerProvider.notifier);
    });
    tearDown(() => container.dispose());
    test(
      'serializes simultaneous edits and survives reconstructing the container',
      () async {
        await Future.wait([
          controller.saveTransaction(charge('a', 1000)),
          controller.saveTransaction(charge('b', 2000)),
        ]);
        expect(repository.workspace.ledger, hasLength(2));
        expect(repository.workspace.revision, 2);
        final restored = ProviderContainer(
          overrides: [
            financeRepositoryProvider.overrideWithValue(repository),
            initialWorkspaceProvider.overrideWithValue(await repository.load()),
          ],
        );
        expect(restored.read(workspaceProvider).ledger.map((t) => t.id), [
          'a',
          'b',
        ]);
        restored.dispose();
      },
    );
    test(
      'a failed disk save is not published and does not poison future edits',
      () async {
        repository.failSave = true;
        await expectLater(
          controller.saveTransaction(charge('a', 1000)),
          throwsStateError,
        );
        expect(container.read(workspaceProvider).ledger, isEmpty);
        expect(container.read(financeControllerProvider).error, isNotNull);
        repository.failSave = false;
        await controller.saveTransaction(charge('a', 1000));
        expect(repository.workspace.ledger.single.id, 'a');
        expect(container.read(financeControllerProvider).error, isNull);
      },
    );
    test('expense, income and transfer reconcile; delete reverses only that record', () async {
      await controller.saveTransaction(
        charge(
          'pay',
          10000,
          kind: TransactionKind.income,
          category: TransactionCategory.salary,
        ),
      );
      await controller.saveTransaction(charge('meal', 3000));
      await controller.saveTransaction(
        charge(
          'move',
          5000,
          kind: TransactionKind.transfer,
          category: TransactionCategory.transfer,
          destination: 'wallet',
        ),
      );
      expect(accountBalance(cash('cash'), repository.workspace.ledger), 2000);
      expect(accountBalance(cash('wallet'), repository.workspace.ledger), 5000);
      await controller.deleteTransaction('meal');
      expect(accountBalance(cash('cash'), repository.workspace.ledger), 5000);
      await expectLater(
        controller.removeAccount('wallet'),
        throwsArgumentError,
      );
      await controller.saveAccount(cash('wallet').copyWith(archived: true));
      expect(repository.workspace.accounts.last.archived, isTrue);
    });
    test('category corrections persist and invalid type/account edits are rejected', () async {
      await controller.saveTransaction(
        charge('a', 1000, category: TransactionCategory.shopping),
        rememberCategory: true,
      );
      expect(
        categorize(
          kind: TransactionKind.expense,
          merchant: 'EXAMPLE MERCHANT',
          userRules: repository.workspace.merchantRules,
        ),
        TransactionCategory.shopping,
      );
      await expectLater(
        controller.saveTransaction(charge('a', 2000)),
        throwsArgumentError,
      );
      await expectLater(
        controller.saveTransaction(
          charge('b', 1000, kind: TransactionKind.income),
        ),
        throwsArgumentError,
      );
      await expectLater(
        controller.saveTransaction(charge('b', 1000, account: 'missing')),
        throwsArgumentError,
      );
      await controller.saveTransaction(
        charge('a', 2000, category: TransactionCategory.shopping),
        editing: true,
      );
      expect(repository.workspace.ledger.single.amount, 2000);
    });
    test('financial mutation atomically creates real alerts with persistent read state', () async {
      await controller.saveBudget(
        SpendingBudget(
          id: 'monthly',
          name: 'Monthly plan',
          limit: 10000,
          period: AnalyticsPeriod.month,
          startDate: DateTime(2026, 10),
        ),
      );
      await controller.saveTransaction(charge('a', 6000));
      final first = repository.workspace.notices.single;
      expect(first.conditionKey, endsWith(':50'));
      await controller.setNoticeRead(first.id, true);
      await controller.evaluateConditions();
      expect(repository.workspace.notices, hasLength(1));
      expect(repository.workspace.noticeReadIds, {first.id});
      await controller.saveTransaction(charge('b', 5000));
      expect(repository.workspace.notices, hasLength(2));
      expect(repository.workspace.notices.first.conditionKey, endsWith(':101'));
      await controller.savePreferences(
        repository.workspace.preferences.copyWith(notifications: false),
      );
      final notices = evaluateNotices(repository.workspace, now);
      expect(notices, hasLength(2));
    });
    test(
      'duplicate budgets and mixed currencies cannot enter the workspace',
      () async {
        final plan = SpendingBudget(
          id: 'one',
          name: 'Food',
          limit: 10000,
          period: AnalyticsPeriod.week,
          startDate: now,
          category: TransactionCategory.food,
        );
        await controller.saveBudget(plan);
        await expectLater(
          controller.saveBudget(
            SpendingBudget(
              id: 'two',
              name: 'Duplicate',
              limit: 20000,
              period: AnalyticsPeriod.week,
              startDate: now,
              category: TransactionCategory.food,
            ),
          ),
          throwsArgumentError,
        );
        await expectLater(
          controller.savePreferences(
            repository.workspace.preferences.copyWith(currency: 'USD'),
          ),
          throwsArgumentError,
        );
        await controller.clearFinancialData();
        expect(repository.workspace.accounts, isEmpty);
        expect(repository.workspace.budgets, isEmpty);
        await controller.savePreferences(
          repository.workspace.preferences.copyWith(currency: 'USD'),
        );
        expect(repository.workspace.preferences.currency, 'USD');
      },
    );
  });

  test(
    'analytics empty ranges contain no fake graphs or undefined percentage',
    () {
      for (final period in AnalyticsPeriod.values) {
        final report = financialAnalytics(
          selection: AnalyticsSelection(now, period),
          ledger: [],
          now: now,
        );
        expect(report.totalExpense, 0);
        expect(report.points, isEmpty);
        expect(report.categories, isEmpty);
        expect(report.hasActivity, isFalse);
        expect(report.comparison.percent, isNull);
        expect(report.savingsRate, isNull);
        expect(report.highestSpendingDay, isNull);
      }
    },
  );
  test(
    'analytics calculates current/prior metrics without snapshot offsets',
    () {
      final report = financialAnalytics(
        selection: AnalyticsSelection(now),
        now: now,
        ledger: [
          charge('old', 1000, date: DateTime(2026, 9, 7)),
          charge('one', 2000, date: DateTime(2026, 10, 1)),
          charge('two', 3000),
          charge('refund', 500, kind: TransactionKind.refund),
          charge(
            'pay',
            10000,
            kind: TransactionKind.income,
            category: TransactionCategory.salary,
          ),
          charge(
            'transfer',
            500000,
            kind: TransactionKind.transfer,
            destination: 'wallet',
          ),
          charge('future', 100000, date: DateTime(2026, 10, 8)),
        ],
      );
      expect(report.totalExpense, 4500);
      expect(report.totalIncome, 10000);
      expect(report.netFlow, 5500);
      expect(report.savingsRate, 55);
      expect(report.averageTransaction, 2500);
      expect(report.dailyAverage, 642);
      expect(report.comparison.previous, 1000);
      expect(report.comparison.percent, 350);
      expect(report.points.last.amount, 4500);
      expect(report.highestSpendingDay!.amount, 2500);
      expect(report.merchants.single.amount, 4500);
    },
  );
  test('categorization gives type and remembered corrections priority over keywords', () {
    expect(
      categorize(kind: TransactionKind.transfer, merchant: 'Restaurant'),
      TransactionCategory.transfer,
    );
    expect(
      categorize(kind: TransactionKind.income, merchant: 'Monthly payroll'),
      TransactionCategory.salary,
    );
    expect(
      categorize(kind: TransactionKind.expense, merchant: 'Unknown vendor'),
      TransactionCategory.other,
    );
    expect(
      categorize(kind: TransactionKind.expense, merchant: 'SM supermarket'),
      TransactionCategory.groceries,
    );
    expect(
      categorize(
        kind: TransactionKind.expense,
        merchant: 'Coffee shop',
        userRules: {'expense:coffee shop': TransactionCategory.business},
      ),
      TransactionCategory.food,
    );
    expect(
      categorize(
        kind: TransactionKind.expense,
        merchant: 'Coffee SHOP!',
        userRules: {'expense:coffee shop': TransactionCategory.education},
      ),
      TransactionCategory.education,
    );
  });
  test('recurring detection requires repeated history and supports all four intervals', () {
    for (final cycle in BillingCycle.values) {
      final first = DateTime(2024, 1, 28);
      final second = advanceRenewal(first, cycle);
      final third = advanceRenewal(second, cycle);
      final rows = [
        charge('a', 5000, date: first),
        charge('b', 5000, date: second),
        charge('c', 5100, date: third),
      ];
      expect(detectRecurring(rows.take(2), third), isEmpty);
      final candidate = detectRecurring(rows, third).single;
      expect(candidate.cycle, cycle);
      expect(candidate.observations, 3);
      expect(candidate.amount, 5000);
      expect(candidate.nextExpected, advanceRenewal(third, cycle));
      expect(
        detectRecurring([
          ...rows.take(2),
          charge('c', 10000, date: third),
        ], third),
        isEmpty,
      );
    }
    expect(
      advanceRenewal(DateTime(2024, 1, 31), BillingCycle.monthly),
      DateTime(2024, 2, 29),
    );
  });
  test('unusual-spending cooldown and renewals are deduplicated across evaluations', () {
    final workspace = FinanceWorkspace(
      accounts: [cash('cash')],
      ledger: [
        for (var i = 0; i < 5; i++)
          charge('old$i', 1000, date: DateTime(2026, 10, 1 + i)),
        charge('large', 5000),
        charge('large2', 7000),
      ],
      subscriptions: [
        SubscriptionPlan(
          id: 'tracked',
          name: 'User plan',
          amount: 1000,
          cycle: BillingCycle.monthly,
          nextRenewal: DateTime(2026, 10, 10),
          paymentSource: 'cash',
          category: 'Subscriptions',
        ),
      ],
    );
    final notices = evaluateNotices(workspace, now);
    expect(notices, hasLength(2));
    expect(
      evaluateNotices(workspace.copyWith(notices: notices), now),
      hasLength(2),
    );
    expect(evaluateNotices(FinanceWorkspace(), now), isEmpty);
  });
}
