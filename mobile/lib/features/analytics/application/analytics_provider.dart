import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../budgets/application/budgets_provider.dart';
import '../../transactions/application/transactions_provider.dart';
import '../../transactions/data/transaction_fixture.dart';
import '../domain/analytics_report.dart';
import '../data/analytics_fixture.dart';
import '../domain/project_analytics.dart';

class AnalyticsSelectionController extends Notifier<AnalyticsSelection> {
  @override
  AnalyticsSelection build() => AnalyticsSelection(demoClock);
  void selectDate(DateTime date) =>
      state = AnalyticsSelection(date, state.period);
  void selectPeriod(AnalyticsPeriod period) =>
      state = AnalyticsSelection(state.date, period);
}

final analyticsSelectionProvider =
    NotifierProvider<AnalyticsSelectionController, AnalyticsSelection>(
      AnalyticsSelectionController.new,
    );
final analyticsProvider = FutureProvider<AnalyticsReport>(
  (ref) async => projectAnalytics(
    ref.watch(analyticsSelectionProvider),
    ref.watch(demoLedgerProvider),
    transactionFixture(),
    ref.watch(demoBudgetPlansProvider),
    analyticsFixture(),
  ),
  retry: (_, _) => null,
);
