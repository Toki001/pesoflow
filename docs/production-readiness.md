# Production readiness — 19 October 2026

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


## Receipt recognition and screenshot corrections — 17 October 2026

Notifications combines alert type with an independent unread filter and reports
matching versus total notices. Budgets keeps the period separate, places New by
Category Budgets, and exposes Subscriptions & Bills below the category list.
Icons remain brand blue; financial amounts/progress preserve semantic colors.
Review offers separate Rotate and Crop actions without changing the approved
screen hierarchy.

OCR now tries up to three local recognitions: original, grayscale/contrast, and
paper-shadow correction when essential fields remain missing. Image derivatives
run off the UI isolate and never replace the saved evidence. A selected pass must
improve extraction without losing or contradicting an existing total, date or
payment method. Invoice titles are excluded from merchants, invoice serials are
excluded from items, and paper layouts tolerate common title OCR errors. Cash is
explicitly a suggestion when no electronic tender is stated; confirmation remains
mandatory. No OCR text or private receipt photo is committed or uploaded. No new
package, financial-engine rewrite, schema change or key change was introduced.

Automated verification: formatting PASS (163 files), analysis PASS, **234 Flutter
tests PASS**, including 29 golden comparisons. Added tests cover shadow flattening
with retained ink/source bytes, fallback failures/cleanup, and conflicting
amount/date/payment protection. Native recognition quality is evaluated separately
from mocked-adapter tests; this is not a handwriting-accuracy claim.

Release APK (100.0 MB), App Bundle (81.0 MB), and unsigned iOS device compile PASS.
Android still uses development signing; iOS runtime testing remains unavailable.
Backend was unchanged and was not rerun at this checkpoint.

Physical Android follow-up confirmed the repaired merchant, no invoice-number
items, explicit Cash suggestion and separate blue image controls on the owner's
paper invoice. The handwritten amount/date remained unrecognized. This image is
720×405; preprocessing cannot guarantee recovery of missing detail. The first
three-pass build also exposed a roughly 40-second fallback cost. A subsequent
verified optimization uses one luminance channel, linear upscaling and fast
lossless PNG encoding. All checks above include that final code.

At this checkpoint, optimized timing, native editing, test-copy cleanup and the
final restart were still pending. The 18 October results below supersede that
pending status. See [device evidence](verification/android-device-test.md).


## Pre-scan editing and invoice field layout — 17 October 2026

Milestone `ac5a728` introduces Prepare Receipt: capture/gallery/recovery stops at
an image preview, Rotate/Crop can run before OCR, and Scan receipt explicitly
starts recognition. Editing an already reviewed image requires confirmation and
returns to preparation; cancel preserves the prior image/review. No financial
record is created during preparation or recognition.

Milestone `2078a8d` adds parser-v4 geometric field associations. Amount-column
values below the header are matched to table rows; one complete row may suggest a
low-confidence total only when no explicit total/adjustments exist. Multiple or
unreadable rows do not generate a guessed total. The Date field above Received
From takes priority and preserves an adjacent time. Missing/invalid form dates
cannot fall back to printer registration dates. Evidence versions 1–3 remain readable; schema/key/financial
commands are unchanged. These rules process recognized digits, not the owner's
known expected values. Handwriting recognition remains limited by the OCR engine.

Formatting and analysis PASS; **246 tests PASS, including 31 golden comparisons**.
The release APK builds successfully (100.1 MB). New preview light/dark captures
were inspected against the existing receipt card/header/control patterns. Backend
code is unchanged. After reconnection on 17 October, the APK installed in place,
Prepare Receipt appeared without automatic OCR, rotation changed the photo and
the native crop editor opened. Crop completion, final recognition timing and
restart verification were interrupted; the 18 October follow-up resumes these
checks. No test financial records were saved.


## Connected-device completion — 18 October 2026

Milestone `40095ff` adds immediate scan-button status, screen-reader live status,
reduced-motion progress behavior and brand-blue native Android crop toolbar,
frame and active controls. Preparation/review tests pass at 200% text in narrow
portrait and landscape. Existing Stitch layouts and financial commands are retained.

Final checks: formatting PASS (165 files), analysis PASS, **248 tests PASS,
including 31 golden comparisons**, release APK PASS (100.1 MB), App Bundle PASS
(81.1 MB), unsigned iOS device compile PASS. The first iOS attempt failed because
one local MLKitTextRecognitionCommon framework binary was missing. Reinstalling
that pod at locked version 6.0.0 restored the build without dependency/lockfile
changes. Backend was unchanged and not rerun. Development signing and physical
Apple-device/simulator limitations remain.

