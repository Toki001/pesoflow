import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../domain/transaction.dart';

/// Stable category identity, shared by entry tiles, ledger rows and budgets.
Color categoryColor(TransactionCategory category, FinancePalette c) {
  final dark = c.isDark;
  return switch (category) {
    TransactionCategory.food || TransactionCategory.coffee =>
      dark ? const Color(0xFFFED7AA) : const Color(0xFFC66D32),
    TransactionCategory.shopping || TransactionCategory.personalCare =>
      dark ? const Color(0xFFE9D5FF) : const Color(0xFF9163D6),
    TransactionCategory.bills || TransactionCategory.housing =>
      dark ? const Color(0xFF99F6E4) : const Color(0xFF368C82),
    TransactionCategory.subscriptions || TransactionCategory.entertainment =>
      dark ? const Color(0xFFDDD6FE) : const Color(0xFF7773D8),
    TransactionCategory.groceries || TransactionCategory.healthcare =>
      dark ? const Color(0xFFA7F3D0) : const Color(0xFF4B8F67),
    TransactionCategory.transport ||
    TransactionCategory.travel ||
    TransactionCategory.transfer =>
      dark ? const Color(0xFFBFDBFE) : const Color(0xFF6285D3),
    TransactionCategory.income ||
    TransactionCategory.refund ||
    TransactionCategory.salary ||
    TransactionCategory.freelance ||
    TransactionCategory.business ||
    TransactionCategory.allowance ||
    TransactionCategory.interest ||
    TransactionCategory.otherIncome => c.positive,
    _ => dark ? c.secondaryInk : const Color(0xFF788598),
  };
}

/// Opaque pastel badge fills keep category identity soft on solid section cards.
Color categoryBackground(TransactionCategory category, FinancePalette c) =>
    Color.alphaBlend(
      categoryColor(category, c).withValues(alpha: c.isDark ? .13 : .08),
      c.surface,
    );
