import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/category_icon.dart';
import '../../../../core/widgets/finance_card.dart';
import '../../../../core/widgets/money_text.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/dashboard.dart';

class UpcomingBills extends StatelessWidget {
  const UpcomingBills({required this.bills, super.key});
  final List<UpcomingBill> bills;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final stacked =
          constraints.maxWidth < 340 ||
          MediaQuery.textScalerOf(context).scale(14) > 18;
      if (bills.isEmpty) {
        return const FinanceCard(child: Text('No upcoming bills'));
      }
      return Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        children: [
          for (final bill in bills)
            SizedBox(
              width: stacked
                  ? constraints.maxWidth
                  : (constraints.maxWidth - AppSpacing.xs) / 2,
              child: _BillCard(bill: bill),
            ),
        ],
      );
    },
  );
}

class _BillCard extends StatelessWidget {
  const _BillCard({required this.bill});
  final UpcomingBill bill;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tomorrow = bill.daysUntilDue == 1;
    return FinanceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CategoryIcon(
                bill.estimated ? Icons.electric_bolt : Icons.music_note,
                foreground: c.secondaryInk,
                background: c.mutedSurface,
                size: 32,
                round: false,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Align(
                  alignment: Alignment.topRight,
                  child: StatusBadge(
                    tomorrow ? 'Due tomorrow' : 'In ${bill.daysUntilDue} days',
                    foreground: tomorrow ? c.danger : c.secondaryInk,
                    background: tomorrow
                        ? c.soft(c.danger, AppColors.dangerSoft)
                        : c.mutedSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(bill.name, style: AppTypography.merchant),
          const SizedBox(height: 4),
          Wrap(
            spacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              MoneyText(bill.amount),
              Text(
                bill.estimated ? 'est.' : '/ mo',
                style: AppTypography.labelSmall.copyWith(color: c.mutedInk),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
