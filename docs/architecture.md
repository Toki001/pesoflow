# Foundation architecture

## Current scope

Native Android/iOS Flutter scaffold, shared theme/components, Riverpod state,
GoRouter shell, all nine native Stitch-backed demo screens, onboarding, Settings,
a demo notification center, and a minimal NestJS `/v1/health` endpoint. Drift/SQLite
stores the demo ledger, reviewed receipts, budget plans, subscription tracking,
appearance, completed demo introduction and sample alert read markers. Unfinished
introduction steps and sample connection membership remain transient. No HTML
rendering, WebViews, real provider calls, authentication,
server persistence, queues, camera/OCR, notification delivery or money movement
are implemented. The phase notes below describe earlier implementation boundaries.

`mobile/lib/app` owns composition, navigation and the light/dark design system.
`core` contains presentation primitives, deterministic formatters and a reserved
Dio provider. `features/dashboard` separates domain models/repository contract,
fixture data, Riverpod application state, and presentation. Only folders with
actual responsibilities exist; other feature/module trees are deferred.

The shared transaction widget accepts display values and has no feature-domain
dependency. A dashboard presentation adapter maps domain categories to icon and
color roles. Freezed models have generated JSON serializers and immutable lists;
generated source is retained so checkout analysis works before regeneration.

The repository interface returns `Future<Dashboard?>`: AsyncValue represents
loading/data/error; null represents no overview. Retry is explicit, avoiding
hidden automatic requests. Empty lists have individual messages. Offline and
refresh/sync state machines belong to a future persistence/API implementation;
the current demo works entirely offline after installation.

All money is integer PHP centavos. Display ratios use floating point
for painting/percentage formatting. Recent rows do not sum to the monthly snapshot. Dates are frozen
Philippine wall-time fixture values, initialized with `en_PH` date symbols.
Real event timestamps will require UTC storage and explicit timezone conversion.

GoRouter's indexed stateful shell preserves tab state and Home scroll. Home,
Transactions, Analytics and Budgets are implemented shell destinations.
Add opens `/add` above the shell, Home's balance card opens `/accounts`, and row taps open
`/transactions/:id`; both suppress bottom navigation as approved in Stitch. Close
pops to the originating screen, or goes to Transactions when directly linked.
`/` redirects to Home. OS universal/app-link associations are not configured.

The backend binds localhost and provides a versioned liveness response, Helmet
headers, validation pipe and shutdown handling. Nest module composition is ready
for future features; no speculative provider/data modules were added. Tests use
Node's built-in runner plus Nest testing utilities and Supertest. This avoids
the vulnerable transitive Jest tooling chain found during the initial install.

## Toolchain and dependencies

Validated with Flutter 3.47.5 / Dart 3.13.4; use the same Flutter version for
goldens. Node 22 or later; `package-lock.json` and `pubspec.lock` pin resolution.

Flutter runtime: Riverpod 3, GoRouter 18, Dio 5, Freezed annotations 3,
json_annotation 4, intl 0.20. Dev: Flutter test/lints, build_runner 2,
Freezed 4, json_serializable 6. Inter is a locally bundled variable font under
OFL, downloaded from Google Fonts' `ofl/inter` source. Material icons ship with
Flutter; no runtime font/image network access or chart package is needed.

Backend runtime: NestJS 12, Express adapter, reflect-metadata, RxJS, Helmet,
class-validator and class-transformer. Dev: Nest CLI/testing, TypeScript 6,
ESLint/typescript-eslint, Prettier, Supertest and Node/Supertest type definitions.
No Drift, secure storage, camera, biometrics or messaging SDK until needed.

## Local commands

From `mobile/`:

```sh
flutter pub get
dart run build_runner build
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter run
```

Home uses fixtures regardless of `API_BASE_URL`. The optional Dio provider can
later receive a base URL through `--dart-define=API_BASE_URL=https://.../v1`;
it is not read or instantiated by Home and has no logging interceptor.

From `backend/`:

```sh
npm ci
npm run format:check
npm run lint
npm run build
npm test
npm audit --audit-level=moderate
npm run start:dev
```

Backend default: `http://127.0.0.1:3000/v1/health`. Optional `PORT` is the only
runtime environment variable used. Root `.env.example` entries are reserved for
later phases and are not read; no secrets are required to run this foundation.

From the repository root, `bash scripts/check.sh` runs local formatting,
analysis/build and tests. CI runs mobile tests on macOS (matching the reviewed
golden platform) and backend checks/audit on Linux. Native store signing and
deployment are deferred.

## Golden workflow and visual review

`mobile/test/goldens` contains light/dark 390×1447 full-page captures and a
390×844 light phone capture. Tests load the bundled Inter and Material icon
fonts, use DPR 1 and deterministic data, and make no network calls. Review
changes against the original Stitch screenshot before updating baselines:

```sh
flutter test test/home_test.dart --update-goldens
flutter test
```

These are Flutter-rendered widget screenshots, not an emulator capture and not
pixel comparisons against the Stitch PNG. Exact Flutter/toolchain/OS pinning
limits rasterization variance. Do not replace the golden comparator with a
broad tolerance to mask layout changes.

Visual review corrected the initial greeting/hero offsets, excessive section
gaps, budget spacing, account-count alignment and bottom-bar height. At 390px,
the final hero, summary, insight, budget and recent-transaction section starts
are within approximately 1–6px of the reference. Upcoming Bills starts about
30px lower because native transaction rows preserve whole signed amounts and
wrap metadata/transfer badges. This intentional tradeoff avoids the reference's
isolated plus/minus signs. Initials avatar replaces the unlicensed remote photo;
native Material glyph shapes and text rasterization also differ slightly.

Golden shadows use Flutter's test-mode shadow setting. Platform status/home
indicators are absent in the full-page reference capture; separate widget tests
exercise safe insets. Dark mode extrapolates the approved dark palette because
there is no supplied dark screenshot. Touch targets are at least 48px; 200%
text uses stacked metrics/pairs and a taller navigation bar. Landscape and
320/390/430px phone widths are covered.

## Transactions phase

