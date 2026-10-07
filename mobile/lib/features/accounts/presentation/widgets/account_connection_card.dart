import 'package:flutter/material.dart';

import 'package:pesoflow/app/theme/app_colors.dart';
import 'package:pesoflow/app/theme/app_radius.dart';
import 'package:pesoflow/app/theme/app_typography.dart';
import 'package:pesoflow/core/formatting/money_formatter.dart';
import 'package:pesoflow/core/widgets/category_icon.dart';
import 'package:pesoflow/core/widgets/finance_card.dart';
import 'package:pesoflow/core/widgets/status_badge.dart';
import 'package:pesoflow/features/accounts/domain/account_view.dart';

String balanceAge(AccountView account, DateTime clock) {
  final age = clock.difference(account.balanceAsOf);
  if (age.inDays >= 1) return '${age.inDays} days ago';
  if (age.inHours >= 1) return '${age.inHours}h ago';
  if (age.inMinutes >= 1) return '${age.inMinutes}m ago';
  return 'just now';
}

class AccountConnectionCard extends StatelessWidget {
  const AccountConnectionCard({
    required this.account,
    required this.clock,
    required this.onSettings,
    required this.onDetails,
    required this.onDisconnect,
    required this.onReconnect,
    super.key,
  });
  final AccountView account;
  final DateTime clock;
  final VoidCallback onSettings;
  final VoidCallback onDetails;
  final VoidCallback onDisconnect;
  final VoidCallback onReconnect;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final expired = account.needsReauthentication;
    final color = expired
        ? c.warning
        : account.kind == AccountKind.wallet
        ? c.primary
        : account.kind == AccountKind.bank
        ? c.secondary
        : c.secondaryInk;
    final soft = expired
        ? AppColors.warningSoft
        : account.kind == AccountKind.wallet
        ? AppColors.primarySoft
        : account.kind == AccountKind.bank
        ? AppColors.secondarySoft
        : AppColors.surfaceMuted;
    final badge = StatusBadge(
      expired
          ? 'Needs Re-authentication'
          : account.archived
          ? 'Archived'
          : account.manual
          ? 'Manual'
          : 'Connected',
      foreground: expired ? c.warning : c.positive,
      background: c.soft(
        expired ? c.warning : c.positive,
        expired ? AppColors.warningSoft : AppColors.positiveSoft,
      ),
      icon: Icons.circle,
      iconSize: 6,
    );
    final balance = Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          expired
              ? 'Last known'
              : account.manual
              ? 'Tracked balance'
              : 'Reported balance',
          style: AppTypography.labelSmall.copyWith(color: c.mutedInk),
        ),
        const SizedBox(height: 4),
        Text(
          MoneyFormatter.php(account.balance),
          style: AppTypography.numericMedium.copyWith(
            color: expired ? c.mutedInk : c.ink,
          ),
        ),
      ],
    );
    final metadata =
        '${account.maskedIdentifier} · ${expired
            ? 'Last synced ${balanceAge(account, clock)}'
            : account.kind == AccountKind.wallet
            ? 'E-Wallet'
            : account.kind == AccountKind.cash
            ? 'Cash'
            : 'Bank'}';
    final footer = expired
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Connection expired. Balance is stale.',
                  style: AppTypography.bodySmall.copyWith(
                    color: c.secondaryInk,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: FilledButton.icon(
                  onPressed: onReconnect,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.warning,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  icon: const Icon(Icons.lock_reset, size: 16),
                  label: const Text('Reconnect Account'),
                ),
              ),
            ],
          )
        : Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Icon(Icons.schedule, size: 15, color: c.mutedInk),
                  const SizedBox(width: 6),
                  Text(
                    account.manual
                        ? 'Manually tracked'
                        : 'Synced ${balanceAge(account, clock)}',
                    style: AppTypography.bodySmall.copyWith(color: c.mutedInk),
                  ),
                ],
              ),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  TextButton(
                    key: ValueKey('settings-${account.id}'),
                    onPressed: onSettings,
                    style: TextButton.styleFrom(
                      foregroundColor: c.secondaryInk,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: const Text('Edit'),
                  ),
                  Container(width: 1, height: 14, color: c.border),
                  TextButton(
                    key: ValueKey('disconnect-${account.id}'),
                    onPressed: onDisconnect,
                    style: TextButton.styleFrom(
                      foregroundColor: c.danger,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: Text(account.archived ? 'Restore' : 'Remove'),
                  ),
                ],
              ),
            ],
          );
    return FinanceCard(
      radius: AppRadius.budgetHero,
      padding: const EdgeInsets.all(16),
      borderColor: expired ? c.warning.withValues(alpha: .4) : c.border,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            button: true,
            child: InkWell(
              key: ValueKey('account-details-${account.id}'),
              onTap: onDetails,
              child: LayoutBuilder(
                builder: (context, bounds) {
                  final stacked =
                      bounds.maxWidth < 320 ||
                      MediaQuery.textScalerOf(context).scale(14) > 19;
                  final identity = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(account.name, style: AppTypography.merchant),
                          badge,
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        metadata,
                        style: AppTypography.bodySmall.copyWith(
                          color: c.mutedInk,
                        ),
                      ),
                    ],
                  );
                  return Row(
                    children: [
                      CategoryIcon(
                        account.kind == AccountKind.bank
                            ? Icons.account_balance
                            : Icons.account_balance_wallet,
                        foreground: color,
                        background: c.soft(color, soft),
                        size: 40,
                        iconSize: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: stacked
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  identity,
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: balance,
                                  ),
                                ],
                              )
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: identity),
                                  const SizedBox(width: 8),
                                  balance,
                                ],
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 14),
          Divider(height: 1, color: c.border),
          const SizedBox(height: 4),
          SizedBox(width: double.infinity, child: footer),
        ],
      ),
    );
  }
}
