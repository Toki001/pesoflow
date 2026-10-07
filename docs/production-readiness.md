# Production readiness

This is an implementation tracker, not a release certification. Audit baseline:
`ed26c56`, 7 October 2026. `CODEX.md` was read completely before this migration.

## Original audit (historical baseline)

The repository contains nine approved Stitch screenshot/HTML pairs, two design
documents, native Flutter screens, bundled Inter, reusable light/dark tokens,
Riverpod/GoRouter/Dio, Freezed models, Drift demo storage, 40 golden images and
a NestJS health endpoint. The visual references remain authoritative.

| Area | Baseline status | Finding / required work |
| --- | --- | --- |
| Native UI and design system | Complete foundation | Preserve hierarchy, typography, spacing, navigation and dark mode. |
| Accounts | Missing production behavior | Four fixture profiles; no persisted manual accounts or balance engine. |
| Transactions | Partial | Integer-centavo manual entry and edits; fixture payment sources and totals. |
| Budgets | Partial | Monthly planning/editing only; aggregates include fixture offsets. |
| Analytics | Partial | Calendar ranges exist; October/September sample aggregates are injected. |
| Subscriptions | Partial | Manual plan editing; five seeded plans; no history detection. |
| Receipts | Missing | Review UI exists; camera, OCR, stored images and real tax parsing absent. |
| Notifications | Partial | Read markers persist for four fixture events; no condition evaluator. |
| Persistence | Partial | Unencrypted, versioned demo snapshot; only activity/plans/preferences/read markers. |
| Fresh install | Missing | Onboarding leads into seeded demo workspace. |
| Authentication/API integration | Missing | Reserved Dio client; no sessions, auth or financial endpoints. |
| Backend | Partial | NestJS validation/security headers/health test; no PostgreSQL or migrations. |
| Financial providers | External service required | No actual integration, consent, credentials or live connections. |
| Settings/data management | Partial | Theme persists; remaining settings and export/deletion are absent. |
| Tests | Partial | Useful deterministic domain/widget/golden coverage; runtime fixture defaults must go. |
| Device/release configuration | Partial | Generated projects; debug release signing and default launcher assets. |

At the baseline, runtime fixture dependencies were concentrated in feature `data/*_fixture.dart`,
the `demo_workspace` coordinator and bootstrap, snapshot codecs, Home/monthly/
analytics projections, receipt review and account selection. Fixed October 2024
dates and financial copy also occurred in presentation widgets. The existing
immutable transaction model, exact decimal parser, receipt review controls,
layout primitives, query filters and theme can be preserved and extended.

## Migration decisions

- Local-first manual tracking is usable without a server account or bank access.
- The production store is a separate `pesoflow` SQLite database. Existing
  `pesoflow_demo` files are retained, never silently adopted or deleted: they mix
  sample records with possible user edits. A reviewed migration path must exclude
  seeded finances while preserving user-created records.
- Financial amounts use integer minor units. One workspace currency prevents
  adding incompatible currencies or inventing exchange rates.
- Repository commits are atomic. Financial records are authenticated-encrypted
  before SQLite persistence; keys belong in platform secure storage.
- Tests inject fake repositories and clocks. Production defaults contain product
  categories and preferences only, never sample user financial activity.
- Provider connectivity stays explicitly unavailable until an authorized adapter
  and real configuration exist. Manual wallets are labeled as manually tracked.

## READY

- Approved native screen structures and shared Inter/light/dark design tokens.
- Repository audit and migration boundaries above.
- Production startup opens the encrypted Drift workspace before routing; fresh
  installs contain no financial records and open the introduction.
- Home, Transactions, Accounts, Budgets and Analytics read the same persisted
  workspace through Riverpod. No fixture offsets or default sample accounts.
- Manual account creation/editing, expense/income/transfer entry, transaction
  editing/deletion/exclusion, and monthly budget editing are durable commands.
  Balances and projections refresh after successful saves; failed saves retain
  committed records and form inputs. Used accounts archive instead of losing history.
- Theme, introduction completion, manually entered subscription plans and in-app
  financial notice read status persist. External connections remain unavailable.
