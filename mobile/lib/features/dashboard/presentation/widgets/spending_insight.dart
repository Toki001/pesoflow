import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/formatting/money_formatter.dart';
import '../../../../core/widgets/category_icon.dart';
import '../../../../core/widgets/finance_card.dart';
import '../../../../core/widgets/status_badge.dart';

class SpendingInsight extends StatelessWidget {
  const SpendingInsight({required this.extraSavings, super.key});
  final int extraSavings;
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
                      'On Track',
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
                      const TextSpan(text: "You're spending "),
                      TextSpan(
                        text: '18% less on Dining Out',
                        style: AppTypography.labelMedium.copyWith(color: c.ink),
                      ),
                      const TextSpan(
                        text: ' compared to last month. On track to save an extra ',
                      ),
                      TextSpan(
                        text:
                            '${MoneyFormatter.php(extraSavings, decimals: false)}.',
                        style: AppTypography.labelMedium.copyWith(
                          color: c.positive,
                        ),
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
