import 'dart:convert';

import '../../features/notifications/data/notice_read_codec.dart';
import '../../../fixtures/features/notifications/data/notification_fixture.dart';
import '../../features/settings/data/demo_preferences_codec.dart';
import '../../features/settings/domain/demo_preferences.dart';
import '../../../fixtures/features/budgets/data/budget_fixture.dart';

import 'package:pesoflow/features/budgets/data/budget_plans_codec.dart';

import '../../../fixtures/features/subscriptions/data/subscription_fixture.dart';

import 'package:pesoflow/features/subscriptions/data/subscription_plans_codec.dart';

import '../../features/demo_workspace/domain/demo_workspace.dart';

import 'package:pesoflow/features/receipts/domain/receipt_draft.dart';
import 'package:pesoflow/features/transactions/domain/transaction.dart';

/// Versioned, exact-centavo demo snapshot. No labels are converted into IDs.
abstract final class DemoWorkspaceCodec {
  static String encode(DemoWorkspace workspace) => jsonEncode({
    'formatVersion': 4,
    'fixtureVersion': 1,
    'noticeReadState': NoticeReadCodec.encode(workspace.noticeReadIds),
    'preferences': DemoPreferencesCodec.encode(workspace.preferences),
    'budgets': BudgetPlansCodec.encode(workspace.budgets),
    'subscriptions': SubscriptionPlansCodec.encode(workspace.subscriptions),
    'ledger': [for (final t in workspace.ledger) t.toJson()],
    'receipts': {
      for (final e in workspace.receipts.entries) e.key: _receiptJson(e.value),
    },
  });

  static bool needsMigration(String payload) =>
      (jsonDecode(payload) as Map<String, dynamic>)['formatVersion'] != 4;

  static DemoWorkspace decode(String payload) {
    final json = jsonDecode(payload) as Map<String, dynamic>;
    if (json['formatVersion'] is! int ||
        json['fixtureVersion'] is! int ||
        ![1, 2, 3, 4].contains(json['formatVersion']) ||
        json['fixtureVersion'] != 1) {
      throw const FormatException('Unsupported demo format.');
    }
    final ledger = <TransactionRecord>[];
    for (final value in json['ledger'] as List) {
      final t = value as Map<String, dynamic>;
      // Generated JSON decoding accepts num.toInt(); never truncate persisted money.
      if (t['amount'] is! int) throw const FormatException('Invalid centavos.');
      ledger.add(TransactionRecord.fromJson(t));
    }
    return DemoWorkspace(
      ledger: ledger,
      noticeReadIds: json['formatVersion'] == 4
          ? NoticeReadCodec.decode(
              json['noticeReadState'] as Map<String, dynamic>,
            )
          : initialNoticeReadIds,
      preferences: (json['formatVersion'] as int) >= 3
          ? DemoPreferencesCodec.decode(
              json['preferences'] as Map<String, dynamic>,
            )
          : const DemoPreferences(),
      budgets: json['formatVersion'] == 1
          ? {budgetFixture().key: budgetFixture()}
          : BudgetPlansCodec.decode(json['budgets'] as Map<String, dynamic>),
      subscriptions: json['formatVersion'] == 1
          ? subscriptionFixture()
          : SubscriptionPlansCodec.decode(
              json['subscriptions'] as Map<String, dynamic>,
            ),
      receipts: {
        for (final e in (json['receipts'] as Map<String, dynamic>).entries)
          e.key: _receiptFromJson(e.value as Map<String, dynamic>),
      },
    );
  }

  static Map<String, dynamic> _receiptJson(ReceiptDraft d) => {
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
  static ReceiptDraft _receiptFromJson(Map<String, dynamic> d) => ReceiptDraft(
    id: d['id'] as String,
    merchant: d['merchant'] as String,
    account: d['account'] as String,
    accountId: d['accountId'] as String,
    occurredAt: DateTime.parse(d['occurredAt'] as String),
    category: TransactionCategory.values.byName(d['category'] as String),
    savedTransactionId: d['savedTransactionId'] as String?,
    items: [
      for (final value in d['items'] as List)
        _itemFromJson(value as Map<String, dynamic>),
    ],
  );
  static ReceiptItem _itemFromJson(Map<String, dynamic> i) => ReceiptItem(
    id: i['id'] as String,
    name: i['name'] as String,
    detail: i['detail'] as String,
    quantity: i['quantity'] as int,
    unitPrice: i['unitPrice'] as int,
    confidence: i['confidence'] as int?,
    reviewed: i['reviewed'] as bool,
  );
}
