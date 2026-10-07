import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:pesoflow/app/theme/app_colors.dart';
import 'package:pesoflow/app/theme/app_radius.dart';
import 'package:pesoflow/app/theme/app_typography.dart';
import 'package:pesoflow/core/formatting/money_formatter.dart';
import 'package:pesoflow/core/widgets/finance_card.dart';
import 'package:pesoflow/features/accounts/domain/account_view.dart';

class AccountsBalanceHero extends StatelessWidget {
  const AccountsBalanceHero(
    this.overview, {
    required this.onRefresh,
    required this.asOf,
    super.key,
  });
  final AccountsOverview overview;
  final VoidCallback onRefresh;
  final DateTime asOf;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final figures = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Total tracked balance',
          style: AppTypography.labelMedium.copyWith(color: c.mutedInk),
        ),
        const SizedBox(height: 4),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: overview.availableBalance < 0 ? '-₱ ' : '₱ ',
                style: AppTypography.headlineMedium.copyWith(
                  color: c.secondaryInk,
                ),
              ),
              TextSpan(
                text: MoneyFormatter.php(overview.availableBalance.abs())
                    .substring(1),
                style: AppTypography.numericXL,
              ),
            ],
          ),
          key: const ValueKey('accounts-total'),
        ),
      ],
    );
    final action = OutlinedButton.icon(
      onPressed: overview.refreshing ? null : onRefresh,
      style: OutlinedButton.styleFrom(
        backgroundColor: c.canvas,
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      icon: const Icon(Icons.sync, size: 16),
      label: Text('Refresh'),
    );
    return FinanceCard(
      hero: true,
      radius: AppRadius.feature,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, bounds) =>
                bounds.maxWidth < 315 ||
                    MediaQuery.textScalerOf(context).scale(14) > 19
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [figures, const SizedBox(height: 8), action],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: figures),
                      const SizedBox(width: 8),
                      action,
                    ],
                  ),
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: c.border),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 8,
              runSpacing: 8,
              children: [
                Text(
                  '${overview.accounts.length} tracked accounts',
                  style: AppTypography.bodySmall.copyWith(color: c.positive),
                ),
                Text(
                  DateFormat('MMM d, yyyy').format(asOf),
                  style: AppTypography.bodySmall.copyWith(color: c.mutedInk),
                ),
              ],
            ),
          ),
          if (overview.checked || overview.refreshError) ...[
            const SizedBox(height: 12),
            Text(
              overview.refreshError
                  ? "We couldn't refresh your saved records."
                  : 'Balances calculated from saved records.',
              style: AppTypography.bodySmall.copyWith(
                color: overview.refreshError ? c.warning : c.mutedInk,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
