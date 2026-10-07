import '../domain/budget_plan.dart';

/// Stores base plans only. Ledger-derived spending is projected after loading.
abstract final class BudgetPlansCodec {
  static Map<String, dynamic> encode(Map<String, BudgetPlan> plans) => {
    'version': 1,
    'plans': {
      for (final e in plans.entries)
        e.key: {
          ...e.value.toJson(),
          'allowances': [for (final a in e.value.allowances) a.toJson()],
        },
    },
  };

  static Map<String, BudgetPlan> decode(Map<String, dynamic> json) {
    if (json['version'] is! int || json['version'] != 1) {
      throw const FormatException('Unsupported budget plan format.');
    }
    return {
      for (final e in (json['plans'] as Map<String, dynamic>).entries)
        e.key: _plan(e.value as Map<String, dynamic>),
    };
  }

  static BudgetPlan _plan(Map<String, dynamic> json) {
    for (final field in ['year', 'month', 'monthlyLimit', 'spent']) {
      if (json[field] is! int) {
        throw const FormatException('Invalid budget integer.');
      }
    }
    _forecast(json);
    for (final value in json['allowances'] as List) {
      final allowance = value as Map<String, dynamic>;
      if (allowance['limit'] is! int ||
          allowance['spent'] is! int ||
          allowance['settled'] is! bool ||
          allowance['fixed'] is! bool) {
        throw const FormatException('Invalid budget allowance.');
      }
      _forecast(allowance);
    }
    return BudgetPlan.fromJson(json);
  }

  static void _forecast(Map<String, dynamic> json) {
    final value = json['projectedAdditional'];
    if (value != null && (value is! int || value < 0)) {
      throw const FormatException('Invalid budget forecast.');
    }
  }
}
