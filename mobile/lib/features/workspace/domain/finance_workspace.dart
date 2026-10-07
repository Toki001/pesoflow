import '../../../core/serialization/values.dart';
import '../../accounts/domain/financial_account.dart';
import '../../budgets/domain/spending_budget.dart';
import '../../notifications/domain/financial_notice.dart';
import '../../receipts/domain/receipt_draft.dart';
import '../../settings/domain/user_preferences.dart';
import '../../subscriptions/domain/subscription_plan.dart';
import '../../transactions/domain/transaction.dart';

/// Immutable aggregate committed atomically. All collections begin empty.
class FinanceWorkspace {
  FinanceWorkspace({
    this.revision = 0,
    Iterable<FinancialAccount> accounts = const [],
    Iterable<TransactionRecord> ledger = const [],
    Iterable<SpendingBudget> budgets = const [],
    Iterable<SubscriptionPlan> subscriptions = const [],
    Map<String, ReceiptDraft> receipts = const {},
    Iterable<FinancialNotice> notices = const [],
    Set<String> noticeReadIds = const {},
    Map<String, TransactionCategory> merchantRules = const {},
    Set<String> dismissedRecurringKeys = const {},
    this.preferences = const UserPreferences(),
    this.sync = const SyncMetadata(),
  }) : accounts = List.unmodifiable(accounts),
       ledger = List.unmodifiable(ledger),
       budgets = List.unmodifiable(budgets),
       subscriptions = List.unmodifiable(subscriptions),
       receipts = Map.unmodifiable(receipts),
       notices = List.unmodifiable(notices),
       noticeReadIds = Set.unmodifiable(noticeReadIds),
       merchantRules = Map.unmodifiable(merchantRules),
       dismissedRecurringKeys = Set.unmodifiable(dismissedRecurringKeys) {
    validate();
  }
  final int revision;
  final List<FinancialAccount> accounts;
  final List<TransactionRecord> ledger;
  final List<SpendingBudget> budgets;
  final List<SubscriptionPlan> subscriptions;
  final Map<String, ReceiptDraft> receipts;
  final List<FinancialNotice> notices;
  final Set<String> noticeReadIds, dismissedRecurringKeys;
  final Map<String, TransactionCategory> merchantRules;
  final UserPreferences preferences;
  final SyncMetadata sync;

  void validate() {
    preferences.validate();
    if (revision < 0) throw const FormatException('Invalid revision.');
    void unique(Iterable<String> ids) {
      final list = ids.toList();
      if (list.any((id) => id.trim().isEmpty) ||
          list.toSet().length != list.length) {
        throw const FormatException('Duplicate or empty record identity.');
      }
    }

    unique(accounts.map((v) => v.id));
    unique(ledger.map((v) => v.id));
    unique(budgets.map((v) => v.id));
    unique(subscriptions.map((v) => v.id));
    unique(notices.map((v) => v.id));
    unique(notices.map((v) => v.conditionKey));
    final byId = {for (final a in accounts) a.id: a};
    if (accounts.any((a) => a.currency != preferences.currency) ||
        !notices.map((n) => n.id).toSet().containsAll(noticeReadIds)) {
      throw const FormatException('Inconsistent workspace references.');
    }
    for (final t in ledger) {
      if (t.amount <= 0 ||
          t.amount > maxMoney ||
          t.merchant.trim().isEmpty ||
          t.merchant.length > 100 ||
          t.note.length > 2000 ||
          !byId.containsKey(t.accountId) ||
          (t.kind == TransactionKind.transfer &&
              (!byId.containsKey(t.destinationAccountId) ||
                  t.accountId == t.destinationAccountId)) ||
          (t.kind != TransactionKind.transfer &&
              t.destinationAccountId != null)) {
        throw const FormatException(
          'Invalid transaction or account association.',
        );
      }
    }
    final transactions = {for (final t in ledger) t.id: t};
    for (final e in receipts.entries) {
      final t = transactions[e.key];
      if (t == null ||
          !t.hasReceipt ||
          t.source != TransactionSource.receipt ||
          e.value.savedTransactionId != e.key ||
          e.value.total != t.amount ||
          e.value.accountId != t.accountId ||
          e.value.validationError != null) {
        throw const FormatException('Invalid receipt association.');
      }
    }
    if (merchantRules.keys.any((k) => k.trim().isEmpty || k.length > 100)) {
      throw const FormatException('Invalid categorization rule.');
    }
  }

  FinanceWorkspace copyWith({
    int? revision,
    Iterable<FinancialAccount>? accounts,
    Iterable<TransactionRecord>? ledger,
    Iterable<SpendingBudget>? budgets,
    Iterable<SubscriptionPlan>? subscriptions,
    Map<String, ReceiptDraft>? receipts,
    Iterable<FinancialNotice>? notices,
    Set<String>? noticeReadIds,
    Map<String, TransactionCategory>? merchantRules,
    Set<String>? dismissedRecurringKeys,
    UserPreferences? preferences,
    SyncMetadata? sync,
  }) => FinanceWorkspace(
    revision: revision ?? this.revision,
    accounts: accounts ?? this.accounts,
    ledger: ledger ?? this.ledger,
    budgets: budgets ?? this.budgets,
    subscriptions: subscriptions ?? this.subscriptions,
    receipts: receipts ?? this.receipts,
    notices: notices ?? this.notices,
    noticeReadIds: noticeReadIds ?? this.noticeReadIds,
    merchantRules: merchantRules ?? this.merchantRules,
    dismissedRecurringKeys:
        dismissedRecurringKeys ?? this.dismissedRecurringKeys,
    preferences: preferences ?? this.preferences,
    sync: sync ?? this.sync,
  );
}

/// Revisions are scoped to the authenticated owner; no tokens enter the database.
class SyncMetadata {
  const SyncMetadata({
    this.ownerId,
    this.serverRevision = 0,
    this.lastSyncedAt,
    this.localRevisionAtSync = 0,
  });
  final String? ownerId;
  final int serverRevision, localRevisionAtSync;
  final DateTime? lastSyncedAt;
  Json toJson() => {
    'ownerId': ownerId,
    'serverRevision': serverRevision,
    'localRevisionAtSync': localRevisionAtSync,
    'lastSyncedAt': lastSyncedAt?.toIso8601String(),
  };
  factory SyncMetadata.fromJson(Json json) => SyncMetadata(
    ownerId: json['ownerId'] as String?,
    serverRevision: jsonInt(json, 'serverRevision', min: 0),
    localRevisionAtSync: jsonInt(json, 'localRevisionAtSync', min: 0),
    lastSyncedAt: json['lastSyncedAt'] == null
        ? null
        : jsonDate(json, 'lastSyncedAt'),
  );
}

abstract interface class FinanceRepository {
  Future<FinanceWorkspace> load();

  /// Reject stale writers. Returns the durable state with its next revision.
  Future<FinanceWorkspace> save(
    FinanceWorkspace workspace, {
    required int expectedRevision,
  });
  Future<void> close();
}

class WorkspaceConflict implements Exception {
  const WorkspaceConflict();
}
