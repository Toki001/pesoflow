import '../../settings/domain/demo_preferences.dart';
import '../../budgets/domain/budget_plan.dart';
import '../../subscriptions/domain/subscription_plan.dart';

import '../../receipts/domain/receipt_draft.dart';
import '../../transactions/domain/transaction.dart';

/// Atomic local demo activity and planning metadata; never provider credentials.
class DemoWorkspace {
  DemoWorkspace({
    required Iterable<TransactionRecord> ledger,
    Map<String, ReceiptDraft> receipts = const {},
    Map<String, BudgetPlan> budgets = const {},
    Iterable<SubscriptionPlan> subscriptions = const [],
    this.preferences = const DemoPreferences(),
  }) : ledger = List.unmodifiable(ledger),
       receipts = Map.unmodifiable(receipts),
       budgets = Map.unmodifiable(budgets),
       subscriptions = List.unmodifiable(subscriptions) {
    for (final entry in this.budgets.entries) {
      final plan = entry.value;
      final categories = plan.allowances.map((a) => a.category).toSet();
      if (entry.key != plan.key ||
          plan.year < 1 ||
          plan.year > 9999 ||
          plan.month < 1 ||
          plan.month > 12 ||
          plan.monthlyLimit <= 0 ||
          plan.monthlyLimit > 99999999999 ||
          plan.allocated > plan.monthlyLimit ||
          categories.length != plan.allowances.length ||
          plan.editedCategories.toSet().length !=
              plan.editedCategories.length ||
          !categories.containsAll(plan.editedCategories) ||
          plan.allowances.any(
            (a) =>
                a.limit <= 0 ||
                a.limit > 99999999999 ||
                [
                  TransactionCategory.income,
                  TransactionCategory.transfer,
                  TransactionCategory.refund,
                ].contains(a.category),
          )) {
        throw const FormatException('Invalid demo budget plan.');
      }
    }
    if (this.subscriptions.map((p) => p.id).toSet().length !=
        this.subscriptions.length) {
      throw const FormatException('Duplicate demo subscription ID.');
    }
    if (this.ledger.any(
          (t) => t.id.isEmpty || t.amount <= 0 || t.amount > 99999999999,
        ) ||
        this.ledger.map((t) => t.id).toSet().length != this.ledger.length) {
      throw const FormatException('Invalid demo ledger.');
    }
    for (final entry in this.receipts.entries) {
      final matches = this.ledger.where((t) => t.id == entry.key);
      final receipt = entry.value;
      if (matches.length != 1 ||
          receipt.savedTransactionId != entry.key ||
          receipt.validationError != null ||
          matches.single.source != TransactionSource.receipt ||
          !matches.single.hasReceipt ||
          matches.single.amount != receipt.total ||
          matches.single.accountId != receipt.accountId) {
        throw const FormatException('Invalid saved demo receipt.');
      }
    }
  }
  final List<TransactionRecord> ledger;
  final Map<String, ReceiptDraft> receipts;
  final Map<String, BudgetPlan> budgets;
  final List<SubscriptionPlan> subscriptions;
  final DemoPreferences preferences;
}

abstract interface class DemoWorkspaceRepository {
  Future<DemoWorkspace> load();
  Future<void> save(DemoWorkspace workspace);
  Future<void> close();
}
