import '../../receipts/domain/receipt_draft.dart';
import '../../transactions/domain/transaction.dart';

/// Demo activity only. Other preferences and financial features remain transient.
class DemoWorkspace {
  DemoWorkspace({
    required Iterable<TransactionRecord> ledger,
    Map<String, ReceiptDraft> receipts = const {},
  }) : ledger = List.unmodifiable(ledger),
       receipts = Map.unmodifiable(receipts) {
    if (this.ledger.any(
          (t) => t.id.isEmpty || t.amount <= 0 || t.amount > 99999999999,
        ) ||
        this.ledger.map((t) => t.id).toSet().length != this.ledger.length) {
      throw const FormatException('Invalid demo ledger.');
    }
    for (final entry in this.receipts.entries) {
      final matches = this.ledger.where((t) => t.id == entry.key);
      final receipt = entry.value;
      if (matches.length != 1 ||
          receipt.savedTransactionId != entry.key ||
          receipt.validationError != null ||
          matches.single.source != TransactionSource.receipt ||
          !matches.single.hasReceipt ||
          matches.single.amount != receipt.total ||
          matches.single.accountId != receipt.accountId) {
        throw const FormatException('Invalid saved demo receipt.');
      }
    }
  }
  final List<TransactionRecord> ledger;
  final Map<String, ReceiptDraft> receipts;
}

abstract interface class DemoWorkspaceRepository {
  Future<DemoWorkspace> load();
  Future<void> save(DemoWorkspace workspace);
  Future<void> close();
}
