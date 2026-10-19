import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../transactions/domain/transaction.dart';

class TransactionTypeSelector extends StatelessWidget {
  const TransactionTypeSelector({
    required this.selected,
    required this.onSelected,
    required this.enabled,
    super.key,
  });

  final TransactionKind selected;
  final ValueChanged<TransactionKind> onSelected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: c.primary.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(22),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (kind, label, icon) in const [
              (TransactionKind.expense, 'Expense', Icons.north_east),
              (TransactionKind.income, 'Income', Icons.south_west),
              (TransactionKind.transfer, 'Transfer', Icons.swap_horiz),
            ])
              Expanded(
                child: Semantics(
                  selected: selected == kind,
                  button: true,
                  child: TextButton(
                    key: ValueKey('transaction-type-${kind.name}'),
                    onPressed: enabled ? () => onSelected(kind) : null,
                    style: TextButton.styleFrom(
                      backgroundColor: selected == kind
                          ? AppColors.primary
                          : Colors.transparent,
                      foregroundColor: selected == kind
                          ? Colors.white
                          : c.secondaryInk,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: selected == kind
                                ? Colors.white
                                : c.primary.withValues(alpha: .06),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            icon,
                            size: 18,
                            color: selected == kind
                                ? AppColors.primary
                                : c.primary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          label,
                          textAlign: TextAlign.center,
                          style: AppTypography.labelMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
