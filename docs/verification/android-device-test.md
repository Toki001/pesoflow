# Physical Android verification — 12 October 2026

This records completed physical Android checks and remaining acceptance gaps,
not release certification. The final installed build includes the release registrar
fix described below; the final checkpoint supersedes earlier pending checks.
The connected device is a physical Xiaomi Redmi 14C, model `2409BRN2CA`, running
Android 16 (API 36), ARM64, with a 720 × 1640 display. Flutter and ADB identify it
as `NBDEXCJNL7JR9DIJ`; ADB reports `device`, not `unauthorized` or an emulator.
Flutter doctor reports a healthy Android toolchain and accepted SDK licenses.

## Runtime and pre-install checks

The installed entry point is `lib/main.dart`: `FinanceBootstrap` initializes
`SqliteFinanceRepository`, `FinanceDatabase` and `SecureEncryptionKeyStore`.
Source inspection found no runtime financial fixture injection or demo controls.
Physical save/restart checks below exercise native secure storage and the
encrypted repository together; they do not independently inspect ciphertext. No previous `com.pesoflow.pesoflow` installation was present when checked.
During this initial finance/receipt verification no phone/app data was cleared,
no app was uninstalled and no financial records were injected. The subsequent
authorized pre-v7 recovery exercise is summarized as a historical checkpoint below.

Before installation, formatting was clean (186 files), Flutter analysis passed,
and all 195 tests passed, including 21 current golden comparisons. The debug APK
built successfully. Post-fix formatting and analysis also pass, and all 195
Flutter tests pass again, including the 21 current golden comparisons.

## Release-build defect and fix

The first release APK build failed in R8 because the ML Kit Flutter adapter
references Chinese, Devanagari, Japanese and Korean recognizer options whose
optional native modules are not bundled. PesoFlow explicitly requests only the
bundled Latin recognizer. `android/app/proguard-rules.pro` now suppresses the eight
specific absent options/builder references, and the release Gradle configuration
loads those rules. R8 remains enabled; other missing classes remain errors.
Enabling another script requires its native dependency first.

After the fix, `flutter build apk` passed (100.0 MB) and
`flutter build appbundle` passed (81.0 MB). Release builds still use the existing
debug signing configuration; these artifacts are not Play Store release packages.
Physical release-mode Latin OCR subsequently passed after the additional
registrar fix described in the final checkpoint below.

## Installation history and resolution

`flutter run -d NBDEXCJNL7JR9DIJ --debug` and targeted `adb install -r` attempts
returned `INSTALL_FAILED_USER_RESTRICTED: Install canceled by user`. The owner
enabled USB debugging, approved ADB authorization and reported enabling Install
via USB; the latest attempt still returned the same installation rejection.
This is a Xiaomi installation-policy/confirmation blocker, not a Flutter crash.
The debug APK was also copied to `Download/PesoFlow-device-test-20261012.apk`
for installation through the normal Files UI. After the owner completed the setting/approval steps,
`flutter run -d NBDEXCJNL7JR9DIJ --debug` installed and launched successfully.
Home showed zero accounts/balance and no budgets before test records were created.
The first onboarding screens were not independently observed. A brief initial
black startup frame resolved; no sustained blank screen or startup error remained.
No Xiaomi sign-in credentials were requested or entered, and no security policy
was bypassed.

## Hardware results

| Check | Result |
| --- | --- |
| Physical device discovery / ADB authorization | PASS |
| Install / launch | PASS: debug and optimized release production builds on the physical Redmi |
| Empty finances / encrypted repository / secure storage | PASS: empty Home, durable UI saves and process restart; no independent ciphertext inspection |
| Manual account / expense / income / transfer / balances | PASS: exact values below; full account CRUD not tested |
| Budgets / analytics | PASS: category creation/edit/delete/recreate, threshold warning and actual expense breakdown |
| Process restart / persistence | PASS: scoped force-stop and cold relaunch; records and appearance remain. Separate recents dismissal not tested |
| Background/resume / screen lock | PASS: Home key then bring task forward; screen lock not tested |
| UI / keyboard / back navigation / light and dark themes | PASS for inspected portrait screens, numeric decimal keyboard, scrolling, keyboard dismissal and route back; broader cases pending |
| Receipt OCR / camera / denial / save | PASS: owner-assisted camera capture, Latin OCR, corrected save and saved-image reopen in release; permanently disabled recovery tested via ADB, ordinary dialog denial not independently verified |
| OS notifications | NOT IMPLEMENTED; in-app budget notices are separate |
| Biometric unlock | NOT IMPLEMENTED; phone enrollment unchanged |
| Low storage | NOT TESTED; phone storage will not be artificially filled |
| Large-list / OCR performance | NOT TESTED on hardware |
| Debug APK / release APK / release App Bundle | PASS builds; release also installed and exercised, not store signing |

