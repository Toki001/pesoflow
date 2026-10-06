import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/formatting/money_formatter.dart';
import '../../../../core/widgets/category_icon.dart';
import '../../../../core/widgets/finance_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/subscription_plan.dart';

String renewalLabel(SubscriptionPlan plan, DateTime clock) {
  final days = plan.daysUntil(clock);
  final date = DateFormat('MMM d, yyyy').format(plan.nextRenewal);
  if (days < 0) return 'Expected $date · overdue';
  if (days == 0) return 'Renews today';
  return 'Renews $date${days <= 7 ? ' (in $days days)' : ''}';
}

String shortName(SubscriptionPlan p) => switch (p.id) {
  'netflix' => 'Netflix',
  'spotify' => 'Spotify',
  'google' => 'Google',
  'icloud' => 'iCloud+',
  _ => p.name,
};

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
    final (icon, color, soft) = switch (plan.id) {
      'netflix' => (Icons.movie_outlined, c.danger, AppColors.dangerSoft),
      'spotify' => (Icons.headphones, c.positive, AppColors.positiveSoft),
      'google' => (Icons.cloud_outlined, c.primary, AppColors.primarySoft),
      'icloud' => (Icons.cloud_outlined, c.mutedInk, AppColors.surfaceMuted),
      _ => (Icons.smart_display_outlined, c.primary, AppColors.primarySoft),
    };
    final urgent = plan.active && plan.daysUntil(clock) <= 7;
    return Semantics(
      button: true,
      label: 'Manage ${plan.name}',
      child: InkWell(
        key: ValueKey('subscription-${plan.id}'),
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: FinanceCard(
          child: Column(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final compact =
                      constraints.maxWidth < 310 ||
                      MediaQuery.textScalerOf(context).scale(14) > 19;
                  final identity = Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CategoryIcon(
                        icon,
                        foreground: color,
                        background: c.soft(color, soft),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    plan.name,
                                    style: AppTypography.bodyMedium,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                StatusBadge(
                                  !plan.active
                                      ? 'Paused'
                                      : plan.cycle == BillingCycle.yearly
                                      ? 'Annual'
                                      : 'Active',
                                  foreground:
                                      plan.active &&
                                          plan.cycle != BillingCycle.yearly
                                      ? c.positive
                                      : c.secondaryInk,
                                  background:
                                      plan.active &&
                                          plan.cycle != BillingCycle.yearly
                                      ? c.soft(
                                          c.positive,
                                          AppColors.positiveSoft,
                                        )
                                      : c.mutedSurface,
                                  pill: false,
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              plan.cycle == BillingCycle.yearly
                                  ? '${MoneyFormatter.php(plan.monthlyEquivalent)}/mo equivalent'
                                  : plan.category,
                              style: AppTypography.bodySmall.copyWith(
                                color: c.mutedInk,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                  final price = Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        MoneyFormatter.php(plan.amount),
                        style: AppTypography.numericMedium,
                      ),
                      Text(
                        '/ ${plan.cycle.unit}',
                        style: AppTypography.labelSmall.copyWith(
                          color: c.mutedInk,
                        ),
                      ),
                    ],
                  );
                  return compact
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            identity,
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: price,
                            ),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: identity),
                            const SizedBox(width: 8),
                            price,
                          ],
                        );
                },
              ),
              const SizedBox(height: 12),
              Divider(color: c.border),
              const SizedBox(height: 10),
              LayoutBuilder(
                builder: (context, constraints) {
                  final source = _IconText(
                    Icons.account_balance_wallet_outlined,
                    plan.paymentSource,
                    c.secondaryInk,
                  );
                  final renewal = _IconText(
                    urgent ? Icons.schedule : Icons.event_repeat,
                    plan.active ? renewalLabel(plan, clock) : 'Tracking paused',
                    urgent ? c.warning : c.mutedInk,
                  );
                  return constraints.maxWidth >= 330 &&
                          MediaQuery.textScalerOf(context).scale(12) < 16
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            source,
                            const SizedBox(width: 8),
                            Flexible(child: renewal),
                          ],
                        )
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [source, renewal],
                        );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconText extends StatelessWidget {
  const _IconText(this.icon, this.text, this.color);
  final IconData icon;
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 14, color: color),
      const SizedBox(width: 4),
      Flexible(
        child: Text(
          text,
          style: AppTypography.bodySmall.copyWith(color: color),
        ),
      ),
    ],
  );
}

