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


`SubscriptionPlan` is immutable session tracking metadata: service ID/name,
positive integer-centavo price, weekly/monthly/quarterly/yearly billing cycle,
expected next renewal, sample payment-source label, category, active/paused flag,
fixture/manual provenance and optional detection confidence (unknown in this demo).
`SubscriptionOverview` validates unique IDs, exposes a read-only plan list and
projects exact annualized/normalized monthly commitments from active plans only.
Equivalent cost uses 52/12/4/1 annual payments and rounds half-up once to the nearest centavo for display after
summing exact annual centavos. It does not advance dates or infer provider charges.

Sorting is by expected date, name or annualized amount with an ID tie-breaker.
The four earliest active dates form the timeline. The storage tip is conditional
on both unedited original cloud fixtures being active. Plans never mutate ledger
records; history filters existing posted recurring expense records and retains
transaction provenance. There is no recurring-detection, persistence, subscription
API or remote cancellation contract yet. Model edits withdraw fixture provenance.


`ReceiptItem` records immutable ID/name, whole quantity, integer-centavo unit
price, optional sample confidence and explicit reviewed state. `ReceiptDraft`
records merchant/date, read-only uniquely identified items, expense category,
sample payment source and optional saved transaction ID. Unknown/below-90%
confidence needs explicit review. Reviewed corrections retain sample confidence.
Subtotal/total sum quantity × price; sample included VAT uses gross × 12/112 with
half-up rounding. It assumes uniform sample tax treatment and is never an extra
charge. Real discounts/mixed taxes/receipt matching are not modeled yet.

`receiptReviewProvider` holds editable session state. `savedDemoReceiptsProvider`
holds read-only reviewed snapshots keyed by ledger transaction ID. Save creates
one posted expense with source `receipt`, `hasReceipt` and demo provenance note;
it does not represent a stored photograph or OCR file. The stable sample ID makes
repeated save/reload return that same transaction, with the saved review read-only.
Item edits update only the review until save; removal/discard/reload never deletes
posted expenses. Transaction Detail reads the saved item snapshot. These transient
models add no backend API, JSON, persistence or actual image-storage contract.


`OnboardingStep` is an enum (`overview`, `plans`, `demo`) controlled by a bounded
Riverpod notifier. It retains the current introduction step only within the
active ProviderScope; fresh sessions start at overview. Skip selects demo,
Next/Back stop at their respective boundaries. Previews read existing immutable
Home fixtures rather than duplicating financial data. Entering or revisiting the
introduction never resets the demo ledger. No JSON, database, user identity,
authentication session or consent record is introduced.


`Appearance` contains `system`, `light` and `dark`; `settingsProvider` holds the
selected enum for the active ProviderScope. It defaults to system and can restore
that default without changing financial providers. The app maps the preference
to `ThemeMode` at the presentation boundary. It introduces no JSON, disk storage,
backend contract, identity or authentication state. The Settings introduction
link resets only `onboardingProvider`; other session data remains untouched.


`DemoNotice` records immutable ID/title/message, sample event date, `NoticeKind`
and a typed `NoticeDestination`. The enum limits destinations to budgets,
subscriptions, accounts and analytics; it does not accept arbitrary external
URLs. The asynchronous loader validates nonempty/unique IDs and returns an
unmodifiable newest-first list (ID breaks timestamp ties). Monetary text is
formatted from integer-centavo fixture values using the central formatter.

`noticeReadProvider` stores an unmodifiable set of read IDs separately from the
loaded inbox. Individual actions validate membership, bulk-read covers known
items, and repeated actions do not duplicate IDs. Read state survives reloads
and defaults to the sample read set on fresh sessions. `noticeFilterProvider`
selects All/Unread; unread count is derived from loaded notices and read IDs.
There is no financial mutation, serialization, persistence, notification token
or delivery/event contract. Fixed snapshots do not recompute after demo edits.


`AccountDetail` holds a `DemoAccount` and an unmodifiable newest-first activity
list. `accountDetailProvider(id)` projects the current account overview plus
ledger and returns null for missing/removed IDs. An explicit fixture alias map
associates gcash→GCash, maya→Maya, bdo→BDO Checking and bpi→BPI Savings. Source
and destination membership include transfers once; institution-name prefix
matching is deliberately absent. Other BDO products are separate fixture sources.
Manual ledger edits update related activity without recalculating or advancing
reported profile balances/timestamps. This local alias bridge introduces no JSON,
provider identity, storage or API contract; real association requires stable
financial account IDs during the domain/persistence milestone.
