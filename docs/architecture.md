# Foundation architecture

## Current scope

Native Android/iOS Flutter scaffold, shared theme/components, Riverpod state,
GoRouter shell, fixture-backed Home/Transactions/Detail/Add Expense/Budgets/Analytics/Accounts, a session-only
demo ledger, and minimal NestJS `/v1/health` endpoint.
No HTML rendering, WebViews, provider calls, authentication, database, queues,
OCR, notifications, persistence, or money movement are implemented.

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

The next approved screen is Subscriptions. Use deterministic recurring-expense
fixtures and the existing demo ledger; integrations remain deferred.

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
