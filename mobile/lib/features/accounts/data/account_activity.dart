import '../../transactions/domain/transaction.dart';

/// Explicit legacy fixture aliases. Institution names do not identify products.
const _ledgerAliases = {
  'gcash': {'GCash'},
  'bdo': {'BDO Checking'},
  'maya': {'Maya'},
  'bpi': {'BPI Savings'},
};

List<TransactionRecord> sampleAccountActivity(
  String accountId,
  List<TransactionRecord> ledger,
) {
  final aliases = _ledgerAliases[accountId] ?? const <String>{};
  final activity =
      ledger
          .where(
            (t) =>
                aliases.contains(t.account) ||
                (t.kind == TransactionKind.transfer &&
                    aliases.contains(t.destinationAccount)),
          )
          .toList()
        ..sort((a, b) {
          final date = b.occurredAt.compareTo(a.occurredAt);
          return date == 0 ? a.id.compareTo(b.id) : date;
        });
  return List.unmodifiable(activity);
}
