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

## Android follow-up — 16 October 2026

The supplied root `logo.svg` now generates Android/iOS launcher icons through
`scripts/generate-app-icons.swift` (macOS Quick Look/CoreGraphics; no new package).
Native icons replace the Flutter defaults; iOS images are opaque. Section cards
are borderless in light/dark themes. Input and selection outlines remain functional.
Budgets now exposes Subscriptions & Bills directly; Settings retains its entry.
Home distinguishes archived accounts from a genuinely empty installation.

Final follow-up checks: formatting PASS (162 files), analysis PASS, **220 Flutter
tests PASS**, including 29 updated golden comparisons. Reviewed Home/Budgets and
subscription captures, including the physical Android subscription screen.
APK PASS (99.8 MB), AAB PASS (80.8 MB), unsigned iOS device compile PASS.
Backend code was unchanged; its passing results above are from the prior checkpoint.

**Physical Android: partial acceptance PASS.** The existing Redmi was upgraded
using `adb install -r`, without uninstall/reset/reseed/key changes. The current
pre-update dataset differs from the historical October 12 test dataset. Its
PHP 1,642.50 total (two active accounts), PHP 47.50 October expense, PHP 1,000
category budget and PHP 799 monthly subscription remained accessible after the
update; a cold process restart preserved balances and expense details. Archived
accounts remained visible. No financial records were created/edited/deleted for
these checks. See [device evidence](verification/android-device-test.md).

Verified navigation includes Home, Accounts, Transactions/detail, Analytics,
Budgets, Subscriptions/details/Add form, Notifications and Settings/native version.
Expense/Income/Transfer forms opened; no test writes were made to the current data.
Native gallery opened and canceled safely. CSV cancellation returned to the app;
the save-dialog hierarchy was not captured reliably, so full file-save acceptance
is still pending. Camera/OCR/crop, saved-image reopen, low storage, accessibility
and comprehensive interrupted-write scenarios were not repeated in this follow-up.

**Physical iPhone: unavailable**, as confirmed by the owner. Keep compile-only
results separate; an iPhone is not a prerequisite for continuing Android work.
Next: owner-assisted Android receipt capture/reopen and CSV save acceptance, then
broader accessibility/low-storage checks on an isolated test installation. Never
clear this phone or uninstall to work around an installation error. Development
signing and the ML Kit simulator limitation above remain unchanged.
