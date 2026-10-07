import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pesoflow/core/identity/new_id.dart';
import 'package:pesoflow/core/time/clock.dart';
import 'package:pesoflow/features/accounts/domain/financial_account.dart';
import 'package:pesoflow/features/budgets/domain/spending_budget.dart';
import 'package:pesoflow/features/notifications/domain/evaluate_notices.dart';
import 'package:pesoflow/features/receipts/domain/receipt_draft.dart';
import 'package:pesoflow/features/settings/domain/user_preferences.dart';
import 'package:pesoflow/features/subscriptions/domain/subscription_plan.dart';
import 'package:pesoflow/features/transactions/domain/categorization.dart';
import 'package:pesoflow/features/transactions/domain/transaction.dart';
import 'package:pesoflow/features/workspace/domain/finance_workspace.dart';

final financeRepositoryProvider = Provider<FinanceRepository>(
  (ref) =>
      throw StateError('Finance repository must be supplied at bootstrap.'),
);
final initialWorkspaceProvider = Provider<FinanceWorkspace>(
  (ref) => throw StateError(
    'Load the workspace before rendering financial screens.',
  ),
);

class FinanceState {
  const FinanceState(this.workspace, {this.saving = false, this.error});
  final FinanceWorkspace workspace;
  final bool saving;
  final String? error;
}

final financeControllerProvider =
    NotifierProvider<FinanceController, FinanceState>(FinanceController.new);
final workspaceProvider = Provider<FinanceWorkspace>(
  (ref) => ref.watch(financeControllerProvider.select((s) => s.workspace)),
);

/// Serialized, durable-before-visible edits. Failed writes preserve the previous
/// committed state and propagate to the form so unsaved inputs remain available.
class FinanceController extends Notifier<FinanceState> {
  Future<void> _tail = Future.value();
  @override
  FinanceState build() => FinanceState(ref.watch(initialWorkspaceProvider));

