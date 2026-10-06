import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/finance_card.dart';
import '../../transactions/data/transaction_fixture.dart';
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
    final c = context.colors;
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Container(
            constraints: const BoxConstraints(minHeight: 56),
            padding: const EdgeInsets.fromLTRB(8, 4, 16, 4),
            decoration: BoxDecoration(
              color: c.surface,
              border: Border(bottom: BorderSide(color: c.border)),
            ),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Back',
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/budgets');
                    }
                  },
                  icon: const Icon(Icons.arrow_back, size: 20),
                ),
                Expanded(
                  child: Text(
                    'Subscriptions',
                    style: AppTypography.headlineSmall,
                  ),
                ),
                TextButton.icon(
                  key: const ValueKey('add-subscription'),
                  onPressed: state.value == null
                      ? null
                      : () => showSubscriptionEditor(context),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add'),
                  style: TextButton.styleFrom(
                    minimumSize: const Size(64, 28),
                    backgroundColor: c.primary,
                    foregroundColor: c.surface,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: state.when(
              loading: () => Semantics(
                label: 'Loading subscriptions',
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    for (final height in [160.0, 70.0, 70.0, 90.0, 90.0])
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: FinanceCard(
                          child: SizedBox(
                            height: height,
                            child: ColoredBox(color: c.mutedSurface),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              error: (_, _) => Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "We couldn't load your subscriptions.",
                        textAlign: TextAlign.center,
                        style: AppTypography.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Please try again.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => ref.invalidate(subscriptionsProvider),
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (overview) => SingleChildScrollView(
                key: const PageStorageKey('subscriptions-scroll'),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CommitmentHero(overview, clock: demoClock),
                    const SizedBox(height: 16),
                    if (overview.cloudSaving > 0) ...[
                      SubscriptionTip(saving: overview.cloudSaving),
                      const SizedBox(height: 16),
                    ],
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Upcoming renewals',
                          style: AppTypography.headlineSmall,
                        ),
                        Text(
                          '${overview.upcoming.length} scheduled',
                          style: AppTypography.bodySmall.copyWith(
                            color: c.mutedInk,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (overview.upcoming.isNotEmpty)
                      RenewalTimeline(
                        plans: overview.upcoming,
                        onTap: (p) => showSubscriptionDetails(context, p),
                      )
                    else
                      Text(
                        'No active renewals scheduled',
                        style: AppTypography.bodySmall,
                      ),
                    const SizedBox(height: 0),
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          overview.plans.any((p) => !p.active)
                              ? 'Tracked Subscriptions (${overview.plans.length})'
                              : 'Active Subscriptions (${overview.active.length})',
                          style: AppTypography.headlineSmall,
                        ),
                        PopupMenuButton<SubscriptionSort>(
                          tooltip: 'Sort subscriptions',
                          initialValue: sort,
                          onSelected: (value) => ref
                              .read(subscriptionSortProvider.notifier)
                              .set(value),
                          itemBuilder: (_) => [
                            for (final s in SubscriptionSort.values)
                              PopupMenuItem(
                                value: s,
                                child: Text('Sort by ${s.name}'),
                              ),
                          ],
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(minHeight: 48),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Sort by ${sort.name == 'date'
                                      ? 'Date'
                                      : sort.name == 'name'
                                      ? 'Name'
                                      : 'Amount'}',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: c.primary,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_drop_down,
                                  size: 16,
                                  color: c.primary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (overview.plans.isEmpty)
                      FinanceCard(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Text(
                              'No subscriptions tracked',
                              style: AppTypography.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Add a demo plan to track its commitment and renewal.',
                              textAlign: TextAlign.center,
                            ),
                            TextButton(
                              onPressed: () => showSubscriptionEditor(context),
                              child: const Text('Add a subscription'),
                            ),
                          ],
                        ),
                      ),
                    for (final p in overview.sorted(sort)) ...[
                      SubscriptionCard(
                        plan: p,
                        clock: demoClock,
                        onTap: () => showSubscriptionDetails(context, p),
                      ),
                      const SizedBox(height: 10),
                    ],
                    const SizedBox(height: 6),
                    InkWell(
                      key: const ValueKey('subscription-history'),
                      onTap: () => showSubscriptionHistory(context),
                      borderRadius: BorderRadius.circular(12),
                      child: FinanceCard(
                        child: Row(
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 20,
                              color: c.mutedInk,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Subscription History',
                                    style: AppTypography.merchant,
                                  ),
                                  Text(
                                    'View recorded recurring charges',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: c.mutedInk,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              size: 20,
                              color: c.mutedInk,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Demo plans · Oct 24, 2024 · Session only',
                      textAlign: TextAlign.center,
                      style: AppTypography.labelSmall.copyWith(
                        color: c.mutedInk,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
