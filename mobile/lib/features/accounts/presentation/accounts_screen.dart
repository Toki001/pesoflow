import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pesoflow/app/theme/app_colors.dart';
import 'package:pesoflow/app/theme/app_typography.dart';
import 'package:pesoflow/core/widgets/finance_card.dart';
import 'package:pesoflow/core/widgets/task_screen.dart';
import 'package:pesoflow/core/time/clock.dart';
import 'package:pesoflow/features/workspace/application/finance_controller.dart';
import 'package:pesoflow/features/accounts/presentation/manual_account_editor.dart';
import 'package:pesoflow/features/accounts/application/accounts_provider.dart';
import 'package:pesoflow/features/accounts/domain/account_view.dart';
import 'package:pesoflow/features/accounts/presentation/account_dialogs.dart';
import 'package:pesoflow/features/accounts/presentation/widgets/account_connection_card.dart';
import 'package:pesoflow/features/accounts/presentation/widgets/accounts_balance_hero.dart';
import 'package:pesoflow/features/accounts/presentation/widgets/accounts_trust.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});
  Future<void> disconnect(
    BuildContext context,
    WidgetRef ref,
    AccountView account,
  ) async {
    if (await confirmAccountRemoval(context, account) && context.mounted) {
      try {
        await ref.read(accountsProvider.notifier).disconnect(account.id);
      } catch (_) {
        /* Shared save banner retains the failure. */
      }
    }
  }

  Future<void> reconnect(
    BuildContext context,
    WidgetRef ref,
    AccountView account,
  ) async {
    if (await showConnectionUnavailable(context, account) && context.mounted) {
      await disconnect(context, ref, account);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(accountsProvider);
    final c = context.colors;
    return TaskScreen(
      title: 'Accounts',
      backIcon: Icons.arrow_back,
      backTooltip: 'Back',
      fallbackRoute: '/home',
      actions: [
        TextButton.icon(
          onPressed: state.value == null
              ? null
              : () => showAccountCatalog(context),
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Add Account'),
          style: TextButton.styleFrom(
            backgroundColor: c.soft(c.primary, AppColors.primarySoft),
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
        ),
      ],
      footer: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: state.value == null
                ? null
                : () => showAccountCatalog(context),
            icon: const Icon(Icons.add_circle_outline, size: 20),
            label: const Text('Add Manual Account'),
          ),
        ),
      ),
      child: state.when(
        loading: () => Semantics(
          label: 'Loading connected accounts',
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final height in [90.0, 140.0, 130.0, 130.0])
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
                  "We couldn't load your accounts.",
                  style: AppTypography.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please try again. No financial institution was contacted.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => ref.invalidate(accountsProvider),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
        data: (overview) => SingleChildScrollView(
          key: const PageStorageKey('accounts-scroll'),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AccountsReassurance(),
              const SizedBox(height: 16),
              AccountsBalanceHero(
                overview,
                asOf: ref.watch(clockProvider)(),
                onRefresh: () => ref.read(accountsProvider.notifier).refresh(),
              ),
              const SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 8,
                runSpacing: 8,
                children: [
                  Text(
                    'TRACKED ACCOUNTS (${overview.accounts.length})',
                    style: AppTypography.labelMedium.copyWith(
                      color: c.mutedInk,
                    ),
                  ),
                  Text(
                    'Local records',
                    style: AppTypography.labelSmall.copyWith(color: c.mutedInk),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (overview.accounts.isEmpty)
                FinanceCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        'No accounts yet',
                        style: AppTypography.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Create a manual cash, wallet or bank account to begin.',
                        textAlign: TextAlign.center,
                      ),
                      TextButton(
                        onPressed: () => showAccountCatalog(context),
                        child: const Text('Add Manual Account'),
                      ),
                    ],
                  ),
                ),
              for (final account in overview.accounts) ...[
                AccountConnectionCard(
                  account: account,
                  clock: ref.watch(clockProvider)(),
                  onSettings: () => showManualAccountEditor(
                    context,
                    account: ref
                        .read(workspaceProvider)
                        .accounts
                        .firstWhere((a) => a.id == account.id),
                  ),
                  onDetails: () => context.push('/accounts/${account.id}'),
                  onDisconnect: () => disconnect(context, ref, account),
                  onReconnect: () => reconnect(context, ref, account),
                ),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 4),
              const AccountsTrust(),
              const SizedBox(height: 16),
              const AccountsInsight(),
            ],
          ),
        ),
      ),
    );
  }
}
