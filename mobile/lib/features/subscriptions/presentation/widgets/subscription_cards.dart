import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/formatting/money_formatter.dart';
import '../../../../core/widgets/category_icon.dart';
import '../../../../core/widgets/finance_card.dart';
import '../../domain/subscription_plan.dart';

class SubscriptionCard extends StatelessWidget {
  const SubscriptionCard({
    required this.plan,
    required this.clock,
    required this.onTap,
    super.key,
  });
  final SubscriptionPlan plan;
  final DateTime clock;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: FinanceCard(
        child: Row(
          children: [
            CategoryIcon(
              Icons.event_repeat_outlined,
              foreground: c.primary,
              background: c.primary.withValues(alpha: .08),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(plan.name, style: AppTypography.merchant),
                  const SizedBox(height: 6),
                  Text(
                    plan.active
                        ? 'Due ${DateFormat('MMM d').format(plan.nextRenewal)} · ${plan.paymentSource}'
                        : 'Tracking paused',
                    style: AppTypography.bodySmall.copyWith(color: c.mutedInk),
                  ),
                  if (plan.cycle == BillingCycle.yearly)
                    Text(
                      '${MoneyFormatter.php(plan.monthlyEquivalent)} / month equivalent',
                      style: AppTypography.bodySmall.copyWith(color: c.primary),
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
                    MoneyFormatter.php(plan.amount),
                    style: AppTypography.merchant,
                  ),
                  Text(
                    '/ ${plan.cycle.unit}',
                    style: AppTypography.bodySmall.copyWith(color: c.mutedInk),
                  ),
                  if (plan.active && plan.daysUntil(clock) < 0)
                    Text(
                      'Overdue',
                      style: AppTypography.bodySmall.copyWith(color: c.warning),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CommitmentHero extends StatelessWidget {
  const CommitmentHero(this.overview, {required this.clock, super.key});
  final SubscriptionOverview overview;
  final DateTime clock;
  @override
  Widget build(BuildContext context) {
    final next = overview.active.where(
      (p) => p.daysUntil(clock) >= 0 && p.daysUntil(clock) < 7,
    );
    return FinanceCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'TOTAL MONTHLY COMMITMENTS',
            style: AppTypography.labelMedium.copyWith(
              color: context.colors.mutedInk,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: 6,
            children: [
              Text(
                MoneyFormatter.php(overview.monthlyEquivalent),
                style: AppTypography.numericXL,
              ),
              const Text('/ mo'),
            ],
          ),
          const SizedBox(height: 24),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 8,
            runSpacing: 8,
            children: [
              Text(
                'Next 7 Days Due: ${MoneyFormatter.php(next.fold(0, (sum, p) => sum + p.amount))}',
                style: AppTypography.bodySmall,
              ),
              Text('${next.length} recurring', style: AppTypography.labelSmall),
            ],
          ),
        ],
      ),
    );
  }
}

String renewalLabel(SubscriptionPlan plan, DateTime clock) {
  final days = plan.daysUntil(clock);
  return days < 0
      ? 'Overdue by ${-days} days'
      : days == 0
      ? 'Due today'
      : 'Due in $days days';
}
