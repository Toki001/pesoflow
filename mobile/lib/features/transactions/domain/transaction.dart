import 'package:freezed_annotation/freezed_annotation.dart';
part 'transaction.freezed.dart';
part 'transaction.g.dart';

enum TransactionKind { expense, income, transfer, refund }

enum TransactionCategory {
  food,
  transport,
  transfer,
  income,
  groceries,
  coffee,
  subscriptions,
  shopping,
  bills,
  entertainment,
  refund,
}

enum TransactionStatus { posted, pending }

enum TransactionSource { manual, bankSync, walletSync, receipt }

@freezed
abstract class TransactionRecord with _$TransactionRecord {
  const TransactionRecord._();
  const factory TransactionRecord({
    required String id,
    required String merchant,
    required String metadata,
    required int amount,
    required DateTime occurredAt,
    required TransactionKind kind,
    required TransactionCategory category,
    @Default('GCash') String account,
    @Default(TransactionStatus.posted) TransactionStatus status,
    @Default(TransactionSource.manual) TransactionSource source,
    @Default('') String note,
    @Default(false) bool hasReceipt,
    @Default(false) bool recurring,
    @Default(false) bool excludedFromBudget,
    @Default([]) List<String> tags,
  }) = _TransactionRecord;
  factory TransactionRecord.fromJson(Map<String, dynamic> json) =>
      _$TransactionRecordFromJson(json);
  int get displayAmount => kind == TransactionKind.expense ? -amount : amount;
  int get expenseImpact => status == TransactionStatus.pending
      ? 0
      : switch (kind) {
          TransactionKind.expense => amount,
          TransactionKind.refund => -amount,
          TransactionKind.income || TransactionKind.transfer => 0,
        };
  int get budgetImpact => excludedFromBudget ? 0 : expenseImpact;
  int get cashFlowImpact =>
      status == TransactionStatus.pending || kind == TransactionKind.transfer
      ? 0
      : displayAmount;
}

String categoryLabel(TransactionCategory category) => switch (category) {
  TransactionCategory.food => 'Food & Dining',
  TransactionCategory.transport => 'Transport',
  TransactionCategory.groceries => 'Groceries',
  TransactionCategory.coffee => 'Coffee & Drinks',
  TransactionCategory.transfer => 'Account Transfer',
  TransactionCategory.income => 'Income',
  TransactionCategory.subscriptions => 'Subscriptions',
  TransactionCategory.shopping => 'Shopping',
  TransactionCategory.bills => 'Bills & Utilities',
  TransactionCategory.entertainment => 'Entertainment & Leisure',
  TransactionCategory.refund => 'Refund',
};
