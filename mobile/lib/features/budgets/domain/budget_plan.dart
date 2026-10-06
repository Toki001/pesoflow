import 'package:freezed_annotation/freezed_annotation.dart';

import '../../transactions/domain/transaction.dart';

part 'budget_plan.freezed.dart';
part 'budget_plan.g.dart';

enum BudgetStatus { healthy, approaching, exceeded, settled, fixed }

enum BudgetFilter { all, atRisk, onTrack }

enum BudgetSort { reference, utilization, remaining, name }

@freezed
abstract class BudgetAllowance with _$BudgetAllowance {
  const BudgetAllowance._();
  const factory BudgetAllowance({
    required TransactionCategory category,
    required String description,
    required int limit,
    @Default(0) int spent,
    @Default(false) bool settled,
    @Default(false) bool fixed,
    int? projectedAdditional,
  }) = _BudgetAllowance;
  factory BudgetAllowance.fromJson(Map<String, dynamic> json) =>
      _$BudgetAllowanceFromJson(json);
  String get name => categoryLabel(category);
  int get remaining => limit - spent;
  double get used => limit <= 0 ? 0 : spent / limit;
  int get percentUsed => limit <= 0 ? 0 : (spent * 100 / limit).round();
  int? get projectedEndTotal =>
      projectedAdditional == null ? null : spent + projectedAdditional!;
  int get projectedOverage {
    final overage = (projectedEndTotal ?? spent) - limit;
    return overage > 0 ? overage : 0;
  }

  BudgetStatus get status => spent >= limit
      ? BudgetStatus.exceeded
      : settled
      ? BudgetStatus.settled
      : fixed
      ? BudgetStatus.fixed
      : spent * 100 >= limit * 80 || projectedOverage > 0
      ? BudgetStatus.approaching
      : BudgetStatus.healthy;
  bool get atRisk =>
      status == BudgetStatus.approaching || status == BudgetStatus.exceeded;
}

@freezed
abstract class BudgetPlan with _$BudgetPlan {
  const BudgetPlan._();
  const factory BudgetPlan({
    required int year,
    required int month,
    required int monthlyLimit,
    required List<BudgetAllowance> allowances,
    @Default([]) List<TransactionCategory> editedCategories,
    @Default(0) int spent,
    int? projectedAdditional,
  }) = _BudgetPlan;
  factory BudgetPlan.fromJson(Map<String, dynamic> json) =>
      _$BudgetPlanFromJson(json);
  String get key => '$year-$month';
  int get remaining => monthlyLimit - spent;
  int get allocated => allowances.fold(0, (sum, a) => sum + a.limit);
  int get percentUsed =>
      monthlyLimit <= 0 ? 0 : (spent * 100 / monthlyLimit).round();
  double get used => monthlyLimit <= 0 ? 0 : spent / monthlyLimit;
  int? get projectedEndTotal =>
      projectedAdditional == null ? null : spent + projectedAdditional!;
  int get periodDays => DateTime(year, month + 1, 0).day;
  int daysLeft(DateTime clock) {
    final period = year * 12 + month;
    final current = clock.year * 12 + clock.month;
    if (current < period) return periodDays;
    if (current > period) return 0;
    return (periodDays - clock.day).clamp(0, periodDays);
  }

  int elapsedDays(DateTime clock) => periodDays - daysLeft(clock);
  int safeDailyPace(DateTime clock) => daysLeft(clock) == 0
      ? 0
      : (remaining > 0 ? remaining : 0) ~/ daysLeft(clock);

  BudgetPlan withLimit(TransactionCategory? category, int limit) {
    if (limit <= 0 || limit > 99999999999) {
      throw ArgumentError('Enter a positive PHP limit.');
    }
    if (category == null) {
      if (limit < allocated) {
        throw ArgumentError(
          'The monthly limit must cover category allowances.',
        );
      }
      return copyWith(monthlyLimit: limit);
    }
    if ([
      TransactionCategory.income,
      TransactionCategory.transfer,
      TransactionCategory.refund,
    ].contains(category)) {
      throw ArgumentError('Choose an expense category.');
    }
    final existing = allowances.where((a) => a.category == category);
    final items = [
      for (final a in allowances)
        if (a.category == category) a.copyWith(limit: limit) else a,
      if (existing.isEmpty)
        BudgetAllowance(
          category: category,
          description: 'Monthly spending allowance',
          limit: limit,
        ),
    ];
    final total = items.fold<int>(0, (sum, a) => sum + a.limit);
    if (monthlyLimit > 0 && total > monthlyLimit) {
      throw ArgumentError('Category allowances exceed the monthly limit.');
    }
    return copyWith(
      monthlyLimit: monthlyLimit == 0 ? limit : monthlyLimit,
      allowances: items,
      editedCategories: {...editedCategories, category}.toList(),
    );
  }

  BudgetPlan reallocate(
    TransactionCategory from,
    TransactionCategory to,
    int amount,
  ) {
    if (amount <= 0 || from == to) {
      throw ArgumentError('Choose a valid reallocation.');
    }
    final donor = allowances.where((a) => a.category == from);
    final target = allowances.where((a) => a.category == to);
    if (donor.isEmpty ||
        target.isEmpty ||
        donor.single.remaining < amount ||
        donor.single.limit <= amount) {
      throw ArgumentError(
        'The source allowance has insufficient remaining budget.',
      );
    }
    return copyWith(
      editedCategories: {...editedCategories, from, to}.toList(),
      allowances: [
        for (final a in allowances)
          if (a.category == from)
            a.copyWith(limit: a.limit - amount)
          else if (a.category == to)
            a.copyWith(limit: a.limit + amount)
          else
            a,
      ],
    );
  }
}

BudgetPlan projectBudgetLedger(
  BudgetPlan base,
  List<TransactionRecord> ledger,
  List<TransactionRecord> baseline,
) {
  bool inMonth(TransactionRecord t) =>
      t.occurredAt.year == base.year && t.occurredAt.month == base.month;
  int contribution(
    List<TransactionRecord> records, {
    TransactionCategory? category,
  }) => records
      .where((t) => inMonth(t) && (category == null || t.category == category))
      .fold(0, (sum, t) => sum + t.budgetImpact);
  return base.copyWith(
    spent: base.spent + contribution(ledger) - contribution(baseline),
    allowances: [
      for (final a in base.allowances)
        a.copyWith(
          spent:
              a.spent +
              contribution(ledger, category: a.category) -
              contribution(baseline, category: a.category),
        ),
    ],
  );
}

List<BudgetAllowance> selectAllowances(
  BudgetPlan plan,
  BudgetFilter filter,
  BudgetSort sort,
) {
  final list = plan.allowances
      .where(
        (a) => switch (filter) {
          BudgetFilter.all => true,
          BudgetFilter.atRisk => a.atRisk,
          BudgetFilter.onTrack => !a.atRisk,
        },
      )
      .toList();
  if (sort != BudgetSort.reference) {
    list.sort((a, b) {
      final result = switch (sort) {
        BudgetSort.utilization => b.used.compareTo(a.used),
        BudgetSort.remaining => a.remaining.compareTo(b.remaining),
        BudgetSort.name => a.name.compareTo(b.name),
        _ => 0,
      };
      return result == 0 ? a.name.compareTo(b.name) : result;
    });
  }
  return list;
}
