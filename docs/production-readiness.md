# Production readiness

This is an implementation tracker, not a release certification. Audit baseline:
`ed26c56`, 7 October 2026. `CODEX.md` was read completely before this migration.

Current receipt status and limits are documented in [receipt capture and review](receipts.md).
The checkpoints below include historical states; they are not all current blockers.

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
- User-controlled password-encrypted portable backups, transaction CSV export,
  reviewed atomic restore and missing-device-key recovery. See [backup and
  recovery](backup.md) for scope, format limits and native file-picker checks.

- Native receipt capture/photo selection, manual crop/rotation and on-device Latin
  OCR, with editable fields, explicit review, actual account selection and atomic
  encrypted image/expense persistence. Saved receipts reopen from Transaction
  Detail, participate in backup/restore and are removed with transaction deletion.
  See [receipt behavior](receipts.md) and [pending device checks](verification/receipt-device-checklist.md).

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

For checkpoints 1–4, no database or financial-engine rewrite, new package dependency, backend feature,
OCR implementation, provider integration or release packaging was needed.

## Remaining work / next recommended task

The requested local manual-finance launch milestone is complete. No external
credential is needed to run it. This does not certify release readiness.

The data export/backup and tested restore task is now complete. Recovery after
uninstall or device-key loss requires a previously saved `.pfbackup` and its
password. There is no recovery service or password reset. SQLite corruption,
inaccessible secure storage and exhausted disk space can still block a restore;
the original database is preserved when replacement fails.

