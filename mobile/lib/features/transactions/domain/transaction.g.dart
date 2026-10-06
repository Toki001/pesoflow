// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TransactionRecord _$TransactionRecordFromJson(Map<String, dynamic> json) =>
    _TransactionRecord(
      id: json['id'] as String,
      merchant: json['merchant'] as String,
      metadata: json['metadata'] as String,
      amount: (json['amount'] as num).toInt(),
      occurredAt: DateTime.parse(json['occurredAt'] as String),
      kind: $enumDecode(_$TransactionKindEnumMap, json['kind']),
      category: $enumDecode(_$TransactionCategoryEnumMap, json['category']),
      account: json['account'] as String? ?? 'GCash',
      destinationAccount: json['destinationAccount'] as String?,
      status:
          $enumDecodeNullable(_$TransactionStatusEnumMap, json['status']) ??
          TransactionStatus.posted,
      source:
          $enumDecodeNullable(_$TransactionSourceEnumMap, json['source']) ??
          TransactionSource.manual,
      note: json['note'] as String? ?? '',
      hasReceipt: json['hasReceipt'] as bool? ?? false,
      recurring: json['recurring'] as bool? ?? false,
      excludedFromBudget: json['excludedFromBudget'] as bool? ?? false,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
    );

Map<String, dynamic> _$TransactionRecordToJson(_TransactionRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'merchant': instance.merchant,
      'metadata': instance.metadata,
      'amount': instance.amount,
      'occurredAt': instance.occurredAt.toIso8601String(),
      'kind': _$TransactionKindEnumMap[instance.kind]!,
      'category': _$TransactionCategoryEnumMap[instance.category]!,
      'account': instance.account,
      'destinationAccount': instance.destinationAccount,
      'status': _$TransactionStatusEnumMap[instance.status]!,
      'source': _$TransactionSourceEnumMap[instance.source]!,
      'note': instance.note,
      'hasReceipt': instance.hasReceipt,
      'recurring': instance.recurring,
      'excludedFromBudget': instance.excludedFromBudget,
      'tags': instance.tags,
    };

const _$TransactionKindEnumMap = {
  TransactionKind.expense: 'expense',
  TransactionKind.income: 'income',
  TransactionKind.transfer: 'transfer',
  TransactionKind.refund: 'refund',
};

const _$TransactionCategoryEnumMap = {
  TransactionCategory.food: 'food',
  TransactionCategory.transport: 'transport',
  TransactionCategory.transfer: 'transfer',
  TransactionCategory.income: 'income',
  TransactionCategory.groceries: 'groceries',
  TransactionCategory.coffee: 'coffee',
  TransactionCategory.subscriptions: 'subscriptions',
  TransactionCategory.shopping: 'shopping',
  TransactionCategory.bills: 'bills',
  TransactionCategory.entertainment: 'entertainment',
  TransactionCategory.refund: 'refund',
};

const _$TransactionStatusEnumMap = {
  TransactionStatus.posted: 'posted',
  TransactionStatus.pending: 'pending',
};

const _$TransactionSourceEnumMap = {
  TransactionSource.manual: 'manual',
  TransactionSource.bankSync: 'bankSync',
  TransactionSource.walletSync: 'walletSync',
  TransactionSource.receipt: 'receipt',
};