## Financial workflow evidence

All entries were created with the production UI, not an injected fixture runtime:

1. GCash, E-wallet, PHP 5,000 opening balance: account list showed PHP 5,000.
2. Jollibee, Food & Dining, PHP 325 expense: Transactions spent PHP 325 and
   Home balance PHP 4,675. A keyboard-added merchant character was corrected
   through Edit Details; no extra transaction was created.
3. Device test income, PHP 1,000 into GCash: income PHP 1,000, net flow +PHP 675,
   tracked total PHP 5,675.
4. Cash device test, Cash, PHP 0 opening balance; transfer PHP 500 from GCash:
   GCash PHP 5,175, Cash PHP 500, total PHP 5,675. Spending remained PHP 325.
5. Food & Dining allowance PHP 1,000: spent PHP 325, remaining PHP 675,
   displayed 33% (rounded from 32.5%). Edited to PHP 400: remaining PHP 75,
   displayed 81% (rounded from 81.25%), approaching-limit state and one
   in-app unread warning. This is not an Android OS notification.
6. Analytics: expense PHP 325, Food & Dining 100%, Jollibee one record,
   category target PHP 400. Its trajectory uses actual spending, with no
   overall target because no overall monthly limit was created.
7. Light appearance explicitly selected after inspecting dark portrait screens.
   Background/resume succeeded. `am force-stop com.pesoflow.pesoflow` followed
   by `am start -W` reported a cold launch (5,345 ms activity launch, not a
   benchmark of time to financial content). Transactions, the edited category
   budget, warning and light appearance remained after loading completed.

Scoped app logs inspected through startup, writes, restart and ML Kit execution
showed no Flutter exceptions, SQLite/secure-storage failures or render overflows.
The camera-stage log selected the bundled local Latin ML Kit model and loaded
its native OCR pipeline. Recognition output appeared in review; total/date
were flagged missing. Recognition execution is not proof of parsing accuracy.

Later checkpoints below complete corrected receipt save and release-mode checks.
Low storage, iPhone and broad receipt-corpus accuracy remain
separate acceptance gaps.


## Receipt defect fixes and saved-image checkpoint

A real owner-provided paper receipt reached native Latin OCR review. The owner
verified the missing total and ambiguous printed date: PHP 480, August 4, 2026
at 12:15 PM. The item was corrected to 15 units at PHP 32 and Healthcare.
At the owner's request, a Maya E-wallet test account was created with zero
opening balance from the review; the corrections remained intact.

Two repository defects were identified and fixed:

- `eM-PAY` electronic tender was mistaken for an item. Parser version 2 excludes
  electronic-tender/PayMaya rows from items, recognizes PayMaya as Maya and still
  refuses to use an unlabeled tender as the expense total. Sanitized regressions
  contain no real receipt image, identifiers or medical product details. Version 1
  evidence remains readable; new scans record version 2 explicitly.
- Receipt scrolling, expansion state and the selectable original text inherited
  one PageStorage identifier. A physical debug screen showed a double-to-bool
  cast error; a widget regression reproduced the inverse bool-to-double collision
  when opening the extracted text. Dedicated expansion/selection keys fix both
  without layout changes. Hot reload recovered the active review with corrections
  retained; no hot restart was used to recover the unsaved draft.

