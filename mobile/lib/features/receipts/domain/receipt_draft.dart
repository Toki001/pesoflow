import 'package:pesoflow/features/transactions/domain/transaction.dart';

import 'receipt_evidence.dart';

class ReceiptItem {
  ReceiptItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    this.detail = '',
    this.confidence,
    this.reviewed = false,
  }) {
    if (id.isEmpty ||
        name.trim().isEmpty ||
        quantity < 1 ||
        quantity > 999 ||
        unitPrice <= 0 ||
        unitPrice > 99999999999 ||
        (confidence != null && (confidence! < 0 || confidence! > 100))) {
      throw ArgumentError('Invalid receipt item.');
    }
  }
  final String id, name, detail;
  final int quantity, unitPrice;
  final int? confidence;
  final bool reviewed;
  int get total => quantity * unitPrice;
  bool get needsReview => !reviewed && (confidence == null || confidence! < 90);
}

/// A reviewable local expense. Captured receipts carry extraction evidence;
/// legacy item-only records remain readable. Saving never initiates a payment.
class ReceiptDraft {
  ReceiptDraft({
    required this.id,
    required this.merchant,
    required this.accountId,
    required this.occurredAt,
    required Iterable<ReceiptItem> items,
    this.category = TransactionCategory.groceries,
    this.account = '',
    this.savedTransactionId,
    this.evidence,
  }) : items = List.unmodifiable(items) {
    if (this.items.map((i) => i.id).toSet().length != this.items.length) {
      throw ArgumentError('Duplicate receipt item ID.');
    }
  }
  final String id, merchant, account;
  final String accountId;
  final DateTime occurredAt;
  final List<ReceiptItem> items;
  final TransactionCategory category;
  final String? savedTransactionId;
  final ReceiptEvidence? evidence;
  int get total => evidence?.total ?? items.fold(0, (sum, i) => sum + i.total);
  // Tax is captured evidence, never inferred from a blanket percentage.
  int get includedVat => evidence?.tax ?? 0;
  List<ReceiptItem> get uncertain => items.where((i) => i.needsReview).toList();
  String? get validationError {
    if (merchant.trim().isEmpty || merchant.length > 100) {
      return 'Enter a valid merchant name.';
    }
    if (account.trim().isEmpty || accountId.trim().isEmpty) {
      return 'Choose a payment source.';
    }
    if (!isExpenseCategory(category)) {
      return 'Choose an expense category.';
    }
    if (evidence == null && items.isEmpty) {
      return 'Add at least one receipt item.';
    }
    if (evidence != null &&
        (evidence!.imageId != id || evidence!.currency != 'PHP')) {
      return 'Verify the receipt image and PHP currency.';
    }
    if (total <= 0 || total > 99999999999) {
      return 'Receipt total is outside the supported amount range.';
    }
    if (evidence != null && !evidence!.confirmed) {
      return 'Verify the merchant, date, total and items before saving.';
    }
    if (evidence == null && uncertain.isNotEmpty) {
      return 'Review the flagged items before saving.';
    }
    return null;
  }

  ReceiptDraft copyWith({
    String? merchant,
    DateTime? occurredAt,
    List<ReceiptItem>? items,
    TransactionCategory? category,
    String? account,
    String? accountId,
    String? savedTransactionId,
    ReceiptEvidence? evidence,
  }) => ReceiptDraft(
    id: id,
    merchant: merchant ?? this.merchant,
    occurredAt: occurredAt ?? this.occurredAt,
    items: items ?? this.items,
    category: category ?? this.category,
    account: account ?? this.account,
    accountId: accountId ?? this.accountId,
    savedTransactionId: savedTransactionId ?? this.savedTransactionId,
    evidence: evidence ?? this.evidence,
  );
  TransactionRecord toTransaction(String transactionId) {
    final error = validationError;
    if (error != null) throw ArgumentError(error);
    return TransactionRecord(
      id: transactionId,
      merchant: merchant.trim(),
      metadata: '${categoryLabel(category)} · $account',
      amount: total,
      occurredAt: occurredAt,
      kind: TransactionKind.expense,
      category: category,
      account: account,
      accountId: accountId,
      source: TransactionSource.receipt,
      hasReceipt: true,
      note: 'Reviewed receipt.',
    );
  }
}
