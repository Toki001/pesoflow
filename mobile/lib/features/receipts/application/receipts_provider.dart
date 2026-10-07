import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../accounts/domain/ledger_account.dart';

import '../../transactions/application/transactions_provider.dart';
import '../../transactions/domain/transaction.dart';
import '../data/receipt_fixture.dart';
import '../domain/receipt_draft.dart';

final receiptLoaderProvider = Provider<Future<ReceiptDraft?> Function()>(
  (ref) =>
      () async => receiptFixture(),
);

class SavedDemoReceipts extends Notifier<Map<String, ReceiptDraft>> {
  @override
  Map<String, ReceiptDraft> build() => const {};
  void put(String transactionId, ReceiptDraft draft) =>
      state = Map.unmodifiable({...state, transactionId: draft});
}

final savedDemoReceiptsProvider =
    NotifierProvider<SavedDemoReceipts, Map<String, ReceiptDraft>>(
      SavedDemoReceipts.new,
    );

class ReceiptReview extends AsyncNotifier<ReceiptDraft?> {
  int _sequence = 0;
  @override
  Future<ReceiptDraft?> build() async {
    final draft = await ref.watch(receiptLoaderProvider)();
    if (draft == null) return null;
    return ref.read(savedDemoReceiptsProvider)['receipt-${draft.id}'] ?? draft;
  }

  void setDraft(ReceiptDraft draft) {
    final current = state.value;
    if (current == null ||
        current.savedTransactionId != null ||
        current.id != draft.id) {
      return;
    }
    state = AsyncData(draft);
  }

  void setMerchant(String value) {
    final d = state.value;
    if (d != null) setDraft(d.copyWith(merchant: value.trim()));
  }

  void setDate(DateTime value) {
    final d = state.value;
    if (d != null) setDraft(d.copyWith(occurredAt: value));
  }

  void setCategory(TransactionCategory value) {
    final d = state.value;
    if (d != null) setDraft(d.copyWith(category: value));
  }

  void setAccount(LedgerAccount value) {
    final d = state.value;
    if (d != null) {
      setDraft(d.copyWith(account: value.label, accountId: value.id));
    }
  }

  String nextItemId() => 'receipt-item-${++_sequence}';
  void saveItem(ReceiptItem item) {
    final d = state.value;
    if (d == null) return;
    final exists = d.items.any((i) => i.id == item.id);
    setDraft(
      d.copyWith(
        items: [
          for (final i in d.items)
            if (i.id == item.id) item else i,
          if (!exists) item,
        ],
      ),
    );
  }

  void removeItem(String id) {
    final d = state.value;
    if (d != null) {
      setDraft(d.copyWith(items: d.items.where((i) => i.id != id).toList()));
    }
  }

  String save() {
    final draft = state.value;
    if (draft == null) throw StateError('No receipt available to review.');
    if (draft.savedTransactionId != null) return draft.savedTransactionId!;
    final id = 'receipt-${draft.id}';
    final record = draft.toTransaction(id);
    // Synchronous ledger insertion and snapshot publication prevent double taps.
    ref.read(demoLedgerProvider.notifier).add(record);
    final saved = draft.copyWith(savedTransactionId: id);
    ref.read(savedDemoReceiptsProvider.notifier).put(id, saved);
    state = AsyncData(saved);
    return id;
  }
}

final receiptReviewProvider =
    AsyncNotifierProvider<ReceiptReview, ReceiptDraft?>(
      ReceiptReview.new,
      retry: (_, _) => null,
    );
