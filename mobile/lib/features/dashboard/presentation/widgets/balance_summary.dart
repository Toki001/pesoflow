import 'package:flutter/material.dart';

import 'package:pesoflow/app/theme/app_colors.dart';
import 'package:pesoflow/app/theme/app_spacing.dart';
import 'package:pesoflow/app/theme/app_typography.dart';
import 'package:pesoflow/core/formatting/money_formatter.dart';
import 'package:pesoflow/core/widgets/finance_card.dart';
import 'package:pesoflow/core/widgets/money_text.dart';
import 'package:pesoflow/core/widgets/status_badge.dart';
import 'package:pesoflow/features/dashboard/domain/dashboard.dart';

class BalanceHero extends StatelessWidget {
  const BalanceHero({required this.data, super.key});
  final Dashboard data;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return FinanceCard(
      hero: true,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 6),
          Text(
            'Net Available Balance',
            style: AppTypography.labelMedium.copyWith(color: c.mutedInk),
          ),
          const SizedBox(height: 10),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: data.balance < 0 ? '-₱ ' : '₱ ',
                  style: AppTypography.numericLarge,
                ),
                TextSpan(
                  text: MoneyFormatter.php(data.balance.abs()).substring(1),
                  style: AppTypography.numericXL,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Divider(),
          const SizedBox(height: AppSpacing.xs),
          SizedBox(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                StatusBadge(
                  '${MoneyFormatter.php(data.monthChange, decimals: false)} net flow this month',
                  foreground: data.monthChange < 0 ? c.warning : c.positive,
                  background: c.soft(c.positive, AppColors.positiveSoft),
                  icon: data.monthChange < 0
                      ? Icons.arrow_downward
                      : Icons.arrow_upward,
                ),
                Text(
                  'Across ${data.accountCount} accounts',
                  style: AppTypography.labelSmall.copyWith(color: c.mutedInk),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FlowSummary extends StatelessWidget {
  const FlowSummary({required this.data, super.key});
  final Dashboard data;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final metrics = [
      ('Inflow', data.inflow, 'This month', c.positive, c.positive, true),
      (
        'Outflow',
        -data.outflow,
        '${data.transactionCount} txns',
        c.ink,
        c.mutedInk,
        false,
      ),
      (
        'Savings',
        data.savings,
        data.savingsRate == '—' ? 'No income yet' : '${data.savingsRate}% rate',
        c.primary,
        c.secondary,
        false,
      ),
    ];
    return FinanceCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stacked = MediaQuery.textScalerOf(context).scale(18) > 24;
          Widget metric(int i) {
            final (label, value, caption, color, captionColor, signed) =
                metrics[i];
            return Padding(
              padding: EdgeInsets.only(
                left: stacked || i == 0 ? 0 : AppSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.labelSmall.copyWith(color: c.mutedInk),
                  ),
                  const SizedBox(height: 4),
                  MoneyText(
                    value,
                    compact: true,
                    signed: signed,
                    style: AppTypography.numericMedium.copyWith(color: color),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    caption,
                    style: AppTypography.labelSmall.copyWith(
                      color: captionColor,
                    ),
                  ),
                ],
              ),
            );
          }

          if (stacked) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppSpacing.sm,
              children: List.generate(3, metric),
            );
          }
          return IntrinsicHeight(
            child: Row(
              children: [
                for (var i = 0; i < 3; i++) ...[
                  if (i > 0) VerticalDivider(width: 1, color: c.border),
                  Expanded(child: metric(i)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
