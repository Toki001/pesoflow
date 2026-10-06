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

`BudgetPlan` and `BudgetAllowance` now model period, monthly/category limits,
qualifying spend, fixed/settled status, projected additional spend and explicit
session category edits. `projectBudgetLedger` applies immutable baseline deltas;
allowance editing never persists projected spending again. Creation includes
known spend for newly tracked categories. Filters use risk status rather than
label colors, and settled/fixed allowances become exceeded when fully used.

`Dashboard.budgetSpent` is distinct from cash outflow. Account transfers and
pending records have zero budget impact; refunds offset spend; user exclusions
change budgets while retaining expense/cash-flow semantics. Limits are shared
across budget, entry, detail and Home views once explicitly edited. Initial
Stitch cross-screen variants remain until then. No backend schema/API contract changed.

`AnalyticsSelection` defines calendar ranges and prior periods. Computed immutable
`AnalyticsReport`, `AnalyticsCategoryTotal`, `MerchantTotal`, `SpendingPoint` and
`ExpenseComparison` use integer-centavo money and read-only lists. No JSON or
storage contract is needed for these transient report values. `AnalyticsReference`
is the explicit data-layer input to domain projection; domain logic does not
import fixtures or Flutter.

October Month/Year aggregates preserve omitted history using baseline deltas.
Other ranges aggregate known records. Analytics uses expense impact independently
of budget exclusion. Category totals sum to net expense, refunds stay signed,
merchant ranking excludes nonpositive net totals, and undefined percentage change
has a null value. The September comparison aggregate, October category trend
badges, narrative and trajectory are separate illustrative reference inputs;
there is no reconciled prior-period category history. See architecture.md for
coverage and forecast limitations. No backend data model/API changed.

`DemoAccount` stores a sample ID/institution/name, masked identifier, bank/wallet
kind, integer-centavo reported balance, balance-as-of timestamp and active/expired
sample status. No raw identifiers, credentials, tokens or granted permissions are
modeled. `AccountsOverview` validates unique IDs, exposes immutable profiles,
separates available/last-known totals and represents local refresh progress/errors.
`DemoAccountsRepository` loads/checks only fixtures. These session values have no
serialization/backend contract. Demo list changes do not mutate the ledger,
Home snapshot, budgets or manual payment sources; no reported balance is derived
from a manual transaction. Expired BPI remains excluded from available totals.
