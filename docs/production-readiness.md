# Production readiness

This is an implementation tracker, not a release certification. Audit baseline:
`ed26c56`, 7 October 2026. `CODEX.md` was read completely before this migration.

## Audit

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

Runtime fixture dependencies are concentrated in feature `data/*_fixture.dart`,
the `demo_workspace` coordinator and bootstrap, snapshot codecs, Home/monthly/
analytics projections, receipt review and account selection. Fixed October 2024
dates and financial copy also occur in presentation widgets. The existing
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

## Implementation in progress

Checkpoint 1 adds the production account/workspace/preferences/budget models,
balance and budget calculations, an atomic encrypted Drift repository, encrypted
receipt-image storage, a strict versioned codec, stale-write protection and a
version-1 schema snapshot. AES-256-GCM uses fresh nonces and record-bound associated
data; its key is held by platform secure storage. See the maintained
[cryptography package](https://pub.dev/packages/cryptography) and
[secure-storage configuration](https://pub.dev/packages/flutter_secure_storage).
The production repository is not yet connected to startup or screens; the app
still runs the old demo while that wiring is migrated in the next checkpoint.

All items marked Partial/Missing in the audit remain required local work until
their implementation and verification are recorded here. They are not external
blockers. No production build or security completion is claimed yet.

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
