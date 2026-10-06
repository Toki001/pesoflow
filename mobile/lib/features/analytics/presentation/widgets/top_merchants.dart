import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/formatting/money_formatter.dart';
import '../../../../core/widgets/finance_card.dart';
import '../../domain/analytics_report.dart';
import 'analytics_controls.dart';

class TopMerchants extends StatelessWidget {
  const TopMerchants(this.report, {super.key});
  final AnalyticsReport report;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return FinanceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnalyticsHeading(
            'Top Merchants',
            trailing: Text(
              'Ranked by volume',
              style: AppTypography.labelSmall.copyWith(color: c.mutedInk),
            ),
          ),
          const SizedBox(height: 12),
          if (report.merchants.isEmpty)
            Text(
              'No positive merchant spending in this period.',
              style: AppTypography.bodySmall.copyWith(color: c.mutedInk),
            ),
          for (var i = 0; i < report.merchants.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: LayoutBuilder(
                builder: (context, bounds) {
                  final item = report.merchants[i];
                  final stacked =
                      bounds.maxWidth < 285 ||
                      MediaQuery.textScalerOf(context).scale(14) > 19;
                  final title = Text(item.name, style: AppTypography.merchant);
                  final metadata = Text(
                    '${item.count} ${item.unit} · ${item.context}',
                    style: AppTypography.bodySmall.copyWith(color: c.mutedInk),
                  );
                  final amount = Text(
                    MoneyFormatter.php(item.amount),
                    style: AppTypography.numericMedium,
                  );
                  return Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: c.mutedSurface,
                          border: Border.all(color: c.border),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${i + 1}',
                          style: AppTypography.labelMedium.copyWith(
                            color: c.secondaryInk,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: stacked
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  title,
                                  metadata,
                                  const SizedBox(height: 8),
                                  amount,
                                ],
                              )
                            : Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [title, metadata],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  amount,
                                ],
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
            if (i < report.merchants.length - 1)
              Divider(height: 1, color: c.border),
          ],
        ],
      ),
    );
  }
}
