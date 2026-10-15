import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/formatting/money_formatter.dart';
import '../../../../core/widgets/finance_card.dart';
import '../../domain/dashboard.dart';

class BalanceHero extends StatelessWidget {
  const BalanceHero({required this.data, super.key});
  final Dashboard data;
  @override
  Widget build(BuildContext context) => FinanceCard(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TOTAL TRACKED BALANCE',
          style: AppTypography.labelMedium.copyWith(
            color: context.colors.mutedInk,
          ),
        ),
        const SizedBox(height: 16),
        Text(MoneyFormatter.php(data.balance), style: AppTypography.numericXL),
        const SizedBox(height: 20),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            Text(
              '${MoneyFormatter.php(data.monthChange, signed: true)} net flow this month',
              style: AppTypography.labelSmall.copyWith(
                color: data.monthChange < 0
                    ? context.colors.danger
                    : context.colors.positive,
              ),
            ),
            Text(
              '${data.accountCount} tracked accounts',
              style: AppTypography.labelSmall.copyWith(
                color: context.colors.mutedInk,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class FlowSummary extends StatelessWidget {
  const FlowSummary({required this.data, super.key});
  final Dashboard data;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Widget metric(
      String label,
      int amount,
      String caption,
      Color color,
    ) => Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.canvas,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.labelSmall.copyWith(color: color)),
          const SizedBox(height: 8),
          Text(MoneyFormatter.php(amount), style: AppTypography.numericMedium),
          const SizedBox(height: 8),
          Text(
            caption,
            style: AppTypography.labelSmall.copyWith(color: c.mutedInk),
          ),
        ],
      ),
    );
    final children = [
      metric(
        'SPENDING',
        data.outflow,
        data.inflow > 0
            ? '${(data.outflow * 100 / data.inflow).round()}% of monthly income'
            : 'No income recorded',
        c.danger,
      ),
      metric('INCOME', data.inflow, 'Recorded this month', c.positive),
    ];
    return FinanceCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${DateFormat.MMMM().format(data.asOf)} Cashflow',
                  style: AppTypography.merchant,
                ),
              ),
              TextButton(
                onPressed: () => context.go('/analytics'),
                child: const Text('This month ›'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (MediaQuery.textScalerOf(context).scale(14) > 19)
            Column(
              spacing: 12,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            )
          else
            Row(
              spacing: 12,
              children: children.map((w) => Expanded(child: w)).toList(),
            ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: c.mutedSurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 8,
              runSpacing: 8,
              children: [
                const Text('Net Cash Flow This Month'),
                Text(
                  MoneyFormatter.php(data.inflow - data.outflow, signed: true),
                  style: AppTypography.merchant.copyWith(
                    color: data.inflow >= data.outflow ? c.positive : c.danger,
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
