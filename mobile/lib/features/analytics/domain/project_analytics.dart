import '../../transactions/domain/transaction.dart';
import '../../budgets/domain/budget_plan.dart';
import 'analytics_report.dart';

String _merchantKey(String merchant) {
  final key = merchant.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  return key == 'grab car' ? 'grab' : key;
}

/// Aggregate once per state change. Budget exclusions do not hide cash expenses.
AnalyticsReport projectAnalytics(
  AnalyticsSelection selection,
  List<TransactionRecord> ledger,
  List<TransactionRecord> baseline,
  Map<String, BudgetPlan> plans,
  AnalyticsReference reference,
) {
  final snapshot = selection.includesOctoberSnapshot;
  bool qualifying(TransactionRecord t) =>
      t.status == TransactionStatus.posted &&
      (t.kind == TransactionKind.expense || t.kind == TransactionKind.refund);
  final current = ledger
      .where((t) => selection.contains(t.occurredAt) && qualifying(t))
      .toList();
  final priorRows = baseline
      .where((t) => selection.contains(t.occurredAt) && qualifying(t))
      .toList();
  final amounts = <AnalyticsCategory, int>{
    if (snapshot)
      for (final c in reference.categories) c.category: c.amount,
  };
  final merchantAmounts = <String, int>{};
  final merchantCounts = <String, int>{};
  final merchantNames = <String, String>{};
  final merchantContexts = <String, String>{};
  if (snapshot) {
    for (final m in reference.merchants) {
      final key = _merchantKey(m.name);
      merchantAmounts[key] = m.amount;
      merchantCounts[key] = m.count;
      merchantNames[key] = m.name;
      merchantContexts[key] = m.context;
    }
    // Known records outside the four ranked merchants remain available for ranking.
    for (final t in priorRows) {
      final key = _merchantKey(t.merchant);
      if (!merchantAmounts.containsKey(key)) {
        merchantAmounts[key] = t.expenseImpact;
        merchantCounts[key] = t.kind == TransactionKind.expense ? 1 : 0;
        merchantNames[key] = t.merchant;
        merchantContexts[key] = categoryLabel(t.category);
      }
    }
  }
  void apply(TransactionRecord t, int sign) {
    final category = analyticsCategory(t.category);
    amounts[category] = (amounts[category] ?? 0) + t.expenseImpact * sign;
    final key = _merchantKey(t.merchant);
    merchantAmounts[key] = (merchantAmounts[key] ?? 0) + t.expenseImpact * sign;
    merchantCounts[key] =
        (merchantCounts[key] ?? 0) +
        (t.kind == TransactionKind.expense ? sign : 0);
    merchantNames.putIfAbsent(key, () => t.merchant.trim());
    merchantContexts.putIfAbsent(key, () => categoryLabel(t.category));
  }

  if (snapshot) {
    for (final t in priorRows) {
      apply(t, -1);
    }
  }
  for (final t in current) {
    apply(t, 1);
  }
  final total = amounts.values.fold<int>(0, (a, b) => a + b);
  final previous = selection.previous;
  final previousSnapshot = previous.includesOctoberSnapshot;
  final sepComparison =
      selection.period == AnalyticsPeriod.month &&
      selection.date.year == 2024 &&
      selection.date.month == 10;
  int expenses(List<TransactionRecord> rows, AnalyticsSelection period) => rows
      .where((t) => period.contains(t.occurredAt))
      .fold(0, (sum, t) => sum + t.expenseImpact);
  final previousTotal =
      (previousSnapshot
          ? reference.total
          : sepComparison
          ? reference.previousMonthExpense
          : 0) +
      expenses(ledger, previous) -
      (previousSnapshot ? expenses(baseline, previous) : 0);
  final plan = plans['${selection.date.year}-${selection.date.month}'];
  final monthly = selection.period == AnalyticsPeriod.month;
  final categories = [
    for (final category in AnalyticsCategory.values)
      if (snapshot || (amounts[category] ?? 0) != 0)
        () {
          final original = reference.categories.firstWhere(
            (c) => c.category == category,
          );
          final matching = plan?.allowances.where(
            (a) =>
                analyticsCategory(a.category) == category &&
                plan.editedCategories.contains(a.category),
          );
          final primary = switch (category) {
            AnalyticsCategory.food => TransactionCategory.food,
            AnalyticsCategory.shopping => TransactionCategory.shopping,
            AnalyticsCategory.transport => TransactionCategory.transport,
            AnalyticsCategory.bills => TransactionCategory.bills,
            AnalyticsCategory.subscriptions =>
              TransactionCategory.subscriptions,
            AnalyticsCategory.other => null,
          };
          int? target = snapshot && monthly ? original.target : null;
          if (monthly && matching != null && matching.isNotEmpty) {
            final editedPrimary = matching.where((a) => a.category == primary);
            target = editedPrimary.isNotEmpty
                ? editedPrimary.single.limit
                : target;
            target =
                (target ?? 0) +
                matching
                    .where((a) => a.category != primary)
                    .fold<int>(0, (sum, a) => sum + a.limit);
          }
          final amount = amounts[category] ?? 0;
          return AnalyticsCategoryTotal(
            category,
            amount,
            target: target,
            referenceTrend: snapshot && monthly && amount == original.amount
                ? original.referenceTrend
                : null,
            context: snapshot && monthly && amount == original.amount
                ? original.context
                : '',
          );
        }(),
  ];
  final merchants =
      [
        for (final key in merchantAmounts.keys)
          if (merchantAmounts[key]! > 0)
            () {
              final fixture = reference.merchants.where(
                (m) => _merchantKey(m.name) == key,
              );
              return MerchantTotal(
                merchantNames[key]!,
                merchantAmounts[key]!,
                merchantCounts[key]!,
                merchantContexts[key]!,
                unit: snapshot && fixture.isNotEmpty
                    ? fixture.first.unit
                    : 'records',
              );
            }(),
      ]..sort((a, b) {
        final amount = b.amount.compareTo(a.amount);
        return amount == 0 ? a.name.compareTo(b.name) : amount;
      });
  final points = <SpendingPoint>[];
  if (snapshot && monthly) {
    final dailyDeltas = <DateTime, int>{};
    void addDelta(TransactionRecord t, int sign) {
      final date = DateTime(
        t.occurredAt.year,
        t.occurredAt.month,
        t.occurredAt.day,
      );
      dailyDeltas[date] = (dailyDeltas[date] ?? 0) + t.expenseImpact * sign;
    }

    for (final t in current) {
      addDelta(t, 1);
    }
    for (final t in priorRows) {
      addDelta(t, -1);
    }
    final dates = {
      ...reference.points.map((p) => p.date),
      ...dailyDeltas.entries.where((e) => e.value != 0).map((e) => e.key),
    }.toList()..sort();
    final trajectory = reference.points;
    int baseAt(DateTime date) {
      for (var i = 1; i < trajectory.length; i++) {
        if (!date.isAfter(trajectory[i].date)) {
          final before = trajectory[i - 1];
          final after = trajectory[i];
          return before.amount +
              (after.amount - before.amount) *
                  (date.day - before.date.day) ~/
                  (after.date.day - before.date.day);
        }
      }
      return trajectory.last.amount;
    }

    int through(List<TransactionRecord> rows, DateTime date) => rows
        .where(
          (t) => !DateTime(
            t.occurredAt.year,
            t.occurredAt.month,
            t.occurredAt.day,
          ).isAfter(date),
        )
        .fold(0, (sum, t) => sum + t.expenseImpact);
    for (final date in dates) {
      points.add(
        SpendingPoint(
          date,
          baseAt(date) + through(current, date) - through(priorRows, date),
        ),
      );
    }
  } else {
    // Dated records are exact; year includes the approved October aggregate.
    final buckets = <DateTime, int>{};
    if (snapshot) buckets[DateTime(2024, 10, 1)] = reference.total;
    void bucket(TransactionRecord t, int sign) {
      final date = selection.period == AnalyticsPeriod.year
          ? DateTime(t.occurredAt.year, t.occurredAt.month)
          : DateTime(t.occurredAt.year, t.occurredAt.month, t.occurredAt.day);
      buckets[date] = (buckets[date] ?? 0) + t.expenseImpact * sign;
    }

    if (snapshot) {
      for (final t in priorRows) {
        bucket(t, -1);
      }
    }
    for (final t in current) {
      bucket(t, 1);
    }
    final dates = buckets.keys.toList()..sort();
    var cumulative = 0;
    if (dates.isNotEmpty && dates.first.isAfter(selection.start)) {
      points.add(SpendingPoint(selection.start, 0));
    }
    for (final date in dates) {
      cumulative += buckets[date]!;
      points.add(SpendingPoint(date, cumulative));
    }
  }
  return AnalyticsReport(
    selection: selection,
    totalExpense: total,
    comparison: ExpenseComparison(total, previousTotal),
    categories: categories,
    merchants: merchants.take(4).toList(),
    points: points,
    hasActivity: snapshot || current.isNotEmpty,
    target: monthly && plan != null && plan.monthlyLimit > 0
        ? plan.monthlyLimit
        : null,
    projectedExpense: snapshot && monthly
        ? total + reference.projectedAdditional
        : null,
    referenceInsight:
        snapshot &&
        monthly &&
        categories.every(
          (c) =>
              c.amount ==
              reference.categories
                  .firstWhere((f) => f.category == c.category)
                  .amount,
        ),
  );
}
