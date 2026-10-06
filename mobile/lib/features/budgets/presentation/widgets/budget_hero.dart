import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/formatting/money_formatter.dart';
import '../../../../core/widgets/budget_progress_bar.dart';
import '../../../../core/widgets/finance_card.dart';
import '../../../../core/widgets/status_badge.dart';
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
    final exceeded = plan.spent >= plan.monthlyLimit;
    final statusColor = exceeded ? c.danger : c.positive;
    final days = plan.daysLeft(clock);
    final small = AppTypography.bodySmall;
    Widget metric(
      String title,
      String amount,
      String caption,
      Color color,
      Color captionColor,
    ) => FinanceCard(
      color: c.canvas,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.labelSmall.copyWith(color: c.mutedInk),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: AppTypography.numericMedium.copyWith(color: color),
          ),
          const SizedBox(height: 4),
          Text(caption, style: small.copyWith(color: captionColor)),
        ],
      ),
    );
    final spent = metric(
      'Spent so far',
      MoneyFormatter.php(plan.spent),
      '${plan.percentUsed}% utilized',
      c.ink,
      c.mutedInk,
    );
    final remaining = metric(
      'Remaining',
      MoneyFormatter.php(plan.remaining),
      '${100 - plan.percentUsed}% left',
      exceeded ? c.danger : c.primary,
      statusColor,
    );
    return FinanceCard(
      hero: true,
      radius: AppRadius.budgetHero,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 8,
            runSpacing: 8,
            children: [
              Semantics(
                button: true,
                label: 'Edit monthly budget',
                child: InkWell(
                  onTap: onEdit,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MONTHLY BUDGET',
                        style: AppTypography.labelMedium.copyWith(
                          color: c.mutedInk,
                          letterSpacing: .7,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.end,
                        spacing: 6,
                        children: [
                          Text(
                            MoneyFormatter.php(plan.monthlyLimit),
                            style: AppTypography.headlineMedium,
                          ),
                          Text(
                            'limit',
                            style: small.copyWith(color: c.mutedInk),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              StatusBadge(
                exceeded
                    ? plan.spent == plan.monthlyLimit
                          ? 'Limit reached'
                          : 'Above limit'
                    : 'Within limit',
                foreground: statusColor,
                background: c.soft(
                  statusColor,
                  exceeded ? AppColors.dangerSoft : AppColors.positiveSoft,
                ),
                icon: Icons.circle,
                iconSize: 6,
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (MediaQuery.textScalerOf(context).scale(14) > 19) ...[
            spent,
            const SizedBox(height: 12),
            remaining,
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: spent),
                const SizedBox(width: 12),
                Expanded(child: remaining),
              ],
            ),
          const SizedBox(height: 16),
          BudgetProgressBar(
            value: plan.used,
            color: exceeded ? c.danger : AppColors.primary,
            label: 'Overall monthly budget',
            height: 8,
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '0%',
                style: AppTypography.labelSmall.copyWith(color: c.mutedInk),
              ),
              Text(
                '${plan.percentUsed}% spent',
                style: AppTypography.labelSmall.copyWith(color: c.mutedInk),
              ),
              Text(
                '100%',
                style: AppTypography.labelSmall.copyWith(color: c.mutedInk),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: c.border),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.savings_outlined, size: 18, color: c.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  days == 0
                      ? 'This budget period has ended.'
                      : '${MoneyFormatter.php(plan.safeDailyPace(clock))} / day safe pace for next $days days',
                  style: small,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FinanceCard(
            color: c.canvas,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 8,
              runSpacing: 4,
              children: [
                Text(
                  'Estimated Month-End:',
                  style: small.copyWith(color: c.mutedInk),
                ),
                if (plan.projectedEndTotal case final estimate?)
                  Text.rich(
                    TextSpan(
                      text: MoneyFormatter.php(estimate),
                      children: [
                        TextSpan(
                          text:
                              ' (${MoneyFormatter.php((plan.monthlyLimit - estimate).abs(), decimals: false)} ${estimate > plan.monthlyLimit ? 'over' : 'buffer'})',
                          style: small.copyWith(
                            color: estimate > plan.monthlyLimit
                                ? c.warning
                                : c.positive,
                          ),
                        ),
                      ],
                    ),
                    style: small,
                  )
                else
                  Text(
                    'Not available yet',
                    style: small.copyWith(color: c.mutedInk),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
