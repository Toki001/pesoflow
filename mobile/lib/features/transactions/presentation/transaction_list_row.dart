import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/formatting/money_formatter.dart';
import '../../../core/widgets/category_icon.dart';
import '../../../core/widgets/status_badge.dart';
import '../domain/transaction.dart';

/// Compact row used by the approved Transactions feed, distinct from Home.
class TransactionListRow extends StatelessWidget {
  const TransactionListRow({
    required this.transaction,
    this.wrapText = false,
    super.key,
  });
  final TransactionRecord transaction;
  final bool wrapText;
  @override
  Widget build(BuildContext context) {
    final t = transaction;
    final c = context.colors;
    final icon = switch (t.category) {
      TransactionCategory.food => Icons.fastfood_outlined,
      TransactionCategory.transport => Icons.directions_car_outlined,
      TransactionCategory.coffee => Icons.local_cafe_outlined,
      TransactionCategory.transfer => Icons.swap_horiz,
      TransactionCategory.income => Icons.arrow_downward,
      TransactionCategory.groceries => Icons.shopping_cart_outlined,
      TransactionCategory.refund => Icons.undo,
      TransactionCategory.subscriptions => Icons.smart_display_outlined,
      _ => Icons.receipt_long_outlined,
    };
    final foreground = switch (t.category) {
      TransactionCategory.food => c.danger,
      TransactionCategory.coffee => c.warning,
      TransactionCategory.income => c.positive,
      TransactionCategory.refund => c.secondary,
      _ => c.secondaryInk,
    };
    final background = c.soft(foreground, switch (t.category) {
      TransactionCategory.food => AppColors.dangerSoft,
      TransactionCategory.coffee => AppColors.warningSoft,
      TransactionCategory.income => AppColors.positiveSoft,
      TransactionCategory.refund => AppColors.secondarySoft,
      _ => AppColors.surfaceMuted,
    });
    final (
      badge,
      badgeColor,
      badgeBackground,
    ) = t.status == TransactionStatus.pending
        ? ('PENDING', c.warning, c.soft(c.warning, AppColors.warningSoft))
        : switch (t.kind) {
            TransactionKind.transfer => (
              'Transfer',
              c.mutedInk,
              c.mutedSurface,
            ),
            TransactionKind.income => (
              'Income',
              c.positive,
              c.soft(c.positive, AppColors.positiveSoft),
            ),
            TransactionKind.refund => (
              'Refund',
              c.secondary,
              c.soft(c.secondary, AppColors.secondarySoft),
            ),
            _ => (
              t.source == TransactionSource.receipt ? 'Receipt' : '',
              c.mutedInk,
              c.mutedSurface,
            ),
          };
    final money = Text(
      MoneyFormatter.php(
        t.kind == TransactionKind.transfer ? t.amount : t.displayAmount,
        signed:
            t.kind == TransactionKind.income ||
            t.kind == TransactionKind.refund,
      ),
      style: AppTypography.numericMedium.copyWith(
        color:
            t.status == TransactionStatus.pending ||
                t.kind == TransactionKind.transfer
            ? c.secondaryInk
            : t.kind == TransactionKind.income ||
                  t.kind == TransactionKind.refund
            ? c.positive
            : c.ink,
      ),
    );
    return Semantics(
      button: true,
      child: InkWell(
        onTap: () => context.push('/transactions/${t.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final large =
                  MediaQuery.textScalerOf(context).scale(14) > 19 ||
                  constraints.maxWidth < 300;
              final details = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          t.merchant,
                          maxLines: large || wrapText ? null : 1,
                          overflow: large || wrapText
                              ? null
                              : TextOverflow.ellipsis,
                          style: AppTypography.merchant,
                        ),
                      ),
                      if (badge.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        StatusBadge(
                          badge,
                          foreground: badgeColor,
                          background: badgeBackground,
                          pill: false,
                        ),
                      ],
                      if (t.recurring) ...[
                        const SizedBox(width: 6),
                        Icon(Icons.sync, size: 14, color: c.mutedInk),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${t.metadata} · ${DateFormat('h:mm a').format(t.occurredAt)}',
                    maxLines: large || wrapText ? null : 1,
                    overflow: large || wrapText ? null : TextOverflow.ellipsis,
                    style: AppTypography.bodySmall.copyWith(color: c.mutedInk),
                  ),
                  if (large) ...[const SizedBox(height: 8), money],
                ],
              );
              return Row(
                children: [
                  CategoryIcon(
                    icon,
                    foreground: foreground,
                    background: background,
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: details),
                  if (!large) ...[const SizedBox(width: 12), money],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
