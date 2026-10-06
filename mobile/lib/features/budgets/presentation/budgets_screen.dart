import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/finance_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../../transactions/data/transaction_fixture.dart';
import '../../transactions/domain/transaction.dart';
import '../application/budgets_provider.dart';
import '../domain/budget_plan.dart';
import 'budget_editor.dart';
import 'widgets/budget_category_card.dart';
import 'widgets/budget_hero.dart';
import 'widgets/budget_reallocation_card.dart';

class BudgetsScreen extends ConsumerStatefulWidget {
  const BudgetsScreen({super.key});
  @override
  ConsumerState<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends ConsumerState<BudgetsScreen> {
  BudgetFilter filter = BudgetFilter.all;
  BudgetSort sort = BudgetSort.reference;
  Future<void> pickPeriod() async {
    final date = ref.read(budgetPeriodProvider);
    final selected = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030, 12, 31),
      helpText: 'Choose a date in the budget month',
    );
    if (selected != null && mounted) {
      ref.read(budgetPeriodProvider.notifier).select(selected);
      setState(() => filter = BudgetFilter.all);
    }
  }

  Future<void> chooseSort() async {
    final selected = await showModalBottomSheet<BudgetSort>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Sort category budgets', style: AppTypography.headlineSmall),
            for (final (value, label) in [
              (BudgetSort.reference, 'Default order'),
              (BudgetSort.utilization, 'Most used first'),
              (BudgetSort.remaining, 'Least remaining first'),
              (BudgetSort.name, 'Category name'),
            ])
              ListTile(
                title: Text(label),
                trailing: sort == value ? const Icon(Icons.check) : null,
                onTap: () => Navigator.pop(context, value),
              ),
          ],
        ),
      ),
    );
    if (selected != null && mounted) setState(() => sort = selected);
  }

  Future<void> adjust(BudgetPlan plan) async {
    final apply = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adjust budgets'),
        content: const Text(
          'Move ₱500 of Entertainment allowance to Food & Dining? Your monthly limit stays the same. No money is moved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Apply adjustment'),
          ),
        ],
      ),
    );
    if (apply != true || !mounted) return;
    try {
      ref
          .read(demoBudgetPlansProvider.notifier)
          .reallocate(
            plan.year,
            plan.month,
            TransactionCategory.entertainment,
            TransactionCategory.food,
            50000,
          );
    } on ArgumentError {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'The available allowance changed. Please review the budgets.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(budgetsProvider);
    final period = ref.watch(budgetPeriodProvider);
    final dismissed = ref.watch(dismissedBudgetSuggestionsProvider);
    final c = context.colors;
    final plan = state.value;
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: c.surface,
              border: Border(bottom: BorderSide(color: c.border)),
            ),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: c.soft(c.primary, AppColors.primarySoft),
                      child: Text(
                        'PF',
                        style: AppTypography.labelSmall.copyWith(
                          color: c.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'PesoFlow',
                        style: AppTypography.headlineSmall,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Notifications',
                      onPressed: () => showDialog<void>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Demo notifications'),
                          content: const Text(
                            'You’re viewing sample budgets. No financial accounts are connected.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      ),
                      icon: const Icon(Icons.notifications_none),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Semantics(
                          button: true,
                          label: 'Choose budget month',
                          child: InkWell(
                            onTap: pickPeriod,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  spacing: 6,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      'Budgets',
                                      style: AppTypography.headlineLarge,
                                    ),
                                    StatusBadge(
                                      period.year == 2024 && period.month == 10
                                          ? 'Active'
                                          : period.isBefore(DateTime(2024, 10))
                                          ? 'Past'
                                          : 'Upcoming',
                                      foreground: c.primary,
                                      background: c.soft(
                                        c.primary,
                                        AppColors.primarySoft,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 4,
                                  children: [
                                    Text(
                                      '${DateFormat('MMMM yyyy').format(period)} ⌄',
                                      style: AppTypography.labelMedium.copyWith(
                                        color: c.mutedInk,
                                      ),
                                    ),
                                    Text(
                                      '•  ${plan?.daysLeft(demoClock) ?? 0} days left',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: c.mutedInk,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: plan == null
                            ? null
                            : () => showBudgetEditor(
                                context,
                                plan,
                                creating: true,
                              ),
                        style: FilledButton.styleFrom(
                          backgroundColor: c.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          foregroundColor: c.isDark
                              ? AppColors.darkSurface
                              : Colors.white,
                        ),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('New'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: state.when(
              loading: () => const _BudgetSkeleton(),
              error: (_, _) => _BudgetMessage(
                title: "We couldn't load your budgets.",
                message: 'Please try again.',
                button: 'Try Again',
                onTap: () => ref.invalidate(budgetsProvider),
              ),
              data: (plan) {
                final visible = selectAllowances(plan, filter, sort);
                final risk = plan.allowances.where((a) => a.atRisk).length;
                final suggestion =
                    canSuggestReallocation(plan) &&
                    !dismissed.contains(plan.key);
                return SingleChildScrollView(
                  key: const PageStorageKey('budgets-scroll'),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (plan.monthlyLimit > 0) ...[
                        BudgetHero(
                          plan: plan,
                          clock: demoClock,
                          onEdit: () => showBudgetEditor(context, plan),
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (suggestion) ...[
                        BudgetReallocationCard(
                          surplus: plan.allowances
                              .firstWhere(
                                (a) =>
                                    a.category ==
                                    TransactionCategory.entertainment,
                              )
                              .remaining,
                          onAdjust: () => adjust(plan),
                          onDismiss: () => ref
                              .read(dismissedBudgetSuggestionsProvider.notifier)
                              .dismiss(plan.key),
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (plan.allowances.isEmpty)
                        _BudgetMessage(
                          title: 'Create your first budget',
                          message: 'Set a spending limit and let PesoFlow help you stay on track.',
                          button: 'New budget',
                          onTap: () =>
                              showBudgetEditor(context, plan, creating: true),
                        )
                      else ...[
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Category Budgets',
                                    style: AppTypography.headlineMedium,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${plan.allowances.length} categorized allowances tracked',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: c.mutedInk,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton.icon(
                              onPressed: chooseSort,
                              iconAlignment: IconAlignment.end,
                              icon: const Icon(Icons.swap_vert, size: 16),
                              label: const Text('Sort'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (final (value, label, count) in [
                                (
                                  BudgetFilter.all,
                                  'All',
                                  plan.allowances.length,
                                ),
                                (BudgetFilter.atRisk, 'At Risk', risk),
                                (
                                  BudgetFilter.onTrack,
                                  'On Track',
                                  plan.allowances.length - risk,
                                ),
                              ])
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Semantics(
                                    selected: filter == value,
                                    button: true,
                                    child: OutlinedButton(
                                      onPressed: () =>
                                          setState(() => filter = value),
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: filter == value
                                            ? c.ink
                                            : c.surface,
                                        foregroundColor: filter == value
                                            ? c.surface
                                            : c.secondaryInk,
                                        shape: const StadiumBorder(),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                        ),
                                      ),
                                      child: Text('$label  $count'),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (visible.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Column(
                              children: [
                                Text(
                                  'No budgets in this filter',
                                  style: AppTypography.headlineSmall,
                                ),
                                TextButton(
                                  onPressed: () =>
                                      setState(() => filter = BudgetFilter.all),
                                  child: const Text('Show all budgets'),
                                ),
                              ],
                            ),
                          ),
                        for (final allowance in visible) ...[
                          BudgetCategoryCard(
                            allowance: allowance,
                            plan: plan,
                            clock: demoClock,
                            onEdit: () => showBudgetEditor(
                              context,
                              plan,
                              category: allowance.category,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ],
                      const SizedBox(height: 16),
                      Text(
                        'Demo budgets • changes last for this session.\nNext period begins ${DateFormat('MMMM d, yyyy').format(DateTime(plan.year, plan.month + 1))}.',
                        style: AppTypography.bodySmall.copyWith(
                          color: c.mutedInk,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetMessage extends StatelessWidget {
  const _BudgetMessage({
    required this.title,
    required this.message,
    required this.button,
    required this.onTap,
  });
  final String title, message, button;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: AppTypography.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          message,
          style: AppTypography.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        FilledButton(onPressed: onTap, child: Text(button)),
      ],
    ),
  );
}

class _BudgetSkeleton extends StatelessWidget {
  const _BudgetSkeleton();
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Loading budgets',
    child: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final height in [300.0, 180.0, 140.0, 140.0])
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: FinanceCard(
              child: SizedBox(
                height: height,
                child: ColoredBox(color: context.colors.mutedSurface),
              ),
            ),
          ),
      ],
    ),
  );
}
