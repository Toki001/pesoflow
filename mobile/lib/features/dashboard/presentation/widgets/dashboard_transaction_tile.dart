import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:pesoflow/app/theme/app_colors.dart';
import 'package:pesoflow/core/formatting/date_formatter.dart';
import 'package:pesoflow/core/widgets/transaction_tile.dart';
import 'package:pesoflow/features/dashboard/domain/dashboard.dart';

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
    return Semantics(
      button: true,
      child: InkWell(
        onTap: () => context.push('/transactions/${transaction.id}'),
        child: TransactionTile(
          merchant: transaction.merchant,
          subtitle:
              '${transaction.metadata}${transaction.status == TransactionStatus.pending ? ' · Pending' : ''} · ${DateFormatter.transaction(transaction.occurredAt, asOf)}',
          amount: transaction.displayAmount,
          transfer: transaction.kind == TransactionKind.transfer,
          incoming:
              transaction.kind == TransactionKind.income ||
              transaction.kind == TransactionKind.refund,
          icon: icon,
          iconColor: color,
          iconBackground: soft,
        ),
      ),
    );
  }
}
