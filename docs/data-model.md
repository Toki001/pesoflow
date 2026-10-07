# Demo data model

Dashboard, BudgetSnapshot, TransactionRecord and UpcomingBill are immutable
Freezed models with generated JSON serialization. Money is integer centavos;
amount signs are presentation derived from transaction kind. Internal transfers
and income have zero expense impact; refunds offset expenses. This is not a
production ledger or an API contract.

The Home snapshot is fixed at October 24, 2024. Monthly totals are independent
fixture aggregates, not totals computed from the four recent transactions.
Cross-screen Stitch examples contain inconsistent values; see ui-reference.md.
A versioned local demo snapshot now stores activity; provider reconciliation and
salary matching remain unimplemented.

Transactions now own the shared `TransactionRecord`: account/destination,
posted/pending status, manual/bank/wallet/receipt source, note, tags, receipt and
recurring flags, and budget exclusion. Pending records and internal transfers
have zero cash-flow impact; refunds reduce expenses. Budget exclusion affects
`budgetImpact`, independently of `expenseImpact` and `cashFlowImpact`.

The recent feed contains nine records from Stitch. `MonthSnapshot` and Home
projection apply session additions/edits against baseline snapshots, so omitted
history is preserved. `ManualTransactionDraft` validates integer-centavo amounts
(up to ₱999,999,999.99), required merchant/account, and transfer destinations.
The Riverpod ledger is immutable, rejects duplicate IDs and restores its manual
ID sequence from loaded records. Native startup injects saved local activity;
previews/tests default to memory fixtures. Local editing is not provider sync. Financial fields on synced fixtures remain read-only.

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
posted expenses. Transaction Detail reads the saved item snapshot. Saved review
snapshots now serialize into the local activity workspace described below; unsaved
corrections remain transient. There is no backend API or image-storage contract.


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
ledger and returns null for missing/removed profiles. `accountActivity` now lives
in the account domain and matches explicit source/destination IDs. Transfers
include either endpoint once. Label changes do not change association. Manual
ledger edits update related activity without recalculating or advancing reported
profile balances/timestamps.

`demoAccessProvider(id)` holds an ephemeral acknowledgment boolean per sample
profile. Its typed `DemoAccessResult` reports added, acknowledgment required,
already listed or unavailable; these describe local list operations, never
provider consent. It has no serialization, consent record, token, scope, expiry
or backend contract. The guard uses current catalog/account state and delegates
to the existing sample-list mutation; balances, timestamps, connection status
and ledger activity remain unchanged. Auto-disposal resets acknowledgment when
the review closes.

## Stable ledger account identities

`LedgerAccount` separates an internal ID from its display label. The deterministic
catalog keeps existing profile IDs (`gcash`, `maya`, `bdo`, `bpi`) so routes and
session restoration remain compatible. `bdo` identifies Checking only; Debit,
Savings and Credit Card use distinct `bdo-debit`, `bdo-savings` and `bdo-credit`
IDs. `cash` is a manual ledger identity with no provider profile or reported
balance. A ledger identity does not imply an active financial connection.

`TransactionRecord.accountId` and `destinationAccountId` are additive nullable
JSON fields. Existing account/destination strings remain display snapshots.
Every current fixture supplies explicit IDs; JSON without IDs decodes with null
references and is never associated by display/institution name. Such records
remain in the unfiltered feed and aggregate totals. Future storage/import
migration must supply verified references instead of guessing from labels.

Manual drafts require a nonempty source ID, and transfers require a nonempty,
distinct destination ID. Non-transfer saves clear destination labels/IDs.
Receipt drafts require a source ID; picker changes atomically update its ID and
label, retained in both the saved transaction and receipt snapshot. Account
filters store IDs and include incoming/outgoing transfers once. Amounts,
provenance, timestamps, refund/pending/transfer impacts and reported balances
retain their existing semantics. There is no local database, ownership identity,
provider adapter or backend contract in the identity milestone; the subsequent
local activity phase is described below.

