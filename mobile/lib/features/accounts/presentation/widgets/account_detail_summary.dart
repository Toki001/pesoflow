import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/formatting/date_formatter.dart';
import '../../../../core/formatting/money_formatter.dart';
import '../../../../core/widgets/category_icon.dart';
import '../../../../core/widgets/finance_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/demo_account.dart';

class AccountDetailSummary extends StatelessWidget {
  const AccountDetailSummary({required this.account, super.key});
  final DemoAccount account;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final expired = account.needsReauthentication;
    return FinanceCard(
      hero: true,
      radius: AppRadius.feature,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CategoryIcon(
                account.kind == DemoAccountKind.bank
                    ? Icons.account_balance
                    : Icons.account_balance_wallet,
                foreground: expired ? c.warning : c.primary,
                background: c.soft(
                  expired ? c.warning : c.primary,
                  expired ? AppColors.warningSoft : AppColors.primarySoft,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(account.name, style: AppTypography.headlineSmall),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      account.maskedIdentifier,
                      style: AppTypography.bodySmall.copyWith(
                        color: c.mutedInk,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            expired ? 'Last-known sample balance' : 'Sample available balance',
            style: AppTypography.labelMedium.copyWith(color: c.mutedInk),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            MoneyFormatter.php(account.balance),
            style: AppTypography.numericXL.copyWith(
              color: expired ? c.mutedInk : c.ink,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: StatusBadge(
              expired ? 'Needs Re-authentication' : 'Demo · Active',
              foreground: expired ? c.warning : c.positive,
              background: c.soft(
                expired ? c.warning : c.positive,
                expired ? AppColors.warningSoft : AppColors.positiveSoft,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(),
          const SizedBox(height: AppSpacing.md),
          _Info(label: 'Institution', value: account.institution),
          _Info(
            label: 'Account type',
            value: account.kind == DemoAccountKind.bank ? 'Bank' : 'E-Wallet',
          ),
          _Info(label: 'Currency', value: 'PHP (₱)'),
          _Info(
            label: 'Reported as of',
            value: DateFormatter.timestamp(account.balanceAsOf),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Illustrative account profile. No provider permissions have been granted. Manual entries do not change this reported balance.',
            style: AppTypography.bodySmall.copyWith(color: c.secondaryInk),
          ),
        ],
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
    child: Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xxs,
      alignment: WrapAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: context.colors.mutedInk,
          ),
        ),
        Text(value, style: AppTypography.bodySmall),
      ],
    ),
  );
}