Explicit confirmation saved the receipt expense and image. Transaction Detail
showed the verified August date, Healthcare and Maya; reopening Saved receipt
showed its captured image and corrected quantity/unit price. Maya showed PHP -480,
aggregate tracked balance PHP 5,195. October spending remains PHP 325 and net
flow +PHP 675, correctly excluding the August expense. A subsequent process
restart restored these values. The private receipt image/raw text is not committed.

Post-fix formatting and analysis pass. All **198 Flutter tests**, including
**21 golden comparisons**, pass. Release APK and App Bundle builds pass again.
One test invocation was blocked by a missing host `flutter_tester` artifact;
`flutter precache --force --universal` repaired the SDK cache and the suite then
ran successfully. This was a host toolchain issue, not a failed app assertion.
The final release and permission checkpoint follows.


## Final optimized release and permission checkpoint

The first optimized release installed and launched, but camera recognition failed:
ML Kit component discovery reported missing no-argument constructors for
`CommonComponentRegistrar`, `VisionCommonRegistrar` and `TextRegistrar`. Their
manifest-named reflection entry points were removed by R8 full mode. Narrow keep
rules now retain exactly those three classes, constructors and `getComponents`
methods. Shrinking remains enabled, no optional script model or dependency was
added, and no financial engine or database rewrite was required.

The repaired release APK and App Bundle built successfully (100.0 MB / 81.0 MB).
The APK was installed as an update with app data retained. R8 mapping inspection
confirmed the registrar entry points remain, and scoped release logs no longer
show their discovery/constructor failures. Owner-assisted recapture of the same
paper receipt reached real Latin recognition/review in this optimized release.
The second capture found PHP 480 but still needed merchant/date/item corrections;
its item sum mismatch was honestly flagged. This review was discarded, preserving
exactly one saved receipt expense. Execution passes; extraction accuracy still
requires manual review and a broader consented/redacted receipt corpus.

After release update and process restart, the original saved expense reopened
through August Transactions → Transaction Detail → Saved receipt. Visual inspection
confirmed the actual image and corrected fields, quantity 15 at PHP 32 and total
PHP 480. Home retained PHP 5,195 across GCash PHP 5,175, Cash PHP 500 and Maya
PHP -480. October spending PHP 325 and net flow +PHP 675 remained correct.
The Food & Dining allowance was deleted without losing transactions, then recreated
at PHP 400: PHP 325 spent, PHP 75 remaining, 81% usage. Two unread in-app notices
were present after the separate budget lifecycles; OS delivery was not tested or
implemented. The app was left on light-theme Home with these records retained.

Only PesoFlow's Camera permission was temporarily revoked and marked permanently
denied via targeted ADB commands. Taking a photo then showed the disabled-camera
explanation, Settings action and photo alternative without a crash or repeated
permission prompt. The temporary flag was cleared and the original granted state
restored and checked. Ordinary “Don't allow” dialog behavior and the Settings
link's exact destination were not independently verified: owner interaction and
activity transitions made those observations inconclusive. No phone data was
cleared and no unrelated app permission, enrollment or storage was modified.

Final `bash scripts/check.sh`: formatting clean (186 files), Flutter analysis
clean, **198 tests including 21 golden comparisons pass**; backend formatting,
lint, build and its one health test pass. Final release APK/App Bundle builds pass.
Signing is still the existing debug configuration, not release packaging.

Remaining hardware gaps: iPhone and native file
dialogs, ordinary permission denial/Settings recovery, airplane-mode first scan,
lock/unlock and recents dismissal, orientation/large-text/accessibility coverage,
full account CRUD, gallery/cloud-provider formats, large collections, interruptions
through each capture/save stage and isolated low-storage behavior. No private
receipt photo/raw text/payment identifier was committed. Recommended next task:
verify the current v7 UI by an in-place upgrade on dedicated devices; expand the
receipt accuracy corpus. Removed recovery features are no longer acceptance tasks.


## Subsequent historical checkpoint and v7 status

A later, separately authorized pre-v7 recovery exercise returned this device to
PHP 5,195 with three accounts, four transactions, one budget and the saved receipt.
That removed feature's dedicated report is retained only in Git history. It is
not an instruction or authorization to reset this installation again.

