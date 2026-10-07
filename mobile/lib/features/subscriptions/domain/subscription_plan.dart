import 'package:pesoflow/features/transactions/domain/transaction.dart';

enum BillingCycle {
  weekly(52, 'week'),
  monthly(12, 'month'),
  quarterly(4, 'quarter'),
  yearly(1, 'year');

  const BillingCycle(this.paymentsPerYear, this.unit);
  final int paymentsPerYear;
  final String unit;
}

enum SubscriptionOrigin { stitchFixture, manual }

enum SubscriptionSort { date, name, amount }

/// Tracking metadata only: a renewal never creates a ledger debit.
class SubscriptionPlan {
  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.amount,
    required this.cycle,
    required this.nextRenewal,
    required this.paymentSource,
    required this.category,
    this.active = true,
    this.origin = SubscriptionOrigin.manual,
    this.confidence,
  }) {
    if (id.trim().isEmpty ||
        name.trim().isEmpty ||
        name.length > 80 ||
        amount <= 0 ||
        amount > 99999999999 ||
        paymentSource.trim().isEmpty ||
        category.trim().isEmpty ||
        (confidence != null &&
            (confidence!.isNaN || confidence! < 0 || confidence! > 1))) {
      throw ArgumentError('Invalid subscription tracking details.');
    }
  }
  final String id, name, paymentSource, category;
  final int amount;
  final BillingCycle cycle;
  final DateTime nextRenewal;
  final bool active;
  final SubscriptionOrigin origin;
  // Unknown for manually supplied and Stitch fixture plans. No detection claim.
  final double? confidence;
  int get annualized => amount * cycle.paymentsPerYear;
  int get monthlyEquivalent => (annualized + 6) ~/ 12;
  int daysUntil(DateTime clock) => DateTime.utc(
    nextRenewal.year,
    nextRenewal.month,
    nextRenewal.day,
  ).difference(DateTime.utc(clock.year, clock.month, clock.day)).inDays;

  SubscriptionPlan withActive(bool value) => SubscriptionPlan(
    id: id,
    name: name,
    amount: amount,
    cycle: cycle,
    nextRenewal: nextRenewal,
    paymentSource: paymentSource,
    category: category,
    active: value,
    origin: origin,
    confidence: confidence,
  );
}

class SubscriptionOverview {
  SubscriptionOverview(Iterable<SubscriptionPlan> plans)
    : plans = List.unmodifiable(plans) {
    if (this.plans.map((p) => p.id).toSet().length != this.plans.length) {
      throw ArgumentError('Duplicate subscription ID.');
    }
  }
  final List<SubscriptionPlan> plans;
  List<SubscriptionPlan> get active => plans.where((p) => p.active).toList();
  int get annualized => active.fold(0, (sum, p) => sum + p.annualized);
  // Round once after summing exact annual centavos, never rounded per-row costs.
  int get monthlyEquivalent => (annualized + 6) ~/ 12;
  List<SubscriptionPlan> sorted(SubscriptionSort sort) =>
      [...plans]..sort((a, b) {
        final value = switch (sort) {
          SubscriptionSort.date => a.nextRenewal.compareTo(b.nextRenewal),
          SubscriptionSort.name => a.name.toLowerCase().compareTo(
            b.name.toLowerCase(),
          ),
          SubscriptionSort.amount => b.annualized.compareTo(a.annualized),
        };
        return value == 0 ? a.id.compareTo(b.id) : value;
      });
  List<SubscriptionPlan> get upcoming =>
      (active..sort((a, b) {
            final date = a.nextRenewal.compareTo(b.nextRenewal);
            return date == 0 ? a.id.compareTo(b.id) : date;
          }))
          .take(4)
          .toList();
}

/// Observed posted charges only; future plans are never presented as billings.
List<TransactionRecord> subscriptionHistory(
  Iterable<TransactionRecord> ledger,
) =>
    ledger
        .where(
          (t) =>
              t.status == TransactionStatus.posted &&
              t.kind == TransactionKind.expense &&
              t.recurring,
        )
        .toList()
      ..sort((a, b) {
        final date = b.occurredAt.compareTo(a.occurredAt);
        return date == 0 ? a.id.compareTo(b.id) : date;
      });
