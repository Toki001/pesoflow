# Physical Android verification — 12 October 2026

This is an in-progress hardware verification record, not release certification.
The connected device is a physical Xiaomi Redmi 14C, model `2409BRN2CA`, running
Android 16 (API 36), ARM64, with a 720 × 1640 display. Flutter and ADB identify it
as `NBDEXCJNL7JR9DIJ`; ADB reports `device`, not `unauthorized` or an emulator.
Flutter doctor reports a healthy Android toolchain and accepted SDK licenses.

## Runtime and pre-install checks

The installed entry point will be `lib/main.dart`: `FinanceBootstrap` initializes
`SqliteFinanceRepository`, `FinanceDatabase` and `SecureEncryptionKeyStore`.
Source inspection found no runtime financial fixture injection or demo controls.
This source audit does not establish secure-storage or database behavior on the
phone. No previous `com.pesoflow.pesoflow` installation was present when checked.
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

## Installation blocker

`flutter run -d NBDEXCJNL7JR9DIJ --debug` and targeted `adb install -r` attempts
returned `INSTALL_FAILED_USER_RESTRICTED: Install canceled by user`. The owner
enabled USB debugging, approved ADB authorization and reported enabling Install
via USB; the latest attempt still returned the same installation rejection.
This is a Xiaomi installation-policy/confirmation blocker, not a Flutter crash.
The debug APK was also copied to `Download/PesoFlow-device-test-20261012.apk`
for installation through the normal Files UI. Owner confirmation is pending.
No Xiaomi sign-in credentials were requested or entered, and no security policy
was bypassed.

## Hardware results

| Check | Result |
| --- | --- |
| Physical device discovery / ADB authorization | PASS |
| Install / launch | BLOCKED by Xiaomi installation rejection; launch not tested |
| Fresh empty state / encrypted database / secure storage | NOT TESTED on hardware |
| Manual account / expense / income / transfer / balances | NOT TESTED on hardware |
| Budgets / analytics | NOT TESTED on hardware |
| Normal restart / process death / persistence | NOT TESTED on hardware |
| Background/resume / screen lock | NOT TESTED on hardware |
| UI / keyboard / back navigation / light and dark themes | NOT TESTED on hardware |
| Camera / denied permission / receipt OCR and save | NOT TESTED on hardware |
| OS notifications | NOT IMPLEMENTED; in-app budget notices are separate |
| Biometric unlock | NOT IMPLEMENTED; phone enrollment unchanged |
| Low storage | NOT TESTED; phone storage will not be artificially filled |
| Large-list / OCR performance | NOT TESTED on hardware |
| Debug APK / release APK / release App Bundle | PASS build checks only |

Next action: complete the normal phone installation approval, then exercise the
requested financial workflow through the production UI and record actual
hardware results. Do not infer a hardware pass from automated tests or builds.
