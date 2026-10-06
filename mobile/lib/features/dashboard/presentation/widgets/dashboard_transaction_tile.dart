import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/formatting/date_formatter.dart';
import '../../../../core/widgets/transaction_tile.dart';
import '../../domain/dashboard.dart';

/// Feature-to-presentation mapping; the shared tile has no domain dependency.
class DashboardTransactionTile extends StatelessWidget {
  const DashboardTransactionTile({
    required this.transaction,
    required this.asOf,
    super.key,
  });
  final TransactionRecord transaction;
  final DateTime asOf;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (icon, color, soft) = switch (transaction.category) {
      TransactionCategory.food => (
        Icons.fastfood_outlined,
        c.danger,
        c.soft(c.danger, AppColors.dangerSoft),
      ),
      TransactionCategory.transport => (
        Icons.directions_car_outlined,
        c.primary,
        c.soft(c.primary, AppColors.primarySoft),
      ),
      TransactionCategory.transfer => (
        Icons.sync_alt,
        c.secondaryInk,
        c.mutedSurface,
      ),
      TransactionCategory.income => (
        Icons.payments_outlined,
        c.positive,
        c.soft(c.positive, AppColors.positiveSoft),
      ),
      _ => (Icons.receipt_long_outlined, c.secondaryInk, c.mutedSurface),
    };
    return TransactionTile(
      merchant: transaction.merchant,
      subtitle:
          '${transaction.metadata} · ${DateFormatter.transaction(transaction.occurredAt, asOf)}',
      amount: transaction.displayAmount,
      transfer: transaction.kind == TransactionKind.transfer,
      incoming:
          transaction.kind == TransactionKind.income ||
          transaction.kind == TransactionKind.refund,
      icon: icon,
      iconColor: color,
      iconBackground: soft,
    );
  }
}