`features/transactions` owns the shared Freezed transaction model, query/domain
functions, deterministic recent-feed fixture, Riverpod session ledger and native
feed. Dashboard imports the shared model. Search/filtering never changes the
month snapshot. Internal transfers and pending amounts are excluded from cash
flow; refunds reduce expense impact. No backend endpoints were added.

Transaction Detail uses root task routes, preserving feed/Home navigation state.
Annotations live in the session ledger; monthly fixture totals use deltas against
the baseline records to avoid double counting. Budget exclusion does not remove
real spending from cash flow.

Add Expense uses exact decimal parsing, native fields, amount increments, recent
merchants, category and account pickers, date/time selection, and a docked save
action. Expense, Income and Transfer use distinct domain semantics; transfers
retain both accounts and cannot target the source account. All created entries
are manual/posted and assigned unique session IDs. Invalid submissions and rapid
repeat taps do not create records. Hashtags in notes become tags.

Home and month summaries apply ledger deltas against their approved full-period
fixture snapshots, preserving omitted historical totals. Budget exclusion changes
budget utilization only. Reported account balances remain fixture values; saving
a manual record does not invent a provider balance update. Session data is lost
on restart; no storage or provider sync was added. Receipt camera/upload/OCR,
export and issue reporting are explicitly unavailable; split sharing is a preview.

## Budgets phase

`features/budgets` contains immutable Freezed plans/allowances, Stitch fixtures,
ledger projections, Riverpod session plans/period selection, and decomposed
screen/hero/reallocation/category/form presentation. No endpoints, persistence
or dependencies were added. The shared card supports the approved 16px budget
hero radius; bottom sheets use the existing 24px sheet token.

Spending is `budgetImpact`, separate from cash flow. Budget exclusion, refunds,
transfers, pending state and recategorization apply as deltas against the full
fixture snapshot. New category allowances include known historical records.
The monthly limit independently covers category allocations; invalid totals
are rejected. Reallocation validates live remaining allowance and updates both
limits atomically without changing spending, account balances or monthly limits.

Session plans record explicitly edited categories so Home's initial approved
Transport variant stays intact until edited. Restoring a limit still counts as
an explicit edit. Home exposes `budgetSpent` separately from `outflow`; exclusion
therefore affects budget utilization without hiding real spending. Add Expense
and Detail use the current period's shared allowances.

Days use calendar arithmetic with zero-day safeguards. Safe pace floors integer
centavos so the proposed daily amount never overshoots the remaining budget.
Month-end and Food overage forecasts preserve the approved fixture's remaining
estimate and apply spending deltas; they are illustrative estimates, not a
production forecasting engine. Other months start without budgets or fabricated
forecasts and support session budget creation.

Budgets validation: 66 Flutter tests, including 11 golden comparisons, pass.
Existing Home/Transactions/Detail/Add goldens are unchanged. New tests cover
financial projection, explicit limit edits, atomic reallocation, validation,
filters/sort, month/new-budget flows, loading/retry, empty states, cross-screen
updates, compact/large/landscape layouts and 200% text with safe insets/keyboard.
Formatting, analysis, Android debug and iOS simulator debug builds pass. Backend
format/lint/build and its existing health HTTP test pass.

All nine approved references now have native demo implementations. The next
phase begins with onboarding/demo-entry UI; real integrations remain deferred.

Transactions/Add milestone verification (historical): 43 Flutter tests passed,
including nine light/dark/phone
goldens, financial projections, queries, annotation edits, navigation and manual
entry flows, keyboard/safe insets and validation of offscreen fields. Formatting
and analysis pass. Android debug and iOS simulator debug builds pass. Backend
format/lint/build and its HTTP test pass (the HTTP test requires localhost
socket permission outside the filesystem sandbox). No dependencies were added.

## Foundation verification

Validated locally on October 6, 2026:

- Dart formatting: clean; Flutter analysis: no issues.
- Flutter tests: 18 passed, including three golden comparisons, fixture JSON
  round trips, financial semantics, navigation, responsive layout, safe insets,
  large text, loading, empty and recoverable error states.
- Backend Prettier, ESLint and TypeScript/Nest build: passed.
- Backend HTTP test: passed; versioned health response, security header and
  unimplemented-route behavior verified.
- npm audit: zero reported vulnerabilities across the resolved dependency tree.
- Android debug build: passed; first build installed NDK 28.2.13676358 and
  Android SDK Platform 36. Artifact: `mobile/build/app/outputs/flutter-apk/app-debug.apk`.
- iOS simulator debug build: passed. Artifact:
  `mobile/build/ios/iphonesimulator/Runner.app`.

Build artifacts and machine-specific configuration are ignored. Native binaries
were compiled, but emulator/device interaction and store release signing were
not tested. The GitHub Actions workflow has been added but not run remotely.

Git was initialized on `main`. Work is committed at coherent milestones;
future implementation should continue that practice. Nothing has been pushed.

## Analytics phase

`features/analytics` separates read-only design fixtures, immutable domain
reports/selections/comparisons, aggregate projection, Riverpod application state
and native screen/chart/category/merchant presentation. Reports are transient
computed values; they have no serialization or persistence contract. No new
packages, backend endpoints or financial integrations were added. A small native
`CustomPainter` reproduces the approved trajectory without adding a chart package.

Riverpod aggregates on selection, ledger or budget-plan changes, rather than on
widget rebuilds. October Month uses the approved full-period category snapshot
with baseline ledger deltas; Year includes that aggregate plus available dated
records. Day, Week and other months use the dated demo ledger only. Week starts
Monday; ranges include the start and exclude the end. Calendar arithmetic handles
leap years and month/year rollover. Full-period daily averages truncate to integer
centavos, matching the approved October ₱541.93 value.

Analytics uses `expenseImpact`: pending entries, income and internal transfers
are excluded; refunds offset expenses; budget exclusion does not conceal cash
expenses. Category mapping groups Coffee with Food, and Groceries/Entertainment/
uncategorized refunds under Other. Merchant grouping normalizes whitespace/case
and the existing Grab Car alias, maintains snapshot visit counts, and ranks by
net positive amount with deterministic name tie-breaking. Refund-only periods
remain visible. Negative category values are retained; the bar uses positive
spending and explicitly explains refunds. Zero previous expense has no percentage.