On the Redmi, an in-place update preserved the initial saved balances. Photo
selection, rotation and completed native cropping all returned to Prepare Receipt
without starting OCR. Explicit scanning reached review in approximately 12.4
seconds (UI-polling upper bound, one edited sample; not a benchmark), versus the
previous roughly 40-second observation. Merchant cleanup, no serial-number items
and explicit Cash suggestion were verified. The low-resolution handwritten total
and date were still unreadable and correctly required correction; this remains
an OCR accuracy limitation, not a completed handwriting acceptance test.

No financial save was issued during verification. After a multi-hour interruption,
Home contained a different current balance; that state was preserved rather than
reverted. A cold restart retained it. Only the identified temporary test-photo
copy was deleted; original photos and saved receipt evidence were untouched.

Next: assess a consented set of clearer printed and handwritten receipts with
verified expected fields, measuring accuracy separately from parser tests. Fresh
camera capture, saved-image reopen and broader low-storage/CSV acceptance remain
separate checks. See the dated device report for exact scope.

## Clearer gallery receipt follow-up — 18 October 2026

The owner authorized testing the latest clearer receipt photo in the gallery.
Its first scan exposed a parser defect: an OCR spelling error in Received From
disabled the form-date guard and allowed a printer-issued date as a suggestion.
Milestone `051db9e` tolerates that narrow label error while retaining strict
numeric parsing and manual confirmation. A synthetic regression failed before
the fix and passes afterward; no private image/text or known expected financial
value is embedded in tests.

Verification: format/analyze PASS; **252 tests including 31 goldens PASS**; APK,
AAB and unsigned iOS build PASS. No dependency, UI, schema or key changes. The
clearer photo still does not establish reliable handwritten OCR: its first scan
took approximately 34.6 seconds and omitted the handwritten transaction amount
and date from extracted text. Missing digits cannot be recovered by label parsing.

The corrected APK installed in place and rescanned the same unedited photo in
approximately 33.9 seconds. Physical review confirmed the printer date is no
longer selected: the date is missing and today's fallback is explicitly flagged
for correction. Total/items remain missing; the merchant suffix also needs
correction. Cash remains an explicit suggestion. The test review was discarded,
the original gallery image retained, and Home remained at PHP 1,542.50 total and
PHP 147.50 October spending. Next OCR work should evaluate handwriting recognition
and field-focused recognition against varied consented examples, with false-date
and false-total checks retained; another generic contrast pass is not established
as a solution by this result.

## Isolated receipt-field experiments — 18–19 October 2026

The owner supplied crops identifying the Amount cell and transaction Date field.
Both were tested on the Redmi, followed by matching crops from the authorized
4080×3072 gallery original. The tiny date attachment received blank padding only
to satisfy the existing minimum input height; no digits were modified. Across
four scans, the selected extracted text contained no usable handwritten amount
or transaction date. The full-resolution crops also failed this acceptance check.

This is a failure of the current end-to-end recognition pipeline on these samples,
not proof that every internal ML Kit pass returned identical text: individual
pass outputs were not collected. Automatic field-region recognition is therefore
not added based on these experiments. Next: evaluate per-pass results and a
handwriting-capable recognizer locally on varied consented samples, preserving
review gates and rejecting conflicting or fabricated values.

All test reviews were discarded; four identified temporary gallery files and
local crop-test copies were removed. The original gallery receipt remains, and
Home retained PHP 1,542.50 total and PHP 147.50 October spending. No application
code, dependencies or financial records changed in this checkpoint. The prior
252-test/build results remain the latest code verification; these experiments
are physical recognition checks, not additional passing unit tests.

## Per-pass and offline handwriting evaluation — 19 October 2026

Diagnostic tooling milestone `6df3c94` separates native recognition from parser
and pass selection. A temporary, offline Android test app collected all 15 native
ML Kit outputs for the full authorized image and four field crops, each with
three preparation variants. None contained the correct target amount/date; the
production parser also found neither. For these inputs, selection is not hiding
a successful pass. The test app was removed and PesoFlow's Home baseline retained.

