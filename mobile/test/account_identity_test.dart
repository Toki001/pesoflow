import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pesoflow/app/app.dart';
import 'package:pesoflow/features/accounts/data/account_fixture.dart';
import 'package:pesoflow/features/accounts/data/ledger_account_fixture.dart';
import 'package:pesoflow/features/accounts/domain/account_activity.dart';
import 'package:pesoflow/features/accounts/domain/ledger_account.dart';
import 'package:pesoflow/features/receipts/data/receipt_fixture.dart';
import 'package:pesoflow/features/transactions/application/transactions_provider.dart';
import 'package:pesoflow/features/transactions/data/transaction_fixture.dart';
import 'package:pesoflow/features/transactions/domain/manual_transaction_draft.dart';
import 'package:pesoflow/features/transactions/domain/transaction.dart';
import 'package:pesoflow/features/transactions/domain/transaction_query.dart';

import 'home_test.dart' show viewport;
import 'transactions_test.dart' show pumpTransactions;

ManualTransactionDraft transferDraft(
  LedgerAccount source,
  LedgerAccount target,
) => ManualTransactionDraft(
  amount: 500000,
  merchant: 'Transfer',
  account: source.label,
  accountId: source.id,
  destinationAccount: target.label,
  destinationAccountId: target.id,
  occurredAt: demoClock,
  kind: TransactionKind.transfer,
  category: TransactionCategory.transfer,
);