October comparison uses the separate approved September aggregate. Category
trend badges and intelligence narrative are independent illustrative Stitch
examples, not an inferred reconciled September ledger; changed category totals
lose those reference trends and use a computed period overview. The forecast
preserves Analytics' ₱5,000 illustrative additional-spend estimate, distinct from
Budgets' ₱5,600. Edited monthly/category limits update target context while
retaining unedited screen-specific targets. Grouped categories include explicitly
added allowances without replacing the original Food target with Coffee alone.

Date and Day/Week/Month/Year selection and the category Amount/% toggle work;
selection, toggle and scrolling survive tab navigation. Chart semantics summarize
spending/target, and tapping opens dated values with a fixture
qualification. Share opens a selectable demo summary, not a file export or system
share. Notifications remain explicitly unavailable. Loading uses skeleton cards;
empty periods offer the October demo, and errors provide a safe explicit retry.

Validation: 91 Flutter tests, including 13 light/dark/phone golden comparisons.
Analytics tests cover money/projections, calendar boundaries, refunds, transfers,
pending state, recategorization, moved dates, comparisons, merchant ranking,
shared target edits, period/toggle/navigation, loading/empty/retry, compact/large/
landscape, 200% text, safe insets and accessible chart details. Existing goldens
remain unchanged. Formatting, analysis, Android debug/iOS simulator builds and
backend format/lint/build/health tests pass.

## Connected Accounts phase

`features/accounts` separates immutable session models and a repository contract,
deterministic sample profiles, Riverpod AsyncNotifier state, native cards/hero/
trust components and account dialogs. These transient fixtures need no JSON or
persistence contract. The repository is explicitly demo-only; its local refresh
method never calls providers, replaces balances or advances their timestamps.
No packages, backend functionality, credential fields or provider adapters were added.

`/accounts` is a task route above the shell, opened by Home's balance card.
Back pops to the originating tab with its scroll preserved; direct links fall
back to Home. The shared TaskScreen accepts optional back icon/tooltip/fallback
settings while existing defaults and goldens remain unchanged. Bottom navigation
is suppressed, matching Stitch; the connect CTA remains docked above safe insets.

Available balance sums integer centavos for active sample profiles (₱34,500).
BPI's expired ₱12,200 is last-known and excluded. The export's ₱34,300 aggregate
is inconsistent with its three active amounts, so the displayed total is corrected
rather than hiding the ₱200 discrepancy. Home's separate ₱30,650 reference
snapshot and manual payment-source fixtures remain independent. Removing a demo
profile does not remove transactions or change budgets/payment sources.

Disconnect requires confirmation. The catalog adds only known sample profiles,
with duplicate prevention; restoring BPI retains its stale status. Reconnect
explains the unavailable real integration and offers confirmed demo removal,
without accepting credentials or pretending to restore authorization. Settings
show only masked identifiers, dated balances and the demo permission boundary.
State remains session-only and survives route navigation.

Loading uses skeleton cards. Refresh disables repeated checks, retains visible
balances during failures, hides exception payloads and permits retry. If a profile
is removed while a local check is pending, completion keeps the latest list and
does not resurrect it. Empty lists offer sample restoration. Repository errors
provide an explicit safe retry. All security/provider copy is qualified: no
256-bit encryption, ISO/NPC certification, Open Finance authorization, guaranteed
provider availability or time-saving claims are asserted.

Validation: 110 Flutter tests, including 15 golden comparisons, pass. New tests
cover exact totals/stale exclusion, immutable lists, duplicate prevention,
removal/restoration, concurrent refresh and cached-error recovery, masked settings,
loading/empty/retry, navigation/back, compact/large/landscape, 200% text and safe
insets. Accounts light/dark captures are visually reviewed at 390 × 1632; older
screen goldens remain unchanged. Formatting/analysis, Android debug/iOS simulator
builds and backend format/lint/build/health tests pass.


## Subscriptions phase

`features/subscriptions` separates immutable domain plans/projections, five Stitch
fixtures, Riverpod session state, native hero/tip/timeline/service cards, and
tracking editor/detail/history sheets. No packages, backend endpoints or storage
contracts were added. Plain immutable Dart models suit these transient values;
Freezed/JSON remains reserved for existing serializable contracts.

`/subscriptions` redirects to `/budgets/subscriptions`, nested in the Budgets
shell branch to preserve the approved active bottom tab. Home's Upcoming Bills
card navigates there without altering Home's pixels. Back returns to Budgets;
tab switching preserves subscription sorting/scroll and the Home scroll position.
Plan state survives navigation and resets with the app's demo session.

Every monetary amount is integer centavos. Annualization uses 52 weekly, 12
monthly, 4 quarterly or 1 yearly payment. Monthly equivalence divides the exact
annual amount by 12, with one nearest-centavo (half-up) display rounding step; overview totals sum exact
annual amounts first. Paused plans remain listed but contribute no commitments
or upcoming renewals. Calendar-day comparisons use UTC calendar dates to avoid
clock-time/DST truncation; overdue expected dates remain visible, never implying
that a charge occurred. Dates are explicitly tracked, not automatically advanced.

The five approved plans total ₱18,742/year and ₱1,561.83/month, correcting the
export's inconsistent ₱18,600/₱1,550 hero and four-service count. Cross-screen
Home/Budgets/Analytics fixture aggregates remain independent. The four earliest
active dates span October/November, so the timeline says Upcoming renewals.
The cloud-storage saving tip appears only while the two original sample plans
remain active and unedited; manual changes withdraw its unverified overlap claim.

Add/edit validates a service name and exact positive PHP price; cadence, sample
source, category and expected date are editable. Manual edits replace fixture
provenance and keep detection confidence unknown. Pause/resume changes only
tracking, and removal requires confirmation. Detail/confirmation copy explains
that these controls cannot cancel subscriptions, stop payments or delete charges.
No recurring detection engine is implied from the sparse demo history.

