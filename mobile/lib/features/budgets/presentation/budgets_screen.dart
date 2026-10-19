import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import 'package:pesoflow/app/theme/app_colors.dart';
import 'package:pesoflow/core/widgets/main_app_bar.dart';
import 'package:pesoflow/app/theme/app_typography.dart';
import 'package:pesoflow/core/widgets/finance_card.dart';

import 'package:pesoflow/core/time/clock.dart';
import 'package:pesoflow/features/transactions/domain/transaction.dart';
import 'package:pesoflow/features/budgets/application/budgets_provider.dart';
import 'package:pesoflow/features/budgets/domain/budget_plan.dart';
import 'package:pesoflow/features/budgets/presentation/budget_editor.dart';
import 'package:pesoflow/features/budgets/presentation/widgets/budget_category_card.dart';
import 'package:pesoflow/features/budgets/presentation/widgets/budget_hero.dart';
import 'package:pesoflow/features/budgets/presentation/widgets/budget_reallocation_card.dart';

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
      sheetAnimationStyle: MediaQuery.disableAnimationsOf(context)
          ? AnimationStyle.noAnimation
          : null,
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
                trailing: sort == value
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
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
      await ref
          .read(budgetPlansProvider.notifier)
          .reallocate(
            plan.year,
            plan.month,
            TransactionCategory.entertainment,
            TransactionCategory.food,
            50000,
          );
    } catch (_) {
      if (!mounted) return;
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
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          const MainAppBar('Budgets'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: pickPeriod,
                    child: Text('${DateFormat('MMMM yyyy').format(period)} ⌄'),
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
                          clock: ref.watch(clockProvider)(),
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
                            onPressed: () =>
                                showBudgetEditor(context, plan, creating: true),
                            icon: const Icon(
                              Icons.add,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            label: const Text('New'),
                          ),
                        ],
                      ),
                      if (plan.allowances.isEmpty)
                        _BudgetMessage(
                          title: 'Create your first budget',
                          message: 'Set a spending limit and let PesoFlow help you stay on track.',
                          button: 'New budget',
                          onTap: () =>
                              showBudgetEditor(context, plan, creating: true),
                        )
                      else ...[
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: chooseSort,
                            icon: const Icon(
                              Icons.sort,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            label: const Text('Sort budgets'),
                          ),
                        ),
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
                                      key: ValueKey(
                                        'budget-filter-${value.name}',
                                      ),
                                      onPressed: () =>
                                          setState(() => filter = value),
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: filter == value
                                            ? AppColors.primary
                                            : c.primary.withValues(alpha: .06),
                                        foregroundColor: filter == value
                                            ? Colors.white
                                            : c.primary,
                                        side: BorderSide(
                                          color: filter == value
                                              ? AppColors.primary
                                              : c.primary.withValues(alpha: .2),
                                        ),
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
                            clock: ref.watch(clockProvider)(),
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
                      FinanceCard(
                        padding: EdgeInsets.zero,
                        child: ListTile(
                          key: const ValueKey('open-subscriptions'),
                          leading: const Icon(
                            Icons.event_repeat_outlined,
                            color: AppColors.primary,
                          ),
                          title: const Text('Subscriptions & Bills'),
                          subtitle: const Text('Manage recurring commitments'),
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: AppColors.primary,
                          ),
                          onTap: () => context.push('/budgets/subscriptions'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Monthly limits repeat automatically. Spending comes from your saved transactions.',
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
