# Receipt capture and review

PesoFlow reads a camera or selected photo on the device, suggests receipt fields,
and saves an expense only after review. No backend account, network connection,
external provider or payment initiation is required. The approved
[Stitch receipt review](../design/stitch/receipt_review/screen.png) remains
the layout reference. Real receipts replace the former synthetic preview.

## Native input and OCR

- [image_picker](https://pub.dev/packages/image_picker) opens the system camera or
  photo picker. Camera access is requested only on an explicit capture action.
  Cancellation preserves the current review. Android lost-picker results are
  recovered when the scanner is reopened after activity/process recreation.
- [permission_handler](https://pub.dev/packages/permission_handler) distinguishes
  denied/restricted/permanently denied camera access and offers Settings or photo
  selection. The selected 12.x line supports this app's Android SDK 36 toolchain;
  13.x requires SDK 37. No microphone or broad-storage permission was added.
- [image_cropper](https://pub.dev/packages/image_cropper) supplies manual cropping
  and rotation. PesoFlow does not claim automatic edge/perspective detection.
  The system camera owns its flash controls; the app does not display a fake flash
  state. Tapping the preview opens a zoomable image.
- [image](https://pub.dev/packages/image) normalizes orientation, removes EXIF/text/
  ICC metadata and limits the longest side to 3,000 pixels, then writes JPEG at
  quality 90. Processing runs in an isolate. Inputs returned by the picker are
  bounded at 25 MiB/40 megapixels, with a 20 MiB processed-image ceiling. Native
  pickers may already resize/convert input; these limits apply to their result.
  Corrupt/unsupported input fails with an actionable message. The saved evidence is never thresholded or contrast-filtered; optional OCR
  derivatives are processed separately and discarded.
- [Google ML Kit Text Recognition](https://pub.dev/packages/google_mlkit_text_recognition)
  uses the Latin script recognizer through a `ReceiptOcrService` adapter. The
  Android dependency is the bundled model (`com.google.mlkit:text-recognition`),
  not a first-use Play Services model download. iOS links the native ML Kit
  libraries. OCR content is not uploaded by PesoFlow. `OcrDocument` retains native
  blocks, lines, elements, bounding rectangles and optional native confidence.
  The UI depends on the abstraction, not ML Kit types.

iOS deployment minimum is 15.5. ML Kit currently requires CocoaPods alongside the
other plugins' SwiftPM packages. Its simulator binaries are x86_64; simulator
builds pass with arm64 excluded **for the simulator only**. This artifact cannot
run on this Mac's installed Apple Silicon iOS 27 simulator. Device arm64 remains
enabled. A passing build is not a native OCR/camera runtime verification.

## Extraction and review

`ReceiptParser` is deterministic and runs off the UI isolate. It attempts merchant,
receipt date/time, integer quantities, unit/line prices, subtotal, VAT/tax,
discount, final total, PHP currency and a payment-method suggestion. It ranks
GRAND TOTAL above TOTAL DUE/AMOUNT DUE/NET TOTAL and TOTAL; it excludes cash,
tender, change, subtotal and tax classifications from final-total candidates.
A large unlabeled number is never silently promoted to the expense total.
OCR price columns are joined using line geometry when available.

Amounts use integer centavos. Supported printed amounts have two decimal places,
with optional thousands separators and ₱/PHP/P prefixes. Labeled whole-peso totals and whole-peso items inside an item table are also
supported. Fractional-weight items and complex multiline discounts may require
manual correction. Unit price × whole quantity determines an item's line total;
the receipt's final total remains independently editable. VAT is recorded only
when found/entered; a blanket 12% amount is never invented or added again.

Dates support ISO, numeric day/month or month/day, and English month names with
12/24-hour time. Ambiguous numeric dates suggest month/day with a warning and low
confidence. Missing/invalid dates suggest today's date **with an explicit warning**;
a missing time uses midnight and is disclosed. Foreign-currency evidence is
flagged and cannot save until the user verifies PHP; no FX conversion exists.

Field confidence is a parser heuristic, not calibrated OCR accuracy. The initial
merchant/total/date confidence and item flags remain visible; edits do not invent
better OCR scores. The user verifies merchant, date, totals and items explicitly,
and every correction clears that confirmation. Original OCR text and warnings
remain preserved as extraction provenance. Item rows are optional: a verified
merchant/date/total/account can be saved even when OCR found no items or failed.
All editable monetary fields validate exact decimal input.

The existing merchant rules/category engine provides suggestions, with an optional
remember-category choice. A detected CASH/GCASH/MAYA/CARD label is only a hint:
the user chooses an active manually tracked account. A manual account can be
created from the picker without losing the receipt review. No payment is sent.

## Persistence and privacy

`ReceiptScanController` owns one unsaved review. Progress describes actual stages,
without invented percentages. Capture cancellation preserves corrections;
OCR failure keeps the image for manual entry/retry. Retake/re-read confirmation
warns that a new extraction replaces corrections. A failed durable save keeps
both the image and review and permits retry. Concurrent save taps cannot create
duplicate expenses.

Captured/cropped images temporarily occupy application-private cache, never a
public receipt directory. Prepared staging files are released on discard,
replacement and successful save; stale PesoFlow staging files are removed on the
next scanner session after a restart. Partial-write cleanup is attempted. Plugin
and OS cache copies may outlive a crash and are not a forensic-erasure guarantee.
Unsaved corrections are session-only; Android recovery recovers picker input,
not every edit. Receipt bytes also exist in memory while displayed/OCR runs.

On confirmation, the existing financial command writes the expense, reviewed
metadata and encrypted image in one Drift transaction. Metadata includes image
and transaction IDs, independent totals, currency, raw OCR text, parser version,
confidence, creation time and confirmation. No database schema/financial engine
rewrite was required. Existing projections and condition-based notices update
only after that commit. Deleting the transaction removes its receipt/image in the
same transaction. Transaction Detail opens the persisted image and metadata;
missing, unauthenticatable or undecodable images have safe display states.

Images and metadata use the existing authenticated encryption/device key. No raw
OCR or image logging is added. Legacy records without evidence and without the
optional note field remain readable. Notes save with the reviewed expense.
Backup/Restore are removed; transaction CSV remains an independent readable report.

The v7 scanner has a dark camera/gallery entry frame; it opens the actual system
camera rather than simulating a camera feed. Review uses a light/dark secondary
header, actual image card, total hero, editable assignments/items and confirmation.
A configured default payment account can preselect an active manual account;
users still verify it against the receipt's payment hint.

## Verification

Parser, image preparation, adapter mapping, scan controller, review widgets,
financial projections, atomic failures, file-backed reopen and deletion tests live under `mobile/test/receipt_*_test.dart`. Only test helpers
supply fake OCR and generated receipt images. Production has no sample loader.
Five current goldens cover normal, uncertain, missing-item, OCR-error and dark review.
The production screen tests also cover scanner entry in light and dark modes.

Run `bash scripts/check.sh`, then the Android debug and iOS simulator builds.
See the [physical-device checklist](verification/receipt-device-checklist.md).
Automated widget/adapter checks do not measure recognition accuracy on real
thermal receipts or prove native permissions/file-dialog behavior.


## Parser v3 and review controls — 17 October 2026

Review exposes separate left/right Rotate and Crop actions. Rotation changes the
staged photo by 90 degrees; cropping uses the native editor. Capture, gallery
selection, recovered images and successful edits now stop at Prepare Receipt.
The user can rotate/crop repeatedly before pressing Scan receipt; no recognition
or financial write runs during preparation. Cancelled image edits preserve the
existing preview/review. Editing a previously scanned image returns to preparation
and clears its old extraction/confirmation.
Replacing a reviewed image requires confirmation before dropping unsaved edits.
The saved image is the reviewed original/crop, never an OCR contrast derivative.

When total/date/header extraction is incomplete, Latin ML Kit tries a private
contrast-normalized grayscale derivative with bounded upscaling. If still
incomplete, a third pass estimates local paper illumination and reduces uneven
shadows without binary thresholding. Processing runs off the UI isolate and stops
when the essential fields are found (three native recognitions maximum).
Derivatives use a single luminance channel, linear upscaling and fast lossless PNG
encoding to limit CPU and temporary storage on lower-powered devices. The
selected whole recognition must improve structured extraction without losing or
contradicting an already recognized total, date or payment method. Fields from
different passes are not spliced together. Failed enhancement retains the best
readable result. Derivatives are deleted; interrupted staging directories are
cleaned on a later scan session. Missing pixels and blurry handwriting cannot be
recovered reliably by contrast processing; manual review remains necessary.

Parser v3 strips adjacent invoice titles, tolerates common title OCR errors,
prioritizes business-header reading order and normalizes a terminal comma-ING
company suffix to INC. (still requiring merchant review). Whole-peso totals and
two-digit numeric years are supported. Whole-peso items require an item-table
context; invoice/reference numbers are excluded. A strictly recognized, labeled
English amount-in-words line can suggest a total at low confidence. Missing or
conflicting fields require manual correction. No largest-number fallback exists.
Old parser-v1/v2 evidence remains readable without a database migration.

For camera captures or recognizable paper-invoice layouts without explicit
payment evidence, Cash is suggested and labeled as an assumption. Explicit wallet
or card/bank tender takes precedence; blank printed payment options are not a
selection. An unambiguous active matching manual account may be preselected;
multiple matches require a choice. Generic gallery images do not assume cash.
The confirmation gate remains mandatory. This is printed-text OCR with limited
handwriting support, not guaranteed recognition of handwritten invoices.


## Invoice layout extraction (parser v4) — 17 October 2026

Recognized word/line rectangles associate the Amount column with descriptions in
its table, bounded below by the Total row. This handles a numeric value below the
header even when OCR places it in a separate, slightly offset line. Unit-price,
serial/reference, tax and tender numbers do not supply that column's value.
If there is exactly one complete row and no recognized adjustments or explicit
total, its amount may suggest the total at low confidence, with an explicit warning
to verify taxes/discounts and the final amount. Multiple rows are not silently
summed; unreadable/unmatched rows or multiple tables suppress this suggestion.
An explicit labeled total retains priority. Recognized values remain variable;
no merchant, amount or date from the owner's private photo is hardcoded.

The date next to the form's Date label, above Received From, takes priority over
unrelated printer/registration dates; an adjacent transaction time is retained.
If that form field is missing or invalid,
it remains flagged rather than using a printer date. Short numeric years retain
the existing warning. This associates OCR output with fields; it cannot recover
handwritten digits that ML Kit did not recognize. Evidence versions 1–3 remain
readable; new scans record parser version 4 without changing the database schema.

New tests cover explicit pre-scan gating, repeated image edits without OCR,
recovered-image preparation, amount-column geometry, alternative amounts,
multiple/unreadable rows, printer-date rejection and native word rectangles.
Light/dark Prepare Receipt goldens extend the existing review captures.


## Preparation accessibility — 18 October 2026

Scan receipt immediately displays the current work status while disabled. Status
changes are live regions for assistive technology; reduced motion retains static
status without an indeterminate progress animation. Tests exercise preparation
and completed review at 200% text in narrow portrait and landscape. Android's
native crop toolbar, frame and active controls use brand blue.

Physical testing confirms preparation, rotate/crop completion and explicit scan.
The supplied low-resolution handwritten invoice still requires manual total/date
correction. Cleaner preprocessing and geometric parsing do not guarantee recovery
of characters absent from the native recognizer output.

The clearer-photo follow-up exposed a form-label OCR error: `Recaived` bypassed
the `Received` safeguard and allowed a printer-issued date into the fallback.
The layout parser now accepts that narrow label variation in both form detection
and the date row's lower boundary. Synthetic regressions cover readable/missing
transaction dates and separately tokenized footer dates. Numeric characters are
never substituted or filled from the owner's expected values.
