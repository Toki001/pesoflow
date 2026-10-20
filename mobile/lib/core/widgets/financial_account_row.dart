import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../features/accounts/domain/financial_account.dart';
import '../formatting/money_formatter.dart';
import 'account_badge.dart';

class FinancialAccountRow extends StatelessWidget {
  const FinancialAccountRow({
    required this.account,
    required this.balance,
    this.showBalance = true,
    this.onTap,
    super.key,
  });
  final FinancialAccount account;
  final int balance;
  final bool showBalance;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final type = switch (account.type) {
      AccountType.cash => 'Cash',
      AccountType.wallet => 'E-wallet',
      AccountType.bank => 'Bank account',
      AccountType.savings => 'Savings',
      AccountType.credit => 'Credit card',
    };
    return InkWell(
      onTap: onTap ?? () => context.push('/accounts/${account.id}'),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            AccountBadge(account: account),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(account.name, style: AppTypography.merchant),
                  const SizedBox(height: 3),
                  Text(
                    '$type${account.maskedIdentifier.isEmpty ? '' : ' · ${account.maskedIdentifier}'}${account.archived ? ' · Archived' : ''}',
                    style: AppTypography.bodySmall.copyWith(color: c.mutedInk),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                showBalance ? MoneyFormatter.php(balance) : '••••',
                textAlign: TextAlign.end,
                style: AppTypography.merchant.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                  color: balance < 0 ? c.danger : c.ink,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, size: 18),
          ],
        ),
      ),
    );
  }
}
