import '../../budgets/domain/spending_budget.dart';
import '../../transactions/domain/categorization.dart';
import '../../transactions/domain/transaction.dart';
import 'analytics_report.dart';

/// Exact posted records only. No reference aggregates, invented history or trend.
AnalyticsReport financialAnalytics({
  required AnalyticsSelection selection,
  required Iterable<TransactionRecord> ledger,
  required DateTime now,
  Iterable<SpendingBudget> budgets = const [],
}) {
  final posted = ledger
      .where(
        (t) =>
            t.status == TransactionStatus.posted && !t.occurredAt.isAfter(now),
      )
      .toList();
  final current = posted
      .where((t) => selection.contains(t.occurredAt))
      .toList();
  final previous = posted.where(
    (t) => selection.previous.contains(t.occurredAt),
  );
  final expenses = current.where(
    (t) =>
        t.kind == TransactionKind.expense || t.kind == TransactionKind.refund,
  );
  final categoryTotals = <AnalyticsCategory, int>{};
  final detailed = <TransactionCategory, int>{};
  final merchantTotals = <String, int>{};
  final merchantRows = <String, List<TransactionRecord>>{};
  final days = <DateTime, int>{};
  var total = 0;
  for (final t in expenses) {
    final impact = t.expenseImpact;
    total += impact;
    final category = analyticsCategory(t.category);
    categoryTotals[category] = (categoryTotals[category] ?? 0) + impact;
    detailed[t.category] = (detailed[t.category] ?? 0) + impact;
    final key = normalizeMerchant(t.merchant);
    merchantTotals[key] = (merchantTotals[key] ?? 0) + impact;
    (merchantRows[key] ??= []).add(t);
    final day = DateTime(
      t.occurredAt.year,
      t.occurredAt.month,
      t.occurredAt.day,
    );
    days[day] = (days[day] ?? 0) + impact;
  }
  final overall = budgets.where(
    (b) =>
        b.enabled &&
        b.category == null &&
        b.period == selection.period &&
        !selection.start.isBefore(
          AnalyticsSelection(b.startDate, b.period).start,
        ),
  );
  // One overall limit per cycle is enforced by workspace commands.
  final plan = overall.isEmpty ? null : overall.first;
  final progress = plan == null
      ? null
      : evaluateBudget(plan, posted, now, selectedDate: selection.date);
  final today = DateTime(now.year, now.month, now.day);
  final elapsed = today.isBefore(selection.start)
      ? 0
      : !today.isBefore(selection.end)
      ? selection.days
      : DateTime.utc(today.year, today.month, today.day)
                .difference(
                  DateTime.utc(
                    selection.start.year,
                    selection.start.month,
                    selection.start.day,
                  ),
                )
                .inDays +
            1;
  final merchants =
      [
        for (final e in merchantTotals.entries)
          if (e.value > 0)
            MerchantTotal(
              merchantRows[e.key]!.first.merchant,
              e.value,
              merchantRows[e.key]!
                  .where((t) => t.kind == TransactionKind.expense)
                  .length,
              categoryLabel(merchantRows[e.key]!.first.category),
            ),
      ]..sort(
        (a, b) => b.amount == a.amount
            ? a.name.compareTo(b.name)
            : b.amount.compareTo(a.amount),
      );
  final orderedDays = days.keys.toList()..sort();
  final points = <SpendingPoint>[];
  var cumulative = 0;
  if (orderedDays.isNotEmpty && orderedDays.first.isAfter(selection.start)) {
    points.add(SpendingPoint(selection.start, 0));
  }
  for (final day in orderedDays) {
    cumulative += days[day]!;
    points.add(SpendingPoint(day, cumulative));
  }
  final rankedDays = days.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  final rankedCategories = detailed.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  final categories = [
    for (final e in categoryTotals.entries)
      AnalyticsCategoryTotal(
        e.key,
        e.value,
        target: _categoryTarget(e.key, budgets, selection),
      ),
  ]..sort((a, b) => b.amount.compareTo(a.amount));
  return AnalyticsReport(
    selection: selection,
    totalExpense: total,
    totalIncome: current
        .where((t) => t.kind == TransactionKind.income)
        .fold(0, (sum, t) => sum + t.amount),
    expenseCount: current
        .where((t) => t.kind == TransactionKind.expense)
        .length,
    grossExpense: current
        .where((t) => t.kind == TransactionKind.expense)
        .fold(0, (sum, t) => sum + t.amount),
    elapsedDays: elapsed,
    highestSpendingDay: rankedDays.isEmpty || rankedDays.first.value <= 0
        ? null
        : SpendingPoint(rankedDays.first.key, rankedDays.first.value),
    highestCategory:
        rankedCategories.isEmpty || rankedCategories.first.value <= 0
        ? null
        : rankedCategories.first.key,
    comparison: ExpenseComparison(
      total,
      previous.fold(0, (sum, t) => sum + t.expenseImpact),
    ),
    categories: categories,
    merchants: merchants.take(4).toList(),
    points: points,
    hasActivity: current.isNotEmpty,
    target: plan?.limit,
    projectedExpense: progress?.projectedSpend,
  );
}

int? _categoryTarget(
  AnalyticsCategory category,
  Iterable<SpendingBudget> budgets,
  AnalyticsSelection range,
) {
  final matches = budgets.where(
    (b) =>
        b.enabled &&
        b.category != null &&
        analyticsCategory(b.category!) == category &&
        b.period == range.period &&
        !range.start.isBefore(AnalyticsSelection(b.startDate, b.period).start),
  );
  return matches.isEmpty
      ? null
      : matches.fold<int>(0, (sum, b) => sum + b.limit);
}
