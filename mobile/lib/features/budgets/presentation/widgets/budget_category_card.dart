import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/formatting/money_formatter.dart';
import '../../../../core/widgets/budget_progress_bar.dart';
import '../../../../core/widgets/category_icon.dart';
import '../../../../core/widgets/finance_card.dart';
import '../../domain/budget_plan.dart';
import '../../../transactions/presentation/category_style.dart';

class BudgetCategoryCard extends StatelessWidget {
  const BudgetCategoryCard({
    required this.allowance,
    required this.plan,
    required this.clock,
    required this.onEdit,
    super.key,
  });
  final BudgetAllowance allowance;
  final BudgetPlan plan;
  final DateTime clock;
  final VoidCallback onEdit;
  @override
  Widget build(BuildContext context) {
    final a = allowance;
    final c = context.colors;
    final color = a.spent >= a.limit
        ? c.danger
        : a.atRisk
        ? c.warning
        : c.primary;
    final label = a.spent >= a.limit
        ? 'Limit reached'
        : a.atRisk
        ? 'Near limit'
        : 'On track';
    return Semantics(
      button: true,
      label: 'Edit ${a.name} budget',
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(16),
        child: FinanceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  CategoryIcon(
                    transactionCategoryIcon(a.category),
                    round: true,
                    foreground: categoryColor(a.category, c),
                    background: categoryBackground(a.category, c),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a.name, style: AppTypography.merchant),
                        const SizedBox(height: 4),
                        Text(
                          '${MoneyFormatter.php(a.remaining)} remaining',
                          style: AppTypography.bodySmall.copyWith(
                            color: c.mutedInk,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          MoneyFormatter.php(a.spent),
                          style: AppTypography.merchant,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'of ${MoneyFormatter.php(a.limit)}',
                          style: AppTypography.bodySmall.copyWith(
                            color: c.mutedInk,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              BudgetProgressBar(
                value: a.used,
                color: color,
                label: '${a.name} budget',
                height: 8,
              ),
              const SizedBox(height: 6),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 12,
                runSpacing: 8,
                children: [
                  Text(
                    '${a.percentUsed}% spent',
                    style: AppTypography.bodySmall.copyWith(color: color),
                  ),
                  Text(
                    label,
                    style: AppTypography.bodySmall.copyWith(
                      color: c.secondaryInk,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
