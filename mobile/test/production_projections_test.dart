import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pesoflow/core/time/clock.dart';
import 'package:pesoflow/features/accounts/application/accounts_provider.dart';
import 'package:pesoflow/features/accounts/domain/financial_account.dart';
import 'package:pesoflow/features/analytics/application/analytics_provider.dart';
import 'package:pesoflow/features/budgets/application/budgets_provider.dart';
import 'package:pesoflow/features/dashboard/application/dashboard_provider.dart';
import 'package:pesoflow/features/transactions/application/transactions_provider.dart';
import 'package:pesoflow/features/transactions/domain/manual_transaction_draft.dart';
import 'package:pesoflow/features/transactions/domain/transaction.dart';
import 'package:pesoflow/features/workspace/application/finance_controller.dart';

import 'support/finance_fakes.dart';

void main() {
  test('all screen projections follow durable create, edit, exclude, delete and transfer commands', () async {
    final repo = FakeFinanceRepository();
    final now = DateTime(2026, 10, 7, 12);
    final c = ProviderContainer(
      overrides: [
        financeRepositoryProvider.overrideWithValue(repo),
        initialWorkspaceProvider.overrideWithValue(repo.workspace),
        clockProvider.overrideWithValue(() => now),
      ],
    );
    addTearDown(c.dispose);
    final commands = c.read(financeControllerProvider.notifier);
    for (final id in ['cash', 'bank']) {
      await commands.saveAccount(
        FinancialAccount(
          id: id,
          name: id,
          type: AccountType.cash,
          startingBalance: 100000,
          currency: 'PHP',
          createdAt: now,
        ),
      );
    }
    final plans = c.read(budgetPlansProvider.notifier);
    await plans.setLimit(2026, 10, null, 100000);
    await plans.setLimit(2026, 10, TransactionCategory.food, 50000);
    final ledger = c.read(ledgerProvider.notifier);
    Future<void> add(
      TransactionKind kind,
      int amount,
      String merchant,
    ) => ledger.createManual(
      ManualTransactionDraft(
        kind: kind,
        amount: amount,
        merchant: merchant,
        category: kind == TransactionKind.income
            ? TransactionCategory.salary
            : kind == TransactionKind.transfer
            ? TransactionCategory.transfer
            : TransactionCategory.food,
        account: 'cash',
        accountId: 'cash',
        destinationAccount: kind == TransactionKind.transfer ? 'bank' : null,
        destinationAccountId: kind == TransactionKind.transfer ? 'bank' : null,
        occurredAt: now,
      ),
    );
    Future<void> totals(
      int balance,
      int income,
      int expense,
      int budget,
    ) async {
      final home = (await c.read(dashboardProvider.future))!;
      final analytics = await c.read(analyticsProvider.future);
      final accounts = await c.read(accountsProvider.future);
      final plan = await c.read(budgetsProvider.future);
      expect(home.balance, balance);
      expect(accounts.availableBalance, balance);
      expect(home.inflow, income);
      expect(analytics.totalIncome, income);
      expect(home.outflow, expense);
      expect(analytics.totalExpense, expense);
      expect(home.budgetSpent, budget);
      expect(plan.spent, budget);
      expect(await c.read(transactionsProvider.future), repo.workspace.ledger);
    }

    await totals(200000, 0, 0, 0);
    await add(TransactionKind.expense, 12345, 'Lunch');
    await totals(187655, 0, 12345, 12345);
    await add(TransactionKind.income, 300000, 'Salary');
    await totals(487655, 300000, 12345, 12345);
    await add(TransactionKind.transfer, 10000, 'Transfer');
    await totals(487655, 300000, 12345, 12345);
    expect(
      (await c.read(accountsProvider.future)).accounts.last.balance,
      110000,
    );
    final expense = repo.workspace.ledger.first;
    await ledger.update(expense.copyWith(amount: 20000));
    await totals(480000, 300000, 20000, 20000);
    await ledger.update(
      expense.copyWith(amount: 20000, excludedFromBudget: true),
    );
    await totals(480000, 300000, 20000, 0);
    repo.failSave = true;
    await expectLater(ledger.remove(expense.id), throwsStateError);
    await totals(480000, 300000, 20000, 0);
    repo.failSave = false;
    await ledger.remove(expense.id);
    await totals(500000, 300000, 0, 0);
    // Removing a used account archives it and preserves the ledger/history.
    await c.read(accountsProvider.notifier).disconnect('bank');
    expect(repo.workspace.accounts.last.archived, true);
    expect(repo.workspace.ledger, hasLength(2));
    await totals(390000, 300000, 0, 0);
    await c.read(accountsProvider.notifier).disconnect('bank');
    await totals(500000, 300000, 0, 0);
  });
  test('reallocation validates current projections and commits both limits atomically', () async {
    final repo = FakeFinanceRepository();
    final c = ProviderContainer(
      overrides: [
        financeRepositoryProvider.overrideWithValue(repo),
        initialWorkspaceProvider.overrideWithValue(repo.workspace),
        clockProvider.overrideWithValue(() => DateTime(2026, 10, 31)),
      ],
    );
    addTearDown(c.dispose);
    final plans = c.read(budgetPlansProvider.notifier);
    await plans.setLimit(2026, 10, TransactionCategory.entertainment, 100000);
    await plans.setLimit(2026, 10, TransactionCategory.food, 100000);
    final revision = repo.workspace.revision;
    await plans.reallocate(
      2026,
      10,
      TransactionCategory.entertainment,
      TransactionCategory.food,
      50000,
    );
    expect(repo.workspace.revision, revision + 1);
    expect(repo.workspace.budgets.map((b) => b.limit), [50000, 150000]);
    final before = repo.workspace;
    await expectLater(
      plans.reallocate(
        2026,
        10,
        TransactionCategory.entertainment,
        TransactionCategory.food,
        50000,
      ),
      throwsArgumentError,
    );
    expect(repo.workspace, same(before));
  });
}