History reads the shared ledger's posted recurring expenses only. Pending,
income, transfers, refunds and unflagged expenses are excluded; an observed charge
opens Transaction Detail. Plan creation/renewal never inserts expenses or changes
balances, budgets or analytics. History source provenance stays on the existing
transaction. This is not provider billing, payment scheduling or reconciliation.

Loading skeletons, safe retry and empty tracking/history states are implemented.
Rows stack on compact/large-text displays; forms and sheets scroll above keyboard
and safe insets. Light/dark use existing semantic palette roles and Inter. Visual
comparison corrected service title/badge wrapping, source/renewal alignment,
header margins and excess list spacing. The reference-size 390 × 1205 light golden
and full 390 × 1420 light/dark goldens preserve the screenshot hierarchy.

Validation: 134 Flutter tests, including 18 golden comparisons, pass. Subscription
tests cover exact money/cadences, aggregate rounding, duplicate IDs, immutable
lists, paused/empty projections, calendar/leap-year boundaries, deterministic sort,
manual edits/provenance, tip withdrawal, unchanged ledger, confirmed removal,
recorded-charge history/detail navigation, date editing, cancellation, shell/tab
state, loading/retry, compact/large/landscape, 200% text, keyboard and safe insets.
Older screen goldens remain unchanged. Formatting, static analysis, Android debug
and iOS simulator builds and backend format/lint/build/health regression checks pass.

Receipt Scanner Review is completed below. Actual camera/OCR/provider work
remains a later integration phase.


## Receipt Scanner Review phase

`features/receipts` separates immutable `ReceiptItem`/`ReceiptDraft` domain values,
deterministic extraction fixtures, a local asynchronous loader, Riverpod review/
saved-snapshot state, native preview/review cards and validated correction sheets.
No new dependency, backend endpoint, serialized/storage contract, camera/OCR SDK
or remote image asset was introduced. Plain immutable Dart models fit these
session-only values. The loader supports deterministic loading/error/empty tests.

`/receipt` is a task route above the shell. Add Expense's Scan opens it; confirmed
close/discard preserves the original form and scroll, while direct-link dismissal
falls back to Add. PopScope handles system Back with the same confirmation. Retake/
gallery explicitly confirms reloading the original fixture. Frame controls disclose
unavailable real crop/capture; flash is labelled as a demo preference.

Line totals are positive integer-centavo unit prices × integer quantity. Subtotal
and total sum those lines; the illustrative included tax is rounded half-up as
gross × 12/112, never added to the total. All items use the same sample treatment;
real receipt tax breakdowns, discounts, exemptions and reconciliation are outside
this milestone. Quantity/price/name validation, duplicate item IDs and a total cap
prevent invalid expenses. Unknown or under-90% unconfirmed confidence requires
explicit correction/confirmation or removal. Confirmation retains the original
confidence and marks the line Reviewed; manual additions are explicitly reviewed.

Review edits never mutate the ledger. Save validates merchant/source/category,
nonempty items, total and uncertainty, then synchronously inserts one posted
receipt-source expense and publishes an immutable snapshot keyed by transaction
ID. A stable sample receipt identity prevents repeat saves after navigation/reload;
saved reviews lock financial controls and offer the existing transaction. This
is idempotence for one local sample, not production duplicate detection or imported
transaction matching. Receipt expenses update Home/budget/analytics through the
existing shared ledger projections; reported account balances remain unchanged.

Transaction Detail reads saved receipt snapshots and displays reviewed quantity/
item amounts and included-tax metadata. Existing Jollibee fixture content/goldens
remain unchanged. The original Add form stays independent, so scan/save cannot
silently submit its previous manual values. No receipt photo/file is attached,
shared, exported or uploaded. All review state disappears when the demo session
ends. Loading skeletons, safe error retry and empty review/item states work.

Visual review used 427 × 1600 light/dark captures. It corrected title wrapping,
item typography/spacing, amount alignment, secondary button widths and overly
bright dark uncertainty fill. Compact/landscape/200% text, safe areas and keyboard
keep the review and editors scrollable. The decorative preview retains its text
scale and exposes a semantic summary; editable review text scales normally.

Validation: 156 Flutter tests, including 20 golden comparisons, pass. New tests
cover item arithmetic, included-tax rounding, invalid/unknown-confidence states,
immutable/duplicate items, edited total/category/source, save gating/idempotence,
readonly reopening, unchanged reported balances, shared spending/budget deltas,
item snapshot in Transaction Detail, merchant/date/time correction, confirmation,
retake/flash/frame boundaries, system Back/direct link, original Add state/scroll,
loading/empty/retry, phone sizes/landscape, 200% text and keyboard/safe insets.
Formatting/static analysis, Android debug and iOS simulator builds and existing
backend format/lint/build/health checks pass. Only the two Add Expense goldens were
updated among earlier screens, for its newly available demo-review caption.

Next: Phase 3 onboarding and explicit demo entry, using the established design
system. Authentication/persistence and real capture/OCR/provider work require
their own later implementation milestones.

## Onboarding and explicit demo entry phase

`features/onboarding` adds a bounded Riverpod `OnboardingStep` controller and
a native three-step presentation: balance overview, budget preview and demo
disclosure. It reuses Home's `BalanceHero` and `BudgetSummary`, existing October
2024 fixtures, Inter typography, semantic palette, cards and themed buttons.
There is no onboarding-specific financial calculation, repository, backend
endpoint, dependency or persistence. Static local content needs no asynchronous
loading/error state.

Default startup and `/` now open `/onboarding`, outside the bottom navigation.
Next/Back and system Back move through the introduction; Skip reaches the final
disclosure. Explore demo replaces the route with `/home`, without an intro route
on the back stack. Explicit feature deep links still work: this introduction is
not an authentication or authorization gate. Returning to `/onboarding` retains
the current step within the same ProviderScope and leaves all demo edits intact.
A fresh app session starts at the first step.

The final screen explicitly explains sample financial data, session-only edits,
no account connection or money movement, and unavailable real capture/OCR. It
collects no credentials and records no identity, authentication or consent.

