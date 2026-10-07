import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:pesoflow/app/theme/app_colors.dart';
import 'package:pesoflow/app/theme/app_typography.dart';
import 'package:pesoflow/core/formatting/money_formatter.dart';
import 'package:pesoflow/core/widgets/category_icon.dart';
import 'package:pesoflow/core/widgets/finance_card.dart';
import 'package:pesoflow/core/widgets/status_badge.dart';
import 'package:pesoflow/features/transactions/domain/transaction.dart';
import 'package:pesoflow/features/receipts/domain/receipt_draft.dart';

class ReceiptMerchantCard extends StatelessWidget {
  const ReceiptMerchantCard({
    required this.draft,
    required this.onMerchant,
    required this.onDate,
    super.key,
  });
  final ReceiptDraft draft;
  final VoidCallback? onMerchant, onDate;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return FinanceCard(
      color: c.canvas,
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              CategoryIcon(
                Icons.storefront_outlined,
                foreground: c.primary,
                background: c.soft(c.primary, AppColors.primarySoft),
                round: false,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MERCHANT',
                      style: AppTypography.labelSmall.copyWith(
                        color: c.mutedInk,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(draft.merchant, style: AppTypography.headlineSmall),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Edit merchant name',
                onPressed: onMerchant,
                icon: Icon(Icons.edit_outlined, size: 16, color: c.mutedInk),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: c.border),
          Semantics(
            button: onDate != null,
            label: 'Change receipt date and time',
            child: InkWell(
              key: const ValueKey('receipt-date'),
              onTap: onDate,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final date = Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 16,
                          color: c.mutedInk,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            DateFormat('MMM d, yyyy • h:mm a')
                                .format(draft.occurredAt),
                            style: AppTypography.bodySmall,
                          ),
                        ),
                      ],
                    );
                    final parsed = Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified_outlined,
                          size: 14,
                          color: c.positive,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Sample parsed',
                          style: AppTypography.labelSmall.copyWith(
                            color: c.positive,
                          ),
                        ),
                      ],
                    );
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child:
                          constraints.maxWidth >= 330 &&
                              MediaQuery.textScalerOf(context).scale(12) < 16
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(child: date),
                                const SizedBox(width: 8),
                                parsed,
                              ],
                            )
                          : Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [date, parsed],
                            ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ReceiptItemsCard extends StatelessWidget {
  const ReceiptItemsCard({
    required this.items,
    required this.onItem,
    super.key,
  });
  final List<ReceiptItem> items;
  final ValueChanged<ReceiptItem>? onItem;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return FinanceCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text('No receipt items. Add a missing item.'),
              ),
            for (final (index, item) in items.indexed) ...[
              if (index > 0) Divider(color: c.border),
              Semantics(
                button: onItem != null,
                label: 'Review item ${index + 1}: ${item.name}',
                child: InkWell(
                  key: ValueKey('receipt-item-${item.id}'),
                  onTap: onItem == null ? null : () => onItem!(item),
                  child: Container(
                    color: item.needsReview
                        ? c
                              .soft(c.warning, AppColors.warningSoft)
                              .withValues(alpha: c.isDark ? .12 : .45)
                        : null,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final identity = Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 10,
                              backgroundColor: item.needsReview
                                  ? c.soft(c.warning, AppColors.warningSoft)
                                  : c.mutedSurface,
                              child: Text(
                                '${index + 1}',
                                style: AppTypography.labelSmall.copyWith(
                                  color: item.needsReview
                                      ? c.warning
                                      : c.mutedInk,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: AppTypography.merchant.copyWith(
                                      fontSize: 16,
                                      height: 20 / 16,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.detail.isNotEmpty
                                        ? item.detail
                                        : 'Qty: ${item.quantity} • Unit: ${MoneyFormatter.php(item.unitPrice)}',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: c.mutedInk,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                        final price = Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (item.needsReview) ...[
                                  StatusBadge(
                                    'Check',
                                    foreground: c.warning,
                                    background: c.soft(
                                      c.warning,
                                      AppColors.warningSoft,
                                    ),
                                    pill: false,
                                  ),
                                  const SizedBox(width: 4),
                                ],
                                Text(
                                  MoneyFormatter.php(item.total),
                                  style: AppTypography.numericMedium,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.reviewed
                                  ? 'Reviewed'
                                  : item.confidence == null
                                  ? 'Manual item'
                                  : 'CONF: ${item.confidence}%',
                              style: AppTypography.labelSmall.copyWith(
                                color: item.needsReview
                                    ? c.warning
                                    : c.mutedInk,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        );
                        return constraints.maxWidth < 310 ||
                                MediaQuery.textScalerOf(context).scale(14) > 19
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  identity,
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: price,
                                  ),
                                ],
                              )
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: identity),
                                  const SizedBox(width: 8),
                                  price,
                                ],
                              );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ReceiptTotalsCard extends StatelessWidget {
  const ReceiptTotalsCard(this.draft, {super.key});
  final ReceiptDraft draft;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Widget row(String label, int value, Color color) => Wrap(
      alignment: WrapAlignment.spaceBetween,
      spacing: 8,
      runSpacing: 8,
      children: [
        Text(label, style: AppTypography.bodySmall.copyWith(color: color)),
        Text(
          MoneyFormatter.php(value),
          style: AppTypography.numericMedium.copyWith(color: color),
        ),
      ],
    );
    return FinanceCard(
      color: c.canvas,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          row('Subtotal', draft.total, c.secondaryInk),
          const SizedBox(height: 8),
          row('VAT (sample, 12% included)', draft.includedVat, c.mutedInk),
          const SizedBox(height: 12),
          Divider(color: c.border),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'TOTAL AMOUNT',
                style: AppTypography.labelMedium.copyWith(color: c.mutedInk),
              ),
              Text(
                MoneyFormatter.php(draft.total),
                style: AppTypography.numericXL.copyWith(color: c.primary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Demo receipt · no rewards applied',
            style: AppTypography.bodySmall.copyWith(color: c.positive),
          ),
        ],
      ),
    );
  }
}

