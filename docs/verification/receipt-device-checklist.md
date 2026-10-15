# Receipt device acceptance checklist

Status: **partially verified on physical Android; iPhone and the wider matrix
remain pending**. On 12 October 2026 the connected Redmi 14C passed camera capture,
optimized-release Latin OCR, corrected expense/image save and restart/reopen.
Permanently disabled camera recovery was exercised with targeted ADB permission
state; ordinary dialog denial and Settings destination remain inconclusive.
See [device evidence and exact gaps](android-device-test.md). Items below are an
acceptance checklist, not blanket PASS claims. ML Kit's x86_64 simulator limitation
also prevents running this build on the installed Apple Silicon iOS 27 simulator.

Use dedicated test installations and synthetic/redacted receipts. Never delete
existing personal records or clear/uninstall an installation for this testing. Never log or
commit real receipt photos, raw OCR, loyalty numbers or payment references.
Record device, OS, app commit, result and redacted defect description for each case.

## Capture, selection and preprocessing

- Fresh installation: scanner has no sample receipt. Opening the app/scanner does
  not request camera access; tapping capture does. Select a photo without granting
  unnecessary broad library access.
- Grant, deny, permanently deny/restrict and later restore Camera access. Verify
  the Settings link, photo alternative and honest unavailable-camera response.
- Cancel system camera/photo picker/crop: keep the current image and corrections.
  Camera failure should not erase a previous review.
- Select JPEG/PNG and supported HEIC conversions from local and cloud photo
  sources. Test unavailable provider download, corrupt/truncated files, very
  small images and large images. Check clear errors and responsive navigation.
- Crop/rotate a sideways and upside-down receipt. Verify the displayed and OCR
  image is the same adjusted image. Cancel adjustment without changing the review.
- Check that captures/staging files stay private and no photo is automatically
  published to a gallery. Inspect EXIF/location removal on saved test images.

## OCR corpus and review

Test real recognizer output for: good lighting, crumpled paper, angled perspective,
a long grocery receipt, faded thermal print, low light, a Philippine VAT receipt,
VAT-exempt/zero-rated labels, discounts, cash/change, GCash/Maya/card wording,
ambiguous dates and missing/competing totals. Record field accuracy separately
from parser confidence; do not interpret the heuristic score as an accuracy rate.

- Airplane mode **before first scan**: OCR and local save work without a model
  download/login/backend. Native camera flash behaves through system controls.
- Compare merchant, date/time, item quantities/prices and final total to the image.
  Payment wording must not force an account. Foreign currency must need correction.
- Correct each field, add/remove an item, change category/account and confirm.
  Item changes must not silently replace the independent receipt total.
- An unreadable/blank receipt permits manual completion; uncertain date/total and
  missing items are visible. OCR failure retains the photo for retry/manual entry.
- With no accounts, create one in the account picker and return to the same review.
- Small screens, large text, light/dark mode, zoom, screen reader and long merchant
  names: no overflow, hidden primary action or inaccessible edit control.

## Save, interruption, storage and recovery

- Double-tap Save: exactly one expense/image. Before explicit confirmation, no
  ledger mutation. A save failure retains the review for retry.
- Verify Transactions, account balance, Home, budget consumption, Analytics,
  merchant rule and applicable in-app budget notices after commit. Transfers or
  unrelated accounts must not change. No OS notification delivery is claimed.
- Terminate/reopen after save: the expense, original OCR, reviewed fields and image
  reopen through Transaction Detail. Restart while unsaved: session corrections
  may be lost; Android pending picker input should recover on reopening scanner.
- Background/resume during camera, selection, crop, OCR and save. On Android also
  test activity destruction while the external picker is open. No duplicate save,
  indefinite progress or phantom success should result.
- On an isolated low-storage installation, fail capture staging and database/image
  commit. Restore space and retry. Inspect for partial expenses and stale staging;
  never exhaust storage on a personal device to perform this check.
- On a disposable test installation only, explicitly delete a synthetic receipt
  transaction: image and metadata disappear atomically and projections recalculate.
  This does not authorize deletion of the existing Redmi's personal/test records.

Release consideration needs this device evidence plus review of recognition
accuracy on a consented/redacted Philippine receipt corpus. Native build success
and fake-adapter tests alone are insufficient.
