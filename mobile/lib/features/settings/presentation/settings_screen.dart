import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/platform/app_version.dart';
import '../../../core/widgets/category_icon.dart';
import '../../../core/widgets/finance_card.dart';
import '../../../core/widgets/task_screen.dart';
import '../../workspace/application/finance_controller.dart';
import '../../accounts/domain/financial_account.dart';
import '../../transactions/domain/transaction.dart';
import '../domain/appearance.dart';
import '../domain/local_preferences.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});
  Future<void> save(
    BuildContext context,
    WidgetRef ref,
    LocalPreferences preferences,
  ) async {
    try {
      await ref
          .read(financeControllerProvider.notifier)
          .savePreferences(preferences);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save preference. Please try again.'),
          ),
        );
      }
    }
  }

  Future<void> appearance(BuildContext context, WidgetRef ref) async {
    final option = await showModalBottomSheet<Appearance>(
      context: context,
      sheetAnimationStyle: MediaQuery.disableAnimationsOf(context)
          ? AnimationStyle.noAnimation
          : null,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final value in Appearance.values)
              ListTile(
                key: ValueKey('appearance-${value.name}'),
                title: Text(value.label),
                subtitle: Text(value.description),
                onTap: () => Navigator.pop(context, value),
              ),
          ],
        ),
      ),
    );
    if (option != null && context.mounted) {
      await save(
        context,
        ref,
        ref.read(workspaceProvider).preferences.copyWith(appearance: option),
      );
    }
  }

  Future<void> defaultAccount(BuildContext context, WidgetRef ref) async {
    final accounts = ref
        .read(workspaceProvider)
        .accounts
        .where((a) => !a.archived && a.source == BalanceSource.manual);
    final id = await showModalBottomSheet<String>(
      context: context,
      sheetAnimationStyle: MediaQuery.disableAnimationsOf(context)
          ? AnimationStyle.noAnimation
          : null,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * .7,
          ),
          child: ListView(
            shrinkWrap: true,
            children: [
              const ListTile(title: Text('Default payment account')),
              ListTile(
                title: const Text('First available account'),
                onTap: () => Navigator.pop(context, ''),
              ),
              for (final a in accounts)
                ListTile(
                  title: Text(a.name),
                  onTap: () => Navigator.pop(context, a.id),
                ),
              if (accounts.isEmpty)
                const ListTile(
                  title: Text('Create a manual account from Accounts first.'),
                ),
            ],
          ),
        ),
      ),
    );
    if (id != null && context.mounted) {
      await save(
        context,
        ref,
        ref.read(workspaceProvider).preferences.copyWith(defaultAccountId: id),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final w = ref.watch(workspaceProvider);
    final p = w.preferences;
    final c = context.colors;
    final version = ref.watch(appVersionProvider);
    final defaultName =
        w.accounts
            .where((a) => a.id == p.defaultAccountId && !a.archived)
            .firstOrNull
            ?.name ??
        'First available account';
    Widget section(String title) => Padding(
      padding: const EdgeInsets.fromLTRB(8, 24, 8, 10),
      child: Text(
        title,
        style: AppTypography.labelMedium.copyWith(
          color: c.secondaryInk,
          letterSpacing: .8,
        ),
      ),
    );
    Widget row(
      IconData icon,
      String title,
      String value, {
      VoidCallback? onTap,
    }) => InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: LayoutBuilder(
          builder: (context, bounds) {
            final stacked =
                MediaQuery.textScalerOf(context).scale(14) > 19 ||
                bounds.maxWidth < 290;
            final label = Text(title, style: AppTypography.bodyMedium);
            final detail = Text(
              value,
              style: AppTypography.bodySmall.copyWith(color: c.mutedInk),
              textAlign: stacked ? TextAlign.start : TextAlign.end,
            );
            return Row(
              children: [
                CategoryIcon(
                  icon,
                  foreground: c.primary,
                  background: c.primary.withValues(alpha: .08),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: stacked
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [label, const SizedBox(height: 6), detail],
                        )
                      : label,
                ),
                if (!stacked) ...[
                  const SizedBox(width: 8),
                  Expanded(flex: 2, child: detail),
                ],
                if (onTap != null) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right, size: 18),
                ],
              ],
            );
          },
        ),
      ),
    );
    return TaskScreen(
      title: 'Settings',
      backIcon: Icons.arrow_back,
      backTooltip: 'Back',
      fallbackRoute: '/home',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          section('PREFERENCES'),
          FinanceCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                row(
                  Icons.palette_outlined,
                  'Appearance',
                  p.appearance.label,
                  onTap: () => appearance(context, ref),
                ),
                row(
                  Icons.payments_outlined,
                  'Currency & Format',
                  '${p.currency} · Tabular amounts',
                  onTap: () => showDialog<void>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Currency & number format'),
                      content: Text(
                        '${p.currency} amounts use two decimal places and grouped thousands. This ledger records PHP; currency conversion is not available. Money is stored as exact integer centavos.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Done'),
                        ),
                      ],
                    ),
                  ),
                ),
                row(
                  Icons.category_outlined,
                  'Categories Management',
                  '${TransactionCategory.values.where((v) => (isExpenseCategory(v) || isIncomeCategory(v)) && !p.hiddenCategories.contains(v)).length} visible categories',
                  onTap: () => showModalBottomSheet<void>(
                    context: context,
                    sheetAnimationStyle: MediaQuery.disableAnimationsOf(context)
                        ? AnimationStyle.noAnimation
                        : null,
                    isScrollControlled: true,
                    showDragHandle: true,
                    builder: (_) => const _CategoryPreferences(),
                  ),
                ),
                row(
                  Icons.account_balance_wallet_outlined,
                  'Default Payment Account',
                  defaultName,
                  onTap: () => defaultAccount(context, ref),
                ),
                row(
                  Icons.account_balance_outlined,
                  'Financial Accounts',
                  'Manage manually tracked balances',
                  onTap: () => context.push('/accounts'),
                ),
              ],
            ),
          ),
          section('ALERTS & REMINDERS'),
          FinanceCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Financial alerts'),
                  subtitle: const Text('Inside PesoFlow'),
                  value: p.notifications,
                  onChanged: (v) =>
                      save(context, ref, p.copyWith(notifications: v)),
                ),
                SwitchListTile(
                  title: const Text('Budget Threshold Alerts'),
                  subtitle: const Text(
                    'Uses each budget’s configured thresholds',
                  ),
                  value: p.budgetAlerts,
                  onChanged: p.notifications
                      ? (v) => save(context, ref, p.copyWith(budgetAlerts: v))
                      : null,
                ),
                SwitchListTile(
                  title: const Text('Bill Due Reminders'),
                  subtitle: const Text('Upcoming tracked renewals'),
                  value: p.renewalAlerts,
                  onChanged: p.notifications
                      ? (v) => save(context, ref, p.copyWith(renewalAlerts: v))
                      : null,
                ),
                row(
                  Icons.event_repeat_outlined,
                  'Subscriptions & Bills',
                  'Manage recurring commitments',
                  onTap: () => context.push('/subscriptions'),
                ),
              ],
            ),
          ),
          section('ABOUT'),
          FinanceCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                row(
                  Icons.info_outline,
                  'PesoFlow Version',
                  version.when(
                    data: (v) => v,
                    loading: () => 'Reading installed version…',
                    error: (_, _) => 'Version unavailable',
                  ),
                  onTap: version.hasError
                      ? () => ref.invalidate(appVersionProvider)
                      : null,
                ),
                row(
                  Icons.shield_outlined,
                  'Local privacy',
                  'How your records are stored',
                  onTap: () => showDialog<void>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Your data on this device'),
                      content: const Text(
                        'Financial records and receipt images are encrypted locally. Receipt text recognition runs on your device. PesoFlow has no cloud account or bank connection. CSV exports are readable files; share them only with people you trust. Removing app data removes your records.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Done'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Local financial tracking · No advertising tracking',
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(color: c.mutedInk),
          ),
        ],
      ),
    );
  }
}

class _CategoryPreferences extends ConsumerWidget {
  const _CategoryPreferences();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(workspaceProvider).preferences;
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * .75,
        child: ListView(
          children: [
            const ListTile(
              title: Text('Visible categories'),
              subtitle: Text(
                'Hide unused choices from new entry forms. Existing records and reports keep their categories.',
              ),
            ),
            for (final category in TransactionCategory.values.where(
              (v) => isExpenseCategory(v) || isIncomeCategory(v),
            ))
              SwitchListTile(
                title: Text(categoryLabel(category)),
                value: !p.hiddenCategories.contains(category),
                onChanged: (visible) async {
                  final hidden = {...p.hiddenCategories};
                  if (visible) {
                    hidden.remove(category);
                  } else {
                    hidden.add(category);
                  }
                  if (!TransactionCategory.values.any(
                        (c) => isExpenseCategory(c) && !hidden.contains(c),
                      ) ||
                      !TransactionCategory.values.any(
                        (c) => isIncomeCategory(c) && !hidden.contains(c),
                      )) {
                    return;
                  }
                  await const SettingsScreen().save(
                    context,
                    ref,
                    p.copyWith(hiddenCategories: hidden.toList()),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
