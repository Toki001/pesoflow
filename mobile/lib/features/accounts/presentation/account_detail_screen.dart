import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/formatting/date_formatter.dart';
import '../../../core/widgets/finance_card.dart';
import '../../../core/widgets/task_screen.dart';
import '../../transactions/presentation/transaction_list_row.dart';
import '../application/account_detail_provider.dart';
import '../application/accounts_provider.dart';
import '../domain/account_detail.dart';
import '../domain/demo_account.dart';
import 'account_dialogs.dart';
import 'widgets/account_detail_summary.dart';
import 'widgets/accounts_trust.dart';

class AccountDetailScreen extends ConsumerWidget {
  const AccountDetailScreen({required this.id, super.key});
  final String id;

  Future<void> remove(
    BuildContext context,
    WidgetRef ref,
    DemoAccount account,
  ) async {
    if (!await confirmDemoDisconnect(context, account) || !context.mounted) {
      return;
    }
    ref.read(accountsProvider.notifier).disconnect(account.id);
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/accounts');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(accountDetailProvider(id));
    return TaskScreen(
      title: 'Account Detail',
      backIcon: Icons.arrow_back,
      backTooltip: 'Back',
      fallbackRoute: '/accounts',
      child: state.when(
        loading: () => Semantics(
          label: 'Loading sample account',
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              for (final height in [200.0, 180.0, 120.0])
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: FinanceCard(
                    child: SizedBox(
                      height: height,
                      child: ColoredBox(color: context.colors.mutedSurface),
                    ),
                  ),
                ),
            ],
          ),
        ),
        error: (_, _) => _DetailMessage(
          title: "We couldn't load this sample account.",
          message: 'Please try again. No financial institution was contacted.',
          action: 'Try Again',
          onAction: () => ref.invalidate(accountsProvider),
        ),
        data: (detail) => detail == null
            ? _DetailMessage(
                title: 'Sample account unavailable',
                message: 'This profile was removed from the session or the link does not match a sample account.',
                action: 'View sample accounts',
                onAction: () => context.go('/accounts'),
              )
            : _AccountContent(
                detail: detail,
                onRemove: () => remove(context, ref, detail.account),
              ),
      ),
    );
  }
}

class _AccountContent extends ConsumerWidget {
  const _AccountContent({required this.detail, required this.onRemove});
  final AccountDetail detail;
  final VoidCallback onRemove;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = detail.account;
    final overview = ref.watch(accountsProvider).value!;
    final c = context.colors;
    return SingleChildScrollView(
      key: PageStorageKey('account-detail-${account.id}'),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AccountsReassurance(),
          const SizedBox(height: AppSpacing.md),
          AccountDetailSummary(account: account),
          const SizedBox(height: AppSpacing.md),
          if (account.needsReauthentication)
            FinanceCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              borderColor: c.warning.withValues(alpha: .4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Sample connection expired',
                    style: AppTypography.merchant.copyWith(color: c.warning),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'The last-known balance is stale and excluded from the available total. Real reconnection is not available yet.',
                    style: AppTypography.bodySmall.copyWith(
                      color: c.secondaryInk,
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      if (await showDemoReconnect(context, account) &&
                          context.mounted) {
                        onRemove();
                      }
                    },
                    child: const Text('About reconnection'),
                  ),
                ],
              ),
            ),
          if (account.needsReauthentication)
            const SizedBox(height: AppSpacing.md),
          FinanceCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Sample data controls', style: AppTypography.merchant),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'A local check does not contact a provider, update balances or advance the reported timestamp.',
                  style: AppTypography.bodySmall.copyWith(
                    color: c.secondaryInk,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton.icon(
                  onPressed: overview.refreshing
                      ? null
                      : () => ref.read(accountsProvider.notifier).refreshDemo(),
                  icon: const Icon(Icons.sync, size: 18),
                  label: Text(
                    overview.refreshing ? 'Checking demo…' : 'Check demo data',
                  ),
                ),
                if (overview.refreshError || overview.checked) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      overview.refreshError
                          ? "We couldn't check the demo data. The sample balance is unchanged."
                          : 'Sample data checked. No live sync or balance changes.',
                      style: AppTypography.bodySmall.copyWith(
                        color: overview.refreshError
                            ? c.warning
                            : c.secondaryInk,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Semantics(
            header: true,
            child: Text(
              'Related demo activity',
              style: AppTypography.headlineSmall,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Sample records and session entries for this profile. This is not a bank statement and does not reconcile the reported balance. Transfers are shown neutrally.',
            style: AppTypography.bodySmall.copyWith(color: c.mutedInk),
          ),
          const SizedBox(height: AppSpacing.sm),
          FinanceCard(
            padding: EdgeInsets.zero,
            child: detail.activity.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Text(
                      'No related demo transactions',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySmall.copyWith(
                        color: c.mutedInk,
                      ),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < detail.activity.length; i++) ...[
                        if (i > 0) const Divider(),
                        if (i == 0 ||
                            DateUtils.dateOnly(detail.activity[i].occurredAt) !=
                                DateUtils.dateOnly(
                                  detail.activity[i - 1].occurredAt,
                                ))
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                            child: Semantics(
                              header: true,
                              child: Text(
                                DateFormatter.header(
                                  detail.activity[i].occurredAt,
                                ),
                                style: AppTypography.labelMedium.copyWith(
                                  color: c.mutedInk,
                                ),
                              ),
                            ),
                          ),
                        TransactionListRow(
                          transaction: detail.activity[i],
                          wrapText: true,
                        ),
                      ],
                    ],
                  ),
          ),
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton.icon(
            onPressed: onRemove,
            style: OutlinedButton.styleFrom(foregroundColor: c.danger),
            icon: const Icon(Icons.link_off, size: 18),
            label: const Text('Remove demo profile'),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Removal changes the sample account list only. Transaction history and manual payment sources remain available.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(color: c.mutedInk),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _DetailMessage extends StatelessWidget {
  const _DetailMessage({
    required this.title,
    required this.message,
    required this.action,
    required this.onAction,
  });
  final String title;
  final String message;
  final String action;
  final VoidCallback onAction;
  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Text(
            title,
            style: AppTypography.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            message,
            style: AppTypography.bodySmall.copyWith(
              color: context.colors.secondaryInk,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton(onPressed: onAction, child: Text(action)),
        ],
      ),
    ),
  );
}
