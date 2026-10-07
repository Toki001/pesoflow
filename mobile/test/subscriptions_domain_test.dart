import 'support/fixture_container.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:pesoflow/features/subscriptions/application/subscriptions_provider.dart';

import 'fixtures/features/subscriptions/data/subscription_fixture.dart';

import 'package:pesoflow/features/subscriptions/domain/subscription_plan.dart';
import 'package:pesoflow/features/transactions/application/transactions_provider.dart';

import 'fixtures/features/transactions/data/transaction_fixture.dart';

import 'package:pesoflow/features/transactions/domain/transaction.dart';

SubscriptionPlan plan({
  String id = 'test',
  int amount = 10001,
  BillingCycle cycle = BillingCycle.monthly,
  DateTime? date,
  double? confidence,
}) => SubscriptionPlan(
  id: id,
  name: 'Test',
  amount: amount,
  cycle: cycle,
  nextRenewal: date ?? DateTime(2024, 10, 31),
  paymentSource: 'Cash',
  category: 'Other',
  confidence: confidence,
);
void main() {
  test('fixture totals include annual plan and count all five services', () {
    final overview = SubscriptionOverview(subscriptionFixture());
    expect(overview.plans.length, 5);
    expect(overview.active.length, 5);
    expect(overview.annualized, 1874200);
    expect(overview.monthlyEquivalent, 156183);
    expect(overview.upcoming.map((p) => p.id), [
      'netflix',
      'spotify',
      'google',
      'icloud',
    ]);
    expect(overview.plans.last.monthlyEquivalent, 24583);
    expect(() => overview.plans.clear(), throwsUnsupportedError);
  });
  test('all cycles annualize exact centavos and total rounds only once', () {
    for (final cycle in BillingCycle.values) {
      final p = plan(cycle: cycle);
      expect(p.annualized, 10001 * cycle.paymentsPerYear);
      expect(p.monthlyEquivalent, (10001 * cycle.paymentsPerYear + 6) ~/ 12);
    }
    final overview = SubscriptionOverview([
      plan(id: 'a', amount: 5, cycle: BillingCycle.yearly),
      plan(id: 'b', amount: 5, cycle: BillingCycle.yearly),
    ]);
    expect(overview.monthlyEquivalent, 1);
    expect(plan(amount: 6, cycle: BillingCycle.yearly).monthlyEquivalent, 1);
    expect(overview.plans.fold<int>(0, (n, p) => n + p.monthlyEquivalent), 0);
  });
  test('paused and empty plans have no commitments or upcoming renewals', () {
    final overview = SubscriptionOverview(
      subscriptionFixture().map((p) => p.withActive(false)),
    );
    expect(overview.annualized, 0);
    expect(overview.upcoming, isEmpty);
    expect(SubscriptionOverview([]).monthlyEquivalent, 0);
  });
  test(
    'renewal days compare calendar dates across leap and year boundaries',
    () {
      expect(
        plan(date: DateTime(2024, 2, 29))
            .daysUntil(DateTime(2024, 2, 28, 23, 59)),
        1,
      );
      expect(
        plan(date: DateTime(2025, 1, 1)).daysUntil(DateTime(2024, 12, 31, 23)),
        1,
      );
      expect(plan(date: DateTime(2024, 10, 24)).daysUntil(demoClock), 0);
      expect(plan(date: DateTime(2024, 10, 23)).daysUntil(demoClock), -1);
    },
  );
  test(
    'sorts are deterministic and amount uses equivalent annual commitment',
    () {
      final overview = SubscriptionOverview(subscriptionFixture());
      expect(overview.sorted(SubscriptionSort.amount).first.id, 'netflix');
      expect(overview.sorted(SubscriptionSort.name).first.id, 'disney');
      expect(overview.sorted(SubscriptionSort.date).last.id, 'disney');
      expect(
        SubscriptionOverview([plan(id: 'z'), plan(id: 'a')])
            .sorted(SubscriptionSort.date)
            .first
            .id,
        'a',
      );
    },
  );
  test('duplicate subscription IDs rejected', () {
    expect(() => SubscriptionOverview([plan(), plan()]), throwsArgumentError);
  });
  test('rejects invalid amount, identity and detection confidence', () {
    for (final amount in [0, -1, 100000000000]) {
      expect(() => plan(amount: amount), throwsArgumentError);
    }
    for (final confidence in [-0.1, 1.1, double.nan]) {
      expect(() => plan(confidence: confidence), throwsArgumentError);
    }
    expect(() => plan(id: ' '), throwsArgumentError);
    expect(plan().confidence, isNull);
  });
  test(
    'history excludes pending, income, transfer, refund and unflagged records',
    () {
      final base = transactionFixture().first;
      final records = [
        base.copyWith(id: 'posted', recurring: true),
        base.copyWith(
          id: 'pending',
          recurring: true,
          status: TransactionStatus.pending,
        ),
        for (final kind in [
          TransactionKind.income,
          TransactionKind.transfer,
          TransactionKind.refund,
        ])
          base.copyWith(id: kind.name, recurring: true, kind: kind),
        base.copyWith(id: 'unflagged', recurring: false),
      ];
      expect(subscriptionHistory(records).map((t) => t.id), ['posted']);
      expect(subscriptionHistory(transactionFixture()).map((t) => t.id), [
        'netflix',
      ]);
    },
  );
  test('session CRUD preserves ledger; paused state and updates survive provider reads', () async {
    final container = fixtureContainer();
    addTearDown(container.dispose);
    final ledger = container.read(ledgerProvider);
    final controller = container.read(subscriptionPlansProvider.notifier);
    await controller.setActive('icloud', false);
    final id = controller.nextId();
    await controller.save(plan(id: id));
    await controller.save(plan(id: id, amount: 99));
    expect(
      container.read(subscriptionPlansProvider).where((p) => p.id == id).length,
      1,
    );
    expect(container.read(subscriptionPlansProvider).last.amount, 99);
    expect(
      () => container.read(subscriptionPlansProvider).clear(),
      throwsUnsupportedError,
    );
    await controller.remove(id);
    expect(container.read(subscriptionPlansProvider).length, 5);
    await controller.setActive('icloud', true);
    expect(
      (await container.read(subscriptionsProvider.future)).monthlyEquivalent,
      156183,
    );
    expect(container.read(ledgerProvider), ledger);
  });
}
