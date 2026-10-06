import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/subscription_fixture.dart';
import '../domain/subscription_plan.dart';

class DemoSubscriptions extends Notifier<List<SubscriptionPlan>> {
  int _sequence = 0;
  @override
  List<SubscriptionPlan> build() => List.unmodifiable(subscriptionFixture());
  String nextId() => 'subscription-demo-${++_sequence}';
  void save(SubscriptionPlan plan) {
    final exists = state.any((p) => p.id == plan.id);
    state = List.unmodifiable([
      for (final p in state)
        if (p.id == plan.id) plan else p,
      if (!exists) plan,
    ]);
  }

  void setActive(String id, bool active) => state = List.unmodifiable([
    for (final p in state)
      if (p.id == id) p.withActive(active) else p,
  ]);
  void remove(String id) =>
      state = List.unmodifiable(state.where((p) => p.id != id));
}

final demoSubscriptionsProvider =
    NotifierProvider<DemoSubscriptions, List<SubscriptionPlan>>(
      DemoSubscriptions.new,
    );
final subscriptionsProvider = FutureProvider<SubscriptionOverview>(
  (ref) async => SubscriptionOverview(ref.watch(demoSubscriptionsProvider)),
  retry: (_, _) => null,
);

class SubscriptionSortController extends Notifier<SubscriptionSort> {
  @override
  SubscriptionSort build() => SubscriptionSort.date;
  void set(SubscriptionSort value) => state = value;
}

final subscriptionSortProvider =
    NotifierProvider<SubscriptionSortController, SubscriptionSort>(
      SubscriptionSortController.new,
    );
