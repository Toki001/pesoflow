import '../../transactions/domain/transaction.dart';
import '../../transactions/domain/categorization.dart';
import 'subscription_plan.dart';

class RecurringCandidate {
  const RecurringCandidate({
    required this.key,
    required this.merchant,
    required this.accountId,
    required this.accountName,
    required this.amount,
    required this.cycle,
    required this.nextExpected,
    required this.observations,
    required this.category,
    required this.transactionIds,
  });
  final String key, merchant, accountId, accountName;
  final int amount, observations;
  final BillingCycle cycle;
  final DateTime nextExpected;
  final TransactionCategory category;
  final Set<String> transactionIds;
}

DateTime advanceRenewal(DateTime value, BillingCycle cycle, {int? anchorDay}) {
  if (cycle == BillingCycle.weekly) {
    return DateTime(value.year, value.month, value.day + 7);
  }
  final months = switch (cycle) {
    BillingCycle.monthly => 1,
    BillingCycle.quarterly => 3,
    BillingCycle.yearly => 12,
    BillingCycle.weekly => 0,
  };
  final target = DateTime(value.year, value.month + months);
  final day = (anchorDay ?? value.day).clamp(
    1,
    DateTime(target.year, target.month + 1, 0).day,
  );
  return DateTime(target.year, target.month, day);
}

/// Three observed charges and two matching intervals are required. Candidates
/// never create ledger expenses or silently enroll a tracked subscription.
List<RecurringCandidate> detectRecurring(
  Iterable<TransactionRecord> ledger,
  DateTime now,
) {
  final groups = <String, List<TransactionRecord>>{};
  for (final t in ledger) {
    if (t.kind != TransactionKind.expense ||
        t.status != TransactionStatus.posted ||
        t.accountId == null ||
        t.occurredAt.isAfter(now)) {
      continue;
    }
    final key = '${t.accountId}:${normalizeMerchant(t.merchant)}';
    (groups[key] ??= []).add(t);
  }
  final candidates = <RecurringCandidate>[];
  for (final entry in groups.entries) {
    final sorted = entry.value
      ..sort((a, b) => a.occurredAt.compareTo(b.occurredAt));
    if (sorted.length < 3) continue;
    // Check the latest observations; old price changes do not permanently hide a plan.
    final rows = sorted
        .skip((sorted.length - 6).clamp(0, sorted.length))
        .toList();
    final medianAmounts = rows.map((r) => r.amount).toList()..sort();
    final median = medianAmounts[medianAmounts.length ~/ 2];
    if (rows.any((r) => (r.amount - median).abs() * 100 > median * 5)) continue;
    BillingCycle? matched;
    for (final cycle in BillingCycle.values) {
      var matches = true;
      for (var i = 1; i < rows.length; i++) {
        final previous = rows[i - 1].occurredAt;
        final next = rows[i].occurredAt;
        final expected = advanceRenewal(previous, cycle);
        final difference = DateTime.utc(next.year, next.month, next.day)
            .difference(
              DateTime.utc(expected.year, expected.month, expected.day),
            )
            .inDays
            .abs();
        final tolerance = cycle == BillingCycle.weekly ? 1 : 3;
        if (difference > tolerance) {
          matches = false;
          break;
        }
      }
      if (matches) {
        matched = cycle;
        break;
      }
    }
    if (matched == null) continue;
    final last = rows.last;
    final next = advanceRenewal(last.occurredAt, matched);
    // Do not keep advertising subscriptions with no recent supporting history.
    if (now.isAfter(advanceRenewal(next, matched))) continue;
    candidates.add(
      RecurringCandidate(
        key: entry.key,
        merchant: last.merchant,
        accountId: last.accountId!,
        accountName: last.account,
        amount: median,
        cycle: matched,
        nextExpected: next,
        observations: rows.length,
        category: last.category,
        transactionIds: Set.unmodifiable(rows.map((t) => t.id)),
      ),
    );
  }
  candidates.sort((a, b) => a.nextExpected.compareTo(b.nextExpected));
  return List.unmodifiable(candidates);
}
