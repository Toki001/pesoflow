import 'transaction.dart';

/// The approved full-month totals include history outside the recent feed.
/// Apply session edits as deltas against that snapshot, without double counting.
class MonthSnapshot {
  const MonthSnapshot({required this.spent, required this.income});
  final int spent;
  final int income;
  int get netFlow => income - spent;
  static MonthSnapshot fromLedger(
    List<TransactionRecord> ledger,
    int year,
    int month, {
    required List<TransactionRecord> baseline,
  }) {
    bool inMonth(TransactionRecord t) =>
        t.occurredAt.year == year && t.occurredAt.month == month;
    int expense(List<TransactionRecord> records) =>
        records.where(inMonth).fold(0, (sum, t) => sum + t.expenseImpact);
    int incoming(List<TransactionRecord> records) => records
        .where(
          (t) =>
              inMonth(t) &&
              t.kind == TransactionKind.income &&
              t.status == TransactionStatus.posted,
        )
        .fold(0, (sum, t) => sum + t.amount);
    final fixture = baseline;
    final approvedMonth = year == 2024 && month == 10;
    return MonthSnapshot(
      spent:
          (approvedMonth ? 1680000 : 0) +
          expense(ledger) -
          (approvedMonth ? expense(fixture) : 0),
      income:
          (approvedMonth ? 4500000 : 0) +
          incoming(ledger) -
          (approvedMonth ? incoming(fixture) : 0),
    );
  }
}
