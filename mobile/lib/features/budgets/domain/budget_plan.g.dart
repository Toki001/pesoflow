// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_plan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BudgetAllowance _$BudgetAllowanceFromJson(Map<String, dynamic> json) =>
    _BudgetAllowance(
      category: $enumDecode(_$TransactionCategoryEnumMap, json['category']),
      description: json['description'] as String,
      limit: (json['limit'] as num).toInt(),
      spent: (json['spent'] as num?)?.toInt() ?? 0,
      settled: json['settled'] as bool? ?? false,
      fixed: json['fixed'] as bool? ?? false,
      projectedAdditional: (json['projectedAdditional'] as num?)?.toInt(),
    );

Map<String, dynamic> _$BudgetAllowanceToJson(_BudgetAllowance instance) =>
    <String, dynamic>{
      'category': _$TransactionCategoryEnumMap[instance.category]!,
      'description': instance.description,
      'limit': instance.limit,
      'spent': instance.spent,
      'settled': instance.settled,
      'fixed': instance.fixed,
      'projectedAdditional': instance.projectedAdditional,
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

_BudgetPlan _$BudgetPlanFromJson(Map<String, dynamic> json) => _BudgetPlan(
  year: (json['year'] as num).toInt(),
  month: (json['month'] as num).toInt(),
  monthlyLimit: (json['monthlyLimit'] as num).toInt(),
  allowances: (json['allowances'] as List<dynamic>)
      .map((e) => BudgetAllowance.fromJson(e as Map<String, dynamic>))
      .toList(),
  editedCategories:
      (json['editedCategories'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$TransactionCategoryEnumMap, e))
          .toList() ??
      const [],
  spent: (json['spent'] as num?)?.toInt() ?? 0,
  projectedAdditional: (json['projectedAdditional'] as num?)?.toInt(),
);

Map<String, dynamic> _$BudgetPlanToJson(_BudgetPlan instance) =>
    <String, dynamic>{
      'year': instance.year,
      'month': instance.month,
      'monthlyLimit': instance.monthlyLimit,
      'allowances': instance.allowances,
      'editedCategories': instance.editedCategories
          .map((e) => _$TransactionCategoryEnumMap[e]!)
          .toList(),
      'spent': instance.spent,
      'projectedAdditional': instance.projectedAdditional,
    };
