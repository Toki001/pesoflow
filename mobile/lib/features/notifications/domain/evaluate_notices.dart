import 'package:pesoflow/core/identity/new_id.dart';
import 'package:pesoflow/features/analytics/domain/analytics_report.dart';
import 'package:pesoflow/features/budgets/domain/spending_budget.dart';
import 'package:pesoflow/features/transactions/domain/transaction.dart';
import 'package:pesoflow/features/workspace/domain/finance_workspace.dart';
import 'package:pesoflow/features/notifications/domain/notice_view.dart';
import 'package:pesoflow/features/notifications/domain/financial_notice.dart';

/// Persist the result with the financial mutation. Stable condition keys prevent
/// repeated alerts across rebuilds, edits and restarts; periods reset thresholds.
List<FinancialNotice> evaluateNotices(
  FinanceWorkspace workspace,
  DateTime now, {
  String Function() idFactory = newId,
}) {
  final result = [...workspace.notices];
  final known = result.map((n) => n.conditionKey).toSet();
  final prefs = workspace.preferences;
  if (!prefs.notifications) return List.unmodifiable(result);
  void add(
    String key,
    String title,
    String message,
    NoticeKind kind,
    NoticeDestination destination,
  ) {
    if (!known.add(key)) return;
    result.insert(
      0,
      FinancialNotice(
        id: idFactory(),
        conditionKey: key,
        title: title,
        message: message,
        kind: kind,
        destination: destination,
        createdAt: now,
      ),
    );
  }

  if (prefs.budgetAlerts) {
    for (final budget in workspace.budgets.where((b) => b.enabled)) {
      final range = AnalyticsSelection(now, budget.period);
      if (range.start.isBefore(
        AnalyticsSelection(budget.startDate, budget.period).start,
      )) {
        continue;
      }
      final progress = evaluateBudget(budget, workspace.ledger, now);
      final base = 'budget:${budget.id}:${range.start.toIso8601String()}';
      final reached =
          budget.thresholds
              .where((t) => progress.spent * 100 >= budget.limit * t)
              .toList()
            ..sort();
      // One new threshold per evaluation, rather than five simultaneous banners.
      final threshold = progress.spent > budget.limit
          ? 101
          : reached.isEmpty
          ? null
          : reached.last;
      if (threshold == null) continue;
      final prior = result
          .where((n) => n.conditionKey.startsWith('$base:'))
          .map((n) => int.tryParse(n.conditionKey.split(':').last) ?? 0);
      if (prior.any((value) => value >= threshold)) continue;
      add(
        '$base:$threshold',
        threshold == 101
            ? '${budget.name} is above its limit'
            : '${budget.name} has reached $threshold%',
        threshold == 101
            ? 'Your recorded spending is above this ${budget.period.name} budget. Review your plan when convenient.'
            : 'Your recorded spending has reached $threshold% of this ${budget.period.name} budget.',
        NoticeKind.budget,
        NoticeDestination.budgets,
      );
    }
  }
  if (prefs.renewalAlerts) {
    for (final plan in workspace.subscriptions.where((p) => p.active)) {
      final days = plan.daysUntil(now);
      if (days < 0 || days > 7) continue;
      add(
        'renewal:${plan.id}:${plan.nextRenewal.toIso8601String()}',
        '${plan.name} is coming up',
        days == 0
            ? 'Your tracked renewal is expected today. This reminder does not create a charge.'
            : 'Your tracked renewal is expected in $days days. This reminder does not create a charge.',
        NoticeKind.renewal,
        NoticeDestination.subscriptions,
      );
    }
  }
  if (prefs.unusualSpendingAlerts) {
    final today = DateTime(now.year, now.month, now.day);
    final since = DateTime(today.year, today.month, today.day - 30);
    final historic = workspace.ledger
        .where(
          (t) =>
              t.kind == TransactionKind.expense &&
              t.status == TransactionStatus.posted &&
              !t.occurredAt.isBefore(since) &&
              t.occurredAt.isBefore(today),
        )
        .toList();
    if (historic.length >= 5) {
      final amounts = historic.map((t) => t.amount).toList()..sort();
      final median = amounts[amounts.length ~/ 2];
      final unusual = workspace.ledger.where(
        (t) =>
            t.kind == TransactionKind.expense &&
            t.status == TransactionStatus.posted &&
            !t.occurredAt.isBefore(today) &&
            !t.occurredAt.isAfter(now) &&
            t.amount > median * 3,
      );
      if (unusual.isNotEmpty) {
        // At most one unusual-spending notice per calendar day.
        add(
          'unusual:${today.toIso8601String()}',
          'A larger expense than usual',
          'An expense today is more than three times the median of your last 30 days of recorded expenses.',
          NoticeKind.report,
          NoticeDestination.analytics,
        );
      }
    }
  }
  final order = {
    for (final (index, notice) in result.indexed) notice.id: index,
  };
  result.sort((a, b) {
    final date = b.createdAt.compareTo(a.createdAt);
    return date == 0 ? order[a.id]!.compareTo(order[b.id]!) : date;
  });
  return List.unmodifiable(result);
}
