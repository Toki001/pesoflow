import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/formatting/money_formatter.dart';
import '../../../../core/time/clock.dart';
import '../../../../core/widgets/finance_card.dart';
import '../../../workspace/application/finance_controller.dart';
import '../../domain/analytics_report.dart';
import '../../domain/payment_source_totals.dart';

class PaymentSources extends ConsumerWidget {
  const PaymentSources(this.selection, {super.key});
  final AnalyticsSelection selection;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final w = ref.watch(workspaceProvider);
    final totals = paymentSourceTotals(
      w.ledger,
      selection,
      ref.watch(clockProvider)(),
    );
    final entries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final c = context.colors;
    return FinanceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Payment Source Origin', style: AppTypography.headlineSmall),
          const SizedBox(height: 16),
          if (entries.isEmpty)
            const Text('No spending sources in this period.'),
          LayoutBuilder(
            builder: (context, bounds) {
              final columns = MediaQuery.textScalerOf(context).scale(14) > 19
                  ? 1
                  : 2;
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final entry in entries)
                    SizedBox(
                      width: (bounds.maxWidth - (columns - 1) * 8) / columns,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: c.mutedSurface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              w.accounts
                                      .where((a) => a.id == entry.key)
                                      .firstOrNull
                                      ?.name ??
                                  entry.key,
                              style: AppTypography.bodySmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              MoneyFormatter.php(entry.value),
                              style: AppTypography.merchant,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
