import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pesoflow/core/identity/new_id.dart';
import 'package:pesoflow/features/workspace/application/finance_controller.dart';
import 'package:pesoflow/features/subscriptions/domain/subscription_plan.dart';

class SubscriptionPlans extends Notifier<List<SubscriptionPlan>> {
  @override
  List<SubscriptionPlan> build() => ref.watch(workspaceProvider).subscriptions;
  String nextId() => newId();
  Future<void> save(SubscriptionPlan plan) =>
      ref.read(financeControllerProvider.notifier).saveSubscription(plan);
  Future<void> setActive(String id, bool active) =>
      save(state.firstWhere((p) => p.id == id).withActive(active));
  Future<void> remove(String id) =>
      ref.read(financeControllerProvider.notifier).deleteSubscription(id);
}

final subscriptionPlansProvider =
    NotifierProvider<SubscriptionPlans, List<SubscriptionPlan>>(
      SubscriptionPlans.new,
    );
final subscriptionsProvider = FutureProvider<SubscriptionOverview>(
  (ref) async => SubscriptionOverview(ref.watch(subscriptionPlansProvider)),
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
