import 'transaction.dart';

/// Exact decimal parsing into centavos. Reject malformed or over-precise input.
int? parsePhpAmount(String input) {
  final text = input.trim();
  if (!RegExp(r'^\d{1,9}(\.\d{1,2})?$').hasMatch(text)) return null;
  final parts = text.split('.');
  final amount =
      int.parse(parts.first) * 100 +
      (parts.length == 1 ? 0 : int.parse(parts[1].padRight(2, '0')));
  return amount > 0 ? amount : null;
}

class ManualTransactionDraft {
  const ManualTransactionDraft({
    required this.amount,
    required this.merchant,
    required this.account,
    required this.occurredAt,
    required this.kind,
    required this.category,
    this.destinationAccount,
    this.note = '',
  });
  final int amount;
  final String merchant;
  final String account;
  final DateTime occurredAt;
  final TransactionKind kind;
  final TransactionCategory category;
  final String? destinationAccount;
  final String note;
  TransactionRecord toRecord(String id) {
    if (amount <= 0 ||
        amount > 99999999999 ||
        account.trim().isEmpty ||
        merchant.trim().isEmpty) {
      throw ArgumentError(
        'A positive amount, account and merchant are required.',
      );
    }
    if (![
      TransactionKind.expense,
      TransactionKind.income,
      TransactionKind.transfer,
    ].contains(kind)) {
      throw ArgumentError('Unsupported manual transaction type.');
    }
    if (kind == TransactionKind.transfer &&
        (destinationAccount == null ||
            destinationAccount!.trim().isEmpty ||
            destinationAccount == account)) {
      throw ArgumentError('Choose two distinct transfer accounts.');
    }
    final actualCategory = kind == TransactionKind.transfer
        ? TransactionCategory.transfer
        : kind == TransactionKind.income
        ? TransactionCategory.income
        : category;
    if (kind == TransactionKind.expense &&
        [
          TransactionCategory.income,
          TransactionCategory.transfer,
          TransactionCategory.refund,
        ].contains(actualCategory)) {
      throw ArgumentError('Choose an expense category.');
    }
    return TransactionRecord(
      id: id,
      merchant: kind == TransactionKind.transfer
          ? '$account → $destinationAccount'
          : merchant.trim(),
      metadata: kind == TransactionKind.transfer
          ? 'Account Transfer'
          : '${categoryLabel(actualCategory)} · $account',
      amount: amount,
      occurredAt: occurredAt,
      kind: kind,
      category: actualCategory,
      account: account,
      destinationAccount: kind == TransactionKind.transfer
          ? destinationAccount
          : null,
      note: note.trim(),
      tags: RegExp(r'#([a-zA-Z0-9_]+)')
          .allMatches(note)
          .map((m) => m[1]!)
          .toSet()
          .toList(),
    );
  }
}
