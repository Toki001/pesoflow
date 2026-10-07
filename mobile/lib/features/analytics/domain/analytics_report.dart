import '../../transactions/domain/transaction.dart';

enum AnalyticsPeriod { day, week, month, year }

class AnalyticsSelection {
  const AnalyticsSelection(this.date, [this.period = AnalyticsPeriod.month]);
  final DateTime date;
  final AnalyticsPeriod period;
  DateTime get start => switch (period) {
    AnalyticsPeriod.day => DateTime(date.year, date.month, date.day),
    AnalyticsPeriod.week => DateTime(
      date.year,
      date.month,
      date.day - date.weekday + 1,
    ),
    AnalyticsPeriod.month => DateTime(date.year, date.month),
    AnalyticsPeriod.year => DateTime(date.year),
  };
  DateTime get end => switch (period) {
    AnalyticsPeriod.day => DateTime(date.year, date.month, date.day + 1),
    AnalyticsPeriod.week => DateTime(start.year, start.month, start.day + 7),
    AnalyticsPeriod.month => DateTime(date.year, date.month + 1),
    AnalyticsPeriod.year => DateTime(date.year + 1),
  };
  // UTC calendar dates prevent local daylight-saving transitions changing counts.
  int get days => DateTime.utc(
    end.year,
    end.month,
    end.day,
  ).difference(DateTime.utc(start.year, start.month, start.day)).inDays;
  AnalyticsSelection get previous => AnalyticsSelection(switch (period) {
    AnalyticsPeriod.day => DateTime(date.year, date.month, date.day - 1),
    AnalyticsPeriod.week => DateTime(date.year, date.month, date.day - 7),
    AnalyticsPeriod.month => DateTime(date.year, date.month - 1, 1),
    AnalyticsPeriod.year => DateTime(date.year - 1, date.month, date.day),
  }, period);
  bool contains(DateTime value) =>
      !value.isBefore(start) && value.isBefore(end);
  bool get includesOctoberSnapshot =>
      (period == AnalyticsPeriod.month || period == AnalyticsPeriod.year) &&
      contains(DateTime(2024, 10, 24));
}

enum AnalyticsCategory {
  food,
  shopping,
  transport,
  bills,
  subscriptions,
  other,
}

AnalyticsCategory analyticsCategory(TransactionCategory category) =>
    switch (category) {
      TransactionCategory.food ||
      TransactionCategory.coffee => AnalyticsCategory.food,
      TransactionCategory.shopping => AnalyticsCategory.shopping,
      TransactionCategory.transport => AnalyticsCategory.transport,
      TransactionCategory.bills => AnalyticsCategory.bills,
      TransactionCategory.subscriptions => AnalyticsCategory.subscriptions,
      _ => AnalyticsCategory.other,
    };
String analyticsCategoryName(AnalyticsCategory category) => switch (category) {
  AnalyticsCategory.food => 'Food & Dining',
  AnalyticsCategory.shopping => 'Shopping',
  AnalyticsCategory.transport => 'Transport',
  AnalyticsCategory.bills => 'Bills & Utilities',
  AnalyticsCategory.subscriptions => 'Subscriptions',
  AnalyticsCategory.other => 'Other',
};

class AnalyticsCategoryTotal {
  const AnalyticsCategoryTotal(
    this.category,
    this.amount, {
    this.target,
    this.referenceTrend,
    this.context = '',
  });
  final AnalyticsCategory category;
  final int amount;
  final int? target;
  // Independent illustrative trends from the approved export, not reconstructed history.
  final int? referenceTrend;
  final String context;
  double share(int total) => total == 0 ? 0 : amount * 100 / total;
}

class MerchantTotal {
  const MerchantTotal(
    this.name,
    this.amount,
    this.count,
    this.context, {
    this.unit = 'records',
  });
  final String name;
  final int amount;
  final int count;
  final String context;
  final String unit;
}

class SpendingPoint {
  const SpendingPoint(this.date, this.amount);
  final DateTime date;
  final int amount;
}

class ExpenseComparison {
  const ExpenseComparison(this.current, this.previous);
  final int current;
  final int previous;
  int get change => current - previous;
  double? get percent => previous == 0 ? null : change * 100 / previous.abs();
}

class AnalyticsReport {
  AnalyticsReport({
    required this.selection,
    required this.totalExpense,
    required this.comparison,
    required List<AnalyticsCategoryTotal> categories,
    required List<MerchantTotal> merchants,
    required List<SpendingPoint> points,
    required this.hasActivity,
    this.target,
    this.projectedExpense,
    this.referenceInsight = false,
    this.totalIncome = 0,
    this.expenseCount = 0,
    this.grossExpense = 0,
    this.elapsedDays,
    this.highestSpendingDay,
    this.highestCategory,
  }) : categories = List.unmodifiable(categories),
       merchants = List.unmodifiable(merchants),
       points = List.unmodifiable(points);
  final AnalyticsSelection selection;
  final int totalExpense;
  final ExpenseComparison comparison;
  final List<AnalyticsCategoryTotal> categories;
  final List<MerchantTotal> merchants;
  final List<SpendingPoint> points;
  final bool hasActivity;
  final int? target;
  final int? projectedExpense;
  final bool referenceInsight;
  final int totalIncome, expenseCount, grossExpense;
  final int? elapsedDays;
  final SpendingPoint? highestSpendingDay;
  final TransactionCategory? highestCategory;
  int get netFlow => totalIncome - totalExpense;
  int get savings => netFlow;
  double? get savingsRate =>
      totalIncome == 0 ? null : savings * 100 / totalIncome;
  int get averageTransaction =>
      expenseCount == 0 ? 0 : grossExpense ~/ expenseCount;
  int get dailyAverage => (elapsedDays ?? selection.days) == 0
      ? 0
      : totalExpense ~/ (elapsedDays ?? selection.days);
  int? get belowTargetPercent =>
      target == null || target! <= 0 || projectedExpense == null
      ? null
      : (target! - projectedExpense!) * 100 ~/ target!;
  int get positiveCategoryTotal =>
      categories.fold(0, (sum, c) => sum + (c.amount > 0 ? c.amount : 0));
}

/// Read-only design fixture input kept separate from ledger projections.
class AnalyticsReference {
  AnalyticsReference({
    required List<AnalyticsCategoryTotal> categories,
    required List<MerchantTotal> merchants,
    required List<SpendingPoint> points,
    required this.previousMonthExpense,
    required this.projectedAdditional,
  }) : categories = List.unmodifiable(categories),
       merchants = List.unmodifiable(merchants),
       points = List.unmodifiable(points);
  final List<AnalyticsCategoryTotal> categories;
  final List<MerchantTotal> merchants;
  final List<SpendingPoint> points;
  final int previousMonthExpense;
  final int projectedAdditional;
  int get total => categories.fold(0, (sum, c) => sum + c.amount);
}
