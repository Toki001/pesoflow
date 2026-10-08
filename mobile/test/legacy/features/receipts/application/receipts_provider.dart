import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pesoflow/features/accounts/domain/ledger_account.dart';
import 'package:pesoflow/features/workspace/application/finance_controller.dart';

import 'package:pesoflow/features/transactions/domain/transaction.dart';

import 'package:pesoflow/features/receipts/domain/receipt_draft.dart';

final receiptLoaderProvider = Provider<Future<ReceiptDraft?> Function()>(
  (ref) =>
      () async => null,
);

final savedReceiptsProvider = Provider<Map<String, ReceiptDraft>>(
  (ref) => ref.watch(workspaceProvider).receipts,
);

class ReceiptReview extends AsyncNotifier<ReceiptDraft?> {
  int _sequence = 0;
  @override
  Future<ReceiptDraft?> build() async {
    final draft = await ref.watch(receiptLoaderProvider)();
    if (draft == null) return null;
    return ref
            .read(savedReceiptsProvider)
            .values
            .where((r) => r.id == draft.id)
            .firstOrNull ??
        draft;
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

  Future<String> save() async {
    final draft = state.value;
    if (draft == null) throw StateError('No captured receipt.');
    if (draft.savedTransactionId != null) return draft.savedTransactionId!;
    final id = await ref
        .read(financeControllerProvider.notifier)
        .saveReceipt(draft);
    if (ref.mounted) state = AsyncData(draft.copyWith(savedTransactionId: id));
    return id;
  }
}

final receiptReviewProvider =
    AsyncNotifierProvider<ReceiptReview, ReceiptDraft?>(
      ReceiptReview.new,
      retry: (_, _) => null,
    );
