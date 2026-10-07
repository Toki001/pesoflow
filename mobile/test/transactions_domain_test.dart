import 'package:flutter_test/flutter_test.dart';
import 'package:pesoflow/features/transactions/domain/transaction.dart';
import 'package:pesoflow/features/transactions/domain/transaction_query.dart';
import 'package:pesoflow/features/transactions/domain/manual_transaction_draft.dart';

import 'fixtures/features/transactions/data/transaction_fixture.dart';

void main() {
  test(
    'search, month and account filters combine; records sort newest first',
    () {
      final records = transactionFixture();
      expect(
        filterTransactions(
          records,
          const TransactionQuery(year: 2024, month: 10, search: '325'),
        ).single.id,
        'jollibee',
      );
      expect(
        filterTransactions(
          records,
          const TransactionQuery(year: 2024, month: 10, search: 'chickenjoy'),
        ).single.id,
        'jollibee',
      );
      expect(
        filterTransactions(
          records,
          const TransactionQuery(year: 2024, month: 9),
        ),
        isEmpty,
      );
      expect(
        filterTransactions(
          records,
          const TransactionQuery(
            year: 2024,
            month: 10,
            accountId: 'maya',
            filter: TransactionFilter.expenses,
          ),
        ).single.id,
        'grab',
      );
      expect(
        filterTransactions(
          records,
          const TransactionQuery(
            year: 2024,
            month: 10,
            filter: TransactionFilter.pending,
          ),
        ).single.id,
        'starbucks',
      );
      expect(
        filterTransactions(
          records,
          const TransactionQuery(year: 2024, month: 10),
        ).first.id,
        'jollibee',
      );
      expect(groupTransactions(records).length, 4);
    },
  );
  test('internal transfers and pending expenses do not inflate cash flow', () {
    final records = transactionFixture();
    final yesterday = records.where((t) => t.occurredAt.day == 23);
    expect(yesterday.fold(0, (sum, t) => sum + t.cashFlowImpact), -18000);
    expect(records.firstWhere((t) => t.id == 'starbucks').expenseImpact, 0);
    final refund = records.firstWhere((t) => t.id == 'refund');
    expect(refund.expenseImpact, -45000);
    expect(refund.cashFlowImpact, 45000);
    expect(TransactionRecord.fromJson(refund.toJson()), refund);
  });
  test('PHP entry is exact and rejects malformed, negative, zero and over-precise amounts', () {
    expect(parsePhpAmount('0.01'), 1);
    expect(parsePhpAmount('325.1'), 32510);
    expect(parsePhpAmount('325.00'), 32500);
    expect(parsePhpAmount('999999999.99'), 99999999999);
    for (final input in [
      '',
      '0',
      '-1',
      '1.234',
      '1..2',
      '1,00',
      'NaN',
      '1000000000',
    ]) {
      expect(parsePhpAmount(input), isNull, reason: input);
    }
  });
}