On 16 October 2026 ADB discovery for the v7 migration returned no attached devices.
No v7 installation, upgrade, hardware camera check or process restart was performed.
Existing app data and external documents were not touched. The next device task
must upgrade in place and verify the existing records; never uninstall or clear
application data to work around installation/signing errors.


## V7 logo and borderless UI follow-up — 16 October 2026

The same Redmi was authorized and updated in place with `adb install -r`.
Logo milestone `13f7ca3` supplies launcher icons from the owner's SVG. UI milestone
`179c8ec` removes section-card borders, adds the direct Budgets → Subscriptions &
Bills entry, and clarifies Home when all accounts are archived.

The baseline changed between owner sessions. The first pre-update inspection had
three archived accounts and zero active balance. On the resumed session, before
installing the borderless update, the production UI showed two active accounts,
PHP 1,642.50 total and one October expense of PHP 47.50. Use this observed baseline,
not the historical PHP 5,195 test state. No reset/reseed/uninstall/import or
financial mutation was performed by this verification session.

After the borderless upgrade and a scoped force-stop/cold launch, Home/Accounts
retained PHP 1,642.50 (PHP 1,000 and PHP 642.50). Transactions and Analytics retained
PHP 47.50 expense; transaction detail retained its date/category/note. A PHP 1,000
category budget and the existing PHP 799 monthly subscription remained accessible.
Archived accounts were still listed. No private screenshots, raw receipts or
financial exports were committed.

| Current check | Result |
| --- | --- |
| In-place installation and cold launch | PASS; no login or storage error |
| Current balances/expense after process restart | PASS |
| Home/Accounts/Transactions/detail/Analytics/Budgets | PASS navigation and displayed real values |
| Subscriptions shortcut/details/Add form | PASS; existing plan retained; new form canceled |
| Expense/Income/Transfer forms | PASS opening and mode changes; save not exercised on current records |
| Settings/native installed version | PASS, 0.1.0 (Build 1) |
| Notifications | PASS existing three unread notices; read state left unchanged |
| Borderless cards | PASS visual inspection of physical subscription screen and updated goldens |
| Native gallery picker/cancel | PASS; no image selected/imported |
| CSV export/cancel | PASS cancellation message; full save dialog hierarchy inconclusive; no export saved |
| Camera/OCR/crop and saved-image reopen | NOT REPEATED in this session |
| Physical iPhone | UNAVAILABLE per owner; unsigned compile only |

Final automated checks: 220 Flutter tests (29 goldens), format and analysis pass.
APK 99.8 MB and AAB 80.8 MB build successfully; unsigned iOS compile also passes.
Artifacts retain development signing. Remaining Android acceptance includes an
owner-assisted fresh receipt capture, image reopen, actual CSV save, low storage,
large collections and accessibility. Do not reset the current installation.


## Receipt and filter follow-up — 17 October 2026

Verified milestones `680b4ff` and `992dce7` introduced the screenshot corrections
and invoice-parser repairs. `343ca51` added shadow-aware local recognition and
field-consistency protection; `166d924` corrected combined-filter counts.

The authorized Redmi remained available over ADB. Before this update, Home showed
PHP 1,642.50 across Cash PHP 1,000 and the bank account PHP 642.50, with PHP 47.50
October spending. The APK containing `343ca51` and the notification-count change
installed successfully with `adb install -r`; startup opened the existing data.
No uninstall, data clear, reseed, financial command or encryption change occurred.

The owner's supplied low-resolution paper invoice was selected through the native
photo picker using the previously staged test copy. Review showed the correct
company name without the invoice title, zero spurious invoice-number items, and
Cash with an explicit suggestion/verification label. Separate blue Rotate and Crop
controls appeared left/right below the preview. Total/date were still not reliably
recognized and remained flagged for manual entry. No expense was saved; no private
image, extracted text or screenshot is committed.

Native process diagnostics confirmed three completed local recognition passes.
The roughly 40-second fallback scan exposed excessive derivative-processing cost.
Milestone `df10f3e` switches derivatives to one luminance channel, linear upscaling
and fast lossless PNG encoding. Its format/analysis, 234 tests (29 goldens) and APK
checks pass. Final in-place installation and timing of this optimized build, native
Rotate/Crop interaction, test-copy cleanup and final restart verification are
pending a stable untouched phone screen; concurrent screen transitions prevented
reliable control targeting. This is not a completed handwriting-accuracy test.


