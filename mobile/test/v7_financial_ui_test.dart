import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pesoflow/features/accounts/domain/financial_account.dart';
import 'package:pesoflow/features/analytics/domain/analytics_report.dart';
import 'package:pesoflow/features/analytics/domain/payment_source_totals.dart';
import 'package:pesoflow/features/transactions/data/transaction_csv.dart';
import 'package:pesoflow/features/transactions/domain/transaction.dart';

import 'fixtures/finance_workspace_fixture.dart';

void main() {
  test('card metadata and credit limits never inflate ledger balances', () {
    final account = FinancialAccount(
      id: 'card',
      name: 'My card',
      type: AccountType.credit,
      startingBalance: -48000,
      currency: 'PHP',
      createdAt: DateTime(2024),
      creditLimit: 1000000,
      cardNetwork: 'Visa',
      cardLastFour: '1234',
    );
    final loaded = FinancialAccount.fromJson(account.toJson());
    expect(loaded.creditLimit, 1000000);
    expect(loaded.cardLastFour, '1234');
    expect(accountBalance(loaded, []), -48000);
    expect(loaded.copyWith(type: AccountType.bank).creditLimit, isNull);
    expect(
      () => loaded.copyWith(cardLastFour: '4111111111111111'),
      throwsArgumentError,
    );
  });
  test(
    'payment sources net refunds, ignore transfers, pending and future entries',
    () {
      final t = financeFixture().ledger.first.copyWith(
        kind: TransactionKind.expense,
        status: TransactionStatus.posted,
        amount: 10000,
        accountId: 'a',
        occurredAt: DateTime(2024, 10, 10),
      );
      final totals = paymentSourceTotals(
        [
          t,
          t.copyWith(id: 'refund', kind: TransactionKind.refund, amount: 2500),
          t.copyWith(id: 'transfer', kind: TransactionKind.transfer),
          t.copyWith(id: 'pending', status: TransactionStatus.pending),
          t.copyWith(id: 'future', occurredAt: DateTime(2024, 10, 30)),
          t.copyWith(id: 'prior', occurredAt: DateTime(2024, 9, 10)),
          t.copyWith(id: 'other', accountId: 'b', account: t.account),
        ],
        AnalyticsSelection(DateTime(2024, 10)),
        DateTime(2024, 10, 24),
      );
      expect(totals, {'a': 7500, 'b': 10000});
    },
  );
  test(
    'CSV export preserves centavos and safely quotes spreadsheet formulas',
    () {
      final w = financeFixture();
      final csv = utf8.decode(
        transactionCsv(
          w.copyWith(
            ledger: [
              w.ledger.first.copyWith(
                merchant: '=SUM(1,2)',
                note: 'A "quoted", note\nnext line',
                amount: 12345,
              ),
            ],
          ),
        ),
      );
      expect(csv, contains('"\'=SUM(1,2)"'));
      expect(csv, contains('"12345"'));
      expect(csv, contains('"A ""quoted"", note\nnext line"'));
      expect(csv, startsWith('id,date,'));
    },
  );
}