Two pinned TrOCR handwriting models were evaluated locally on the Mac, without
uploading receipt data. TrOCR-base recovered the correct amount token in one of
six amount variants, with extra punctuation, but neither model recovered the
date in six date variants. Both produced output from a blank control. This partial
amount success is insufficient to ship a replacement recognizer. No production
code, dependency, financial data, schema or key changed.

Verification: formatting PASS (167 files), analysis PASS, all **252 tests including
31 goldens PASS**, Python tooling compilation PASS, standalone Android diagnostic
build/permission checks PASS. Production APK/AAB/iOS and backend builds were not
rerun for this test-tool-only checkpoint. See the [evaluation report](verification/receipt-ocr-evaluation-20261019.md)
for model revisions, exact versus token-match results, timing limits and the next
gate: evaluate numeric handwriting on varied consented fields with false-positive
controls before selecting an on-device implementation. Handwritten field acceptance
remains open; explicit correction remains required.

## Lightweight OCR candidates and field scoring — 19 October 2026

Milestone `5b4cec6` adds test-only offline PP-OCR runners, 28 generated printed/
blank/invalid-field controls and strict field scoring. Two pinned official models
each processed 12 private crop variants plus these 28 controls. Neither recovered
the real handwritten fields. The English model produced one valid-looking wrong
amount with raw character score approximately 0.946; this is not calibrated
financial confidence. Neither model is integrated into PesoFlow.

The owner confirmed only the existing Skyline receipt is available. Broader
handwriting accuracy remains unverified; repeated crops and synthetic controls
are not independent receipt samples. The new scorer distinguishes exact text,
correct values, wrong values, unparsable output and negative-control false positives.
It is test infrastructure, not a production parser or automatic financial writer.

Verification: 8 Python scoring regressions PASS; Python formatting/compilation
PASS; Dart formatting PASS (167 files); Flutter analysis PASS; **252 Flutter tests
including 31 goldens PASS**. Production builds and backend checks were not repeated
for Python test tooling. No app UI, runtime dependencies, finances, schema or keys
changed. See the [candidate evaluation](verification/receipt-ocr-lightweight-evaluation-20261019.md)
for measured failures and limitations. Keep manual field confirmation; broader
consented examples are needed before promoting a replacement handwriting engine.

## Pixel-preserving preprocessing performance — 19 October 2026

The shadow pass now interpolates its small paper-lighting estimate directly into
the correction, avoiding a full-resolution background allocation. Single-channel
normalization uses a byte lookup table. Quantization/interpolation order is retained;
non-byte/color/oriented-paper cases retain the original library path. OCR pass
selection, resolution, thresholds, source evidence and financial commands are
unchanged. This improves processing efficiency, not handwriting recognition.

Ten new regression tests compare every output pixel with the prior library
operations, including all 32,896 byte-luminance ranges, varied resize geometry,
constant/black illumination and fallback formats. Complete old/new contrast and
shadow derivatives also produced identical PNG bytes on a synthetic 3000×2250
image in a temporary AOT comparison. Desktop observations: contrast 1,806 → 1,560
ms; shadow 3,167 → 1,783 ms. These are single synthetic processing observations,
not Android scan timings. A committed synthetic benchmark checks pixel equality
before reporting the targeted operations' timings.

Verification: formatting PASS (170 files), analysis PASS, **262 Flutter tests
including 31 goldens PASS**; APK (100.1 MB), AAB (81.1 MB) and unsigned iOS device
build PASS. No dependency/schema/key/UI changes. Backend was unchanged and not
rerun; existing signing and physical-iPhone limitations remain.

The Redmi was updated in place with `adb install -r`. Home's visible monetary
values matched a privately captured pre-update baseline both after installation
and after a cold process restart. No financial save/reset/reseed or gallery edit
was issued. The private baseline was deleted after comparison. This verifies the
visible Home baseline, not every record; camera/OCR end-to-end timing was not
repeated. See [device verification](verification/android-device-test.md).

## Public handwritten receipt test set — 19 October 2026

Two openly reusable handwritten receipt photos now live in test-only fixtures,
with original bytes, hashes, attribution/licenses and manually annotated field
crops. No user receipt was uploaded or committed. Existing offline TrOCR-base and
English PP-OCR runners each processed 12 variants from four fields. Strict
whitespace-normalized transcription matched 0/12 each, although TrOCR recovered
one date's digits with extra punctuation in all three variants. PP-OCR produced a
wrong date with raw score 0.902. Historical British and Indonesian monetary formats
are transcription probes, not supported PHP parsing examples or runtime fixtures.