void main() {
  test(
    'every fixture reference resolves uniquely; product IDs match profiles',
    () {
      final accounts = DemoLedgerAccounts.all;
      expect(accounts.map((a) => a.id).toSet().length, accounts.length);
      expect(
        accounts.every((a) => a.id.isNotEmpty && a.label.isNotEmpty),
        true,
      );
      for (final profile in accountFixture()) {
        expect(DemoLedgerAccounts.byId(profile.id), isNotNull);
      }
      for (final t in transactionFixture()) {
        expect(DemoLedgerAccounts.byId(t.accountId!), isNotNull);
        if (t.kind == TransactionKind.transfer) {
          expect(DemoLedgerAccounts.byId(t.destinationAccountId!), isNotNull);
          expect(t.accountId, isNot(t.destinationAccountId));
        } else {
          expect(t.destinationAccountId, isNull);
        }
      }
      expect(
        () => accounts.add(DemoLedgerAccounts.cash),
        throwsUnsupportedError,
      );
    },
  );

  test('renaming labels and colliding institution labels cannot change association', () {
    final originals = transactionFixture();
    final renamed = [
      for (final t in originals)
        t.copyWith(
          account: 'Same display name',
          destinationAccount: t.kind == TransactionKind.transfer
              ? 'Same display name'
              : null,
        ),
    ];
    for (final account in DemoLedgerAccounts.all) {
      expect(
        accountActivity(account.id, renamed).map((t) => t.id),
        accountActivity(account.id, originals).map((t) => t.id),
      );
    }
    expect(accountActivity('bdo', renamed).map((t) => t.id), ['salary']);
    expect(accountActivity('bdo-savings', renamed).map((t) => t.id), [
      'transfer',
    ]);
    expect(accountActivity('bdo-debit', renamed).map((t) => t.id), [
      'starbucks',
    ]);
    expect(accountActivity('bdo-credit', renamed).map((t) => t.id), [
      'supermarket',
    ]);
  });

  test('source and receiving account filters each include a transfer once', () {
    final t = transactionFixture().firstWhere(
      (t) => t.kind == TransactionKind.transfer,
    );
    for (final id in [t.accountId!, t.destinationAccountId!]) {
      final filtered = filterTransactions([t], TransactionQuery(accountId: id));
      expect(filtered.single.id, 'transfer');
      expect(filtered.single.expenseImpact, 0);
      expect(filtered.single.cashFlowImpact, 0);
    }
    expect(
      filterTransactions([t], const TransactionQuery(accountId: 'bdo')),
      isEmpty,
    );
    expect(
      accountActivity('gcash', [t.copyWith(accountId: 'gcash')]),
      hasLength(1),
    );
    expect(
      t.copyWith(kind: TransactionKind.expense).involvesAccount('gcash'),
      false,
    );
  });

  test(
    'JSON round trips retain source/destination IDs and display snapshots',
    () {
      for (final t in transactionFixture()) {
        expect(TransactionRecord.fromJson(t.toJson()), t);
      }
      final t = transactionFixture().firstWhere(
        (t) => t.kind == TransactionKind.transfer,
      );
      expect(t.toJson()['accountId'], 'bdo-savings');
      expect(t.toJson()['destinationAccountId'], 'gcash');
    },
  );

  test(
    'legacy and unknown references never fall back to institution labels',
    () {
      final json = transactionFixture().first.toJson()
        ..remove('accountId')
        ..remove('destinationAccountId');
      final legacy = TransactionRecord.fromJson(json);
      expect(legacy.account, 'GCash');
      expect(legacy.accountId, isNull);
      expect(accountActivity('gcash', [legacy]), isEmpty);
      expect(
        filterTransactions([
          legacy,
        ], const TransactionQuery(accountId: 'gcash')),
        isEmpty,
      );
      expect(filterTransactions([legacy], const TransactionQuery()), [legacy]);
      final unknown = legacy.copyWith(accountId: 'unresolved-id');
      expect(accountActivity('gcash', [unknown]), isEmpty);
      expect(unknown.involvesAccount(''), false);
      expect(unknown.involvesAccount('  '), false);
    },
  );

  test('manual transfers compare identity rather than labels', () {
    final sameIdRenamed = LedgerAccount(
      id: DemoLedgerAccounts.gcash.id,
      label: 'Renamed wallet',
    );
    expect(
      () => transferDraft(
        DemoLedgerAccounts.gcash,
        sameIdRenamed,
      ).toRecord('same-id'),
      throwsArgumentError,
    );
    final differentIdSameLabel = LedgerAccount(
      id: DemoLedgerAccounts.maya.id,
      label: DemoLedgerAccounts.gcash.label,
    );
    final t = transferDraft(
      DemoLedgerAccounts.gcash,
      differentIdSameLabel,
    ).toRecord('distinct');
    expect(t.accountId, 'gcash');
    expect(t.destinationAccountId, 'maya');
    expect(t.expenseImpact, 0);
    expect(
      () => transferDraft(
        const LedgerAccount(id: '', label: 'GCash'),
        DemoLedgerAccounts.maya,
      ).toRecord('missing-source'),
      throwsArgumentError,
    );
    expect(
      () => transferDraft(
        DemoLedgerAccounts.gcash,
        const LedgerAccount(id: '', label: 'Maya'),
      ).toRecord('missing-target'),
      throwsArgumentError,
    );
  });

  test('receipt validates identity separately from its label', () {
    final draft = receiptFixture();
    expect(draft.accountId, 'gcash');
    expect(
      draft.copyWith(accountId: '').validationError,
      'Choose a payment source.',
    );
    expect(draft.copyWith(account: 'Renamed wallet').accountId, 'gcash');
  });

  testWidgets(
    'account picker selects receiving-only identity and filters transfers',
    (tester) async {
      viewport(tester, const Size(420, 1300));
      await pumpTransactions(tester);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(PesoFlowApp)),
      );
      final t = transactionFixture()
          .firstWhere((t) => t.kind == TransactionKind.transfer)
          .copyWith(
            destinationAccountId: 'receiving-only',
            destinationAccount: 'Receiving wallet',
          );
      container.read(demoLedgerProvider.notifier).update(t);
      await tester.pumpAndSettle();
      await tester.drag(find.text('Transfers'), const Offset(-500, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Accounts (GCash, BDO, Maya)'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.widgetWithText(ListTile, 'Receiving wallet'),
      );
      await tester.tap(find.widgetWithText(ListTile, 'Receiving wallet'));
      await tester.pumpAndSettle();
      expect(
        container.read(transactionQueryProvider).accountId,
        'receiving-only',
      );
      expect(find.text('BDO Savings → GCash'), findsOneWidget);
      expect(find.text('Jollibee'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
