import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/formatting/money_formatter.dart';
import '../../../../core/widgets/budget_progress_bar.dart';
import '../../../../core/widgets/finance_card.dart';
import '../../domain/dashboard.dart';

class BudgetSummary extends StatelessWidget {
  const BudgetSummary({required this.data, super.key});
  final Dashboard data;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final overall = BudgetSnapshot(
      name: 'Overall Limit (${data.daysLeft} days left)',
      spent: data.outflow,
      limit: data.budgetLimit,
      status: 'utilized',
    );
    return FinanceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _BudgetPair(budget: overall, overall: true),
          const SizedBox(height: 6),
          BudgetProgressBar(
            value: overall.used,
            color: AppColors.primary,
            label: 'Overall budget',
            height: 8,
          ),
          const SizedBox(height: 4),
          _Pair(
            left: Text(
              '${(overall.used * 100).round()}% utilized',
              style: AppTypography.labelSmall.copyWith(color: c.mutedInk),
            ),
            right: Text(
              '${MoneyFormatter.php(overall.remaining, decimals: false)} remaining',
              style: AppTypography.labelSmall.copyWith(color: c.positive),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Divider(),
          const SizedBox(height: AppSpacing.xs),
          if (data.budgets.isEmpty) const Text('No category budgets yet'),
          for (var i = 0; i < data.budgets.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.sm),
            _CategoryBudget(budget: data.budgets[i]),
          ],
        ],
      ),
    );
  }
}

Color _budgetColor(BuildContext context, BudgetSnapshot budget) =>
    budget.exceeded
    ? context.colors.danger
    : budget.approaching
    ? context.colors.warning
    : context.colors.primary;

class _CategoryBudget extends StatelessWidget {
  const _CategoryBudget({required this.budget});
  final BudgetSnapshot budget;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _BudgetPair(budget: budget),
        const SizedBox(height: 4),
        BudgetProgressBar(
          value: budget.used,
          color: _budgetColor(context, budget),
          label: budget.name,
        ),
        const SizedBox(height: 4),
        _Pair(
          left: Text(
            '${(budget.used * 100).round()}% · ${budget.status}',
            style: AppTypography.labelSmall.copyWith(
              color: budget.approaching
                  ? _budgetColor(context, budget)
                  : c.mutedInk,
            ),
          ),
          right: Text(
            '${MoneyFormatter.php(budget.remaining, decimals: false)} left',
            style: AppTypography.labelSmall.copyWith(color: c.mutedInk),
          ),
        ),
      ],
    );
  }
}

class _BudgetPair extends StatelessWidget {
  const _BudgetPair({required this.budget, this.overall = false});
  final BudgetSnapshot budget;
  final bool overall;
  @override
  Widget build(BuildContext context) => _Pair(
    left: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!overall) ...[
          Icon(Icons.circle, size: 8, color: _budgetColor(context, budget)),
          const SizedBox(width: 6),
        ],
        Flexible(
          child: Text(
            budget.name,
            style: overall
                ? AppTypography.labelMedium.copyWith(
                    color: context.colors.mutedInk,
                  )
                : AppTypography.merchant,
          ),
        ),
      ],
    ),
    right: Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: MoneyFormatter.php(budget.spent, decimals: false),
            style: AppTypography.numericMedium,
          ),
          TextSpan(
            text: ' / ${MoneyFormatter.php(budget.limit, decimals: false)}',
            style:
                (overall
                        ? AppTypography.numericMedium
                        : AppTypography.bodySmall)
                    .copyWith(
                      color: context.colors.mutedInk,
                      fontVariations: const [FontVariation('wght', 450)],
                    ),
          ),
        ],
      ),
    ),
  );
}

class _Pair extends StatelessWidget {
  const _Pair({required this.left, required this.right});
  final Widget left;
  final Widget right;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth < 310 ||
          MediaQuery.textScalerOf(context).scale(14) > 18) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
          children: [left, right],
        );
      }
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: left),
          const SizedBox(width: 4),
          right,
        ],
      );
    },
  );
}
