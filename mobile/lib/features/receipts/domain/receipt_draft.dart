import '../../transactions/domain/transaction.dart';

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

/// A local review, not evidence of live OCR, provider payment or earned rewards.
class ReceiptDraft {
  ReceiptDraft({
    required this.id,
    required this.merchant,
    required this.occurredAt,
    required Iterable<ReceiptItem> items,
    this.category = TransactionCategory.groceries,
    this.account = 'GCash',
    this.savedTransactionId,
  }) : items = List.unmodifiable(items) {
    if (this.items.map((i) => i.id).toSet().length != this.items.length) {
      throw ArgumentError('Duplicate receipt item ID.');
    }
  }
  final String id, merchant, account;
  final DateTime occurredAt;
  final List<ReceiptItem> items;
  final TransactionCategory category;
  final String? savedTransactionId;
  int get total => items.fold(0, (sum, i) => sum + i.total);
  // Demo assumes every line includes the sample 12% tax. Never add it again.
  int get includedVat => (total * 12 + 56) ~/ 112;
  List<ReceiptItem> get uncertain => items.where((i) => i.needsReview).toList();
  String? get validationError {
    if (merchant.trim().isEmpty || merchant.length > 100) {
      return 'Enter a valid merchant name.';
    }
    if (account.trim().isEmpty) return 'Choose a payment source.';
    if ([
      TransactionCategory.income,
      TransactionCategory.transfer,
      TransactionCategory.refund,
    ].contains(category)) {
      return 'Choose an expense category.';
    }
    if (items.isEmpty) return 'Add at least one receipt item.';
    if (total <= 0 || total > 99999999999) {
      return 'Receipt total is outside the supported amount range.';
    }
    if (uncertain.isNotEmpty) return 'Review the flagged items before saving.';
    return null;
  }

  ReceiptDraft copyWith({
    String? merchant,
    DateTime? occurredAt,
    List<ReceiptItem>? items,
    TransactionCategory? category,
    String? account,
    String? savedTransactionId,
  }) => ReceiptDraft(
    id: id,
    merchant: merchant ?? this.merchant,
    occurredAt: occurredAt ?? this.occurredAt,
    items: items ?? this.items,
    category: category ?? this.category,
    account: account ?? this.account,
    savedTransactionId: savedTransactionId ?? this.savedTransactionId,
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
      source: TransactionSource.receipt,
      hasReceipt: true,
      note: 'Reviewed demo receipt. No camera capture or live OCR.',
    );
  }
}
