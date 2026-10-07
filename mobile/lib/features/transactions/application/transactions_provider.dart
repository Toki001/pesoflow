import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../demo_workspace/application/demo_workspace_providers.dart';

import '../data/transaction_fixture.dart';
import '../domain/transaction.dart';
import '../domain/manual_transaction_draft.dart';
import '../domain/transaction_query.dart';

/// Demo ledger; production bootstrap restores it from the local repository.
class DemoLedger extends Notifier<List<TransactionRecord>> {
  int _sequence = 0;
  void createManual(ManualTransactionDraft draft) {
    final record = draft.toRecord('demo-${++_sequence}');
    add(record);
  }

  @override
  List<TransactionRecord> build() {
    final records =
        ref.watch(initialDemoWorkspaceProvider)?.ledger ?? transactionFixture();
    _restoreSequence(records);
    return List.unmodifiable(records);
  }

  void _restoreSequence(List<TransactionRecord> records) {
    _sequence = 0;
    for (final record in records) {
      final match = RegExp(r'^demo-(\d+)$').firstMatch(record.id);
      final sequence = match == null ? 0 : int.parse(match[1]!);
      if (sequence > _sequence) _sequence = sequence;
    }
  }

  void restore(List<TransactionRecord> records) {
    _restoreSequence(records);
    state = List.unmodifiable(records);
  }

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
