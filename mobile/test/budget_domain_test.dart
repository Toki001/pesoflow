import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'fixtures/features/budgets/data/budget_fixture.dart';

import 'package:pesoflow/features/budgets/domain/budget_plan.dart';

import 'fixtures/features/transactions/data/transaction_fixture.dart';

import 'package:pesoflow/features/transactions/domain/transaction.dart';

void main() {
  test('approved budget snapshot and JSON round trip preserve exact financial values', () {
    final plan = budgetFixture();
    expect(
      BudgetPlan.fromJson(jsonDecode(jsonEncode(plan)) as Map<String, dynamic>),
      plan,
    );
    expect(plan.spent, 1680000);
    expect(plan.remaining, 820000);
    expect(plan.percentUsed, 67);
    expect(plan.daysLeft(demoClock), 7);
    expect(plan.safeDailyPace(demoClock), 117142);
    expect(plan.projectedEndTotal, 2240000);
    expect(plan.allowances.first.used, .8625);
    expect(plan.allowances.first.projectedOverage, 35000);
    expect(plan.allowances.where((a) => a.atRisk).length, 2);
    expect(plan.allowances[3].status, BudgetStatus.settled);
    expect(plan.allowances[4].status, BudgetStatus.fixed);
  });
  test('period boundaries and zero-day pace never divide by zero', () {
    final plan = budgetFixture();
    expect(plan.daysLeft(DateTime(2024, 10, 31)), 0);
    expect(plan.safeDailyPace(DateTime(2024, 11, 1)), 0);
    final feb = plan.copyWith(year: 2024, month: 2);
    expect(feb.periodDays, 29);
    expect(feb.daysLeft(DateTime(2024, 2, 28)), 1);
    expect(feb.daysLeft(DateTime(2024, 1, 31)), 29);
    expect(plan.copyWith(spent: 3000000).safeDailyPace(demoClock), 0);
  });
  test('pending, transfers, refunds, recategorization and exclusion project without double counting', () {
    final baseline = transactionFixture();
    final food = baseline.first;
    final ledger = [
      for (final t in baseline)
        if (t.id == food.id) t.copyWith(excludedFromBudget: true) else t,
      food.copyWith(id: 'manual-food', amount: 10000),
      food.copyWith(
        id: 'pending',
        amount: 90000,
        status: TransactionStatus.pending,
      ),
      food.copyWith(
        id: 'transfer',
        kind: TransactionKind.transfer,
        amount: 500000,
      ),
      food.copyWith(id: 'refund', kind: TransactionKind.refund, amount: 5000),
    ];
    final plan = projectBudgetLedger(budgetFixture(), ledger, baseline);
    expect(plan.spent, 1652500);
    expect(plan.allowances.first.spent, 662500);
    final categorized = projectBudgetLedger(budgetFixture(), [
      for (final t in baseline)
        if (t.id == food.id)
          t.copyWith(category: TransactionCategory.shopping)
        else
          t,
    ], baseline);
    expect(categorized.spent, 1680000);
    expect(categorized.allowances.first.spent, 657500);
    expect(categorized.allowances[1].spent, 372500);
  });
  test('reallocation is atomic, preserves overall allocation and rejects insufficient surplus', () {
    final plan = budgetFixture();
    final changed = plan.reallocate(
      TransactionCategory.entertainment,
      TransactionCategory.food,
      50000,
    );
    expect(changed.monthlyLimit, plan.monthlyLimit);
    expect(changed.allocated, plan.allocated);
    expect(changed.spent, plan.spent);
    expect(changed.allowances.first.limit, 850000);
    expect(changed.allowances.last.limit, 150000);
    expect(
      () => plan.reallocate(
        TransactionCategory.entertainment,
        TransactionCategory.food,
        130000,
      ),
      throwsArgumentError,
    );
    expect(() => plan.withLimit(null, 1000000), throwsArgumentError);
    expect(
      () => plan.withLimit(TransactionCategory.food, 2000000),
      throwsArgumentError,
    );
    expect(
      plan.allowances[3].copyWith(spent: 260000).status,
      BudgetStatus.exceeded,
    );
  });
  test('risk filters and sorting keep settled/fixed allowances on track', () {
    final plan = budgetFixture();
    expect(
      selectAllowances(
        plan,
        BudgetFilter.atRisk,
        BudgetSort.reference,
      ).map((a) => a.category),
      [TransactionCategory.food, TransactionCategory.transport],
    );
    expect(
      selectAllowances(plan, BudgetFilter.onTrack, BudgetSort.reference).length,
      4,
    );
    expect(
      selectAllowances(
        plan,
        BudgetFilter.all,
        BudgetSort.utilization,
      ).first.category,
      TransactionCategory.subscriptions,
    );
    expect(
      selectAllowances(
        plan,
        BudgetFilter.all,
        BudgetSort.remaining,
      ).first.remaining,
      5000,
    );
  });
}