Recommended next task: physical Android/iOS receipt/OCR acceptance on a redacted
Philippine receipt corpus, alongside the pending backup resilience checks. Use the
[receipt checklist](verification/receipt-device-checklist.md), including offline
first scan, permission denial, poor-quality photos, background/resume and saved
receipt reopen. Backup resilience verification includes
native local/cloud document save and selection, backup transfer to another test
installation, force-stop/restart, lock/unlock, interrupted restore and low-storage
failures. Follow the [device checklist](backup.md#verification-and-device-checks).
Physical verification is currently blocked: discovery found no Android/iOS
hardware and the owner cannot connect devices. The [resilience evidence and
device procedure](verification/backup-device-checklist.md) distinguishes the
completed host checks from pending native checks. Do not treat these checks as
physical-device sign-off.
Old demo databases remain outside backup/import; any later migration must
distinguish user edits from sample records and show a review before import.

Separate future tasks remain:

- Physical Android/iOS device verification, including lock/unlock, interruptions,
  storage exhaustion and platform backup/recovery behavior. The earlier manual-
  finance simulator smoke check below predates the OCR dependency; it does not
  establish current receipt runtime or physical-device behavior.
- Day/week/year budget controls (engines exist; approved budget UI remains monthly),
  recurring-suggestion acceptance UI and notification delivery. In-app notice
  evaluation/read status is available; no OS notification delivery is claimed.
- Real-receipt accuracy and native permission/capture acceptance on physical
  hardware. ML Kit simulator builds are x86_64 and cannot run on the installed
  Apple Silicon iOS 27 runtime; device arm64 is a separate build target.
- A versioned streaming backup enhancement for receipt collections that exceed
  current image/JSON bounds; today export fails explicitly rather than dropping images.
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

## Checkpoint 5 — portable export and tested restore

Implementation: `a608c86`, 7 October 2026. Settings → Backup & export now saves
password-encrypted `.pfbackup` files, previews and confirms whole-workspace
replacement, and exports explicitly disclosed plaintext transaction CSV. Startup
errors offer the same restore flow for recovery from a previously saved backup.

Backups include full workspace metadata and encrypted-at-rest receipt image
contents. They exclude device keys, sync ownership and biometric enrollment.
PBKDF2-HMAC-SHA256 and AES-256-GCM run off the UI isolate. The new `file_picker`
13.1.0 dependency supplies native save/selection; existing cryptography, Drift,
Riverpod and financial calculations are reused. No database schema change,
backend functionality, OCR, authentication, provider or release packaging was added.

Restore validates before preview, checks the reviewed revision and replaces both
workspace and images atomically. Tests prove rollback after a deliberate image
insert failure, new-device-key recovery, no duplication on repeated restores,
updates to all five financial projections, and exact workspace/image persistence
after a file-backed close/reopen. Unsupported, malformed, tampered and oversized
files fail without destructive fallback. CSV reads only transactions/workspace,
so receipt-image limits do not block a transaction export.

Verification completed:

- `bash scripts/check.sh`: formatting clean, analysis clean, **130 Flutter tests
  pass**, including **16 light/dark golden comparisons** (14 existing production
  comparisons unchanged; two reviewed new Backup screens). Backend formatting,
  lint, build and health test pass; backend sources unchanged.
- `flutter build apk --debug` and `flutter build ios --simulator --debug`: pass.
  These verify native plugin compilation, not physical file-provider behavior.
- Android merged debug manifest retains `allowBackup="false"` and adds no broad
  storage permission; only the existing debug Internet/internal receiver
  permissions appear.
- Visual review: the new screen inherits TaskScreen, FinanceCard, Inter, existing
  blue actions, light/dark colors and spacing. No approved financial-screen
  layout or existing golden baseline changed. Backup has no separate Stitch
  screenshot; its form/dialog content is derived from the existing components.
- Native picker dialogs are injected in widget tests. No new physical-device,
  cloud-document-provider or native end-to-end backup round trip was performed in
  this checkpoint. The prior simulator launch/restart evidence remains checkpoint 4.

See [backup format, limits and device checklist](backup.md) and the updated
[current security boundary](security.md). There is no remaining implementation
blocker for this scoped local export/restore milestone. Physical-device resilience
verification is the next task; forgotten passwords, missing backup files and
unreadable underlying SQLite storage cannot be repaired by this feature.

## Checkpoint 6 — resilience checks; physical verification blocked

Test implementation: `df6a41c`.

8 October 2026: no physical Android or iOS device was available and the owner
confirmed devices cannot be connected. Native file dialogs, cloud document
providers, cross-platform phone-to-phone restore, real lock/unlock and device
storage exhaustion remain **unverified**. No connected personal device was altered.

Added test-only coverage without changing application code, the database schema,
financial engines, dependencies or approved layouts:

- Real `SQLITE_FULL` during restore in bounded temporary databases, in DELETE and
  WAL journal modes. Controller state stays unchanged; reopening preserves exact
  prior workspace/images and passes integrity checking. Retry succeeds after
  lifting the database-specific growth limit. Host disks were not filled.
- Temporary key-store failure leaves records and key unchanged; retry succeeds
  when access returns. This is injected failure, not native secure-storage proof.
- File-provider read/write errors, safe messages without path leakage, retry,
  stale-preview rejection and simulated background/resume without duplicate
  submission. Native dialogs remain injected in widget tests.
- Four separate host process-interruption cases: SIGKILL before/after restore
  commit in DELETE/WAL mode. The before-commit barrier follows workspace/image
  mutations with forced SQLite cache spill. A fresh process verifies complete
  original or restored state and images, never a partial mixture.

Verification: `bash scripts/check.sh` passes formatting, static analysis,
**136 Flutter tests including the unchanged 16 golden comparisons**, and backend
format/lint/build/health checks. `python3 scripts/check_backup_interruptions.py`
passes all **four** additional interruption cases. These are host tests, not
hardware power-loss tests. No native rebuild was needed: application/plugin
sources are unchanged from the passing checkpoint 5 debug builds.

See the [recorded evidence and deterministic physical test procedure](verification/backup-device-checklist.md).
The physical-device task remains blocked on hardware; no release-readiness claim
is made. Recovery still requires a saved portable backup and its password.

## Receipt/OCR audit — 8 October 2026 (historical task baseline)

At this task baseline, the runtime `/receipt` route was an unavailable placeholder. The approved native
review prototype exists under test/legacy only. No camera/gallery or OCR package,
permission configuration, preprocessing or receipt-text parser exists at this
baseline. ReceiptDraft supports items and per-item confidence, but assumes an
item-sum total and calculated included VAT; those assumptions are unsuitable for
real receipts. Production commands can post receipt metadata and expenses, and
Drift can encrypt image bytes, but those operations are not yet one atomic capture
commit and deletion does not clean up image rows. Backups already include metadata
and all stored images. This task will connect those existing boundaries, preserve
Stitch's review hierarchy and keep all fake OCR in tests. Physical hardware remains
unavailable and is not required for automated completion.

Receipt milestone 1: engine-independent OCR document geometry and deterministic
Philippine receipt parser implemented. Label-ranked totals exclude tender/change
and tax classifications; date ambiguity and missing fields remain explicit.
Confidence represents parser heuristics, not measured recognition accuracy.
Formatting/static analysis and 34 parser cases pass. Camera/OCR/review wiring
remains the next milestone; this audit is not completion of the receipt feature.

Receipt milestone 2: reviewed evidence now retains raw OCR text, parser version,
creation time, field confidence, independent final total and actual adjustments.
Legacy snapshots remain readable through an optional evidence extension; no Drift
schema rewrite. Missing tax is no longer fabricated from a blanket percentage.
Image plus expense/metadata saves are atomic; deleting the receipt transaction
removes its image in the same transaction. Backup rejects missing required image
references. Full Flutter validation passes: analysis clean, 172 tests including
all 16 existing goldens. New tests cover failed image-write rollback, retry,
balance/budget/analytics updates, categorization, duplicate submission, file-backed
restart, encrypted backup round trip and image deletion. Native capture/UI pending.

Receipt milestone 3: native camera/photo acquisition, permission recovery,
private staging, orientation/size normalization, manual crop/rotation and the
Google ML Kit Latin OCR adapter are implemented. Five adapter/preprocessing tests
pass. Android debug APK and iOS simulator debug builds pass. iOS now requires
15.5 and CocoaPods alongside SwiftPM. ML Kit's simulator libraries support
x86_64 only: the simulator artifact builds, but cannot run on the installed
Apple Silicon iOS 27 simulator. This is a native dependency limitation, not a
successful simulator runtime check. Android uses permission_handler 12.x to
remain compatible with the existing SDK 36 toolchain. Review wiring and UI
verification are the next checkpoint; physical camera checks remain pending.

Receipt milestone 4: `/receipt` now opens real capture/review and persists through
production commands. Merchant/date/items/independent totals/currency/category and
account can be corrected; explicit verification is required. Empty/failed OCR can
be completed manually. Native capture/crop cancellation retains the review; failed
saves retain image and corrections. A fresh user can create an account without
losing the review. Transaction Detail reopens the saved receipt; deletion explains
and removes its image. Test-only fake adapters/generator support five new receipt
goldens. Stitch structures are preserved; honest confidence/privacy/confirmation
copy replaces fabricated confidence, auto-crop, tax and rewards claims.

Verification at this checkpoint: all 193 Flutter tests pass (21 current golden
comparisons), static analysis and formatting pass. Backend formatting, lint,
build and its health test pass through `scripts/check.sh`. New flow tests include
budget-notice evaluation, corrections, explicit account choice, concurrent-save
protection, native cancellation/error handling, save retry and saved-image UI.


## Receipt feature completion and final verification — 8 October 2026

The requested receipt capture/OCR/review/save implementation is complete. This is
an implementation and automated-verification milestone, not physical-device or
release certification. There is no runtime mock OCR or sample receipt injection.
The obsolete prototype controller is now test-only. Native UI follows Stitch;
required review/uncertainty controls extend its sheet without replacing its cards
or hierarchy. No backend endpoint, provider integration or release package was added.

Verified implementation commits:

- `b987324`: deterministic Philippine parser and independent OCR document model.
- `46f4035`: persisted extraction evidence, atomic image/expense writes and cleanup.
- `333f7be`: native camera/photo/crop, preprocessing, ML Kit and platform setup.
- `e6d0a05`: real review/corrections/account selection/save/reopen and UI goldens.
- `720a53f`: test-only legacy controller, corrupt-image fallback coverage and a
  merchant-rule key validation fix. Kind prefixes/Unicode normalization can make
  the rule key longer than the supported 100-character display name; the old
  100-character key bound wrongly rejected valid remembered categories. No
  balance, budget, analytics calculation or database schema rewrite was needed.

Final verification on this code:

| Check | Result |
| --- | --- |
| `bash scripts/check.sh` | Formatting clean; Flutter analysis clean; **195 Flutter tests pass**, including **21 current golden comparisons**; backend format/lint/build and 1 health test pass. |
| `flutter build apk --debug` | Pass, final Android debug APK. |
| `flutter build ios --debug --no-codesign` | Pass, unsigned arm64 iPhone debug app; built minimum iOS 15.5. No device install claimed. |
| `flutter build ios --simulator --debug` | Pass, x86_64 simulator artifact; **not runnable on installed Apple Silicon iOS 27** because ML Kit lacks arm64 simulator binaries. |
| `python3 scripts/check_backup_interruptions.py` | Four host process-kill cases pass: DELETE/WAL journal modes, before/after restore commit; complete data/images reopen. |
| Visual inspection | New normal/dark/error receipt goldens compared with approved Stitch. Real image preview, field confidence and confirmation replace prototype claims. Small-screen/large-text widget check passes. |

Direct dependencies added: `google_mlkit_text_recognition` 0.17.1, `image_picker`
1.2.4, `image_cropper` 12.2.1, `image` 4.10.1 and `permission_handler` 12.0.3.
`path_provider` 2.1.6 is now direct for private staging. Lockfiles include native
ML Kit/CocoaPods and cropper SwiftPM resolution. Current Flutter warns that ML
Kit's CocoaPods fallback will need upstream SwiftPM support in a future version.

Remaining blockers/limits: physical Android/iPhone capture, permission, offline
first-use, background/resume, thermal-receipt quality, low-storage and cross-device
restore acceptance remain pending because hardware is unavailable. Host/fake-
adapter tests do not establish recognition accuracy. Parser confidence is
heuristic; whole printed amounts without decimals, fractional quantities and
complex receipt layouts may require corrections. There is no automatic perspective
correction. Unsaved edits are session-only. Existing backup image/JSON limits can
block export of large receipt collections; no image is silently omitted.

Recommended next production task: run the [receipt device/corpus acceptance
checklist](verification/receipt-device-checklist.md) alongside the already pending
backup-device checks when dedicated devices are available. While hardware remains
unavailable, a separately scoped versioned streaming backup improvement can address
receipt-collection size limits. See [receipt architecture and privacy](receipts.md)
for the complete behavior and [backup recovery](backup.md) for the saved-file and
password requirement.

## Physical Android deployment checkpoint — 12 October 2026

A physical Redmi 14C (`2409BRN2CA`, Android 16/API 36, ARM64) is now connected
and authorized as `NBDEXCJNL7JR9DIJ`. This supersedes the earlier hardware
availability limitation for Android; iPhone acceptance remains pending.
Source inspection confirms the production encrypted local runtime remains active
without demo injection. Actual device initialization has not yet been verified:
Xiaomi rejected the debug and release installation attempts with
`INSTALL_FAILED_USER_RESTRICTED`, including after the owner reported enabling
Install via USB. Normal installation approval/manual installation is pending.
No application or unrelated phone data was cleared.

A repository-caused release R8 failure was fixed with eight narrowly scoped
warnings for optional ML Kit script recognizers; PesoFlow uses the bundled Latin
recognizer. R8 stays enabled and no optional models were added. Debug APK, release
APK and release App Bundle builds pass. Formatting, analysis and all 195 Flutter
tests (21 current goldens) pass after the fix. Existing debug signing remains;
build success does not establish store readiness or physical OCR behavior.

See [the physical Android verification record](verification/android-device-test.md)
for the explicit pending hardware checks. Next: complete the phone's normal
installation approval, then test real account/transaction/budget/analytics,
restart, permissions and receipt flows through the production UI. Automated
verification must not be reported as physical-device acceptance.


Physical Android follow-up: the installation restriction was resolved after the
owner completed the phone settings/approval steps. The debug production app now
runs on the Redmi. UI-created GCash/Cash accounts, PHP 325 expense, PHP 1,000
income, PHP 500 transfer and Food & Dining allowance produce correct balances,
expense/income totals and category analytics. Editing the allowance to PHP 400
produces an 81% warning. Scoped process termination/relaunch preserves the
records, edited budget, notice and explicitly selected light appearance;
background/resume passes. Native Latin OCR execution has reached receipt review,
but extraction correction/save and permission acceptance remain in progress.
See the device record for exact values and limits; this is not release readiness.


Physical receipt follow-up: owner-verified corrections now save a real image and
expense through the production commands on Android and reopen after process
restart. Two hardware-discovered receipt defects were fixed: electronic tender
misclassified as an item, and colliding scroll/expansion/selectable-text storage
keys causing a receipt render cast error. Parser version 2 preserves version 1
evidence readability; no database or financial engine rewrite. Formatting,
analysis, all 198 Flutter tests (21 goldens), release APK and App Bundle pass.
Extraction of the original paper receipt required manual total/date/item
corrections; successful OCR execution is not a claim of extraction accuracy.
Final release-mode/denied-permission checks remain in progress.


## Final physical Android checkpoint — 12 October 2026

This supersedes the installation, permission and release-OCR pending statements
in earlier checkpoints for the checks actually completed. The production app now
runs in optimized release mode on the physical Redmi 14C, retaining UI-created
accounts, expenses, income, transfer, budgets and appearance through process
restart and APK update. Category budget deletion/recreation and period-specific
analytics also pass. Home ends at PHP 5,195; the August PHP 480 receipt expense
remains excluded from October's PHP 325 spending and +PHP 675 net flow.

Release-only ML Kit discovery failed because R8 removed three manifest-discovered
registrar constructors. Narrow keep rules retain their reflection entry points;
shrinking stays enabled and no model/dependency was added. The repaired release
captured and recognized the owner's receipt, and the previously saved image and
corrections reopened after restart. Duplicate capture review was discarded.
Recognition still requires manual merchant/date/item corrections; there is no
accuracy or confidence-rate claim. Approved UI layouts and the financial engine
remain intact.

Permanently disabled camera recovery passed with an ADB-induced permission state;
the original Camera grant was restored. Ordinary denial and the Settings link's
exact destination were inconclusive. No app/phone data was cleared. OS notifications
and biometric unlock remain unimplemented. iPhone, airplane-mode first scan,
native backup dialogs/cross-device restore, isolated low storage, lock/orientation,
accessibility, large collections and the broader receipt corpus remain unverified.

Final repository checks pass: clean formatting/analysis, **198 Flutter tests with
21 golden comparisons**, backend format/lint/build and one health test. Final
release APK and App Bundle build; existing debug signing is unchanged and this
is not store readiness. See [physical Android results](verification/android-device-test.md)
for evidence, privacy limits and remaining acceptance cases.

Recommended next task: dedicated-device backup/file-dialog and cross-device restore
acceptance, including interruption and isolated low-storage checks. Recovery needs
a saved backup and its password. Expand consented/redacted receipt-corpus coverage
before relying on extracted fields without review.


## Physical Android backup recovery — 12 October 2026

The single-device local backup/reset/restore acceptance task passed on the
production release installed on Redmi 14C (`NBDEXCJNL7JR9DIJ`, Android 16,
`0.1.0+1`). An owner-password-encrypted external backup was created, selected again
and authenticated with correct preview/image counts before the user-authorized
`pm clear com.pesoflow.pesoflow`. The cleared installation showed production empty
states; native DocumentsUI selection and confirmed restore recovered three
accounts, four financial records, one budget, preferences and the real receipt
image. Home returned to PHP 5,195. Restart and background/resume passed.

A PHP 1 post-restore expense saved durably, updated balance/budget/analytics and
survived restart. Wrong password, modified ciphertext and invalid-file attempts
left those newer records intact. Save/selection/replacement cancellation passed.
The same password subsequently unlocked the original file. Confirmed replacement
removed the temporary expense; repeated restore/restart retained the original
state without duplicates. Final CSV records matched all original transaction
columns and identities exactly; the valid external backup remained unchanged.
Only this run's invalid/corrupted test documents and plaintext verification CSVs
were cleaned up. The original encrypted Downloads backup remains with the owner.

No application-code/dependency/architecture change was needed. Validation passes:
186 formatted files unchanged, analysis clean, 198 Flutter tests including 21
golden comparisons, backend format/lint/build and one health test, four isolated
host restore-interruption cases, release APK and App Bundle. Existing debug
signing is unchanged; this is not store readiness. See
[the dedicated physical backup report](verification/backup-restore-device-test.md)
for the audit, exact results and rollback/security boundaries.

Remaining acceptance gaps: second-device Android/iPhone restore, cloud providers,
safely controlled physical low storage, phone lock/recents removal, exact physical
restore interruption boundaries and populated plan restoration. No external
credential is needed for the completed local flow. Recommended next: cross-device
round trip with a second dedicated device and the saved backup/password, then
provider/storage/interruption tests. Ordinary camera denial, Settings recovery
and broader receipt accuracy remain the earlier task's separate gaps.