class CommitmentHero extends StatelessWidget {
  const CommitmentHero(this.overview, {required this.clock, super.key});
  final SubscriptionOverview overview;
  final DateTime clock;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final next = overview.upcoming.firstOrNull;
    final days = next?.daysUntil(clock);
    return FinanceCard(
      hero: true,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Total Monthly Commitment',
                style: AppTypography.labelSmall.copyWith(color: c.mutedInk),
              ),
              StatusBadge(
                '${overview.active.length} active services',
                foreground: c.secondary,
                background: c.soft(c.secondary, AppColors.secondarySoft),
                icon: Icons.circle,
                iconSize: 6,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              Text(
                MoneyFormatter.php(overview.monthlyEquivalent),
                style: AppTypography.numericXL,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  '/ month',
                  style: AppTypography.bodySmall.copyWith(color: c.mutedInk),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _IconText(
            Icons.calendar_today_outlined,
            'Annualized commitment:  ${MoneyFormatter.php(overview.annualized)}  / year',
            c.secondaryInk,
          ),
          const SizedBox(height: 12),
          Divider(color: c.border),
          const SizedBox(height: 12),
          if (next != null)
            FinanceCard(
              color: c.soft(c.warning, AppColors.warningSoft),
              borderColor: c.warning.withValues(alpha: .25),
              radius: 8,
              padding: const EdgeInsets.all(8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _IconText(
                    Icons.notifications_active_outlined,
                    'Next renewal:  ${shortName(next)} (${MoneyFormatter.php(next.amount, decimals: false)})',
                    c.secondaryInk,
                  ),
                  StatusBadge(
                    days! < 0
                        ? 'Overdue'
                        : days == 0
                        ? 'Today'
                        : 'in $days days',
                    foreground: c.warning,
                    background: c.surface,
                    pill: false,
                  ),
                ],
              ),
            )
          else
            Text(
              'No active renewals',
              style: AppTypography.bodySmall.copyWith(color: c.mutedInk),
            ),
        ],
      ),
    );
  }
}

class SubscriptionTip extends StatelessWidget {
  const SubscriptionTip({required this.saving, super.key});
  final int saving;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return FinanceCard(
      color: c.insight,
      borderColor: c.accentBorder,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CategoryIcon(
            Icons.lightbulb_outline,
            foreground: c.accent,
            background: c.soft(c.accent, AppColors.accentSoft),
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Intelligence Tip',
                  style: AppTypography.labelMedium.copyWith(color: c.accent),
                ),
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'You have 2 cloud storage subscriptions (Google One and iCloud+). Consolidating could save up to ',
                      ),
                      TextSpan(
                        text:
                            '${MoneyFormatter.php(saving, decimals: false)}/yr.',
                        style: AppTypography.labelMedium.copyWith(
                          color: c.primary,
                        ),
                      ),
                    ],
                  ),
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RenewalTimeline extends StatelessWidget {
  const RenewalTimeline({required this.plans, required this.onTap, super.key});
  final List<SubscriptionPlan> plans;
  final ValueChanged<SubscriptionPlan> onTap;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns =
          constraints.maxWidth < 330 ||
              MediaQuery.textScalerOf(context).scale(12) > 18
          ? 2
          : 4;
      final width = (constraints.maxWidth - 8 * (columns - 1)) / columns;
      final c = context.colors;
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final (i, plan) in plans.indexed)
            SizedBox(
              width: width,
              child: Semantics(
                button: true,
                label:
                    '${plan.name} renewal ${DateFormat('MMM d, yyyy').format(plan.nextRenewal)}',
                child: InkWell(
                  onTap: () => onTap(plan),
                  borderRadius: BorderRadius.circular(8),
                  child: FinanceCard(
                    radius: 8,
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 6,
                    ),
                    borderColor: i == 0
                        ? c.primary.withValues(alpha: .5)
                        : c.border,
                    child: Column(
                      children: [
                        Text(
                          DateFormat('MMM dd')
                              .format(plan.nextRenewal)
                              .toUpperCase(),
                          style: AppTypography.labelSmall.copyWith(
                            color: i == 0 ? c.primary : c.mutedInk,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          shortName(plan),
                          textAlign: TextAlign.center,
                          style: AppTypography.labelMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          MoneyFormatter.php(plan.amount, decimals: false),
                          style: AppTypography.bodySmall.copyWith(
                            color: c.secondaryInk,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    },
  );
}
