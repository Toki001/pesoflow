import '../../transactions/domain/transaction.dart';

List<TransactionRecord> accountActivity(
  String accountId,
  List<TransactionRecord> ledger,
) {
  final activity = ledger.where((t) => t.involvesAccount(accountId)).toList()
    ..sort((a, b) {
      final date = b.occurredAt.compareTo(a.occurredAt);
      return date == 0 ? a.id.compareTo(b.id) : date;
    });
  return List.unmodifiable(activity);
}
