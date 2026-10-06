import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/formatting/money_formatter.dart';
import '../../../../core/widgets/category_icon.dart';
import '../../../../core/widgets/finance_card.dart';
import '../../domain/analytics_report.dart';
import 'analytics_controls.dart';

Color categoryColor(AnalyticsCategory category, FinancePalette c) =>
    switch (category) {
      AnalyticsCategory.food => c.isDark ? c.primary : AppColors.primary,
      AnalyticsCategory.shopping => c.secondary,
      AnalyticsCategory.transport => c.warning,
      AnalyticsCategory.bills => c.accent,
      AnalyticsCategory.subscriptions => c.mutedInk,
      AnalyticsCategory.other => c.strongBorder,
    };

class CategoryBreakdown extends StatelessWidget {
  const CategoryBreakdown(
    this.report, {
    required this.percentage,
    required this.onPercentage,
    super.key,
  });
  final AnalyticsReport report;
  final bool percentage;
  final ValueChanged<bool> onPercentage;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return FinanceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnalyticsHeading(
            'Category Breakdown',
            trailing: AnalyticsSegments<bool>(
              options: const {false: 'Amount', true: '%'},
              selected: percentage,
              onSelected: onPercentage,
            ),
          ),
          const SizedBox(height: 12),
          Semantics(
            label:
                'Category proportions. ${report.categories.map((a) => '${analyticsCategoryName(a.category)} ${a.share(report.totalExpense).toStringAsFixed(1)} percent').join(', ')}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: SizedBox(
                height: 12,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (report.positiveCategoryTotal == 0)
                      Expanded(child: ColoredBox(color: c.mutedSurface))
                    else
                      for (final item in report.categories)
                        if (item.amount > 0)
                          Expanded(
                            flex: item.amount,
                            child: ColoredBox(
                              color: categoryColor(item.category, c),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (report.categories.any((item) => item.amount < 0)) ...[
            Text(
              'Net category totals include refunds. The bar shows positive category spending.',
              style: AppTypography.bodySmall.copyWith(color: c.mutedInk),
            ),
            const SizedBox(height: 12),
          ],
          for (var i = 0; i < report.categories.length; i++) ...[
            _CategoryRow(
              report.categories[i],
              total: report.totalExpense,
              percentage: percentage,
            ),
            if (i != report.categories.length - 1) const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow(
    this.item, {
    required this.total,
    required this.percentage,
  });
  final AnalyticsCategoryTotal item;
  final int total;
  final bool percentage;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final foreground = categoryColor(item.category, c);
    final icon = switch (item.category) {
      AnalyticsCategory.food => Icons.restaurant,
      AnalyticsCategory.shopping => Icons.shopping_bag_outlined,
      AnalyticsCategory.transport => Icons.directions_car_outlined,
      AnalyticsCategory.bills => Icons.receipt_long_outlined,
      AnalyticsCategory.subscriptions => Icons.subscriptions_outlined,
      AnalyticsCategory.other => Icons.more_horiz,
    };
    final soft = switch (item.category) {
      AnalyticsCategory.food => AppColors.primarySoft,
      AnalyticsCategory.shopping => AppColors.secondarySoft,
      AnalyticsCategory.transport => AppColors.warningSoft,
      AnalyticsCategory.bills => AppColors.accentSoft,
      _ => AppColors.surfaceMuted,
    };
    final share = '${item.share(total).toStringAsFixed(1)}%';
    final trend = item.referenceTrend;
    final status = item.category == AnalyticsCategory.bills
        ? 'On track'
        : item.category == AnalyticsCategory.subscriptions
        ? 'Fixed'
        : item.category == AnalyticsCategory.other
        ? 'General'
        : null;
    final trendColor = trend == null
        ? c.secondaryInk
        : trend < 0
        ? c.positive
        : trend >= 10
        ? c.danger
        : c.warning;
    final caption = Wrap(
      spacing: 6,
      runSpacing: 2,
      children: [
        Text(
          share,
          style: AppTypography.labelSmall.copyWith(color: c.mutedInk),
        ),
        if (trend != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                trend < 0 ? Icons.trending_down : Icons.trending_up,
                size: 12,
                color: trendColor,
              ),
              Text(
                '${trend.abs()}%',
                style: AppTypography.labelSmall.copyWith(color: trendColor),
              ),
            ],
          )
        else if (status != null && item.context.isNotEmpty)
          Text(
            status,
            style: AppTypography.labelSmall.copyWith(color: c.secondaryInk),
          ),
      ],
    );
    final value = Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          percentage ? share : MoneyFormatter.php(item.amount),
          style: AppTypography.numericMedium,
        ),
        const SizedBox(height: 4),
        if (item.target != null || item.context.isNotEmpty)
          Text(
            item.target == null
                ? item.context
                : '${MoneyFormatter.php(item.target!, decimals: false)} target',
            style: AppTypography.labelSmall.copyWith(color: c.mutedInk),
            textAlign: TextAlign.end,
          ),
      ],
    );
    return LayoutBuilder(
      builder: (context, bounds) {
        final stacked =
            bounds.maxWidth < 285 ||
            MediaQuery.textScalerOf(context).scale(14) > 19;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CategoryIcon(
              icon,
              foreground: item.category == AnalyticsCategory.other
                  ? c.mutedInk
                  : foreground,
              background: c.soft(foreground, soft),
              size: 36,
              iconSize: 18,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: stacked
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          analyticsCategoryName(item.category),
                          style: AppTypography.merchant,
                        ),
                        const SizedBox(height: 2),
                        caption,
                        const SizedBox(height: 8),
                        value,
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                analyticsCategoryName(item.category),
                                style: AppTypography.merchant,
                              ),
                              const SizedBox(height: 2),
                              caption,
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        value,
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }
}
