import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pesoflow/core/time/clock.dart';
import 'package:pesoflow/features/workspace/application/finance_controller.dart';
import 'package:pesoflow/features/analytics/domain/analytics_report.dart';
import 'package:pesoflow/features/analytics/domain/financial_analytics.dart';

class AnalyticsSelectionController extends Notifier<AnalyticsSelection> {
  @override
  AnalyticsSelection build() => AnalyticsSelection(ref.read(clockProvider)());
  void selectDate(DateTime date) =>
      state = AnalyticsSelection(date, state.period);
  void selectPeriod(AnalyticsPeriod period) =>
      state = AnalyticsSelection(state.date, period);
}

final analyticsSelectionProvider =
    NotifierProvider<AnalyticsSelectionController, AnalyticsSelection>(
      AnalyticsSelectionController.new,
    );
final analyticsProvider = FutureProvider<AnalyticsReport>((ref) async {
  final w = ref.watch(workspaceProvider);
  return financialAnalytics(
    selection: ref.watch(analyticsSelectionProvider),
    ledger: w.ledger,
    budgets: w.budgets,
    now: ref.watch(clockProvider)(),
  );
}, retry: (_, _) => null);