Light/dark visual review at 390 × 844 checked all three stages against Home and
Budgets patterns. It corrected a header-height shift when Skip disappears. The
body scrolls independently of the safe-area footer; headings and disclosure text
scale normally. Six new golden baselines cover these inferred screens; previous
approved screen baselines remain unchanged.

Validation: formatting and static analysis pass; all 169 Flutter tests pass,
including 26 golden comparisons (six new onboarding baselines). Tests cover
bounded progression and fresh sessions, default/root startup, system Back,
Skip/disclosure/explicit entry, preserved deep links, three viewport sizes,
landscape, 200% text and safe insets. Android debug and iOS simulator builds
and the existing backend format/lint/build/health test pass.

Next: Settings and session preferences using the established design system.
Real authentication, protected persistence and integrations remain separate
implementation milestones.

## Settings and session preferences phase

`features/settings` separates a plain `Appearance` enum, a synchronous Riverpod
notifier and native Settings presentation. System is the session default; Light
and Dark override device appearance. `PesoFlowApp` maps the selected enum to
Flutter's `ThemeMode`; its optional fixed theme remains for previews/goldens.
Changes update the existing themes without replacing the router or ProviderScope,
so navigation, filters and financial edits remain intact. System continues to
respond to platform brightness changes. Restore device appearance changes only
this preference. A fresh session returns to System; no persistence, async loader,
backend endpoint or new dependency is needed.

`/settings` uses the shared task-screen shell with safe areas, constrained width
and a scrolling body. Home's existing avatar opens it with a 44 × 48px target
and an explicit Settings semantic action; its visible size and placement remain
unchanged. Back restores the previous screen/scroll, and direct-link dismissal
falls back to Home. Sample accounts pushes the existing Accounts route. View
introduction resets only onboarding progression before pushing its first step;
Back returns to Settings and Explore demo replaces the stack with Home.

Settings discloses in-memory sample data and unavailable real connections, fund
movement, camera and OCR. PHP/English (Philippines) formatting is informational;
there is no unsupported currency selector. Appearance is the only adjustable
preference in this milestone. Notifications, authentication and protected
persistence remain separate features.

Visual review used 390 × 1100 light/dark captures and neighboring Accounts/Detail
references. It checked card grouping, Inter hierarchy, row height, gutters and
semantic colors, and replaced internal design terminology with plain copy. The
new screen has no approved Stitch pixel baseline; its two goldens record an
inferred layout. All previous screen goldens remain unchanged.

Validation: all 180 Flutter tests pass, including 28 golden comparisons. The
11 new tests cover fresh-session/default appearance, device brightness changes,
manual overrides, restoration, unchanged ledger/filter/router state, Home entry,
Accounts/introduction navigation, three viewport sizes including landscape,
200% text, safe insets and checked/actionable screen-reader semantics. Formatting
and static analysis, Android debug and iOS simulator builds, and the existing
backend format/lint/build/health test pass.

Next: a session-only notification center with deterministic demo alerts,
read/unread state and links to the existing financial screens. No push delivery
or background monitoring should be implied before those integrations exist.

## Demo notification center phase

`features/notifications` separates immutable `DemoNotice` snapshots, a typed
`NoticeDestination` allowlist, deterministic October 2024 fixtures, an injectable
async loader, read-state/filter Riverpod controllers and native presentation.
The loader rejects duplicate/empty IDs, sorts newest first with an ID tie-breaker
and exposes an unmodifiable list. Read IDs are held independently so retries/
reloads preserve read state; unknown IDs are ignored. Read/unread and bulk-read
actions change no financial provider. A new session restores the fixture default
(three unread, one read). The loader supports loading, empty and safe retry UI.
No repository/API/storage contract, dependency or backend function is added.

`/notifications` uses the existing task shell and has no bottom navigation. The
shared NotificationButton replaces Home/Analytics/Budgets placeholder dialogs
without changing their approved bell geometry/colors. Only Home retains its
existing blue dot; it now disappears at zero unread. Bells expose an accessible
unread summary. All/Unread filters and explicit Read/Unread badges convey state
without relying on color; wrapped action rows accommodate large text.

Opening an alert marks it read and pushes a typed existing destination. Returning
restores the inbox/filter/scroll; direct-link header Back falls back to Home.
Alerts point to overall screens without overriding users' active financial
filters/periods. The snapshot date and financial values remain visibly historic
even when those destination views contain session edits.

Fixtures illustrate Food's sample limit, Netflix's recorded renewal, BPI's sample
expired connection and an October analytics review. The banner explicitly says
fixed snapshots do not update with edits. There is no live event generation,
background monitoring, OS permission, push token, scheduling or delivery. Unique
fixture IDs prevent duplicate inbox entries; production event deduplication and
cooldowns remain part of a later integration milestone.

Light/dark captures at 390 × 1480 were reviewed against Home's bell, Accounts'
task/header/cards and existing typography/spacing. The new inbox has no approved
Stitch screenshot; its inferred layout awaits product review. Existing approved
screen and inferred onboarding/settings goldens remain unchanged.

Validation: formatting/static analysis pass; 196 Flutter tests pass, including
30 golden comparisons. Sixteen new tests cover immutable/sorted/unique fixtures,
idempotent read actions, reload/fresh-session behavior, unchanged ledger, All/
Unread and caught-up states, all four destinations/return scroll, Home badge
clearing, Budgets entry/direct link, loading/empty/safe retry, light/dark goldens,
compact/large/landscape devices, 200% text and safe areas. Android debug and
iOS simulator builds and the existing backend format/lint/build/health test
also pass.

Next: native account detail for the sample profiles, preserving reported balance
semantics, masked identifiers, provenance and truthful demo connection status.

## Native sample account detail phase

`/accounts/:id` uses the task shell and reads `accountDetailProvider(id)`, a
Riverpod projection of the existing account overview and session ledger. A missing
or removed profile produces a safe unavailable state rather than showing the
original catalog balance. Loading/load errors inherit the account repository;
retry reloads that repository. No new dependency, backend endpoint, persistence
or provider adapter is introduced.

