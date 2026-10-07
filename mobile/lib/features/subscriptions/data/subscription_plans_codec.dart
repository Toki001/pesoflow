import '../domain/subscription_plan.dart';

/// Recurring tracking metadata; dates never generate transactions or charges.
abstract final class SubscriptionPlansCodec {
  static Map<String, dynamic> encode(List<SubscriptionPlan> plans) => {
    'version': 1,
    'plans': [
      for (final p in plans)
        {
          'id': p.id,
          'name': p.name,
          'amount': p.amount,
          'cycle': p.cycle.name,
          'nextRenewal': p.nextRenewal.toIso8601String(),
          'paymentSource': p.paymentSource,
          'category': p.category,
          'active': p.active,
          'origin': p.origin.name,
          'confidence': p.confidence,
        },
    ],
  };

  static List<SubscriptionPlan> decode(Map<String, dynamic> json) {
    if (json['version'] is! int || json['version'] != 1) {
      throw const FormatException('Unsupported subscription format.');
    }
    return [
      for (final value in json['plans'] as List)
        _plan(value as Map<String, dynamic>),
    ];
  }

  static SubscriptionPlan _plan(Map<String, dynamic> json) {
    // Cast directly to int: accepting num.toInt() would truncate centavos.
    final date = DateTime.parse(json['nextRenewal'] as String);
    if (date.toIso8601String() != json['nextRenewal']) {
      throw const FormatException('Invalid subscription renewal date.');
    }
    return SubscriptionPlan(
      id: json['id'] as String,
      name: json['name'] as String,
      amount: json['amount'] as int,
      cycle: BillingCycle.values.byName(json['cycle'] as String),
      nextRenewal: date,
      paymentSource: json['paymentSource'] as String,
      category: json['category'] as String,
      active: json['active'] as bool,
      origin: SubscriptionOrigin.values.byName(json['origin'] as String),
      confidence: (json['confidence'] as num?)?.toDouble(),
    );
  }
}
