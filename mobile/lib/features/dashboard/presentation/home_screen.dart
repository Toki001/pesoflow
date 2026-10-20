import 'package:pesoflow/core/widgets/main_app_bar.dart';
import 'package:pesoflow/core/widgets/financial_account_row.dart';
import 'package:pesoflow/features/accounts/domain/financial_account.dart';
import 'package:pesoflow/features/accounts/presentation/manual_account_editor.dart';
import 'package:pesoflow/features/workspace/application/finance_controller.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pesoflow/app/theme/app_colors.dart';
import 'package:pesoflow/app/theme/app_spacing.dart';
import 'package:pesoflow/app/theme/app_typography.dart';
import 'package:pesoflow/core/widgets/finance_card.dart';
import 'package:pesoflow/core/widgets/section_header.dart';
import 'package:pesoflow/features/dashboard/presentation/widgets/dashboard_transaction_tile.dart';
import 'package:pesoflow/features/dashboard/application/dashboard_provider.dart';
import 'package:pesoflow/features/dashboard/domain/dashboard.dart';
import 'package:pesoflow/features/dashboard/presentation/widgets/balance_summary.dart';
import 'package:pesoflow/features/dashboard/presentation/widgets/budget_summary.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardProvider);
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          const MainAppBar('PesoFlow'),
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

class HomeContent extends ConsumerWidget {
  const HomeContent({required this.data, super.key});
  final Dashboard data;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final w = ref.watch(workspaceProvider);
    final accounts = w.accounts.where((a) => !a.archived).toList();
    return SingleChildScrollView(
      key: const PageStorageKey('home-scroll'),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 20,
        children: [
          InkWell(
            key: const ValueKey('open-accounts'),
            onTap: () => context.push('/accounts'),
            child: BalanceHero(data: data),
          ),
          FlowSummary(data: data),
          FinanceCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionHeader(
                  'Tracked Accounts',
                  action: 'All Accounts ›',
                  onAction: () => context.push('/accounts'),
                ),
                if (accounts.isEmpty) ...[
                  Text(
                    w.accounts.isEmpty
                        ? 'No accounts yet. Create a manually tracked account to begin.'
                        : 'All accounts are archived. Open All Accounts to view or re-enable them.',
                  ),
                  TextButton(
                    onPressed: () => showManualAccountEditor(context),
                    child: const Text('Create account'),
                  ),
                ],
                for (final a in accounts.take(5))
                  FinancialAccountRow(
                    account: a,
                    balance: accountBalance(
                      a,
                      w.ledger.where((t) => !t.occurredAt.isAfter(data.asOf)),
                    ),
                  ),
              ],
            ),
          ),
          FinanceCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionHeader(
                  'Budget Pacing',
                  action: 'View all',
                  onAction: () => context.go('/budgets'),
                ),
                Text(
                  'Day ${data.asOf.day} of ${DateTime(data.asOf.year, data.asOf.month + 1, 0).day} days',
                  style: AppTypography.bodySmall.copyWith(
                    color: context.colors.mutedInk,
                  ),
                ),
                const SizedBox(height: 16),
                if (data.budgetLimit > 0 || data.budgets.isNotEmpty)
                  BudgetSummary(data: data, embedded: true)
                else
                  const Text(
                    'No budgets yet. Set a monthly limit to track your spending.',
                  ),
              ],
            ),
          ),
          FinanceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionHeader(
                  'Recent Transactions',
                  action: 'See all',
                  onAction: () => context.go('/transactions'),
                ),
                if (data.transactions.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'No financial activity yet. Use Add to record your first expense.',
                    ),
                  ),
                for (final t in data.transactions)
                  DashboardTransactionTile(transaction: t, asOf: data.asOf),
              ],
            ),
          ),
        ],
      ),
    );
  }
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