See the [public evaluation report](verification/receipt-ocr-public-evaluation-20261019.md)
for complete outputs, attribution and reproduction instructions. Two new receipts
do not establish broad handwriting accuracy. No alternative recognizer is promoted;
review remains mandatory. Fixture hashes/crop generation, 24 local predictions and
8 Python scoring regressions pass. This test-data/docs-only milestone retains the
preceding 262-test/build/device results; production builds were not repeated.

## UI/UX audit and OCR scope decision — 19 October 2026

At the owner's request, further handwriting model research is deferred. Unreliable
handwritten amount/date recognition is a documented product limitation. Retain
manual correction and explicit review; no handwriting-accuracy promise is made.

Applied the apple-design skill to a native UI/UX review while preserving Stitch
v7. Fixed two reproduced accessibility issues: Appearance options now scroll rather
than overflow at 200% text in landscape, and Subscriptions' sort control now has a
48px minimum target. Added 12 screen-entry label/touch-target checks plus a sheet
interaction regression. Updated and inspected only the two subscription goldens.

Formatting PASS (171 files), analysis PASS, **275 Flutter tests including 31 goldens
PASS**. No package, storage, financial-engine or OCR changes. The
[review report](verification/ui-ux-review-20261019.md) records remaining contrast,
TalkBack and global reduced-motion checks. These checks do not establish complete
accessibility compliance. Next priority is semantic text/dark-icon contrast,
followed by assistive navigation; do not resume OCR experiments by default.

Release APK (100.1 MB), AAB (81.1 MB) and unsigned iOS device build PASS for these
UI fixes. Android remains development-signed; physical iOS runtime verification
is unavailable. Backend was unchanged and was not rerun.

The Redmi received the APK in place. Visible Home amounts matched the private
pre-update baseline after update and cold restart; the baseline was then deleted.
No financial writes or preference changes were issued. Physical TalkBack and
large-text landscape interaction checks remain pending; widget tests verify the
specific UI fixes. See [device evidence](verification/android-device-test.md).

## Contrast, semantics and reduced motion — 19 October 2026

Readable light-theme foregrounds now use darker green/amber/red and action blue;
brand blue fills remain. Shared category/status icons choose a brighter blue on
dark badge surfaces and retain brand blue on pale backgrounds. Shared budget
progress bars map the foreground roles back to the original fill colors. The
approved layout, typography, icon meanings and financial semantics are unchanged.
CODEX.md records the foreground variants explicitly.

New regressions require at least 4.5:1 for the tested semantic/action foregrounds
on canvas/card/muted/badge surfaces in both themes and 3:1 for the tested badge
icons. These are defined token combinations, not a blanket accessibility claim.
Main/task titles expose heading semantics. Bottom navigation tests verify single
labels, selected state, button role and activation through a semantic tap action.

With system disableAnimations enabled, page navigation and theme changes are
static; all 17 app bottom-sheet calls request no animation. Native transitions
remain when the setting is off. Tests navigate to Settings, open/dismiss Appearance,
and return Home with the feature both on and off. Existing receipt processing
already suppresses its animated progress indicator under the same setting. Native
camera/crop/picker UI and full screen-reader speech remain separate device checks.

Verification: formatting PASS (172 files), analysis PASS, **282 Flutter tests
including 31 goldens PASS**; APK (100.1 MB), AAB (81.1 MB), unsigned iOS device
build PASS. Updated contrast captures were generated without weakening comparisons;
representative Home light, Accounts dark, Analytics light and Receipt Review dark
captures were visually inspected. No runtime packages/storage/OCR changes. Backend
unchanged, not rerun. Signing/iPhone runtime limitations remain.

Redmi update installed in place and post-update visible Home values survived a
cold restart. A pre-update baseline could not be captured, so no before/after
comparison is claimed for this update. The owner-assisted TalkBack speech check
is pending feedback; automated semantics/motion results above are verified.

## Visual consistency follow-up — 19 October 2026

Home Spending/Income and Accounts balance/credit pairs now share their height in
the two-column layout, including differing caption wraps. Larger-text layouts
retain stacked cards. Transactions, Analytics and Budgets now use filled selected
navigation icons consistently with Home. Pending labels, Analytics' increased-
spending badge and receipt-review notices/items use neutral surfaces rather than
yellow highlights; status messages, warnings and confirmation behavior remain.

