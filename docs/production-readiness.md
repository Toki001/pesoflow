# Production readiness — 16 October 2026

PesoFlow is a local-first expense tracker without login, registration, profiles,
mandatory authentication or Backup/Restore. The 13 approved Stitch v7 screens are
integrated natively with persisted financial data. This is an implementation and
automated-verification checkpoint, not release certification.

## Screen status

| Screen | Implementation and automated checks |
| --- | --- |
| Home Dashboard | Implemented: actual balance/cash flow/accounts/budgets/recent records |
| Transactions | Implemented: search/filters/period/detail/CSV |
| Add Expense | Implemented: amounts/category/account/date/time/notes/receipt flow/save |
| Add Income & Internal Transfer | Implemented: shared form; transfers remain financially neutral |
| All Accounts | Implemented: grouped accounts/card metadata/credit limits/history/edit/archive |
| Budgets | Implemented: real limits/progress/pacing/create/edit/reallocation |
| Analytics | Implemented: periods/comparison/chart/categories/merchants/payment sources |
| Transaction Detail | Implemented: local status/info/budget impact/notes/receipt/edit/delete |
| Subscriptions & Bills | Implemented: commitments/upcoming/active/annual/paused/history |
| Receipt Scanner | Implemented: actual system camera/gallery/crop/permission/error flow |
| Receipt Review | Implemented: actual image/OCR corrections/notes/confirmation/atomic save |
| Notifications | Implemented: real persisted notices/filter/read state/preferences |
| Settings | Implemented: appearance/category visibility/default account/alerts/native version/privacy |

[UI mapping and deliberate differences](ui-reference.md) describes the shared
palette, Inter typography, app bars, cards, form controls and bottom navigation.
Captured images were inspected against each approved PNG. Content-dependent heights,
font wrapping and icon glyphs differ; no pixel-identical claim is made. Manual
icons replace unavailable licensed logos. Native camera entry replaces unsupported
fake edge/flash/multi-page controls. Review retains warnings and explicit checks.
Category management controls visibility; currency remains PHP without conversion.

## Preserved storage and financial integrity

FinanceBootstrap opens encrypted Drift before rendering; FinanceController publishes
only durable atomic writes. Database `pesoflow`, schema 1, Android application ID,
key `pesoflow.financial-data-key.v1`, AES-GCM nonces and associated data are unchanged.
Pre-v7 JSON still opens without rewriting ciphertext; optional old identity/sync
fields are ignored. New card metadata, preferences and receipt notes have defaults.
No financial records were cleared, reseeded or imported during this work.

Tests verify restart persistence, transfers/refunds, account identity, credit limits
outside cash totals, budget/analytics projections, save failure rollback, stale
writes, receipt confirmation/duplicate protection, atomic image insertion/deletion
and saved-image reopen. Fresh installations open Home with empty collections.
Receipt capture/gallery/crop and Latin ML Kit OCR remain on-device.

## Removed code and dependencies

Portable backup/password cryptography/restore/replacement commands, recovery routes,
feature-only tests/docs and obsolete introductory identity/sync preferences were
removed. No login/backend-auth implementation existed to retain. Dead connection
UI, profile-name projection, unused providers/transport and prototype storage/UI
were deleted. Required financial regression helpers remain test-only.

Dio and dio_web_adapter were removed. No new package was added. Drift, cryptography,
secure storage, image/receipt adapters and file_picker remain required. CSV export
is a one-way readable report. Existing external saved documents were untouched.

## Verification results

- `dart format --output=none --set-exit-if-changed .`: PASS, 162 files, no changes.
- `flutter analyze`: PASS, no issues.
- `flutter test`: PASS, **219 tests**, including **29 golden comparisons**:
  12 screen states × light/dark plus 5 receipt-review states. Tests include compact
  200% text, landscape and software-keyboard layout checks.
- Backend `format:check`, `lint`, `build`, `test`: PASS, 1 health integration test.
  The test needed localhost access outside the filesystem sandbox.
- `flutter build apk`: PASS, final release APK approximately 99.8 MB.
- `flutter build appbundle`: PASS, final AAB approximately 80.7 MB.
- `flutter build ios --debug --no-codesign`: PASS, final unsigned device build.
  A missing local ML Kit framework
  binary was recovered from the matching CocoaPods cache; no dependency upgrade.

Android release configuration still uses development signing. APK/AAB artifacts
are not store-ready signed releases. iOS is unsigned. The retained ML Kit dependency
still lacks the arm64 simulator support needed for this Mac's iOS 27 simulator;
an unsigned device compile does not establish camera/permission runtime behavior.

## Physical acceptance and next task

**V7 physical-device testing: NOT TESTED.** ADB discovery on 16 October returned no
attached devices. No app was installed/uninstalled, cleared or reseeded. The prior
12 October Redmi evidence remains historical: PHP 5,195 across three accounts/four
transactions, one budget and one saved receipt. See the [device report](verification/android-device-test.md).

Next: in-place upgrade on the existing Redmi and a dedicated iPhone runtime check.
Verify those existing records/images before and after restart, all navigation/forms,
actual installed version, CSV dialog, camera/gallery/crop and permission recovery.
Never uninstall or clear data to bypass signing/installation errors. No recovery
feature is available. Broader real-receipt accuracy, offline first scan, low storage,
large collections and screen-reader acceptance remain gaps. OS notification delivery,
external financial providers and release signing are outside this implementation.
