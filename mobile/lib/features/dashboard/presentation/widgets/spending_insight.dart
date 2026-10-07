import 'package:flutter/material.dart';

import 'package:pesoflow/app/theme/app_colors.dart';
import 'package:pesoflow/app/theme/app_spacing.dart';
import 'package:pesoflow/app/theme/app_typography.dart';
import 'package:pesoflow/core/formatting/money_formatter.dart';
import 'package:pesoflow/core/widgets/category_icon.dart';
import 'package:pesoflow/core/widgets/finance_card.dart';
import 'package:pesoflow/core/widgets/status_badge.dart';

class SpendingInsight extends StatelessWidget {
  const SpendingInsight({
    required this.extraSavings,
    this.hasBudget = false,
    super.key,
  });
  final int extraSavings;
  final bool hasBudget;
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
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Spending Pace',
                      style: AppTypography.labelMedium.copyWith(
                        color: c.accent,
                      ),
                    ),
                    StatusBadge(
                      hasBudget
                          ? (extraSavings >= 0 ? 'Within plan' : 'Above plan')
                          : 'Get started',
                      foreground: c.secondaryInk,
                      background: c.surface,
                      pill: false,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    style: AppTypography.bodySmall.copyWith(
                      color: c.secondaryInk,
                    ),
                    children: [
                      TextSpan(
                        text: !hasBudget
                            ? 'Create a monthly budget to see a spending pace estimate based on your records.'
                            : 'At your recorded pace, projected spending is ${MoneyFormatter.php(extraSavings.abs())} ${extraSavings >= 0 ? 'below' : 'above'} your monthly limit. Estimates change as you add transactions.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