`AccountDetail` exposes an immutable profile/activity view. A dedicated fixture
association maps profile IDs to exact legacy ledger account labels: GCash, Maya,
BDO Checking and BPI Savings. It never matches institution prefixes; BDO Debit,
Savings and Credit Card records are not assigned to the Checking profile. A
transfer is included once if either its source or destination matches. Activity
sorts newest first with an ID tie-breaker, retains transaction provenance/status,
and opens the existing Transaction Detail. Date groups use centralized formatting;
long identity/metadata text wraps through an opt-in Transactions row option. The
existing Transactions feed retains its original layout. This mapping is a local
fixture bridge; production association needs stable account IDs.

The balance hero keeps the reported amount separate from ledger activity. It
shows only masked identifiers, currency, account type, institution and the
original October 2024 timestamp. Stale BPI keeps a last-known label and warning,
remains excluded from the available total and cannot be promoted by a local
check or the reconnection explanation. The related activity explicitly states
it is not a bank statement and does not reconcile the sample balance.

Identity areas and existing Settings actions on Connected Accounts now push the
detail, preserving visible card geometry. Header Back restores the Accounts
scroll; a direct detail link falls back to Accounts. Local checks reuse the
existing pending/error/retry state and never advance balance timestamps. Removal
reuses the existing confirmation, changes only the sample account list and
returns to the preceding screen or Accounts. The old Settings preview sheet
is replaced by the native detail. No credentials, real consent or live sync
are claimed.

Visual review checked four light/dark captures for active GCash (390 × 1700) and
stale BPI (390 × 1300) against neighboring Accounts/Transaction Detail patterns.
It corrected truncated transfer destinations and aligned activity date groups.
No approved account-detail screenshot exists; the inferred layout awaits product
review. All previous goldens remain unchanged.

Validation: formatting/static analysis, Android debug and iOS simulator builds
and existing backend format/lint/build/health checks pass. All 217 Flutter tests
pass, including 34 golden comparisons. Twenty-one new tests cover exact alias
association/transfer deduplication, immutable activity, reactive manual entries,
unchanged reported balances, identity entry/return scroll, transaction drilldown,
stale reconnection boundaries, local check pending/error/retry, confirmed removal
and intact ledger history, missing profiles, loading/retry, active/stale light/
dark captures, compact/large/landscape layouts and 200% text/safe insets.

Next: an explicit demo connection-consent flow using these trust patterns. It
should explain sample-only access and revocation without collecting credentials
or suggesting that real provider authorization has occurred.

## Explicit demo connection review phase

The catalog now opens `/connections/demo/:id` outside bottom navigation. The
native presentation reuses the task shell and account summary rather than a
provider web page. The financial_connections feature holds an auto-disposed
Riverpod acknowledgment per profile and a typed local operation result. No
package, backend endpoint, adapter or storage is added.

The application guard requires acknowledgment, a unique catalog profile, loaded
error-free account state and no pending local check. It revalidates current
membership immediately before the existing sample-list mutation, preventing
repeated additions. Provider loading/error or invalid/ambiguous IDs cannot add a
profile. Listed direct links offer detail only. Cancel and Back do not mutate;
leaving the review disposes acknowledgment so returning starts unchecked.
Successful add replaces the review with Account Detail, preserving the preceding
Accounts route; direct-entry Back falls back to Accounts.

The fixed balance and original timestamp are preserved. Stale BPI remains stale
and excluded from the available total. Neither acknowledgment nor addition
changes the ledger, grants permissions, creates real consent, contacts a
financial institution or writes to disk. The screen explains session-only data,
read-only sample visibility, no credentials/money movement, and removal without
revoking real consent or erasing transaction history.

Visual review checked two light/dark 390 × 1500 captures against adjacent Accounts
patterns. All earlier goldens remain unchanged. A dedicated consent design does
not exist in Stitch, so this inferred layout awaits product review.

Validation: formatting and static analysis pass. All 231 Flutter tests pass,
including 36 golden comparisons. Fourteen new tests cover acknowledgment gating,
idempotent additions and unchanged ledger/provenance, missing/ambiguous IDs,
pending local checks, catalog cancel/reentry, accessible checkbox actions,
stale restoration, listed direct links, loading/sanitized error/retry, light/dark
captures, compact/large/landscape layouts, 200% text and safe insets. Existing
catalog restoration tests now exercise review → detail → Accounts. Android debug
and iOS simulator builds pass; backend format/lint/build and its one health test
also pass.

Next: start the domain/persistence milestone with stable account identifiers and
explicit ledger associations, replacing the fixture-label bridge before adding
local demo storage. Real authentication and financial integrations remain
separate milestones.

## Stable account identity phase

The label-alias bridge is replaced by explicit `accountId` and
`destinationAccountId` references on the Freezed transaction model, with
regenerated JSON/copy/equality support. Display strings remain snapshots.
`LedgerAccount` and a deterministic fixture catalog distinguish wallet, checking,
savings, debit, credit-card and cash identities. Existing connected-profile IDs
are preserved; additional ledger sources are not presented as connected profiles.
The catalog is independent of session connection removal/restoration.

`accountActivity` moves from fixture data into the account domain. It uses the
shared transaction membership predicate, includes a transfer once for either
endpoint, preserves sorting/immutability and never matches institution/label
text. Account filters also store IDs and expose receiving-only transfer accounts.
Labels shown in the picker/chip come from record snapshots; equal labels remain
separate choices. An ID without current display data shows a safe generic label.

Add Expense retains its visible design and stores selected source/destination
IDs. Manual validation compares IDs, preventing same-account transfers even
when labels differ, and allowing distinct identities with identical labels.
Receipt selections carry typed identities and publish ID/label together; saved
receipt snapshots and transactions retain the selected reference. Balance data
remains separate from ledger edits.

JSON compatibility is additive: missing ID fields decode as null. Unresolved
legacy records remain visible and included in totals, but do not join a profile
or ID filter by name. No saved data currently requires a disk migration because
the app remains session-only. No dependencies, persistence, user identity,
authentication, backend endpoints or financial integrations are introduced.