## Pre-scan preview follow-up — 17 October 2026

The owner requested image rotation/cropping before recognition, and confirmed the
transaction date and amount locations on the paper form. `ac5a728` introduces an
explicit Prepare Receipt step and Scan receipt action; `2078a8d` adds geometric
Amount-column and Date/Received From associations. Subsequent date regression
coverage also preserves an adjacent transaction time and rejects separately
recognized printer-date labels. Private receipt values are not hardcoded.

The Redmi was initially visible with an unsaved receipt review. It disconnected
before the planned close/install action; ADB returned no devices, so that action
did not execute. Repeated discovery during the owner's continuation also returned
no devices. At that interruption the new preview/parser build had not been installed or
physically verified. Later results below supersede this pending status.

Automated checks pass: formatting, analysis and 246 tests, including 31 goldens.
The preview has reviewed light/dark captures and tests proving acquisition, crop,
rotation and recovery do not invoke OCR until Scan receipt. Parser tests use
synthetic variable values and geometry, including unreadable/multiple rows and
printer-date rejection; these do not establish handwriting recognition accuracy.

Next connected-device check: upgrade in place, select the staged receipt copy,
verify preview edits before Scan receipt, measure recognition time, inspect actual
amount/date extraction and discard the test review. Then remove only the staged
test copy and verify unchanged finances after a cold restart. These tasks were pending at that checkpoint; completion is recorded below.


## Pre-scan and OCR completion — 18 October 2026

The APK containing `40095ff` installed in place on the authorized Redmi 14C.
Before/after installation, Home retained PHP 1,642.50 total across two accounts,
PHP 47.50 October spending and three unread alerts. No storage reset, uninstall,
financial command, schema change or key change was used.

| Check | Observed result |
| --- | --- |
| Native photo selection | PASS: known staged test copy opened Prepare Receipt without OCR |
| Rotate | PASS: visible 90-degree edit; still in preparation |
| Native crop | PASS: editor opened, edge adjustment confirmed, returned to preparation |
| Native styling | PASS: toolbar/frame/active controls blue; inactive native tabs retain plugin gray |
| Explicit Scan receipt | PASS: review visible after 12.4 seconds including UI polling |
| Merchant/payment | PASS: invoice heading excluded; Cash explicitly suggested for verification |
| Handwritten total/date | NOT RECOGNIZED: correction warnings remain; no guessed values accepted |
| Spurious invoice items | PASS: no invoice-serial item generated |
| Financial save | NOT EXERCISED: no save action issued |
| Test-copy cleanup | PASS: identified temporary MediaStore entry and file removed; originals preserved |
| Cold restart | PASS: current persisted Home values retained |

The cropped image was restored upright before scanning and retained the merchant,
date and amount table. Timing is a single UI observation, not a controlled speed
benchmark. No private receipt image/text or screenshot is committed. No fresh
camera capture or saved-image reopen was performed in this session.

The session was interrupted by an approval-service usage limit before closing the
unsaved review. On continuation several hours later the phone was on its launcher;
opening PesoFlow cold showed Home, with PHP 1,542.50 total (Cash PHP 900.00 and bank
PHP 642.50), PHP 147.50 October spending and three unread alerts. The intervening
change was not made by these tool actions and was not reverted. A further scoped
force-stop/cold launch retained those current values. This verifies persistence
of the resumed state, not that balances stayed unchanged during the interruption.

Final automated checks: format/analyze PASS; 248 tests including 31 goldens PASS;
APK (100.1 MB), AAB (81.1 MB), unsigned iOS device compile PASS. The missing local
MLKitTextRecognitionCommon binary was restored at its locked version before the
successful iOS retry. Physical iPhone remains unavailable. Receipt preparation
also has tests at 200% text, narrow portrait, landscape and reduced motion.

Next OCR acceptance requires clearer owner-consented samples and expected fields;
these results do not demonstrate reliable handwritten amount/date recognition.
