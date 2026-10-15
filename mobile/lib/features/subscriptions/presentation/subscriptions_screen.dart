import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/finance_card.dart';
import '../../../core/widgets/task_screen.dart';
import '../../../core/time/clock.dart';
import '../application/subscriptions_provider.dart';
import '../domain/subscription_plan.dart';
import 'subscription_dialogs.dart';
import 'widgets/subscription_cards.dart';

class SubscriptionsScreen extends ConsumerWidget {
  const SubscriptionsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(subscriptionsProvider);
    final sort = ref.watch(subscriptionSortProvider);
    final now = ref.watch(clockProvider)();
    return TaskScreen(
      title: 'Subscriptions & Bills',
      backIcon: Icons.arrow_back,
      backTooltip: 'Back',
      fallbackRoute: '/budgets',
      actions: [
        TextButton.icon(
          key: const ValueKey('add-subscription'),
          onPressed: state.hasValue
              ? () => showSubscriptionEditor(context)
              : null,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add'),
        ),
      ],
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: TextButton(
            onPressed: () => ref.invalidate(subscriptionsProvider),
            child: const Text('Could not load subscriptions. Try again.'),
          ),
        ),
        data: (overview) {
          final ordered = overview.sorted(sort);
          final upcoming = ordered.where(
            (p) => p.active && p.daysUntil(now) >= 0 && p.daysUntil(now) < 7,
          );
          Widget heading(String title) => Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 12),
            child: Text(title, style: AppTypography.headlineSmall),
          );
          Widget row(SubscriptionPlan p) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SubscriptionCard(
              plan: p,
              clock: now,
              onTap: () => showSubscriptionDetails(context, p),
            ),
          );
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              CommitmentHero(overview, clock: now),
              if (overview.plans.isEmpty) ...[
                heading('No subscriptions tracked'),
                const Text(
                  'Add a recurring expense to track its commitment and renewal.',
                ),
                TextButton(
                  onPressed: () => showSubscriptionEditor(context),
                  child: const Text('Add a subscription'),
                ),
              ] else ...[
                heading('Upcoming Bills · Next 7 Days'),
                if (upcoming.isEmpty)
                  const Text('No renewals due in the next 7 days.'),
                for (final p in upcoming) row(p),
                Align(
                  alignment: Alignment.centerRight,
                  child: PopupMenuButton<SubscriptionSort>(
                    tooltip: 'Sort subscriptions',
                    initialValue: sort,
                    onSelected: (v) =>
                        ref.read(subscriptionSortProvider.notifier).set(v),
                    itemBuilder: (_) => [
                      for (final s in SubscriptionSort.values)
                        PopupMenuItem(
                          value: s,
                          child: Text('Sort by ${s.name}'),
                        ),
                    ],
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text('Sort by ${sort.name} ⌄'),
                    ),
                  ),
                ),
                for (final (label, plans)
                    in <(String, Iterable<SubscriptionPlan>)>[
                      (
                        'Active Subscriptions & Utilities',
                        ordered.where(
                          (p) => p.active && p.cycle != BillingCycle.yearly,
                        ),
                      ),
                      (
                        'Annual & Long-Term Commitments',
                        ordered.where(
                          (p) => p.active && p.cycle == BillingCycle.yearly,
                        ),
                      ),
                      ('Paused Tracking', ordered.where((p) => !p.active)),
                    ])
                  if (plans.isNotEmpty) ...[
                    heading(label),
                    for (final p in plans) row(p),
                  ],
              ],
              const SizedBox(height: 16),
              FinanceCard(
                child: ListTile(
                  key: const ValueKey('subscription-history'),
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.receipt_long_outlined),
                  title: const Text('Subscription History'),
                  subtitle: const Text('View recorded recurring charges'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => showSubscriptionHistory(context),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Renewals track your commitments. They do not charge your accounts or cancel external services.',
                textAlign: TextAlign.center,
              ),
            ],
          );
        },
      ),
    );
  }
}
