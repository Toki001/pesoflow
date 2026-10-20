import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../domain/transaction.dart';

/// Stable category identity, shared by entry tiles, ledger rows and budgets.
Color categoryColor(TransactionCategory category, FinancePalette c) {
  final dark = c.isDark;
  return switch (category) {
    TransactionCategory.food || TransactionCategory.coffee =>
      dark ? const Color(0xFFFED7AA) : const Color(0xFFC66316),
    TransactionCategory.shopping =>
      dark ? const Color(0xFFE9D5FF) : const Color(0xFF8B3DD6),
    TransactionCategory.bills || TransactionCategory.housing =>
      dark ? const Color(0xFF99F6E4) : const Color(0xFF008282),
    TransactionCategory.subscriptions =>
      dark ? const Color(0xFFDDD6FE) : const Color(0xFF6654D4),
    TransactionCategory.groceries =>
      dark ? const Color(0xFFA7F3D0) : const Color(0xFF22804A),
    TransactionCategory.entertainment =>
      dark ? const Color(0xFFE9B9FF) : const Color(0xFFA13BD4),
    TransactionCategory.healthcare =>
      dark ? const Color(0xFFF9A8CF) : const Color(0xFFC64278),
    TransactionCategory.education =>
      dark ? const Color(0xFF7DD3FC) : const Color(0xFF147DAB),
    TransactionCategory.personalCare =>
      dark ? const Color(0xFFF9A8D4) : const Color(0xFFB84C80),
    TransactionCategory.transport ||
    TransactionCategory.travel ||
    TransactionCategory.transfer =>
      dark ? const Color(0xFFBFDBFE) : const Color(0xFF286DD8),
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
      categoryColor(category, c).withValues(alpha: c.isDark ? .16 : .12),
      c.surface,
    );

/// Exhaustive native glyphs: known categories never fall back to a receipt icon.
IconData transactionCategoryIcon(TransactionCategory category) =>
    switch (category) {
      TransactionCategory.food => Icons.restaurant,
      TransactionCategory.transport => Icons.directions_car_outlined,
      TransactionCategory.transfer => Icons.swap_horiz,
      TransactionCategory.income => Icons.payments_outlined,
      TransactionCategory.groceries => Icons.shopping_cart_outlined,
      TransactionCategory.coffee => Icons.local_cafe_outlined,
      TransactionCategory.subscriptions => Icons.subscriptions_outlined,
      TransactionCategory.shopping => Icons.shopping_bag_outlined,
      TransactionCategory.bills => Icons.bolt,
      TransactionCategory.entertainment => Icons.sports_esports_outlined,
      TransactionCategory.refund => Icons.undo,
      TransactionCategory.housing => Icons.home_outlined,
      TransactionCategory.healthcare => Icons.medical_services_outlined,
      TransactionCategory.education => Icons.school_outlined,
      TransactionCategory.travel => Icons.flight_outlined,
      TransactionCategory.personalCare => Icons.spa_outlined,
      TransactionCategory.fees => Icons.account_balance_outlined,
      TransactionCategory.other => Icons.category_outlined,
      TransactionCategory.salary => Icons.work_outline,
      TransactionCategory.freelance => Icons.laptop_mac_outlined,
      TransactionCategory.business => Icons.storefront_outlined,
      TransactionCategory.allowance => Icons.savings_outlined,
      TransactionCategory.interest => Icons.trending_up,
      TransactionCategory.otherIncome => Icons.add_circle_outline,
    };
