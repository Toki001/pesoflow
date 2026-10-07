import 'dart:convert';

import '../../../core/serialization/values.dart';
import '../../accounts/domain/financial_account.dart';
import '../../budgets/domain/spending_budget.dart';
import '../../notifications/domain/financial_notice.dart';
import '../../receipts/domain/receipt_draft.dart';
import '../../settings/domain/user_preferences.dart';
import '../../subscriptions/data/subscription_plans_codec.dart';
import '../../transactions/domain/transaction.dart';
import '../domain/finance_workspace.dart';

/// Independent from the prototype format: no fixture migration can seed finances.
abstract final class FinanceWorkspaceCodec {
  static const version = 1;
  static String encode(FinanceWorkspace w) {
    w.validate();
    return jsonEncode(toJson(w));
  }

  static Json toJson(FinanceWorkspace w) => {
    'formatVersion': version,
    'revision': w.revision,
    'accounts': w.accounts.map((v) => v.toJson()).toList(),
    'ledger': w.ledger.map((v) => v.toJson()).toList(),
    'budgets': w.budgets.map((v) => v.toJson()).toList(),
    'subscriptions': SubscriptionPlansCodec.encode(w.subscriptions),
    'receipts': {
      for (final e in w.receipts.entries) e.key: receiptToJson(e.value),
    },
    'notices': w.notices.map((v) => v.toJson()).toList(),
    'noticeReadIds': w.noticeReadIds.toList()..sort(),
    'merchantRules': {
      for (final e in w.merchantRules.entries) e.key: e.value.name,
    },
    'dismissedRecurringKeys': w.dismissedRecurringKeys.toList()..sort(),
    'preferences': w.preferences.toJson(),
    'sync': w.sync.toJson(),
  };
  static FinanceWorkspace decode(String payload) =>
      fromJson(jsonDecode(payload) as Json);
  static FinanceWorkspace fromJson(Json json) {
    if (json['formatVersion'] != version || json['formatVersion'] is! int) {
      throw const FormatException('Unsupported financial data version.');
    }
    final ledger = jsonObjects(json, 'ledger').map((t) {
      jsonInt(t, 'amount', min: 1, max: maxMoney);
      jsonDate(t, 'occurredAt');
      return TransactionRecord.fromJson(t);
    }).toList();
    final reads = (json['noticeReadIds'] as List).cast<String>();
    if (reads.toSet().length != reads.length) {
      throw const FormatException('Duplicate notice read marker.');
    }
    return FinanceWorkspace(
      revision: jsonInt(json, 'revision', min: 0),
      accounts: jsonObjects(json, 'accounts').map(FinancialAccount.fromJson),
      ledger: ledger,
      budgets: jsonObjects(json, 'budgets').map(SpendingBudget.fromJson),
      subscriptions: SubscriptionPlansCodec.decode(
        json['subscriptions'] as Json,
      ),
      receipts: {
        for (final e in (json['receipts'] as Json).entries)
          e.key: receiptFromJson(e.value as Json),
      },
      notices: jsonObjects(json, 'notices').map(FinancialNotice.fromJson),
      noticeReadIds: reads.toSet(),
      merchantRules: {
        for (final e in (json['merchantRules'] as Json).entries)
          e.key: TransactionCategory.values.byName(e.value as String),
      },
      dismissedRecurringKeys: (json['dismissedRecurringKeys'] as List)
          .cast<String>()
          .toSet(),
      preferences: UserPreferences.fromJson(json['preferences'] as Json),
      sync: SyncMetadata.fromJson(json['sync'] as Json),
    );
  }

  static Json receiptToJson(ReceiptDraft d) => {
    'id': d.id,
    'merchant': d.merchant,
    'account': d.account,
    'accountId': d.accountId,
    'occurredAt': d.occurredAt.toIso8601String(),
    'category': d.category.name,
    'savedTransactionId': d.savedTransactionId,
    'items': [
      for (final i in d.items)
        {
          'id': i.id,
          'name': i.name,
          'detail': i.detail,
          'quantity': i.quantity,
          'unitPrice': i.unitPrice,
          'confidence': i.confidence,
          'reviewed': i.reviewed,
        },
    ],
  };
  static ReceiptDraft receiptFromJson(Json d) => ReceiptDraft(
    id: jsonString(d, 'id'),
    merchant: jsonString(d, 'merchant', max: 100),
    account: jsonString(d, 'account'),
    accountId: jsonString(d, 'accountId'),
    occurredAt: jsonDate(d, 'occurredAt'),
    category: TransactionCategory.values.byName(d['category'] as String),
    savedTransactionId: d['savedTransactionId'] as String?,
    items: [
      for (final i in jsonObjects(d, 'items'))
        ReceiptItem(
          id: jsonString(i, 'id'),
          name: jsonString(i, 'name'),
          detail: jsonString(i, 'detail', empty: true),
          quantity: jsonInt(i, 'quantity', min: 1, max: 999),
          unitPrice: jsonInt(i, 'unitPrice', min: 1, max: maxMoney),
          confidence: i['confidence'] == null
              ? null
              : jsonInt(i, 'confidence', min: 0, max: 100),
          reviewed: i['reviewed'] as bool,
        ),
    ],
  );
}
