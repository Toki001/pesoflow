import '../../transactions/domain/transaction.dart';
import 'analytics_report.dart';

/// Group by stable account identity, using the same posted/as-of scope as analytics.
Map<String, int> paymentSourceTotals(
  Iterable<TransactionRecord> ledger,
  AnalyticsSelection range,
  DateTime now,
) {
  final totals = <String, int>{};
  for (final t in ledger) {
    if (t.status != TransactionStatus.posted ||
        t.occurredAt.isAfter(now) ||
        !range.contains(t.occurredAt) ||
        t.expenseImpact == 0) {
      continue;
    }
    final key = t.accountId ?? t.account;
    totals[key] = (totals[key] ?? 0) + t.expenseImpact;
  }
  return totals;
}