## Local demo activity snapshot (v1)

`DemoWorkspace` contains immutable ledger records and a map of saved transaction
IDs to reviewed receipt drafts. Its validator rejects duplicate/empty transaction
IDs, invalid amounts, orphaned receipt snapshots and receipt/source/amount/account
inconsistencies. Receipt entries retain merchant/date, category, source ID/label,
item IDs, descriptions, whole quantities, integer unit prices, confidence and
review flags. Unsaved receipt review corrections remain transient.

The Drift database has schema version 1 and one `demo_snapshots` row (ID 1).
Its JSON envelope has integer `formatVersion: 1` and `fixtureVersion: 1`. The
entire activity snapshot is replaced transactionally, so ledger receipt entries
and their item snapshots cannot be partially committed. Persisted monetary JSON
must be an integer before generated model decoding; fractional values are refused
rather than truncated. Nullable legacy account IDs remain unresolved.

Empty databases seed the deterministic October 2024 samples once. Valid existing
rows load without reseeding. Corrupt payloads or unsupported schema/format/fixture
versions produce recovery UI and leave stored data unchanged. Future fixture
changes must bump/migrate the fixture version because financial projections use
that baseline. This snapshot is an incremental demo format, not a normalized
production schema or backend API contract.

Bootstrap supplies loaded data through provider overrides. The persistence
coordinator coalesces synchronous ledger/receipt publications into one snapshot,
serializes writes, retains the newest snapshot on failure and retries it. A
successful confirmed reset writes original fixtures and empty receipt snapshots
before publishing them to memory; failure preserves current activity. Manual ID
allocation resumes above the maximum restored `demo-N` ID. Reported balances,
sample connection membership, budgets/limits, subscriptions, appearance,
notification read state and onboarding progress are not stored in this phase.


## Local plans snapshot (workspace v2)

Workspace v2 adds `budgets: {version: 1, plans: {periodKey: BudgetPlan JSON}}`
and `subscriptions: {version: 1, plans: [SubscriptionPlan JSON]}`. The entire
workspace still occupies the singleton row in SQLite schema v1. Valid workspace
v1 rows migrate transactionally; ledger and reviewed receipts remain unchanged,
while plans seed from the approved fixtures. Unknown versions, invalid payloads
and failed migration writes preserve the original row.

Budget storage retains base spending/forecast offsets, monthly/category limits,
description, fixed/settled flags and edited-category markers across all created
months. Ledger-derived projections are recomputed after loading and never saved
as base values. Stored keys must match year/month, category allocations must fit
the monthly limit, and categories/edited references must be consistent. Integer
money/calendar fields are validated before generated JSON decoding can truncate.

Subscriptions retain ID, service name, exact amount, billing cycle, canonical ISO
renewal date, payment-source label, category, active state, provenance and optional
confidence. Payment sources remain descriptive tracking labels, not provider
account grants. All four billing cycles survive restart; empty tracking lists do
not reseed. Renewal tracking never creates ledger entries. Restored manual IDs
advance allocation above surviving `subscription-demo-N` records.

Reset activity preserves plans; reset plans preserves activity. Only the startup
recovery reset replaces all stored collections, with explicit confirmation.
Appearance, filters/sorts, selected periods, dismissed suggestions, notification
read state, onboarding and sample connections remain session-only.


## Demo preferences (workspace v3)

`preferences: {version: 1, appearance: "system" | "light" | "dark",
introductionCompleted: bool}` joins the atomic workspace. Unknown versions/enums,
missing required values and non-boolean completion are refused. Valid v1/v2
snapshots migrate with default preferences; all previously stored collections are
preserved. SQLite schema and fixture versions stay at 1.

Only explicit Explore demo sets completion. It records a device navigation choice,
not identity, consent or permission. Step progress, notification reads, account
membership, filters/sorts and selected periods stay transient. Reset activity and
reset plans preserve preferences; Restore device appearance saves only System;
startup full recovery reset restores both preferences and all financial samples.
