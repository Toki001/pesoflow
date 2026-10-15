import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/formatting/money_formatter.dart';
import '../../../../core/widgets/budget_progress_bar.dart';
import '../../../../core/widgets/category_icon.dart';
import '../../../../core/widgets/finance_card.dart';
import '../../../transactions/domain/transaction.dart';
import '../../domain/budget_plan.dart';

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
    final icon = switch (a.category) {
      TransactionCategory.food => Icons.restaurant,
      TransactionCategory.transport => Icons.directions_car_outlined,
      TransactionCategory.shopping => Icons.shopping_bag_outlined,
      TransactionCategory.bills => Icons.bolt,
      TransactionCategory.groceries => Icons.shopping_cart_outlined,
      _ => Icons.category_outlined,
    };
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
                    icon,
                    foreground: c.primary,
                    background: c.primary.withValues(alpha: .08),
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
