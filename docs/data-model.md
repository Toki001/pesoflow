# Fixture data model

Dashboard, BudgetSnapshot, TransactionRecord and UpcomingBill are immutable
Freezed models with generated JSON serialization. Money is integer centavos;
amount signs are presentation derived from transaction kind. Internal transfers
and income have zero expense impact; refunds offset expenses. This is not a
production ledger or an API contract.

The Home snapshot is fixed at October 24, 2024. Monthly totals are independent
fixture aggregates, not totals computed from the four recent transactions.
Cross-screen Stitch examples contain inconsistent values; see ui-reference.md.
No database schema, migrations, reconciliation or salary matching exists yet.

Transactions now own the shared `TransactionRecord`: account/destination,
posted/pending status, manual/bank/wallet/receipt source, note, tags, receipt and
recurring flags, and budget exclusion. Pending records and internal transfers
have zero cash-flow impact; refunds reduce expenses. Budget exclusion affects
`budgetImpact`, independently of `expenseImpact` and `cashFlowImpact`.

The recent feed contains nine records from Stitch. `MonthSnapshot` and Home
projection apply session additions/edits against baseline snapshots, so omitted
history is preserved. `ManualTransactionDraft` validates integer-centavo amounts
(up to ₱999,999,999.99), required merchant/account, and transfer destinations.
The Riverpod ledger is immutable and session-only, rejects duplicate IDs and
generates monotonically increasing demo IDs. Local editing is not provider sync
or persistent storage. Financial fields on synced fixtures remain read-only.
