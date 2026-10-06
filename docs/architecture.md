# Foundation architecture

## Current scope

Native Android/iOS Flutter scaffold, shared theme/components, Riverpod state,
GoRouter shell, fixture-backed Home, and minimal NestJS `/v1/health` endpoint.
No HTML rendering, WebViews, provider calls, authentication, database, queues,
OCR, notifications, persistence, or money movement are implemented.

`mobile/lib/app` owns composition, navigation and the light/dark design system.
`core` contains presentation primitives, deterministic formatters and a reserved
Dio provider. `features/dashboard` separates domain models/repository contract,
fixture data, Riverpod application state, and presentation. Only folders with
actual responsibilities exist; other feature/module trees are deferred.

The shared transaction widget accepts display values and has no feature-domain
dependency. A dashboard presentation adapter maps domain categories to icon and
color roles. Freezed models have generated JSON serializers and immutable lists;
generated source is retained so checkout analysis works before regeneration.

The repository interface returns `Future<Dashboard?>`: AsyncValue represents
loading/data/error; null represents no overview. Retry is explicit, avoiding
hidden automatic requests. Empty lists have individual messages. Offline and
refresh/sync state machines belong to a future persistence/API implementation;
the current demo works entirely offline after installation.

All money is integer PHP centavos. Utilization ratios alone use floating point
for painting. Recent rows do not sum to the monthly snapshot. Dates are frozen
Philippine wall-time fixture values, initialized with `en_PH` date symbols.
Real event timestamps will require UTC storage and explicit timezone conversion.

GoRouter's indexed stateful shell preserves each tab and Home scroll. Five
routes exist: `/home`, `/transactions`, `/add`, `/analytics`, `/budgets`; `/`
redirects to Home. Non-Home branches are clearly labeled demo placeholders.
These are in-app route/deep-link targets; OS universal/app-link associations and
transaction-detail back stacks are not yet configured.

The backend binds localhost and provides a versioned liveness response, Helmet
headers, validation pipe and shutdown handling. Nest module composition is ready
for future features; no speculative provider/data modules were added. Tests use
Node's built-in runner plus Nest testing utilities and Supertest. This avoids
the vulnerable transitive Jest tooling chain found during the initial install.

## Toolchain and dependencies

Validated with Flutter 3.47.5 / Dart 3.13.4; use the same Flutter version for
goldens. Node 22 or later; `package-lock.json` and `pubspec.lock` pin resolution.

Flutter runtime: Riverpod 3, GoRouter 18, Dio 5, Freezed annotations 3,
json_annotation 4, intl 0.20. Dev: Flutter test/lints, build_runner 2,
Freezed 4, json_serializable 6. Inter is a locally bundled variable font under
OFL, downloaded from Google Fonts' `ofl/inter` source. Material icons ship with
Flutter; no runtime font/image network access or chart package is needed.

Backend runtime: NestJS 12, Express adapter, reflect-metadata, RxJS, Helmet,
class-validator and class-transformer. Dev: Nest CLI/testing, TypeScript 6,
ESLint/typescript-eslint, Prettier, Supertest and Node/Supertest type definitions.
No Drift, secure storage, camera, biometrics or messaging SDK until needed.

## Local commands

From `mobile/`:

```sh
flutter pub get
dart run build_runner build
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter run
```

Home uses fixtures regardless of `API_BASE_URL`. The optional Dio provider can
later receive a base URL through `--dart-define=API_BASE_URL=https://.../v1`;
it is not read or instantiated by Home and has no logging interceptor.

From `backend/`:

```sh
npm ci
npm run format:check
npm run lint
npm run build
npm test
npm audit --audit-level=moderate
npm run start:dev
```

Backend default: `http://127.0.0.1:3000/v1/health`. Optional `PORT` is the only
runtime environment variable used. Root `.env.example` entries are reserved for
later phases and are not read; no secrets are required to run this foundation.

From the repository root, `bash scripts/check.sh` runs local formatting,
analysis/build and tests. CI runs mobile tests on macOS (matching the reviewed
golden platform) and backend checks/audit on Linux. Native store signing and
deployment are deferred.

## Golden workflow and visual review

`mobile/test/goldens` contains light/dark 390×1447 full-page captures and a
390×844 light phone capture. Tests load the bundled Inter and Material icon
fonts, use DPR 1 and deterministic data, and make no network calls. Review
changes against the original Stitch screenshot before updating baselines:

```sh
flutter test test/home_test.dart --update-goldens
flutter test
```

These are Flutter-rendered widget screenshots, not an emulator capture and not
pixel comparisons against the Stitch PNG. Exact Flutter/toolchain/OS pinning
limits rasterization variance. Do not replace the golden comparator with a
broad tolerance to mask layout changes.

Visual review corrected the initial greeting/hero offsets, excessive section
gaps, budget spacing, account-count alignment and bottom-bar height. At 390px,
the final hero, summary, insight, budget and recent-transaction section starts
are within approximately 1–6px of the reference. Upcoming Bills starts about
30px lower because native transaction rows preserve whole signed amounts and
wrap metadata/transfer badges. This intentional tradeoff avoids the reference's
isolated plus/minus signs. Initials avatar replaces the unlicensed remote photo;
native Material glyph shapes and text rasterization also differ slightly.

Golden shadows use Flutter's test-mode shadow setting. Platform status/home
indicators are absent in the full-page reference capture; separate widget tests
exercise safe insets. Dark mode extrapolates the approved dark palette because
there is no supplied dark screenshot. Touch targets are at least 48px; 200%
text uses stacked metrics/pairs and a taller navigation bar. Landscape and
320/390/430px phone widths are covered.

## Next step

Implement the approved Transactions screen using the existing transaction tile,
theme and fixtures: month summary, search, horizontal filters, dated groups,
pending/refund/transfer/income distinctions and navigation to a later detail
screen. Keep provider integration and persistence out of that visual phase.

## Foundation verification

Validated locally on October 6, 2026:

- Dart formatting: clean; Flutter analysis: no issues.
- Flutter tests: 18 passed, including three golden comparisons, fixture JSON
  round trips, financial semantics, navigation, responsive layout, safe insets,
  large text, loading, empty and recoverable error states.
- Backend Prettier, ESLint and TypeScript/Nest build: passed.
- Backend HTTP test: passed; versioned health response, security header and
  unimplemented-route behavior verified.
- npm audit: zero reported vulnerabilities across the resolved dependency tree.
- Android debug build: passed; first build installed NDK 28.2.13676358 and
  Android SDK Platform 36. Artifact: `mobile/build/app/outputs/flutter-apk/app-debug.apk`.
- iOS simulator debug build: passed. Artifact:
  `mobile/build/ios/iphonesimulator/Runner.app`.

Build artifacts and machine-specific configuration are ignored. Native binaries
were compiled, but emulator/device interaction and store release signing were
not tested. The GitHub Actions workflow has been added but not run remotely.

Git was initialized on `main`. Work is committed at coherent milestones;
future implementation should continue that practice. Nothing has been pushed.
