import '../domain/analytics_report.dart';

// These are screen-specific approved aggregates, not sums of the recent feed.
const analyticsFixtureCategories = [
  AnalyticsCategoryTotal(
    AnalyticsCategory.food,
    520000,
    target: 600000,
    referenceTrend: -6,
  ),
  AnalyticsCategoryTotal(
    AnalyticsCategory.shopping,
    340000,
    target: 400000,
    referenceTrend: 2,
  ),
  AnalyticsCategoryTotal(
    AnalyticsCategory.transport,
    215000,
    target: 250000,
    referenceTrend: 14,
  ),
  AnalyticsCategoryTotal(
    AnalyticsCategory.bills,
    200000,
    context: 'Fixed limit',
  ),
  AnalyticsCategoryTotal(
    AnalyticsCategory.subscriptions,
    155000,
    context: '4 services',
  ),
  AnalyticsCategoryTotal(
    AnalyticsCategory.other,
    250000,
    context: '12 records',
  ),
];
const analyticsFixtureMerchants = [
  MerchantTotal('SM Supermarket', 342050, 2, 'Groceries', unit: 'visits'),
  MerchantTotal('Meralco Electric', 215000, 1, 'Utilities', unit: 'bill'),
  MerchantTotal('Grab', 135000, 6, 'Transit', unit: 'rides'),
  MerchantTotal('Jollibee', 97500, 3, 'Fast Food', unit: 'orders'),
];
List<SpendingPoint> analyticsFixturePoints() => [
  SpendingPoint(DateTime(2024, 10, 1), 0),
  SpendingPoint(DateTime(2024, 10, 8), 600000),
  SpendingPoint(DateTime(2024, 10, 15), 1050000),
  SpendingPoint(DateTime(2024, 10, 24), 1680000),
];

AnalyticsReference analyticsFixture() => AnalyticsReference(
  categories: analyticsFixtureCategories,
  merchants: analyticsFixtureMerchants,
  points: analyticsFixturePoints(),
  previousMonthExpense: 1834000,
  projectedAdditional: 500000,
);
