import 'package:flutter_test/flutter_test.dart';
import 'package:pesoflow/features/accounts/domain/financial_account.dart';
import 'package:pesoflow/features/analytics/domain/analytics_report.dart';
import 'package:pesoflow/features/budgets/domain/spending_budget.dart';
import 'package:pesoflow/features/transactions/domain/transaction.dart';

FinancialAccount account(String id, int opening) => FinancialAccount(
  id: id,
  name: id,
  type: AccountType.cash,
  startingBalance: opening,
  currency: 'PHP',
  createdAt: DateTime(2026),
);
TransactionRecord record(
  String id,
  TransactionKind kind,
  int amount, {
  String from = 'cash',
  String? to,
  DateTime? date,
  TransactionStatus status = TransactionStatus.posted,
  bool excluded = false,
}) => TransactionRecord(
  id: id,
  merchant: id,
  metadata: '',
  amount: amount,
  occurredAt: date ?? DateTime(2026, 10, 7),
  kind: kind,
  category: TransactionCategory.food,
  account: from,
  accountId: from,
  destinationAccount: to,
  destinationAccountId: to,
  status: status,
  excludedFromBudget: excluded,
);

void main() {
  test(
    'manual balances reconcile income, expense, refund and both transfer sides',
    () {
      final ledger = [
        record('income', TransactionKind.income, 10000),
        record('expense', TransactionKind.expense, 3250),
        record('refund', TransactionKind.refund, 250),
        record('transfer', TransactionKind.transfer, 5000, to: 'wallet'),
        record(
          'pending',
          TransactionKind.expense,
          99999,
          status: TransactionStatus.pending,
        ),
      ];
      expect(accountBalance(account('cash', 1000), ledger), 3000);
      expect(accountBalance(account('wallet', 2000), ledger), 7000);
      expect(ledger.fold<int>(0, (sum, t) => sum + t.expenseImpact), 3000);
      expect(ledger.fold<int>(0, (sum, t) => sum + t.cashFlowImpact), 7000);
    },
  );
  test('provider observation is distinct from the manually edited ledger', () {
    final provider = FinancialAccount(
      id: 'provider',
      name: 'Authorized account',
      type: AccountType.bank,
      startingBalance: 0,
      currency: 'PHP',
      createdAt: DateTime(2026),
      source: BalanceSource.provider,
      connectionId: 'real-connection',
      reportedBalance: 4000,
      reportedAt: DateTime(2026, 10, 7),
    );
    expect(
      accountBalance(provider, [
        record('manual', TransactionKind.expense, 500, from: 'provider'),
      ]),
      4000,
    );
    expect(
      () => account('raw', 0).copyWith(maskedIdentifier: '1234567890123456'),
      throwsArgumentError,
    );
  });
  test(
    'budget ignores transfers, income, pending, excluded and future expenses',
    () {
      final budget = SpendingBudget(
        id: 'food',
        name: 'Food',
        limit: 10000,
        period: AnalyticsPeriod.month,
        startDate: DateTime(2026, 10),
        category: TransactionCategory.food,
      );
      final ledger = [
        record('expense', TransactionKind.expense, 4000),
        record('refund', TransactionKind.refund, 1000),
        record('income', TransactionKind.income, 100000),
        record('transfer', TransactionKind.transfer, 100000, to: 'wallet'),
        record('excluded', TransactionKind.expense, 100000, excluded: true),
        record(
          'pending',
          TransactionKind.expense,
          100000,
          status: TransactionStatus.pending,
        ),
        record(
          'future',
          TransactionKind.expense,
          100000,
          date: DateTime(2026, 10, 8),
        ),
      ];
      final result = evaluateBudget(budget, ledger, DateTime(2026, 10, 7, 23));
      expect(result.spent, 3000);
      expect(result.remaining, 7000);
      expect(result.elapsedDays, 7);
      expect(result.daysLeft, 24);
      expect(result.safeDailyPace, 291);
      expect(result.projectedSpend, 13286);
      expect(result.projectedOverage, 3286);
    },
  );
  test('calendar budget periods handle leap years, Monday weeks and empty future ranges', () {
    for (final (period, days) in [
      (AnalyticsPeriod.day, 1),
      (AnalyticsPeriod.week, 7),
      (AnalyticsPeriod.month, 29),
      (AnalyticsPeriod.year, 366),
    ]) {
      final plan = SpendingBudget(
        id: period.name,
        name: 'Plan',
        limit: 10000,
        period: period,
        startDate: DateTime(2024, 2),
      );
      final result = evaluateBudget(plan, [], DateTime(2024, 2, 20));
      expect(result.range.days, days);
      expect(result.projectedSpend, 0);
      expect(result.used, 0);
      expect(result.range.previous.end, result.range.start);
      final future = evaluateBudget(
        plan,
        [],
        DateTime(2024, 2, 20),
        selectedDate: DateTime(2025),
      );
      expect(future.elapsedDays, 0);
      expect(future.projectedSpend, 0);
    }
  });
}
