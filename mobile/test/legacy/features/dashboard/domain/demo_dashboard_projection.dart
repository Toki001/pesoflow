import 'package:pesoflow/features/dashboard/domain/dashboard.dart';

/// Apply session changes to the approved snapshot; omitted fixture history stays.
Dashboard projectDemoLedger(
  Dashboard base,
  List<TransactionRecord> ledger,
  List<TransactionRecord> baseline,
) {
  bool currentMonth(TransactionRecord t) =>
      t.occurredAt.year == base.asOf.year &&
      t.occurredAt.month == base.asOf.month;
  int expenses(List<TransactionRecord> records) =>
      records.where(currentMonth).fold(0, (sum, t) => sum + t.expenseImpact);
  int income(List<TransactionRecord> records) => records
      .where(
        (t) =>
            currentMonth(t) &&
            t.kind == TransactionKind.income &&
            t.status == TransactionStatus.posted,
      )
      .fold(0, (sum, t) => sum + t.amount);
  final outflow = base.outflow + expenses(ledger) - expenses(baseline);
  final inflow = base.inflow + income(ledger) - income(baseline);
  final savings = inflow - outflow;
  final rate = inflow <= 0 ? 0 : (savings * 1000 / inflow).round();
  final baselineIds = baseline.map((t) => t.id).toSet();
  final byId = {for (final t in ledger) t.id: t};
  final manual = ledger.where((t) => !baselineIds.contains(t.id)).toList()
    ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
  return base.copyWith(
    inflow: inflow,
    outflow: outflow,
    savings: savings,
    savingsRate: '${rate < 0 ? '-' : ''}${rate.abs() ~/ 10}.${rate.abs() % 10}',
    transactionCount: base.transactionCount + ledger.length - baseline.length,
    budgetSpent:
        (base.budgetSpent ?? base.outflow) +
        ledger
            .where(currentMonth)
            .fold<int>(0, (sum, t) => sum + t.budgetImpact) -
        baseline
            .where(currentMonth)
            .fold<int>(0, (sum, t) => sum + t.budgetImpact),
    budgets: [
      for (final budget in base.budgets)
        budget.copyWith(
          spent:
              budget.spent +
              ledger
                  .where(
                    (t) =>
                        currentMonth(t) &&
                        categoryLabel(t.category) == budget.name,
                  )
                  .fold<int>(0, (sum, t) => sum + t.budgetImpact) -
              baseline
                  .where(
                    (t) =>
                        currentMonth(t) &&
                        categoryLabel(t.category) == budget.name,
                  )
                  .fold<int>(0, (sum, t) => sum + t.budgetImpact),
        ),
    ],
    transactions: [
      ...manual,
      for (final original in base.transactions)
        if (byId[original.id] case final t?)
          original.copyWith(
            amount: t.amount,
            category: t.category,
            metadata: t.category == original.category
                ? original.metadata
                : t.metadata,
            note: t.note,
            tags: t.tags,
            excludedFromBudget: t.excludedFromBudget,
            status: t.status,
            source: t.source,
            account: t.account,
            destinationAccount: t.destinationAccount,
            hasReceipt: t.hasReceipt,
          ),
    ].take(4).toList(),
  );
}
