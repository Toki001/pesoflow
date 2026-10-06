import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/formatting/money_formatter.dart';
import '../../../../core/widgets/finance_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/analytics_report.dart';

class ExpenseHero extends StatelessWidget {
  const ExpenseHero(this.report, {super.key});
  final AnalyticsReport report;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final comparison = report.comparison;
    final percent = comparison.percent;
    final prior = switch (report.selection.period) {
      AnalyticsPeriod.day => 'yesterday',
      AnalyticsPeriod.week => 'last week',
      AnalyticsPeriod.month => DateFormat(
        'MMM',
      ).format(report.selection.previous.date),
      AnalyticsPeriod.year => '${report.selection.date.year - 1}',
    };
    final label = percent == null
        ? comparison.current == 0
              ? 'No change vs $prior'
              : comparison.current < 0
              ? 'Net refunds vs $prior'
              : 'New spending vs $prior'
        : '${percent.abs().toStringAsFixed(1)}% (${MoneyFormatter.php(comparison.change.abs(), decimals: false)}) vs $prior';
    final badge = StatusBadge(
      label,
      foreground: comparison.change <= 0 ? c.positive : c.warning,
      background: c.soft(
        comparison.change <= 0 ? c.positive : c.warning,
        comparison.change <= 0 ? AppColors.positiveSoft : AppColors.warningSoft,
      ),
      icon: comparison.change <= 0 ? Icons.arrow_downward : Icons.arrow_upward,
      iconSize: 14,
    );
    final title = Text(
      'TOTAL EXPENSE',
      style: AppTypography.bodySmall.copyWith(
        color: c.mutedInk,
        letterSpacing: 1,
      ),
    );
    return FinanceCard(
      hero: true,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, bounds) =>
                bounds.maxWidth < 300 ||
                    MediaQuery.textScalerOf(context).scale(14) > 19
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [title, const SizedBox(height: 8), badge],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [title, badge],
                  ),
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: report.totalExpense < 0 ? '-₱' : '₱',
                  style: AppTypography.numericLarge.copyWith(color: c.mutedInk),
                ),
                TextSpan(
                  text: MoneyFormatter.php(report.totalExpense.abs())
                      .substring(1),
                  style: AppTypography.numericXL.copyWith(color: c.ink),
                ),
              ],
            ),
            key: const ValueKey('analytics-total'),
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: c.border),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 12,
              runSpacing: 8,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.speed, size: 18, color: c.mutedInk),
                    const SizedBox(width: 6),
                    Text(
                      'Daily average:',
                      style: AppTypography.bodySmall.copyWith(
                        color: c.secondaryInk,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${MoneyFormatter.php(report.dailyAverage)} / day',
                  style: AppTypography.labelMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
