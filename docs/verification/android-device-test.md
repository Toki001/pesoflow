# Physical Android verification — 12 October 2026

This is an in-progress hardware verification record, not release certification.
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
No phone data has been cleared, no app has been uninstalled and no financial
records have been injected.

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
Physical release-mode Latin OCR is still unverified.

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
| Install / launch | PASS: debug production entry point on the physical Redmi |
| Empty finances / encrypted repository / secure storage | PASS: empty Home, durable UI saves and process restart; no independent ciphertext inspection |
| Manual account / expense / income / transfer / balances | PASS: exact values below; full account CRUD not tested |
| Budgets / analytics | PASS: category creation/edit, threshold warning, actual expense breakdown; budget deletion pending |
| Process restart / persistence | PASS: scoped force-stop and cold relaunch; records and appearance remain. Separate recents dismissal not tested |
| Background/resume / screen lock | PASS: Home key then bring task forward; screen lock not tested |
| UI / keyboard / back navigation / light and dark themes | PASS for inspected portrait screens, numeric decimal keyboard, scrolling, keyboard dismissal and route back; broader cases pending |
| Receipt OCR / camera / denial / save | Local Latin ML Kit execution observed on hardware; camera capture confirmation, denial and save checks pending |
| OS notifications | NOT IMPLEMENTED; in-app budget notices are separate |
| Biometric unlock | NOT IMPLEMENTED; phone enrollment unchanged |
| Low storage | NOT TESTED; phone storage will not be artificially filled |
| Large-list / OCR performance | NOT TESTED on hardware |
| Debug APK / release APK / release App Bundle | PASS build checks only |

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

Next: confirm/correct the paper receipt and verify durable receipt save, then
finish permission and release-mode checks. Low storage, cross-device restore,
iPhone and broad receipt-corpus accuracy remain separate acceptance gaps.


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
Camera-denial and final release install/recognizer checks are next.