  Future<void> _commit(
    FinanceWorkspace Function(FinanceWorkspace) edit, {
    bool evaluate = true,
  }) {
    final result = _tail.then((_) async {
      if (!ref.mounted) throw StateError('Workspace closed.');
      final before = state.workspace;
      state = FinanceState(before, saving: true);
      try {
        var next = edit(before);
        if (evaluate) {
          next = next.copyWith(
            notices: evaluateNotices(next, ref.read(clockProvider)()),
          );
        }
        final saved = await ref
            .read(financeRepositoryProvider)
            .save(next, expectedRevision: before.revision);
        if (ref.mounted) state = FinanceState(saved);
      } catch (_) {
        if (ref.mounted) {
          state = FinanceState(
            before,
            error: 'Changes could not be saved. Your previously saved data is intact. Please try again.',
          );
        }
        rethrow;
      }
    });
    // Each caller still receives its failure; a failed operation never poisons
    // the queue or allows an older snapshot to overwrite a subsequent edit.
    _tail = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  Future<void> flush() => _tail;
  void dismissError() =>
      state = FinanceState(state.workspace, saving: state.saving);

  Future<void> saveAccount(FinancialAccount account) => _commit((w) {
    if (account.source != BalanceSource.manual ||
        account.currency != w.preferences.currency) {
      throw ArgumentError(
        'Create a manual account in your workspace currency.',
      );
    }
    final existing = w.accounts.where((a) => a.id == account.id);
    if (existing.isNotEmpty && existing.single.source != BalanceSource.manual) {
      throw ArgumentError('Provider accounts cannot be edited manually.');
    }
    return w.copyWith(
      accounts: [
        for (final a in w.accounts)
          if (a.id == account.id) account else a,
        if (existing.isEmpty) account,
      ],
    );
  });

  Future<void> removeAccount(String id) => _commit((w) {
    final matches = w.accounts.where((a) => a.id == id);
    if (matches.length != 1 || matches.single.source != BalanceSource.manual) {
      throw ArgumentError('Manual account not found.');
    }
    if (w.ledger.any((t) => t.involvesAccount(id))) {
      throw ArgumentError(
        'This account has transactions. Archive it to preserve your history.',
      );
    }
    return w.copyWith(accounts: w.accounts.where((a) => a.id != id));
  });

  Future<void> saveTransaction(
    TransactionRecord record, {
    bool editing = false,
    bool rememberCategory = false,
  }) => _commit((w) {
    final existing = w.ledger.where((t) => t.id == record.id);
    if (editing != existing.isNotEmpty) {
      throw ArgumentError('Transaction identity changed.');
    }
    if (record.source != TransactionSource.manual &&
            record.source != TransactionSource.receipt ||
        existing.any(
          (t) =>
              t.source == TransactionSource.bankSync ||
              t.source == TransactionSource.walletSync,
        )) {
      throw ArgumentError('Provider transactions are read-only.');
    }
    _checkAccount(w, record.accountId);
    if (record.kind == TransactionKind.transfer) {
      _checkAccount(w, record.destinationAccountId);
    }
    if (record.kind == TransactionKind.expense &&
            !isExpenseCategory(record.category) ||
        record.kind == TransactionKind.income &&
            !isIncomeCategory(record.category) ||
        record.kind == TransactionKind.transfer &&
            record.category != TransactionCategory.transfer) {
      throw ArgumentError('Choose a category matching this transaction type.');
    }
    final rules = {...w.merchantRules};
    if (rememberCategory &&
        normalizeMerchant(record.merchant).isNotEmpty &&
        [
          TransactionKind.expense,
          TransactionKind.income,
        ].contains(record.kind)) {
      rules[merchantRuleKey(record.kind, record.merchant)] = record.category;
    }
    return w.copyWith(
      ledger: [
        for (final t in w.ledger)
          if (t.id == record.id) record else t,
        if (existing.isEmpty) record,
      ],
      merchantRules: rules,
    );
  });

  void _checkAccount(FinanceWorkspace w, String? id) {
    final matches = w.accounts.where((a) => a.id == id);
    if (matches.length != 1 ||
        matches.single.archived ||
        matches.single.source != BalanceSource.manual) {
      throw ArgumentError('Choose an active manually tracked account.');
    }
  }

  Future<void> deleteTransaction(String id) => _commit((w) {
    final matches = w.ledger.where((t) => t.id == id);
    if (matches.length != 1 ||
        matches.single.source == TransactionSource.bankSync ||
        matches.single.source == TransactionSource.walletSync) {
      throw ArgumentError('Choose a manually recorded transaction.');
    }
    return w.copyWith(
      ledger: w.ledger.where((t) => t.id != id),
      receipts: {...w.receipts}..remove(id),
    );
  });

  Future<String> saveReceipt(ReceiptDraft draft) async {
    final id = draft.savedTransactionId ?? newId();
    await _commit((w) {
      if (w.receipts.values.any((r) => r.id == draft.id)) {
        throw ArgumentError('This receipt has already been saved.');
      }
      _checkAccount(w, draft.accountId);
      final record = draft.toTransaction(id);
      return w.copyWith(
        ledger: [...w.ledger, record],
        receipts: {
          ...w.receipts,
          id: draft.copyWith(savedTransactionId: id),
        },
      );
    });
    return id;
  }

  Future<void> saveBudget(SpendingBudget budget) => _commit((w) {
    if (w.budgets.any(
      (b) =>
          b.id != budget.id &&
          b.period == budget.period &&
          b.category == budget.category,
    )) {
      throw ArgumentError(
        'Edit the existing budget for this category and period.',
      );
    }
    return w.copyWith(
      budgets: [
        for (final b in w.budgets)
          if (b.id == budget.id) budget else b,
        if (!w.budgets.any((b) => b.id == budget.id)) budget,
      ],
    );
  });
  Future<void> deleteBudget(String id) =>
      _commit((w) => w.copyWith(budgets: w.budgets.where((b) => b.id != id)));

  /// Change both allowances in one durable write, validating current spending.
  Future<void> reallocateBudgets(
    String fromId,
    String toId,
    int amount,
    DateTime date,
  ) => _commit((w) {
    final from = w.budgets.firstWhere((b) => b.id == fromId);
    final to = w.budgets.firstWhere((b) => b.id == toId);
    final progress = evaluateBudget(
      from,
      w.ledger,
      ref.read(clockProvider)(),
      selectedDate: date,
    );
    if (fromId == toId ||
        amount <= 0 ||
        !from.enabled ||
        !to.enabled ||
        from.period != to.period ||
        from.category == null ||
        to.category == null ||
        from.limit <= amount ||
        from.limit - progress.projectedSpend < amount) {
      throw ArgumentError('There is not enough projected allowance to move.');
    }
    return w.copyWith(
      budgets: [
        for (final b in w.budgets)
          if (b.id == fromId)
            b.copyWith(limit: b.limit - amount)
          else if (b.id == toId)
            b.copyWith(limit: b.limit + amount)
          else
            b,
      ],
    );
  });
  Future<void> saveSubscription(SubscriptionPlan plan) => _commit(
    (w) => w.copyWith(
      subscriptions: [
        for (final p in w.subscriptions)
          if (p.id == plan.id) plan else p,
        if (!w.subscriptions.any((p) => p.id == plan.id)) plan,
      ],
    ),
  );
  Future<void> deleteSubscription(String id) => _commit(
    (w) => w.copyWith(subscriptions: w.subscriptions.where((p) => p.id != id)),
  );
  Future<void> dismissRecurring(String key) => _commit(
    (w) =>
        w.copyWith(dismissedRecurringKeys: {...w.dismissedRecurringKeys, key}),
  );
  Future<void> savePreferences(UserPreferences prefs) => _commit((w) {
    if (w.accounts.isNotEmpty && prefs.currency != w.preferences.currency) {
      throw ArgumentError(
        'Currency cannot change while accounts exist. Export and clear financial data before changing currency.',
      );
    }
    return w.copyWith(preferences: prefs);
  });
  Future<void> setNoticeRead(String id, bool read) => _commit((w) {
    if (!w.notices.any((n) => n.id == id)) {
      throw ArgumentError('Notice not found.');
    }
    final ids = {...w.noticeReadIds};
    if (read) {
      ids.add(id);
    } else {
      ids.remove(id);
    }
    return w.copyWith(noticeReadIds: ids);
  }, evaluate: false);
  Future<void> markAllRead() => _commit(
    (w) => w.copyWith(noticeReadIds: w.notices.map((n) => n.id).toSet()),
    evaluate: false,
  );
  Future<void> evaluateConditions() => _commit((w) => w);
  Future<void> clearFinancialData() => _commit(
    (w) => FinanceWorkspace(
      revision: w.revision,
      preferences: w.preferences,
      sync: w.sync,
    ),
    evaluate: false,
  );
}
