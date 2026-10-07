import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pesoflow/core/identity/new_id.dart';
import 'package:pesoflow/core/time/clock.dart';
import 'package:pesoflow/features/workspace/application/finance_controller.dart';
import 'package:pesoflow/features/transactions/domain/transaction.dart';
import 'package:pesoflow/features/transactions/domain/manual_transaction_draft.dart';
import 'package:pesoflow/features/transactions/domain/transaction_query.dart';

class LedgerController extends Notifier<List<TransactionRecord>> {
  @override
  List<TransactionRecord> build() => ref.watch(workspaceProvider).ledger;
  Future<void> createManual(ManualTransactionDraft draft) => ref
      .read(financeControllerProvider.notifier)
      .saveTransaction(draft.toRecord(newId()), rememberCategory: true);
  Future<void> update(TransactionRecord record) => ref
      .read(financeControllerProvider.notifier)
      .saveTransaction(record, editing: true, rememberCategory: true);
  Future<void> remove(String id) =>
      ref.read(financeControllerProvider.notifier).deleteTransaction(id);
}

final ledgerProvider =
    NotifierProvider<LedgerController, List<TransactionRecord>>(
      LedgerController.new,
    );
final transactionsProvider = FutureProvider<List<TransactionRecord>>(
  (ref) async => ref.watch(ledgerProvider),
  retry: (_, _) => null,
);

class QueryController extends Notifier<TransactionQuery> {
  @override
  TransactionQuery build() {
    final now = ref.read(clockProvider)();
    return TransactionQuery(year: now.year, month: now.month);
  }

  void set(TransactionQuery query) => state = query;
}

final transactionQueryProvider =
    NotifierProvider<QueryController, TransactionQuery>(QueryController.new);
