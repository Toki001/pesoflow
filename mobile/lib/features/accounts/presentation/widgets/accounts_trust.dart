import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/category_icon.dart';
import '../../../../core/widgets/finance_card.dart';

class AccountsReassurance extends StatelessWidget {
  const AccountsReassurance({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return FinanceCard(
      radius: AppRadius.standard,
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CategoryIcon(
            Icons.lock,
            foreground: c.secondary,
            background: c.soft(c.secondary, AppColors.secondarySoft),
            size: 32,
            iconSize: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Text(
                      'Read-only Bank & Wallet Demo',
                      style: AppTypography.labelMedium,
                    ),
                    Text(
                      'Sample data',
                      style: AppTypography.labelMedium.copyWith(
                        color: c.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Sample balances only. No accounts are connected; PesoFlow cannot transfer, debit or move funds.',
                  style: AppTypography.bodySmall.copyWith(
                    color: c.mutedInk,
                    height: 1.6,
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

class AccountsTrust extends StatelessWidget {
  const AccountsTrust({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return FinanceCard(
      radius: AppRadius.feature,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sample Financial Institutions',
            style: AppTypography.labelMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Demo profiles only. Live bank and wallet connections are not available yet.',
            style: AppTypography.bodySmall.copyWith(color: c.mutedInk),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final name in [
                'GCash',
                'Maya',
                'BDO Unibank',
                'BPI',
                'UnionBank',
                'RCBC',
              ])
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: c.canvas,
                    border: Border.all(color: c.border),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    name,
                    style: AppTypography.labelSmall.copyWith(
                      color: c.secondaryInk,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: c.border),
          const SizedBox(height: 12),
          for (final (icon, title, text) in [
            (
              Icons.verified_user_outlined,
              'No credentials collected:',
              ' This demo never asks for bank passwords, PINs or wallet credentials.',
            ),
            (
              Icons.security_outlined,
              'Demo data only:',
              ' Balances and connection states are sample records. No certification or regulatory compliance is claimed.',
            ),
            (
              Icons.visibility_off_outlined,
              'No Fund Access:',
              ' There are no live financial connections or payment capabilities.',
            ),
          ]) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 18, color: c.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: title,
                          style: AppTypography.labelMedium.copyWith(
                            color: c.ink,
                          ),
                        ),
                        TextSpan(
                          text: text,
                          style: AppTypography.bodySmall.copyWith(
                            color: c.mutedInk,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class AccountsInsight extends StatelessWidget {
  const AccountsInsight({super.key});
  @override
  Widget build(BuildContext context) => FinanceCard(
    radius: AppRadius.feature,
    color: context.colors.insight,
    borderColor: context.colors.accentBorder,
    padding: const EdgeInsets.all(16),
    child: Row(
      children: [
        CategoryIcon(
          Icons.auto_graph,
          foreground: context.colors.primary,
          background: context.colors.surface,
          size: 36,
          iconSize: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Explore sample bank and wallet balances in one place. Real account connections will require an authorized provider.',
            style: AppTypography.bodySmall.copyWith(
              color: context.colors.secondaryInk,
            ),
          ),
        ),
      ],
    ),
  );
}
