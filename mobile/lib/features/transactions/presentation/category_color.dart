import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../domain/transaction.dart';

/// Stable category identity, shared by entry tiles, ledger rows and budgets.
Color categoryColor(TransactionCategory category, FinancePalette c) {
  final dark = c.isDark;
  return switch (category) {
    TransactionCategory.food || TransactionCategory.coffee =>
      dark ? const Color(0xFFFDBA74) : const Color(0xFF9A4515),
    TransactionCategory.shopping || TransactionCategory.personalCare =>
      dark ? const Color(0xFFDDD6FE) : const Color(0xFF6D28D9),
    TransactionCategory.bills || TransactionCategory.housing =>
      dark ? const Color(0xFF5EEAD4) : const Color(0xFF0F6862),
    TransactionCategory.subscriptions || TransactionCategory.entertainment =>
      dark ? const Color(0xFFC7D2FE) : const Color(0xFF4338CA),
    TransactionCategory.groceries ||
    TransactionCategory.healthcare => c.positive,
    TransactionCategory.transport ||
    TransactionCategory.travel ||
    TransactionCategory.transfer => c.primary,
    TransactionCategory.income ||
    TransactionCategory.refund ||
    TransactionCategory.salary ||
    TransactionCategory.freelance ||
    TransactionCategory.business ||
    TransactionCategory.allowance ||
    TransactionCategory.interest ||
    TransactionCategory.otherIncome => c.positive,
    _ => c.secondaryInk,
  };
}