- Runtime demo bootstrap, consent/reset controls and sample loaders removed.
  Design fixtures and legacy prototype helpers live under `mobile/test/` only.
- Android backup disabled for the device-bound key; iOS Keychain entitlement wired.
  The schema, encryption design and financial engines from the foundation remain.
  An atomic budget-reallocation command was added for the existing approved UI.

## Completed foundation checkpoints

Checkpoint 1 (`ed18ee7`) added the production account/workspace/preferences/budget models,
balance and budget calculations, an atomic encrypted Drift repository, encrypted
receipt-image storage, a strict versioned codec, stale-write protection and a
version-1 schema snapshot. AES-256-GCM uses fresh nonces and record-bound associated
data; its key is held by platform secure storage. See the maintained
[cryptography package](https://pub.dev/packages/cryptography) and
[secure-storage configuration](https://pub.dev/packages/flutter_secure_storage).
At that checkpoint, production storage was not yet connected to the UI.

Checkpoint 2 (`bae7f2a`) added durable repository-backed account/transaction/budget/plan/
preference commands, exact real-ledger analytics, the full product category enum,
remembered categorization rules, recurring detection requiring three observed
charges, and persistent condition/deduplication logic for budget thresholds,
renewals and unusually large expenses. These engines contain no sample financial
aggregates. Screen wiring was deferred until checkpoint 4.

Checkpoint 3 (`06817b3`) added a native manual-account editor using existing TaskScreen,
FinanceCard and typography components, a real Home projection, and startup/save
boundary components for the new repository. The editor validates signed opening
balances and stores only optional masked identifiers; failed saves keep inputs
for retry. Widget tests inject the real controller with a fake repository.
Checkpoint 4 connects those existing foundations to the application. Startup,
feature projections, entry forms, onboarding and preferences now use the real
repository. Monthly budgets repeat from their configured starting month. Home,
Accounts, Transactions totals and Analytics use the same as-of boundary; transfers
affect each account but never inflate aggregate income or expense. Category-only
budgets do not invent an overall limit.

No database or financial-engine rewrite, new package dependency, backend feature,
OCR implementation, provider integration or release packaging was needed.

## Remaining work / next recommended task

The requested local manual-finance launch milestone is complete. No external
credential is needed to run it. This does not certify release readiness.

Recommended next task: user-controlled data export/backup and tested restore,
including recovery UX. Device-bound local storage currently has no recovery path
after uninstall or loss of its encryption key. Old demo databases are preserved
but not automatically imported; any migration must distinguish user edits from
sample records and show a review before import.

Separate future tasks remain:

- Physical Android/iOS device verification, including lock/unlock, interruptions,
  storage exhaustion and platform backup/recovery behavior. The native smoke check
  below covers iOS Simulator; it does not establish physical-device behavior.
- Day/week/year budget controls (engines exist; approved budget UI remains monthly),
  recurring-suggestion acceptance UI and notification delivery. In-app notice
  evaluation/read status is available; no OS notification delivery is claimed.
- Camera/OCR/review/image lifecycle. The receipt demo is test-only and the runtime
  Scan route explicitly states scanning is unavailable.
- Backend persistence/authentication/ownership/sync and authorized providers.
- Release signing, distribution assets and packaging.

## REQUIRES EXTERNAL CREDENTIALS

- An authorized financial-data provider contract, sandbox/production credentials
  and published capabilities for bank/e-wallet connectivity.
- Deployment infrastructure, PostgreSQL connection and HTTPS domain for hosted
  accounts/sync. Local-only tracking must work without these.

## REQUIRES SIGNING / STORE CONFIGURATION

- Owner-controlled Android release keystore and Play listing.
- Apple Developer Team, provisioning profiles and App Store listing.
- Confirm ownership of the application/bundle identifier before distribution.

## OPTIONAL FUTURE WORK

- Cross-currency conversion with an identified exchange-rate source.
- Remote push delivery; local condition-based alerts do not require Firebase.

## Verification

The prior demo milestone reported 280 Flutter tests and 40 golden comparisons.
Those are baseline results, not verification of this migration. Commands,
artifacts, reviewed visual differences and exact device steps will be recorded
after implementation.

Checkpoint 1: `dart format` on changed sources, `flutter analyze` (no issues),
`flutter test` (292 passed, including the 40 existing golden comparisons), and
`dart run drift_dev schema dump lib/core/storage/finance_database.dart drift_schemas`
passed. No screenshot baseline changed. Real-device encryption/permissions and
release builds still need verification after production startup is connected.

Checkpoint 2: formatting and static analysis passed; the full Flutter suite
passed (303 tests, existing golden comparisons unchanged). New command tests
exercise serialized writes, save failure recovery, transfers, deletion guards,
remembered corrections and atomic notice creation; calculation tests cover empty
analytics, previous periods, recurring intervals and alert deduplication.

Checkpoint 3: `dart format lib test`, `flutter analyze` and `flutter test` passed
(307 tests, all existing goldens unchanged). Account-form tests cover durable
creation and retry; the Home projection test verifies empty finances. No Android
or iOS release build has been attempted for this migration yet. No signed release
or complete production authentication/OCR integration is claimed.

Checkpoint 4 (`c969674`, 7 October 2026): production runtime and main financial
screens are connected and verified. This completes the scoped launch task.

- `bash scripts/check.sh`: formatting clean, Flutter analysis reports no issues,
  **115 Flutter tests pass**, including **14 production light/dark golden
  comparisons**. Backend formatting, lint, build and its health endpoint test pass;
  no backend source changed.
- `flutter build apk --debug`: passes; artifact
  `mobile/build/app/outputs/flutter-apk/app-debug.apk`.
- `flutter build ios --simulator --debug`: passes; artifact
  `mobile/build/ios/iphonesimulator/Runner.app`.
- iOS 27.0 Simulator: the actual `lib/main.dart` entry point launches with platform
  Keychain and encrypted Drift storage. Fresh startup shows the introduction,
  with no sample financial records.
- Native persistence smoke: the guarded test-only
  `mobile/test/device/persistence_smoke.dart` created a PHP 1,000 manual account,
  PHP 325.25 expense, PHP 5,000 monthly budget and dark appearance on an isolated
  simulator. After quitting the process and launching **`lib/main.dart` without
  test flags**, Home restored the PHP 674.75 balance, expense-derived totals,
  monthly budget and dark theme. See [before restart](verification/production-restart-before.png)
  and [after restart](verification/production-restart-after.png). These captures
  precede the final replacement of the empty-name avatar initial with “PF”.
- The automated file-backed restart test independently closes/reopens the real
  encrypted repository and reconstructs FinanceBootstrap, including theme. It uses
  an injected test key store; the native smoke above exercises actual Keychain.
- Cross-screen regression checks cover successful and failed saves, income,
  expenses, transfers, edits, budget exclusion, deletion, archiving/restoration and
  atomic budget reallocation. Widget checks cover empty installs, onboarding,
  manual account and transaction forms, monthly budget creation, category-only
  budgets and narrow/large-text layouts.

The count differs from the earlier 307-test demo checkpoint because obsolete
seeded-startup, fake consent/reset and prototype-only widget tests were retired.
Production tests explicitly inject fixture workspaces; financial engine,
encryption/codec, exact parsing, identity and query regressions remain.
Historical prototype PNGs remain references, not current comparisons. See
[the test infrastructure notes](../mobile/test/README.md).

Visual review compared production Home with the approved Home screenshot and
reviewed light/dark production goldens. Existing card hierarchy, Inter typography,
financial colors, spacing and navigation are retained. Values, chart trajectories,
account/transaction counts, budget rows and bill sections now follow actual data.
Initials replace the reference portrait; provider/sync claims use truthful manual
tracking copy. Fake receipt items, named bill-sharing contacts and provider IDs
are absent from transaction detail. Empty states and resulting content heights
therefore differ from the populated Stitch examples. Pixel-identical rendering
across devices is not claimed; native font/icon rasterization still varies.
