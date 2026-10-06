import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/formatting/money_formatter.dart';
import '../../../../core/widgets/budget_progress_bar.dart';
import '../../../../core/widgets/category_icon.dart';
import '../../../../core/widgets/finance_card.dart';
import '../../../../core/widgets/status_badge.dart';
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
    final (label, color, soft) = switch (a.status) {
      BudgetStatus.exceeded => (
        a.spent == a.limit ? 'Limit reached' : 'Exceeded',
        c.danger,
        AppColors.dangerSoft,
      ),
      BudgetStatus.approaching => (
        a.category == TransactionCategory.food
            ? 'Slow down slightly'
            : 'Approaching limit',
        c.warning,
        AppColors.warningSoft,
      ),
      BudgetStatus.settled => ('On track', c.positive, AppColors.positiveSoft),
      BudgetStatus.fixed => (
        'Fixed • 4 services',
        c.secondaryInk,
        AppColors.surfaceMuted,
      ),
      BudgetStatus.healthy => (
        a.category == TransactionCategory.entertainment
            ? 'Well on track'
            : 'Healthy',
        c.positive,
        AppColors.positiveSoft,
      ),
    };
    final icon = switch (a.category) {
      TransactionCategory.food => Icons.restaurant,
      TransactionCategory.shopping => Icons.shopping_bag_outlined,
      TransactionCategory.transport => Icons.directions_car_outlined,
      TransactionCategory.bills => Icons.receipt_long_outlined,
      TransactionCategory.subscriptions => Icons.subscriptions_outlined,
      TransactionCategory.entertainment => Icons.sports_esports_outlined,
      TransactionCategory.groceries => Icons.shopping_basket_outlined,
      _ => Icons.local_cafe_outlined,
    };
    final iconColor = a.atRisk
        ? color
        : a.category == TransactionCategory.bills
        ? c.secondary
        : a.category == TransactionCategory.subscriptions
        ? c.secondaryInk
        : a.category == TransactionCategory.entertainment
        ? c.positive
        : c.primary;
    final iconSoft = a.atRisk
        ? soft
        : a.category == TransactionCategory.bills
        ? AppColors.secondarySoft
        : a.category == TransactionCategory.subscriptions
        ? AppColors.surfaceMuted
        : a.category == TransactionCategory.entertainment
        ? AppColors.positiveSoft
        : AppColors.primarySoft;
    final progressColor = a.atRisk
        ? color
        : a.fixed
        ? c.mutedInk
        : a.category == TransactionCategory.entertainment
        ? c.positive
        : AppColors.primary;
    final large =
        MediaQuery.textScalerOf(context).scale(14) > 19 ||
        MediaQuery.sizeOf(context).width < 350;
    final badge = StatusBadge(
      label,
      foreground: color,
      background: c.soft(color, soft),
    );
    final title = Row(
      children: [
        CategoryIcon(
          icon,
          foreground: iconColor,
          background: c.soft(iconColor, iconSoft),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                a.name,
                style: AppTypography.merchant,
                maxLines: large ? null : 1,
                overflow: large ? null : TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                a.description,
                maxLines: large
                    ? null
                    : a.category == TransactionCategory.subscriptions
                    ? 2
                    : 1,
                overflow: large ? null : TextOverflow.ellipsis,
                style: AppTypography.bodySmall.copyWith(color: c.mutedInk),
              ),
            ],
          ),
        ),
      ],
    );
    return Semantics(
      button: true,
      label: 'Edit ${a.name} budget',
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(12),
        child: FinanceCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (large) ...[
                title,
                const SizedBox(height: 8),
                Align(alignment: Alignment.centerLeft, child: badge),
              ] else
                Row(
                  children: [
                    Expanded(child: title),
                    const SizedBox(width: 8),
                    badge,
                  ],
                ),
              const SizedBox(height: 10),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.end,
                spacing: 8,
                runSpacing: 6,
                children: [
                  Text.rich(
                    TextSpan(
                      text: MoneyFormatter.php(a.spent),
                      style: AppTypography.numericMedium,
                      children: [
                        TextSpan(
                          text: ' / ${MoneyFormatter.php(a.limit)}',
                          style: AppTypography.bodySmall.copyWith(
                            color: c.mutedInk,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${a.percentUsed}% used',
                    style: AppTypography.labelMedium.copyWith(
                      color: a.atRisk
                          ? color
                          : a.category == TransactionCategory.entertainment
                          ? c.positive
                          : c.mutedInk,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              BudgetProgressBar(
                value: a.used,
                color: progressColor,
                label: '${a.name} budget',
                height: 8,
              ),
              const SizedBox(height: 8),
              Divider(color: c.border),
              const SizedBox(height: 4),
              if (large) ...[
                Text(
                  _guidance(a),
                  style: AppTypography.bodySmall.copyWith(color: c.mutedInk),
                ),
                const SizedBox(height: 6),
                Text(
                  a.remaining < 0
                      ? '${MoneyFormatter.php(-a.remaining, decimals: false)} over'
                      : '${MoneyFormatter.php(a.remaining, decimals: false)} left',
                  style: AppTypography.bodySmall.copyWith(
                    color: a.remaining < 0 ? c.danger : c.ink,
                  ),
                ),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        _guidance(a),
                        style: AppTypography.bodySmall.copyWith(
                          color: c.mutedInk,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      a.remaining < 0
                          ? '${MoneyFormatter.php(-a.remaining, decimals: false)} over'
                          : '${MoneyFormatter.php(a.remaining, decimals: false)} left',
                      style: AppTypography.bodySmall.copyWith(
                        color: a.remaining < 0
                            ? c.danger
                            : a.status == BudgetStatus.healthy
                            ? c.positive
                            : c.ink,
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

  String _guidance(BudgetAllowance a) {
    if (a.status == BudgetStatus.exceeded) {
      return a.spent == a.limit
          ? 'Your planned allowance is fully used.'
          : 'Spending is above your planned allowance.';
    }
    if (a.settled) return 'Fixed monthly expenses settled.';
    if (a.fixed) return 'All 4 recurring bills charged.';
    if (a.category == TransactionCategory.food && a.projectedOverage > 0) {
      final elapsed = plan.elapsedDays(clock);
      return '${elapsed > 0 ? 'Avg ${MoneyFormatter.php(a.spent ~/ elapsed, decimals: false)}/day. ' : ''}At this rate, will exceed by ${MoneyFormatter.php(a.projectedOverage, decimals: false)}.';
    }
    final days = plan.daysLeft(clock);
    if (days == 0) return 'This budget period has ended.';
    if (a.category == TransactionCategory.transport) {
      return 'Approx ${MoneyFormatter.php((a.remaining > 0 ? a.remaining : 0) ~/ days, decimals: false)}/day safe allowance left.';
    }
    if (a.category == TransactionCategory.entertainment) {
      return '${MoneyFormatter.php(a.remaining, decimals: false)} available cushion for month-end.';
    }
    return 'Paced steadily for $days days remaining.';
  }
}
