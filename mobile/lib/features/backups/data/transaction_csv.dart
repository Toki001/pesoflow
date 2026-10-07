import 'dart:convert';
import 'dart:typed_data';

import '../../workspace/domain/finance_workspace.dart';

/// Readable transaction export, not a restorable backup. Integer centavos remain
/// explicit; quoting protects delimiters and apostrophes neutralize formulas.
Uint8List transactionCsv(FinanceWorkspace w) {
  String text(String value) {
    final safe = RegExp(r'^[\s]*[=+\-@\t\r\n]').hasMatch(value)
        ? "'$value"
        : value;
    return '"${safe.replaceAll('"', '""')}"';
  }

  final rows = <String>[
    'id,date,kind,status,merchant,amount_minor,currency,account_id,account,destination_account_id,destination_account,category,source,excluded_from_budget,note,tags',
    for (final t in w.ledger)
      [
        t.id,
        t.occurredAt.toIso8601String(),
        t.kind.name,
        t.status.name,
        t.merchant,
        t.amount.toString(),
        w.preferences.currency,
        t.accountId ?? '',
        t.account,
        t.destinationAccountId ?? '',
        t.destinationAccount ?? '',
        t.category.name,
        t.source.name,
        t.excludedFromBudget.toString(),
        t.note,
        jsonEncode(t.tags),
      ].map(text).join(','),
  ];
  return Uint8List.fromList(utf8.encode('\uFEFF${rows.join('\r\n')}\r\n'));
}
