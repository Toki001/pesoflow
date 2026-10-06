import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/transaction_fixture.dart';
import '../domain/transaction.dart';
import '../domain/manual_transaction_draft.dart';
import '../domain/transaction_query.dart';

/// Session-only demo ledger. No provider sync or persistent storage.
class DemoLedger extends Notifier<List<TransactionRecord>> {
  int _sequence = 0;
  void createManual(ManualTransactionDraft draft) {
    final record = draft.toRecord('demo-${++_sequence}');
    add(record);
  }

  @override
  List<TransactionRecord> build() => List.unmodifiable(transactionFixture());
  void add(TransactionRecord record) {
    if (state.any((t) => t.id == record.id)) {
      throw ArgumentError('Duplicate transaction ID.');
    }
    state = List.unmodifiable([record, ...state]);
  }

  void update(TransactionRecord record) => state = List.unmodifiable([
    for (final t in state)
      if (t.id == record.id) record else t,
  ]);
}

final demoLedgerProvider =
    NotifierProvider<DemoLedger, List<TransactionRecord>>(DemoLedger.new);
final transactionsProvider = FutureProvider<List<TransactionRecord>>(
  (ref) async => ref.watch(demoLedgerProvider),
  retry: (_, _) => null,
);

class QueryController extends Notifier<TransactionQuery> {
  @override
  TransactionQuery build() => const TransactionQuery();
  void set(TransactionQuery query) => state = query;
}

final transactionQueryProvider =
    NotifierProvider<QueryController, TransactionQuery>(QueryController.new);
