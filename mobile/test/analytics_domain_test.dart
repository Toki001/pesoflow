import 'package:flutter_test/flutter_test.dart';

import 'fixtures/features/analytics/data/analytics_fixture.dart';

import 'package:pesoflow/features/analytics/domain/analytics_report.dart';

import 'legacy/features/analytics/domain/project_analytics.dart';
import 'fixtures/features/budgets/data/budget_fixture.dart';

import 'package:pesoflow/features/budgets/domain/budget_plan.dart';

import 'fixtures/features/transactions/data/transaction_fixture.dart';

import 'package:pesoflow/features/transactions/domain/transaction.dart';

AnalyticsReport report({
  List<TransactionRecord>? ledger,
  AnalyticsSelection? selection,
  Map<String, BudgetPlan>? plans,
}) => projectAnalytics(
  selection ?? AnalyticsSelection(demoClock),
  ledger ?? transactionFixture(),
  transactionFixture(),
  plans ?? {'2024-10': budgetFixture()},
  analyticsFixture(),
);
TransactionRecord record(
  String id,
  int amount, {
  TransactionKind kind = TransactionKind.expense,
  TransactionCategory category = TransactionCategory.food,
  DateTime? date,
  String merchant = 'Jollibee',
  TransactionStatus status = TransactionStatus.posted,
}) => TransactionRecord(
  id: id,
  merchant: merchant,
  metadata: '',
  amount: amount,
  occurredAt: date ?? demoClock,
  kind: kind,
  category: category,
  status: status,
);

