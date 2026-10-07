import 'package:pesoflow/core/widgets/category_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pesoflow/app/theme/app_colors.dart';
import 'package:pesoflow/app/theme/app_typography.dart';
import 'package:pesoflow/core/formatting/money_formatter.dart';
import 'package:pesoflow/core/formatting/date_formatter.dart';
import 'package:pesoflow/core/widgets/finance_card.dart';
import 'package:pesoflow/core/widgets/task_screen.dart';
import 'package:pesoflow/core/widgets/status_badge.dart';
import 'package:pesoflow/core/widgets/budget_progress_bar.dart';
import 'package:pesoflow/features/expense/presentation/add_expense_screen.dart';
import 'package:pesoflow/features/budgets/application/budgets_provider.dart';
import 'package:pesoflow/features/workspace/application/finance_controller.dart';
import 'package:pesoflow/features/transactions/application/transactions_provider.dart';
import 'package:pesoflow/features/transactions/domain/transaction.dart';

class TransactionDetailScreen extends ConsumerWidget {
  const TransactionDetailScreen({required this.id, super.key});
  final String id;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matches = ref.watch(ledgerProvider).where((t) => t.id == id);
    if (matches.isEmpty) {
      return const TaskScreen(
        title: 'Transaction Detail',
        child: Center(child: Text('Transaction not found.')),
      );
    }
    final t = matches.single;
    final c = context.colors;
    ref.watch(budgetPlansProvider);
    final plan = ref
        .read(budgetPlansProvider.notifier)
        .viewFor(t.occurredAt.year, t.occurredAt.month);
    final allowance = plan.allowances
        .where((b) => b.category == t.category)
        .firstOrNull;
    final account = ref
        .watch(workspaceProvider)
        .accounts
        .where((a) => a.id == t.accountId)
        .firstOrNull;
    return TaskScreen(
      title: 'Transaction Detail',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FinanceCard(
            hero: true,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Stack(
                  children: [
                    CategoryIcon(
                      t.category == TransactionCategory.food
                          ? Icons.fastfood_outlined
                          : t.kind == TransactionKind.transfer
                          ? Icons.swap_horiz
                          : Icons.receipt_long_outlined,
                      foreground: Colors.white,
                      iconSize: 32,
                      size: 64,
                      background: t.kind == TransactionKind.expense
                          ? AppColors.danger
                          : AppColors.secondary,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 10,
                        backgroundColor: t.status == TransactionStatus.pending
                            ? c.warning
                            : c.positive,
                        child: Icon(
                          t.status == TransactionStatus.pending
                              ? Icons.schedule
                              : Icons.check,
                          size: 13,
                          color: c.surface,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  MoneyFormatter.php(
                    t.displayAmount,
                    signed:
                        t.kind == TransactionKind.income ||
                        t.kind == TransactionKind.refund,
                  ),
                  style: AppTypography.numericXL,
                ),
                const SizedBox(height: 8),
                Text(
                  t.merchant,
                  textAlign: TextAlign.center,
                  style: AppTypography.headlineSmall,
                ),
                const SizedBox(height: 6),
                Text(categoryLabel(t.category)),
                const SizedBox(height: 12),
                StatusBadge(
                  t.status == TransactionStatus.pending
                      ? 'Pending'
                      : t.source == TransactionSource.manual
                      ? 'Completed • Manual entry'
                      : t.source == TransactionSource.receipt
                      ? 'Completed • Receipt entry'
                      : 'Completed • Read-only synced',
                  foreground: c.secondaryInk,
                  background: c.mutedSurface,
                  icon: Icons.circle,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FinanceCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PROVENANCE & INFO', style: AppTypography.labelMedium),
                const SizedBox(height: 16),
                Row(
                  children: [
                    CategoryIcon(
                      Icons.account_balance_wallet_outlined,
                      foreground: c.primary,
                      background: c.soft(c.primary, AppColors.primarySoft),
                      round: false,
                      size: 36,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            account?.name ?? t.account,
                            style: AppTypography.bodyMedium,
                          ),
                          if (account?.maskedIdentifier.isNotEmpty ?? false)
                            Text(
                              account!.maskedIdentifier,
                              style: AppTypography.bodySmall.copyWith(
                                color: c.mutedInk,
                              ),
                            ),
                        ],
                      ),
                    ),
                    StatusBadge(
                      'Manual',
                      foreground: c.primary,
                      background: c.soft(c.primary, AppColors.primarySoft),
                      pill: false,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(),
                _Info('Date & Time', DateFormatter.timestamp(t.occurredAt)),
                _Info('Category', categoryLabel(t.category)),
                if (t.kind == TransactionKind.transfer)
                  _Info('Transfer to', t.destinationAccount ?? ''),
                if (allowance != null) ...[
                  const SizedBox(height: 12),
                  FinanceCard(
                    color: c.canvas,
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          spacing: 8,
                          children: [
                            Text(
                              'Monthly Budget Impact',
                              style: AppTypography.bodySmall,
                            ),
                            Text(
                              t.excludedFromBudget
                                  ? 'Excluded'
                                  : '${(allowance.used * 100).round()}% Used',
                              style: AppTypography.bodySmall.copyWith(
                                color: allowance.atRisk ? c.warning : c.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        BudgetProgressBar(
                          label: 'Monthly budget utilization',
                          value: allowance.used,
                          color: allowance.atRisk ? c.warning : c.primary,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          spacing: 8,
                          children: [
                            Text(
                              '${MoneyFormatter.php(allowance.spent, decimals: false)} / ${MoneyFormatter.php(allowance.limit, decimals: false)} limit',
                              style: AppTypography.bodySmall,
                            ),
                            Text(
                              '${MoneyFormatter.php(allowance.remaining, decimals: false)} remaining',
                              style: AppTypography.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Text('Notes', style: AppTypography.merchant),
                const SizedBox(height: 8),
                FinanceCard(
                  color: c.canvas,
                  padding: const EdgeInsets.all(12),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      t.note.isEmpty ? 'No note added.' : t.note,
                      style: AppTypography.bodySmall.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (t.tags.isNotEmpty) ...[
            const SizedBox(height: 16),
            FinanceCard(
              child: Wrap(
                spacing: 8,
                children: [
                  for (final tag in t.tags)
                    StatusBadge(
                      '#$tag',
                      foreground: c.accent,
                      background: c.soft(c.accent, AppColors.accentSoft),
                      pill: false,
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          if (t.source == TransactionSource.manual)
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (_) => AddExpenseScreen(transaction: t),
                ),
              ),
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Edit Details'),
            ),
          if (t.kind == TransactionKind.expense) ...[
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () async {
                try {
                  await ref
                      .read(ledgerProvider.notifier)
                      .update(
                        t.copyWith(excludedFromBudget: !t.excludedFromBudget),
                      );
                } catch (_) {}
              },
              child: Text(
                t.excludedFromBudget
                    ? 'Include in Budget'
                    : 'Exclude from Budget',
              ),
            ),
          ],
          const SizedBox(height: 8),
          TextButton(
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (c) => AlertDialog(
                  title: const Text('Delete transaction?'),
                  content: const Text(
                    'Balances, budgets and analytics will be recalculated. This cannot be undone.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(c, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(c, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirmed != true) return;
              try {
                await ref
                    .read(financeControllerProvider.notifier)
                    .deleteTransaction(id);
                if (context.mounted) context.go('/transactions');
              } catch (_) {}
            },
            child: Text(
              'Delete transaction',
              style: TextStyle(color: c.danger),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Saved on this device',
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info(this.label, this.value);
  final String label, value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Wrap(
      alignment: WrapAlignment.spaceBetween,
      spacing: 16,
      runSpacing: 4,
      children: [
        Text(label, style: AppTypography.labelMedium),
        Text(value, style: AppTypography.bodySmall),
      ],
    ),
  );
}
