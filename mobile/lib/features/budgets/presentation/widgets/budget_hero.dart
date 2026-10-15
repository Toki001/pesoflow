import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/formatting/money_formatter.dart';
import '../../../../core/widgets/budget_progress_bar.dart';
import '../../../../core/widgets/finance_card.dart';
import '../../domain/budget_plan.dart';

class BudgetHero extends StatelessWidget {
  const BudgetHero({
    required this.plan,
    required this.clock,
    required this.onEdit,
    super.key,
  });
  final BudgetPlan plan;
  final DateTime clock;
  final VoidCallback onEdit;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return FinanceCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'OVERALL MONTHLY CAP',
                  style: AppTypography.labelMedium.copyWith(color: c.mutedInk),
                ),
              ),
              IconButton(
                tooltip: 'Edit monthly budget',
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 18),
              ),
            ],
          ),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: 6,
            runSpacing: 8,
            children: [
              Text(
                MoneyFormatter.php(plan.spent),
                style: AppTypography.numericXL,
              ),
              Text(
                '/ ${MoneyFormatter.php(plan.monthlyLimit)}',
                style: AppTypography.bodyMedium.copyWith(color: c.mutedInk),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 8,
            runSpacing: 8,
            children: [
              Text(
                '${plan.percentUsed}% used · ${plan.daysLeft(clock)} days left',
                style: AppTypography.bodySmall,
              ),
              Text(
                '${MoneyFormatter.php(plan.remaining)} remaining',
                style: AppTypography.labelMedium.copyWith(
                  color: plan.remaining < 0 ? c.danger : c.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          BudgetProgressBar(
            value: plan.used,
            color: plan.used >= 1 ? c.danger : c.primary,
            label: 'Overall monthly budget',
            height: 8,
          ),
          const SizedBox(height: 20),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 16,
            runSpacing: 12,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Safe Daily Pace',
                    style: AppTypography.bodySmall.copyWith(color: c.mutedInk),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${MoneyFormatter.php(plan.safeDailyPace(clock))} / day',
                    style: AppTypography.merchant,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Projected Month-End',
                    style: AppTypography.bodySmall.copyWith(color: c.mutedInk),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    plan.projectedEndTotal == null
                        ? 'Not enough activity'
                        : MoneyFormatter.php(plan.projectedEndTotal!),
                    style: AppTypography.merchant,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