void main() {
  test('approved aggregates, comparison, exact daily average and forecast', () {
    final value = report();
    expect(value.totalExpense, 1680000);
    expect(value.dailyAverage, 54193);
    expect(value.comparison.change, -154000);
    expect(value.comparison.percent, closeTo(-8.4, .01));
    expect(value.projectedExpense, 2180000);
    expect(value.belowTargetPercent, 12);
    expect(value.categories.map((c) => c.amount), [
      520000,
      340000,
      215000,
      200000,
      155000,
      250000,
    ]);
    expect(value.points.last.amount, value.totalExpense);
    expect(value.merchants.map((m) => m.name), [
      'SM Supermarket',
      'Meralco Electric',
      'Grab',
      'Jollibee',
    ]);
    expect(() => value.categories.clear(), throwsUnsupportedError);
  });
  test(
    'internal transfers, pending records and income never count as expense',
    () {
      final value = report(
        ledger: [
          ...transactionFixture(),
          record('transfer-new', 500000, kind: TransactionKind.transfer),
          record('income-new', 500000, kind: TransactionKind.income),
          record('pending-new', 500000, status: TransactionStatus.pending),
        ],
      );
      expect(value.totalExpense, 1680000);
      expect(value.merchants.first.amount, 342050);
    },
  );
  test('exclusion only affects budgets; refunds offset analytics expense', () {
    final purchase = record(
      'purchase-new',
      50000,
    ).copyWith(excludedFromBudget: true);
    final bought = report(ledger: [...transactionFixture(), purchase]);
    expect(bought.totalExpense, 1730000);
    expect(bought.referenceInsight, false);
    final refunded = report(
      ledger: [
        ...transactionFixture(),
        purchase,
        record('refund-new', 50000, kind: TransactionKind.refund),
      ],
    );
    expect(refunded.totalExpense, 1680000);
    expect(refunded.categories.first.amount, 520000);
    expect(refunded.points.last.amount, 1680000);
  });
  test(
    'recategorization and posting preserve snapshot without counting twice',
    () {
      final baseline = transactionFixture();
      final ledger = [
        for (final t in baseline)
          if (t.id == 'jollibee')
            t.copyWith(category: TransactionCategory.shopping)
          else if (t.id == 'starbucks')
            t.copyWith(status: TransactionStatus.posted)
          else
            t,
      ];
      final value = report(ledger: ledger);
      expect(value.totalExpense, 1704000);
      expect(value.categories.first.amount, 511500);
      expect(value.categories[1].amount, 372500);
      expect(value.categories.first.referenceTrend, null);
      expect(value.points.last.amount, value.totalExpense);
    },
  );
  test('merchant aliases, ranking, counts and tie order are deterministic', () {
    final value = report(
      ledger: [
        ...transactionFixture(),
        record(
          'ride-new',
          250000,
          merchant: '  Grab   Car ',
          category: TransactionCategory.transport,
        ),
      ],
    );
    expect(value.merchants.first.name, 'Grab');
    expect(value.merchants.first.amount, 385000);
    expect(value.merchants.first.count, 7);
    final tied = report(
      selection: AnalyticsSelection(DateTime(2025, 1), AnalyticsPeriod.month),
      ledger: [
        record('b', 500, date: DateTime(2025, 1, 1), merchant: 'B'),
        record('a', 500, date: DateTime(2025, 1, 1), merchant: 'A'),
      ],
    );
    expect(tied.merchants.map((m) => m.name), ['A', 'B']);
  });
  test('period boundaries include start and exclude end across leap years', () {
    final leap = AnalyticsSelection(DateTime(2024, 2, 29));
    expect(leap.days, 29);
    expect(leap.previous.start, DateTime(2024, 1));
    final week = AnalyticsSelection(DateTime(2025, 1, 1), AnalyticsPeriod.week);
    expect(week.start, DateTime(2024, 12, 30));
    expect(week.end, DateTime(2025, 1, 6));
    expect(week.days, 7);
    expect(week.contains(week.end), false);
    expect(
      AnalyticsSelection(DateTime(2024, 1), AnalyticsPeriod.year).days,
      366,
    );
  });
  test(
    'day and week use dated records; year includes the October aggregate',
    () {
      expect(
        report(selection: AnalyticsSelection(demoClock, AnalyticsPeriod.day))
            .totalExpense,
        53500,
      );
      expect(
        report(selection: AnalyticsSelection(demoClock, AnalyticsPeriod.week))
            .totalExpense,
        71500,
      );
      final year = report(
        selection: AnalyticsSelection(demoClock, AnalyticsPeriod.year),
      );
      expect(year.totalExpense, 1680000);
      expect(year.points.last.amount, 1680000);
      expect(year.projectedExpense, null);
    },
  );
  test(
    'zero previous period is new spending without an infinite percentage',
    () {
      expect(const ExpenseComparison(50000, 0).percent, null);
      expect(const ExpenseComparison(0, 0).percent, null);
      expect(const ExpenseComparison(0, 50000).percent, -100);
      final empty = report(selection: AnalyticsSelection(DateTime(2025, 2)));
      expect(empty.hasActivity, false);
      expect(empty.dailyAverage, 0);
      expect(empty.categories, isEmpty);
    },
  );
  test('refund-only and offset periods retain activity and signed values', () {
    final selection = AnalyticsSelection(DateTime(2025, 2));
    final refunded = report(
      selection: selection,
      ledger: [
        record(
          'refund',
          10000,
          date: DateTime(2025, 2, 3),
          kind: TransactionKind.refund,
        ),
      ],
    );
    expect(refunded.totalExpense, -10000);
    expect(refunded.hasActivity, true);
    expect(refunded.positiveCategoryTotal, 0);
    expect(refunded.categories.first.share(refunded.totalExpense), 100);
    expect(refunded.points.last.amount, -10000);
  });
  test(
    'explicit category edits and monthly limits update analytics targets',
    () {
      final edited = budgetFixture()
          .withLimit(TransactionCategory.food, 900000)
          .withLimit(null, 3000000);
      final value = report(plans: {'2024-10': edited});
      expect(value.categories.first.target, 900000);
      expect(value.target, 3000000);
      expect(value.totalExpense, 1680000);
      final next = report(
        selection: AnalyticsSelection(DateTime(2024, 11)),
        ledger: [
          ...transactionFixture(),
          record('nov', 10000, date: DateTime(2024, 11, 1)),
        ],
      );
      expect(next.comparison.previous, 1680000);
      expect(next.totalExpense, 10000);
    },
  );
  test('grouped Food target includes an explicitly added Coffee allowance', () {
    final edited = budgetFixture().withLimit(
      TransactionCategory.coffee,
      100000,
    );
    final value = report(plans: {'2024-10': edited});
    expect(value.categories.first.target, 700000);
    expect(value.categories.first.amount, 520000);
  });
  test(
    'moving an expense between months adjusts both comparisons and charts',
    () {
      final ledger = [
        for (final t in transactionFixture())
          if (t.id == 'jollibee')
            t.copyWith(occurredAt: DateTime(2024, 11, 1))
          else
            t,
      ];
      final october = report(ledger: ledger);
      expect(october.totalExpense, 1647500);
      expect(october.points.last.amount, october.totalExpense);
      final november = report(
        ledger: ledger,
        selection: AnalyticsSelection(DateTime(2024, 11)),
      );
      expect(november.totalExpense, 32500);
      expect(november.comparison.previous, 1647500);
      expect(november.points.last.amount, 32500);
    },
  );
}
