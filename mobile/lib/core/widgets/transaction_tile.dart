import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import 'category_icon.dart';
import 'money_text.dart';
import 'status_badge.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    required this.merchant,
    required this.subtitle,
    required this.amount,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    this.transfer = false,
    this.incoming = false,
    super.key,
  });
  final String merchant;
  final String subtitle;
  final int amount;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final bool transfer;
  final bool incoming;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final money = MoneyText(
      amount,
      signed: incoming,
      style: AppTypography.numericMedium.copyWith(
        color: incoming ? c.positive : (transfer ? c.secondaryInk : c.ink),
      ),
    );
    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(merchant, style: AppTypography.merchant),
        if (transfer)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: StatusBadge(
              'Transfer',
              foreground: c.mutedInk,
              background: c.mutedSurface,
              pill: false,
            ),
          ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: AppTypography.bodySmall.copyWith(color: c.mutedInk),
        ),
      ],
    );
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final large =
              MediaQuery.textScalerOf(context).scale(14) > 19 ||
              constraints.maxWidth < 300;
          return Row(
            children: [
              CategoryIcon(
                icon,
                foreground: iconColor,
                background: iconBackground,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: large
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [details, const SizedBox(height: 8), money],
                      )
                    : details,
              ),
              if (!large) ...[const SizedBox(width: 8), money],
            ],
          );
        },
      ),
    );
  }
}
