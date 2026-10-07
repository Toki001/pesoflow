import '../../../core/serialization/values.dart';
import '../../analytics/domain/analytics_report.dart';
import '../../transactions/domain/transaction.dart';

/// A repeatable calendar budget; derived spending is never persisted in the plan.
class SpendingBudget {
  SpendingBudget({
    required this.id,
    required this.name,
    required this.limit,
    required this.period,
    required this.startDate,
    this.category,
    this.enabled = true,
    List<int> thresholds = const [50, 75, 90, 100],
  }) : thresholds = List.unmodifiable(thresholds) {
    if (id.isEmpty ||
        name.trim().isEmpty ||
        name.length > 80 ||
        limit <= 0 ||
        limit > maxMoney ||
        thresholds.any((v) => v < 1 || v > 100) ||
        thresholds.toSet().length != thresholds.length ||
        (category != null &&
            [
              TransactionCategory.income,
              TransactionCategory.transfer,
              TransactionCategory.refund,
            ].contains(category))) {
      throw ArgumentError('Invalid budget.');
    }
  }
  final String id, name;
  final int limit;
  final AnalyticsPeriod period;
  final DateTime startDate;
  final TransactionCategory? category;
  final bool enabled;
  final List<int> thresholds;

  SpendingBudget copyWith({
    String? name,
    int? limit,
    bool? enabled,
    List<int>? thresholds,
  }) => SpendingBudget(
    id: id,
    name: name ?? this.name,
    limit: limit ?? this.limit,
    period: period,
    startDate: startDate,
    category: category,
    enabled: enabled ?? this.enabled,
    thresholds: thresholds ?? this.thresholds,
  );

  Json toJson() => {
    'id': id,
    'name': name,
    'limit': limit,
    'period': period.name,
    'startDate': startDate.toIso8601String(),
    'category': category?.name,
    'enabled': enabled,
    'thresholds': thresholds,
  };
  factory SpendingBudget.fromJson(Json json) => SpendingBudget(
    id: jsonString(json, 'id'),
    name: jsonString(json, 'name', max: 80),
    limit: jsonInt(json, 'limit', min: 1, max: maxMoney),
    period: AnalyticsPeriod.values.byName(json['period'] as String),
    startDate: jsonDate(json, 'startDate'),
    category: json['category'] == null
        ? null
        : TransactionCategory.values.byName(json['category'] as String),
    enabled: json['enabled'] as bool,
    thresholds: (json['thresholds'] as List).cast<int>(),
  );
}

class BudgetProgress {
  const BudgetProgress({
    required this.budget,
    required this.range,
    required this.spent,
    required this.elapsedDays,
  });
  final SpendingBudget budget;
  final AnalyticsSelection range;
  final int spent, elapsedDays;
  int get remaining => budget.limit - spent;
  int get daysLeft => range.days - elapsedDays;
  double get used => spent / budget.limit;
  double get periodElapsed => elapsedDays / range.days;
  int get safeDailyPace =>
      daysLeft == 0 ? 0 : remaining.clamp(0, maxMoney) ~/ daysLeft;
  int get projectedSpend => elapsedDays == 0
      ? 0
      : (spent * range.days + elapsedDays ~/ 2) ~/ elapsedDays;
  int get projectedOverage =>
      (projectedSpend - budget.limit).clamp(0, maxMoney);
}

BudgetProgress evaluateBudget(
  SpendingBudget budget,
  Iterable<TransactionRecord> ledger,
  DateTime now, {
  DateTime? selectedDate,
}) {
  final range = AnalyticsSelection(selectedDate ?? now, budget.period);
  final today = DateTime(now.year, now.month, now.day);
  final elapsed = today.isBefore(range.start)
      ? 0
      : !today.isBefore(range.end)
      ? range.days
      : DateTime.utc(today.year, today.month, today.day)
                .difference(
                  DateTime.utc(
                    range.start.year,
                    range.start.month,
                    range.start.day,
                  ),
                )
                .inDays +
            1;
  final activeStart = AnalyticsSelection(budget.startDate, budget.period).start;
  final spent = ledger
      .where(
        (t) =>
            range.contains(t.occurredAt) &&
            !t.occurredAt.isBefore(activeStart) &&
            !t.occurredAt.isAfter(now) &&
            (budget.category == null || t.category == budget.category),
      )
      .fold<int>(0, (sum, t) => sum + t.budgetImpact);
  return BudgetProgress(
    budget: budget,
    range: range,
    spent: spent,
    elapsedDays: elapsed.clamp(0, range.days),
  );
}
