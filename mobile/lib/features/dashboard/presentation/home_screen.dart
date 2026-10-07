import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pesoflow/app/theme/app_colors.dart';
import 'package:pesoflow/features/notifications/presentation/widgets/notification_button.dart';
import 'package:pesoflow/app/theme/app_spacing.dart';
import 'package:pesoflow/app/theme/app_typography.dart';
import 'package:pesoflow/core/formatting/date_formatter.dart';
import 'package:pesoflow/core/widgets/finance_card.dart';
import 'package:pesoflow/core/widgets/section_header.dart';
import 'package:pesoflow/features/dashboard/presentation/widgets/dashboard_transaction_tile.dart';
import 'package:pesoflow/features/dashboard/application/dashboard_provider.dart';
import 'package:pesoflow/features/dashboard/domain/dashboard.dart';
import 'package:pesoflow/features/dashboard/presentation/widgets/balance_summary.dart';
import 'package:pesoflow/features/dashboard/presentation/widgets/budget_summary.dart';
import 'package:pesoflow/features/dashboard/presentation/widgets/spending_insight.dart';
import 'package:pesoflow/features/dashboard/presentation/widgets/upcoming_bills.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardProvider);
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          HomeHeader(asOf: state.value?.asOf, name: state.value?.name ?? ''),
          Expanded(
            child: state.when(
              data: (data) => data == null
                  ? _HomeMessage(
                      title: 'No financial overview yet',
                      message:
                          'Your overview will appear when data is available.',
                      onRetry: () => ref.invalidate(dashboardProvider),
                    )
                  : HomeContent(data: data),
              loading: () => const _HomeSkeleton(),
              error: (_, _) => _HomeMessage(
                title: "We couldn't load your overview.",
                message: 'Please try again.',
                onRetry: () => ref.invalidate(dashboardProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeHeader extends StatelessWidget {
  const HomeHeader({required this.asOf, this.name = '', super.key});
  final String name;
  final DateTime? asOf;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(bottom: BorderSide(color: c.border)),
      ),
      child: Row(
        children: [
          Semantics(
            button: true,
            label: 'Settings',
            excludeSemantics: true,
            onTap: () => context.push('/settings'),
            child: Tooltip(
              message: 'Settings',
              child: InkWell(
                onTap: () => context.push('/settings'),
                child: SizedBox(
                  width: 44,
                  height: 48,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: c.soft(c.primary, AppColors.primarySoft),
                      child: Text(
                        name.trim().isEmpty
                            ? 'PF'
                            : name.trim().characters.first.toUpperCase(),
                        style: AppTypography.labelMedium.copyWith(
                          color: c.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('PesoFlow', style: AppTypography.headlineSmall),
                    const SizedBox(width: 4),
                    Icon(Icons.circle, size: 6, color: c.positive),
                  ],
                ),
                Text(
                  asOf == null ? 'Your overview' : DateFormatter.header(asOf!),
                  style: AppTypography.labelSmall.copyWith(color: c.mutedInk),
                ),
              ],
            ),
          ),
          const NotificationButton(showUnreadDot: true),
        ],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({required this.data, super.key});
  final Dashboard data;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    key: const PageStorageKey('home-scroll'),
    padding: const EdgeInsets.fromLTRB(
      AppSpacing.md,
      AppSpacing.sm,
      AppSpacing.md,
      AppSpacing.xxxl,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SyncStrip(),
        const SizedBox(height: 22),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data.name.isEmpty
                  ? 'Your financial overview'
                  : 'Hello, ${data.name}',
              style: AppTypography.headlineMedium,
            ),
            const SizedBox(height: 2),
            Text(
              'Here is your calm financial overview for today.',
              style: AppTypography.bodySmall.copyWith(
                color: context.colors.mutedInk,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Semantics(
          key: const ValueKey('open-accounts'),
          button: true,
          label: 'View accounts',
          child: InkWell(
            onTap: () => context.push('/accounts'),
            child: BalanceHero(data: data),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        FlowSummary(data: data),
        const SizedBox(height: AppSpacing.md),
        SpendingInsight(
          extraSavings: data.projectedExtraSavings,
          hasBudget: data.budgetLimit > 0,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionHeader(
              'Monthly Budgets',
              action: 'View all',
              onAction: () => context.go('/budgets'),
            ),
            if (data.budgetLimit > 0 || data.budgets.isNotEmpty)
              BudgetSummary(data: data)
            else
              const FinanceCard(
                child: Text(
                  'No budgets yet. Set a monthly limit to track your spending.',
                ),
              ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionHeader(
              'Recent Transactions',
              action: 'See all',
              onAction: () => context.go('/transactions'),
            ),
            FinanceCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  if (data.transactions.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(AppSpacing.lg),
                      child: Text('No financial activity yet.'),
                    ),
                  for (var i = 0; i < data.transactions.length; i++) ...[
                    if (i > 0) const Divider(),
                    DashboardTransactionTile(
                      transaction: data.transactions[i],
                      asOf: data.asOf,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SectionHeader('Upcoming Bills', caption: 'Next 7 days'),
            const SizedBox(height: AppSpacing.xs),
            Semantics(
              key: const ValueKey('open-subscriptions'),
              button: true,
              label: 'Manage subscriptions',
              child: InkWell(
                onTap: () => context.go('/subscriptions'),
                child: UpcomingBills(bills: data.bills),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _SyncStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) => FinanceCard(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 6),
    child: Row(
      children: [
        Icon(Icons.circle, size: 8, color: context.colors.positive),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            'Saved on this device',
            style: AppTypography.labelSmall.copyWith(
              color: context.colors.secondaryInk,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          'Manual tracking',
          style: AppTypography.labelSmall.copyWith(
            color: context.colors.primary,
          ),
        ),
      ],
    ),
  );
}

class _HomeMessage extends StatelessWidget {
  const _HomeMessage({
    required this.title,
    required this.message,
    required this.onRetry,
  });
  final String title;
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: AppTypography.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.md),
          TextButton(onPressed: onRetry, child: const Text('Try Again')),
        ],
      ),
    ),
  );
}

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Loading financial overview',
    child: ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        for (final height in [26.0, 46.0, 144.0, 74.0, 94.0, 260.0])
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: FinanceCard(
              child: SizedBox(
                height: height,
                width: double.infinity,
                child: ColoredBox(color: context.colors.mutedSurface),
              ),
            ),
          ),
      ],
    ),
  );
}
