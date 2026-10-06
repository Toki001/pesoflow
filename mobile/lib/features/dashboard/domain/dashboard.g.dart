// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Dashboard _$DashboardFromJson(Map<String, dynamic> json) => _Dashboard(
  name: json['name'] as String,
  asOf: DateTime.parse(json['asOf'] as String),
  balance: (json['balance'] as num).toInt(),
  monthChange: (json['monthChange'] as num).toInt(),
  monthChangePercent: json['monthChangePercent'] as String,
  inflow: (json['inflow'] as num).toInt(),
  outflow: (json['outflow'] as num).toInt(),
  savings: (json['savings'] as num).toInt(),
  savingsRate: json['savingsRate'] as String,
  transactionCount: (json['transactionCount'] as num).toInt(),
  accountCount: (json['accountCount'] as num).toInt(),
  budgetLimit: (json['budgetLimit'] as num).toInt(),
  budgetSpent: (json['budgetSpent'] as num?)?.toInt(),
  daysLeft: (json['daysLeft'] as num).toInt(),
  projectedExtraSavings: (json['projectedExtraSavings'] as num).toInt(),
  budgets: (json['budgets'] as List<dynamic>)
      .map((e) => BudgetSnapshot.fromJson(e as Map<String, dynamic>))
      .toList(),
  transactions: (json['transactions'] as List<dynamic>)
      .map((e) => TransactionRecord.fromJson(e as Map<String, dynamic>))
      .toList(),
  bills: (json['bills'] as List<dynamic>)
      .map((e) => UpcomingBill.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$DashboardToJson(_Dashboard instance) =>
    <String, dynamic>{
      'name': instance.name,
      'asOf': instance.asOf.toIso8601String(),
      'balance': instance.balance,
      'monthChange': instance.monthChange,
      'monthChangePercent': instance.monthChangePercent,
      'inflow': instance.inflow,
      'outflow': instance.outflow,
      'savings': instance.savings,
      'savingsRate': instance.savingsRate,
      'transactionCount': instance.transactionCount,
      'accountCount': instance.accountCount,
      'budgetLimit': instance.budgetLimit,
      'budgetSpent': instance.budgetSpent,
      'daysLeft': instance.daysLeft,
      'projectedExtraSavings': instance.projectedExtraSavings,
      'budgets': instance.budgets,
      'transactions': instance.transactions,
      'bills': instance.bills,
    };

_BudgetSnapshot _$BudgetSnapshotFromJson(Map<String, dynamic> json) =>
    _BudgetSnapshot(
      name: json['name'] as String,
      spent: (json['spent'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
      status: json['status'] as String,
    );

Map<String, dynamic> _$BudgetSnapshotToJson(_BudgetSnapshot instance) =>
    <String, dynamic>{
      'name': instance.name,
      'spent': instance.spent,
      'limit': instance.limit,
      'status': instance.status,
    };

_UpcomingBill _$UpcomingBillFromJson(Map<String, dynamic> json) =>
    _UpcomingBill(
      name: json['name'] as String,
      amount: (json['amount'] as num).toInt(),
      daysUntilDue: (json['daysUntilDue'] as num).toInt(),
      estimated: json['estimated'] as bool? ?? false,
    );

Map<String, dynamic> _$UpcomingBillToJson(_UpcomingBill instance) =>
    <String, dynamic>{
      'name': instance.name,
      'amount': instance.amount,
      'daysUntilDue': instance.daysUntilDue,
      'estimated': instance.estimated,
    };
