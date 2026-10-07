import 'package:pesoflow/core/formatting/money_formatter.dart';
import 'package:pesoflow/features/transactions/domain/transaction.dart';

enum TransactionFilter { all, expenses, income, transfers, pending }

class TransactionQuery {
  const TransactionQuery({
    required this.year,
    required this.month,
    this.search = '',
    this.filter = TransactionFilter.all,
    this.accountId,
    this.category,
  });
  final int year;
  final int month;
  final String search;
  final TransactionFilter filter;
  final String? accountId;
  final TransactionCategory? category;
  TransactionQuery copyWith({
    int? year,
    int? month,
    String? search,
    TransactionFilter? filter,
    String? accountId,
    TransactionCategory? category,
    bool clearAccount = false,
    bool clearCategory = false,
  }) => TransactionQuery(
    year: year ?? this.year,
    month: month ?? this.month,
    search: search ?? this.search,
    filter: filter ?? this.filter,
    accountId: clearAccount ? null : accountId ?? this.accountId,
    category: clearCategory ? null : category ?? this.category,
  );
  bool matches(TransactionRecord t) {
    if (t.occurredAt.year != year || t.occurredAt.month != month) return false;
    if (accountId != null && !t.involvesAccount(accountId!)) return false;
    if (category != null && t.category != category) return false;
    final typeMatch = switch (filter) {
      TransactionFilter.all => true,
      TransactionFilter.expenses => t.kind == TransactionKind.expense,
      TransactionFilter.income => t.kind == TransactionKind.income,
      TransactionFilter.transfers => t.kind == TransactionKind.transfer,
      TransactionFilter.pending => t.status == TransactionStatus.pending,
    };
    final haystack =
        '${t.merchant} ${t.note} ${t.metadata} ${MoneyFormatter.php(t.amount)} ${t.amount ~/ 100}'
            .toLowerCase();
    return typeMatch && haystack.contains(search.trim().toLowerCase());
  }
}

List<TransactionRecord> filterTransactions(
  List<TransactionRecord> records,
  TransactionQuery query,
) =>
    records.where(query.matches).toList()
      ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));

Map<DateTime, List<TransactionRecord>> groupTransactions(
  List<TransactionRecord> records,
) {
  final groups = <DateTime, List<TransactionRecord>>{};
  for (final record in records) {
    final date = record.occurredAt;
    (groups[DateTime(date.year, date.month, date.day)] ??= []).add(record);
  }
  return groups;
}