Validation: code generation, formatting and static analysis pass. All 239 Flutter
tests pass, including all 36 unchanged golden comparisons. Eight new tests cover
fixture reference integrity, renamed/colliding labels, product separation,
source/destination transfer filtering and zero impact, JSON round trips, missing/
unknown references, ID-based transfer validation, receipt identity validation
and a receiving-only account picker. Existing manual/receipt widget/domain tests
now verify saved IDs. Android debug and iOS simulator builds and existing backend
format/lint/build/health checks pass.

Next: introduce versioned local demo persistence behind repositories, starting
with the ledger and explicit account references, while retaining deterministic
fixtures and a clear reset path. Real authentication and provider integrations
remain separate milestones.

## Versioned local demo activity persistence phase

Native `main` now opens `DemoDatabase` through `drift_flutter` and presents
`DemoBootstrap`. Bootstrap loads/validates the existing workspace before creating
the financial ProviderScope. An empty database seeds the known fixtures once;
read/format/schema errors show calm retry and explicitly confirmed reset options.
The app never renders a fresh writable ledger over an unreadable stored one.

`DemoWorkspaceRepository` separates activity storage from presentation. The
SQLite adapter stores one transactional versioned snapshot containing the ledger
and saved receipt map. Runtime database schema, JSON format and fixture baseline
are independently versioned at 1. This small demo format preserves exact model
semantics; normalized tables, indexes and query repositories remain later work.
Its strict codec rejects noninteger money, duplicate transaction IDs, orphaned
receipts and inconsistent receipt provenance/amount/account references. Unsupported
future versions are refused without modifying their data or schema version.

Existing synchronous providers retain responsive interaction and immutable
state. Bootstrap injects loaded records and receipt snapshots; previews and
ordinary widget tests use isolated memory fixtures with no filesystem/plugin
calls. `DemoPersistence` listens to both providers, coalesces synchronous receipt
publication, serializes snapshots, tracks saving/saved/error/resetting state and
retains the newest activity after a failed save. Lifecycle inactive/paused events
request a flush. Durability is confirmed after a completed save; a process killed
before completion may lose pending edits. Loaded IDs initialize the manual entry
sequence, and restored receipt reviews reuse saved IDs rather than posting twice.

Settings adds a native local activity card with truthful scope, save status,
retry and confirmed Reset demo activity. Reset commits the original ledger and
empty receipt map before replacing memory and invalidating receipt review;
failures preserve current activity. It does not reset appearance, session account
choices, budget limits or subscription plans. A global live-region save-error
banner offers retry on all routes; pending resets block pointer edits. Startup
and Settings reset require explicit confirmation, with no remote revocation.

Onboarding, transaction detail and entry feedback distinguish local activity
from session-only edits when persistence is enabled. Existing memory preview
copy and all old golden files stay unchanged. New Settings light/dark 390 × 1600
captures were reviewed against adjacent card/header patterns. There is no approved
Stitch storage/reset design; this inferred addition awaits product review.

