import '../../accounts/domain/financial_account.dart';
import '../../analytics/domain/analytics_report.dart';
import '../../analytics/domain/financial_analytics.dart';
import '../../budgets/domain/spending_budget.dart';
import '../../workspace/domain/finance_workspace.dart';
import 'dashboard.dart';

Dashboard financialDashboard(FinanceWorkspace workspace, DateTime now) {
  final month = AnalyticsSelection(now);
  final report = financialAnalytics(
    selection: month,
    ledger: workspace.ledger,
    now: now,
    budgets: workspace.budgets,
  );
  final accounts = workspace.accounts.where((a) => !a.archived).toList();
  final balance = accounts.fold<int>(
    0,
    (sum, a) =>
        sum +
        accountBalance(
          a,
          workspace.ledger.where((t) => !t.occurredAt.isAfter(now)),
        ),
  );
  final monthly = workspace.budgets.where(
    (b) =>
        b.enabled &&
        b.period == AnalyticsPeriod.month &&
        !month.start.isBefore(AnalyticsSelection(b.startDate).start),
  );
  final overall = monthly.where((b) => b.category == null);
  final progress = overall.isEmpty
      ? null
      : evaluateBudget(overall.first, workspace.ledger, now);
  final recent =
      workspace.ledger.where((t) => !t.occurredAt.isAfter(now)).toList()
        ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
  final renewals =
      workspace.subscriptions
          .where(
            (p) => p.active && p.daysUntil(now) >= 0 && p.daysUntil(now) <= 7,
          )
          .toList()
        ..sort((a, b) => a.nextRenewal.compareTo(b.nextRenewal));
  return Dashboard(
    name: workspace.preferences.name,
    asOf: now,
    balance: balance,
    monthChange: report.netFlow,
    monthChangePercent: '',
    inflow: report.totalIncome,
    outflow: report.totalExpense,
    savings: report.savings,
    savingsRate: report.savingsRate?.toStringAsFixed(1) ?? '—',
    transactionCount: report.expenseCount,
    accountCount: accounts.length,
    budgetLimit: progress?.budget.limit ?? 0,
    budgetSpent: progress?.spent ?? 0,
    daysLeft:
        progress?.daysLeft ??
        DateTime(now.year, now.month + 1, 0).day - now.day,
    projectedExtraSavings: progress == null
        ? 0
        : progress.budget.limit - progress.projectedSpend,
    budgets: [
      for (final budget in monthly.where((b) => b.category != null))
        () {
          final p = evaluateBudget(budget, workspace.ledger, now);
          return BudgetSnapshot(
            name: categoryLabel(budget.category!),
            spent: p.spent,
            limit: budget.limit,
            status: p.spent > budget.limit
                ? 'Above limit'
                : p.spent == budget.limit
                ? 'Limit reached'
                : p.used >= .8
                ? 'Approaching limit'
                : 'On track',
          );
        }(),
    ],
    transactions: recent.take(4).toList(),
    bills: [
      for (final plan in renewals.take(4))
        UpcomingBill(
          name: plan.name,
          amount: plan.amount,
          daysUntilDue: plan.daysUntil(now),
          estimated: true,
        ),
    ],
  );
}
