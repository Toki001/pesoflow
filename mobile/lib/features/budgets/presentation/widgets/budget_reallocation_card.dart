import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/formatting/money_formatter.dart';
import '../../../../core/widgets/category_icon.dart';
import '../../../../core/widgets/finance_card.dart';
import '../../../../core/widgets/status_badge.dart';

class BudgetReallocationCard extends StatelessWidget {
  const BudgetReallocationCard({
    required this.surplus,
    required this.onAdjust,
    required this.onDismiss,
    super.key,
  });
  final int surplus;
  final VoidCallback onAdjust;
  final VoidCallback onDismiss;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return FinanceCard(
      color: c.insight,
      borderColor: c.accentBorder,
      radius: AppRadius.budgetHero,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CategoryIcon(
            Icons.auto_awesome,
            foreground: c.accent,
            background: c.soft(c.accent, AppColors.accentSoft),
            size: 36,
            round: false,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (MediaQuery.textScalerOf(context).scale(14) > 19) ...[
                  Text(
                    'Smart Reallocation Suggestion',
                    style: AppTypography.headlineSmall,
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: StatusBadge(
                      'Supportive',
                      foreground: c.accent,
                      background: c.surface,
                    ),
                  ),
                ] else
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Smart Reallocation\nSuggestion',
                          style: AppTypography.headlineSmall,
                        ),
                      ),
                      const SizedBox(width: 8),
                      StatusBadge(
                        'Supportive',
                        foreground: c.accent,
                        background: c.surface,
                      ),
                    ],
                  ),
                const SizedBox(height: 8),
                Text(
                  'You have ${MoneyFormatter.php(surplus, decimals: false)} surplus in Entertainment. Reallocating ₱500 to Food & Dining will keep all categories comfortably balanced this month.',
                  style: AppTypography.bodySmall.copyWith(
                    color: c.secondaryInk,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    OutlinedButton(
                      onPressed: onAdjust,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: c.accent,
                        side: BorderSide(color: c.accentBorder),
                      ),
                      child: const Text('Adjust Budgets'),
                    ),
                    TextButton(
                      onPressed: onDismiss,
                      style: TextButton.styleFrom(foregroundColor: c.mutedInk),
                      child: const Text('Dismiss'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