Nine new visual-layout regressions cover empty/populated metrics at 320px and
390px plus selected/unselected navigation icons. Formatting PASS (173 files),
analysis PASS, **291 Flutter tests including 31 goldens PASS**. Relevant captures
were updated and inspected. APK (100.1 MB), AAB (81.1 MB) and unsigned iOS device
build PASS. No dependencies, financial calculations, schema or key changes.
Backend unchanged, not rerun; existing signing and iPhone runtime limits remain.

The Redmi received an in-place update. A physical capture confirmed aligned Home
Spending/Income cards with a wrapped caption. Visible Home amounts matched the
private pre-update baseline after installation and cold restart. Temporary device
captures and the private baseline were deleted. No financial writes were issued.

## Modern surface refresh — 19 October 2026

The owner supplied new inspiration images and authorized a modern visual treatment
beyond the original flat Stitch surfaces. Home now has a deep-blue gradient balance
card with readable inset labels. Shared cards use rounded, softly shaded surfaces
and restrained shadows; headers and controls use coordinated rounded wells. The
floating bottom navigation uses one clipped native backdrop filter with a tinted
surface and selected-tab capsules. Dense financial lists retain readable surfaces.
Light and dark palettes, 24px cards, 14px controls and 28px sheets are documented in
CODEX.md and ui-reference.md. Inspiration images are not bundled app assets.

The recent equal-size metric pairs, consistently filled selected icons and neutral
status/review panels remain. Functional routes, financial calculations, storage,
keys, OCR and dependencies are unchanged. Native widgets implement all materials.

Verification: formatting PASS (175 files), analysis PASS, **294 Flutter tests
including 31 goldens PASS**. Three new regressions verify gradient-label contrast, blue header-icon
contrast and the glass panel's opaque/no-blur high-contrast fallback. Existing compact,
large-text, landscape, keyboard and financial regressions pass. Refreshed captures
were generated and representative Home light/dark, Add Expense, Analytics,
Budgets, Transactions and Settings captures visually inspected. APK (100.2 MB),
AAB (81.2 MB) and unsigned iOS device build PASS. Backend unchanged, not rerun.
Existing development signing and physical-iPhone/simulator limits remain.

Physical Redmi review caught and corrected an orphaned navigation-label wrap and
light-mode status-bar icon contrast. The final APK installed in place. All prior
visible monetary values were found across the scrolled Home view; surface grouping
and viewport positions changed with the taller summary. A private baseline of the
new Home layout matched after the final update and a cold restart. Native captures
confirmed the gradient, equal metric pair, floating dock, single-line labels and
dark system icons on the light canvas. No financial commands were issued. Temporary
captures and private baseline files were removed after verification.

## Glass materials and form controls — 19 October 2026

The owner's additional finance/plant references guide a second material pass:
ambient blue gradients in light/dark, translucent tinted cards, a lighter glass
dock, circular header controls, blue gradient pill actions and inset text fields.
Native clipped card filters share a backdrop group for non-overlapping surfaces
per route. Explicit-color/summary-gradient cards avoid extra blur; high contrast
uses opaque cards and a flat backdrop. No inspiration images or packages are added.
Secondary text is darker on light surfaces. Category tiles measure their longest
wrapped label for equal heights, including large text. Amount placeholders retain
their large typography. Layout hierarchy, blue icons, neutral review notices and
all financial commands/storage remain unchanged.

Verification: formatting PASS (177 files), analysis PASS, **297 Flutter tests
including 31 goldens PASS**. Added contrast coverage composites card tints over
linear/radial background extremes in both themes and checks button foregrounds;
two category-size regressions cover normal/200% text. Updated golden comparisons
were reviewed, including Add light/dark, Home dark and Analytics light. APK
(100.3 MB), AAB (81.2 MB), unsigned iOS device build PASS. Backend unchanged,
not rerun. Development signing and physical-iPhone/simulator limits remain.

The Redmi received an in-place update. Visible Home monetary labels matched the
private pre-update baseline. A native capture confirmed the new background/card
materials, readable system icons, aligned metric pair and floating dock. USB
disconnected before the Add-form and cold-restart checks; those checks remain
pending at this checkpoint. No financial writes, reset or reseeding were issued.