class ReceiptAssignments extends StatelessWidget {
  const ReceiptAssignments({
    required this.draft,
    required this.onCategory,
    required this.onAccount,
    super.key,
  });
  final ReceiptDraft draft;
  final VoidCallback? onCategory, onAccount;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Widget card(
      String label,
      String value,
      IconData icon,
      VoidCallback? action, {
      String? caption,
    }) => Semantics(
      button: action != null,
      label: 'Change $label',
      child: InkWell(
        key: ValueKey('receipt-${label.toLowerCase().replaceAll(' ', '-')}'),
        onTap: action,
        child: FinanceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(color: c.mutedInk),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  CategoryIcon(
                    icon,
                    size: 32,
                    round: false,
                    foreground: label == 'CATEGORY' ? c.secondary : c.primary,
                    background: label == 'CATEGORY'
                        ? c.soft(c.secondary, AppColors.secondarySoft)
                        : c.soft(c.primary, AppColors.primarySoft),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(value, style: AppTypography.merchant),
                        if (caption != null)
                          Text(
                            caption,
                            style: AppTypography.labelSmall.copyWith(
                              color: c.mutedInk,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Icon(Icons.expand_more, size: 18, color: c.mutedInk),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final category = card(
          'CATEGORY',
          categoryLabel(draft.category),
          Icons.shopping_basket_outlined,
          onCategory,
        );
        final account = card(
          'PAID WITH',
          draft.account,
          Icons.account_balance_wallet_outlined,
          onAccount,
          caption: 'Demo source',
        );
        return constraints.maxWidth < 330 ||
                MediaQuery.textScalerOf(context).scale(14) > 19
            ? Column(children: [category, const SizedBox(height: 12), account])
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: category),
                  const SizedBox(width: 12),
                  Expanded(child: account),
                ],
              );
      },
    );
  }
}
