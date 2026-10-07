import 'package:pesoflow/features/transactions/domain/transaction.dart';

class MonthSnapshot {
  const MonthSnapshot({required this.spent, required this.income});
  final int spent, income;
  int get netFlow => income - spent;
  static MonthSnapshot fromLedger(
    List<TransactionRecord> ledger,
    int year,
    int month,
  ) {
    final rows = ledger.where(
      (t) => t.occurredAt.year == year && t.occurredAt.month == month,
    );
    return MonthSnapshot(
      spent: rows.fold(0, (s, t) => s + t.expenseImpact),
      income: rows
          .where(
            (t) =>
                t.kind == TransactionKind.income &&
                t.status == TransactionStatus.posted,
          )
          .fold(0, (s, t) => s + t.amount),
    );
  }
}