Dependencies: `drift` 2.35.1 and `drift_flutter` 0.3.1 at runtime, `drift_dev` 2.35.1
for generated tables, reusing build_runner. The platform factory locates
`pesoflow_demo.sqlite` in the application documents directory; native SQLite
assets and path_provider are transitive dependencies. See the official
[Drift Flutter setup](https://drift.simonbinder.eu/setup/).
There is no account integration, backend endpoint, notification permission,
network storage or production encrypted/owned data model in this milestone.

Validation: code generation, formatting and analysis pass. All 256 Flutter tests
pass, including 38 golden comparisons (two new local Settings captures and all
36 earlier baselines unchanged). Seventeen new tests cover file reopen/ID
allocation, saved receipt restart/idempotence, failed SQL rollback, corruption/
fractional money/version refusal, ordered saves/latest retry, receipt integrity,
failed/successful reset and preserved unrelated state, confirmation/cancel,
global errors, startup retry/reset, light/dark layouts, 200% text and safe insets.
Android debug and iOS simulator builds pass with the new native SQLite assets.
Backend format/lint/build and its one health test pass.

Next: persist budget plans and subscription tracking metadata through separate
versioned repositories, retaining ledger-derived spending and explicit demo reset
scope. Real authentication, encryption/ownership and provider integrations remain
separate milestones before handling real financial data.


## Local budget and subscription persistence phase

`DemoWorkspace` now includes immutable base budget plans keyed by year/month and
subscription tracking records. Separate feature codecs (`BudgetPlansCodec` and
`SubscriptionPlansCodec`, each version 1) define their storage contracts. They
share the existing `DemoWorkspaceRepository` and one transactional SQLite snapshot,
so activity and plans cannot be independently replaced by stale concurrent saves.
No additional database, repository singleton, backend endpoint or dependency was
introduced. SQLite schema remains version 1; the workspace envelope is version 2.

Loading a valid v1 activity snapshot preserves its ledger/receipts, seeds the
previously transient plans, and writes the migrated v2 row within the same load
transaction. Failed migration rolls back; malformed or unknown feature/workspace
versions never trigger replacement. Empty v2 plan collections remain empty.
Budget integer fields are checked before generated decoding; monthly keys,
calendar periods, category uniqueness, expense categories, edited-category
references, limits and allocations are validated. Subscription IDs, integer
amounts, billing cycle, canonical renewal date, origin, active flag and confidence
are preserved and validated. No money is persisted as floating point.

Riverpod hydrates each feature from bootstrap and the shared coordinator listens
to both plan stores as well as activity. It stores base budget spending/forecasts,
never the `budgetsProvider` ledger projection: adding expenses/refunds or reopening
the app cannot apply a ledger delta twice. Subscription ID allocation resumes
above surviving saved manual IDs. Plan changes, renewal dates, pauses and removals
never post ledger charges, move money, cancel services or change reported balances.

Settings offers two separately confirmed durable resets. Reset demo activity
restores transactions/clears reviewed receipts while preserving plans. Reset demo
plans restores budget/subscription samples while preserving the ledger/receipts;
budget spending still reflects recorded activity. Resets publish state only after
successful storage and block pointer edits while pending. Startup recovery instead
explicitly confirms replacement of all four stored collections. Failed writes
retain the newest complete snapshot for retry. Unstored UI choices stay transient.

Storage disclosure/editor copy is conditional on persistence; memory previews and
the approved screens retain their prior visual baselines. The two local Settings
goldens reflect the added reset control and updated copy. This remains unencrypted,
unauthenticated sample-data storage; no real integration is implied.

Validation: Dart formatting and Flutter analysis pass. All 265 Flutter tests pass,
including 38 golden comparisons; only the two local Settings images were updated.
Nine added tests cover file reopen/no double projection, all subscription cycles,
empty tracking, migration rollback and preservation, invalid stored plans, queued
save retry, independent durable resets, confirmation/cancel and editor disclosures.
Compact 200% text/safe-inset checks cover the added control. Android debug and iOS
simulator builds pass. Backend formatting, lint, build and its health test pass.

Next: persist appearance and other explicitly scoped demo preferences, with a
versioned migration and clear reset behavior. Authentication, protected storage
and ownership remain prerequisites for real personal financial data.


## Durable demo preference phase

`DemoPreferences` contains only `Appearance` and `introductionCompleted`; its
feature codec uses version 1. Workspace format v3 stores preferences in the same
atomic SQLite snapshot. Database schema/fixture versions stay at 1. Loading v1 or
v2 migrates transactionally with System/false defaults, preserving activity,
receipts and any v2 budget/subscription edits. Unsupported/malformed preferences
or a failed migration never replace the stored row. No dependencies were added.

Settings and the completion provider hydrate from bootstrap. The existing save
coordinator watches both, coalesces writes with financial state and retries the
newest complete snapshot after failure. Restore device appearance changes and
saves only the theme; activity and plan resets preserve both preferences. Startup
recovery explicitly confirms resetting all stored demo data, System appearance
and introduction completion.

The router reads completion once from the loaded snapshot, so finishing the
introduction or changing appearance cannot recreate the navigation stack. Only
Explore demo marks completion; Skip shows the disclosure first. Returning users
open Home in the saved theme. Settings can push the introduction again without
clearing completion. Unfinished step navigation remains ephemeral; this flag is
not authenticated onboarding, provider consent or a security acknowledgment.

Only persistence-enabled disclosure copy changed. No layout/component/token
redesign was introduced; memory preview baselines retain the existing session-only
copy. The two local Settings goldens are refreshed for the truthful disclosures.

Validation: formatting and Flutter analysis pass; all 271 Flutter tests pass,
including 38 golden comparisons. Six added tests cover file reopen for all themes,
v1/v2 migration preservation and rollback, invalid preference refusal, latest-save
retry and scoped reset preservation, startup full-reset disclosure/defaults, and
explicit completion/restart in dark Home/reviewing the introduction. Existing
compact 200% text and safe-inset tests pass. Only the two local Settings goldens
changed for disclosure text; reviewed light/dark typography, spacing and cards
retain the established design. Android debug and iOS simulator builds pass.
Backend formatting, lint, build and its health test pass.

Next: persist demo notification read state with fixture-aware migration and clear
reset scope, retaining existing calm notification UI. Real financial data still
requires authentication, ownership and protected storage before integrations.


## Durable sample notification read state phase

Workspace v4 adds an immutable `noticeReadIds` set, serialized by the feature-owned
`NoticeReadCodec` as `{version: 1, catalogVersion: 1, readIds: [...]}`. The marker
list is sorted on write. It validates unique string IDs against the current fixed
sample catalog and rejects malformed/future versions or unknown IDs without
replacing stored data. Database/financial fixture versions remain at 1. Alert
content/dates/destinations stay in the fixture layer and never become saved events.

Valid v1/v2/v3 rows migrate transactionally with the original one-read/three-unread
markers. Existing transactions/receipts, v2 plans and v3 preferences remain intact.
Failed migrations roll back. Explicit empty read sets stay empty: the originally
read sample must not be silently reseeded. Newly appended catalog IDs remain
unread when absent from saved markers. Removing/reusing an existing ID or changing
its event meaning requires a catalog-version bump and an explicit migration;
unsupported catalogs fail closed into recovery rather than resetting markers.

The existing provider hydrates markers before rendering. Single read/unread,
opening an alert and Mark all read flow through the shared snapshot coordinator,
which serializes saves, preserves the newest snapshot on failure and exposes retry
across routes. Filters and asynchronous fixture loading remain independent and
transient. No financial state, reported balances or alert content are modified by
read actions; no alert generation, scheduling, permissions, delivery, FCM setup or
backend endpoint was introduced. No dependencies were added.

A third independently confirmed Settings reset restores only original read markers.
It commits before publishing; failures preserve memory and stored data. Activity
and plan resets preserve markers, and alert reset preserves both financial domains
and preferences. Startup full recovery explicitly names resetting alert markers.
All markers remain sample-only, unencrypted device data without authenticated
ownership, delivery receipt or provider-consent meaning.

Only persistence-mode disclosure copy changes in the inbox, Settings and demo
introduction. Existing components/tokens/navigation remain intact. Local Settings
light/dark goldens reflect the additional outlined reset; two new persistent-inbox
goldens capture the updated disclosure without changing earlier memory baselines.

Validation: formatting and Flutter analysis pass; all 280 Flutter tests pass,
including 40 golden comparisons. Nine added tests cover file reopen with mixed/
all-read/empty markers, migration from v1/v2/v3 with rollback and preserved data,
invalid marker/catalog refusal, newest-save retry, independent reset durability,
opened-alert restart/badge restoration, confirmed/cancelled Settings reset, two
persistent inbox goldens and compact 200% text/safe insets. The local Settings
compact test also verifies the new reset control. All 36 earlier memory baselines
remain unchanged; the two local Settings images were updated and two persistent
inbox images added. Native Android debug/iOS simulator builds and backend
formatting/lint/build/health test pass.

Next: persist sample account membership/configuration behind the demo repository,
with explicit reset scope and the existing sample-access acknowledgment. Restored
sample connections must remain clearly distinct from real provider authorization.
