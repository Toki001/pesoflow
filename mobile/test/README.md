# Financial and UI verification

Production startup must receive a loaded FinanceWorkspace and FinanceRepository;
there are no default fixture providers. `support/finance_fakes.dart` supplies
controlled failures and an in-memory key store only for tests. The restart widget
test uses the real encrypted Drift repository on a temporary SQLite file, closes
it and reconstructs FinanceBootstrap and the repository, including persisted theme.
It does not substitute for a physical-device Keychain/Keystore recovery test.

`fixtures/` contains deterministic Stitch examples and the explicit workspace used
by production widget/golden tests. `legacy/` retains prototype codecs, projection
helpers and receipt UI for reference-only tests; production cannot import them.
Former demo reset, consent and seeded-startup tests were retired with those flows.
Financial engine, codec/encryption, account identity, filtering and decimal parsing
regressions remain, supplemented by production forms and cross-screen projections.

`production_app_test.dart` compares 14 light/dark baselines covering Home,
Transactions, Accounts, Budgets, Analytics, Add and Detail, and checks empty starts,
large-text layouts, onboarding, command forms and restart. Historical golden PNGs
without the `production_` prefix are prototype references, not current comparisons.
The screenshots intentionally show exact fixture-ledger totals, not the omitted
history/aggregate offsets from the original prototype.

Run `flutter test`. Regenerate a reviewed production baseline only with:
`flutter test test/production_app_test.dart --update-goldens`.

For native persistence, use a dedicated empty simulator only:

```sh
flutter run -d <isolated-simulator-id> -t test/device/persistence_smoke.dart --dart-define=PESOFLOW_STORAGE_SMOKE=true
# Once Home appears, quit with q, then restart using the production target:
flutter run -d <isolated-simulator-id> -t lib/main.dart
```

The guarded harness refuses a nonempty workspace. It uses real platform secure
storage and production commands to persist a PHP 1,000 account, PHP 325.25 expense,
PHP 5,000 monthly budget and dark appearance. After process termination the normal
entry point must restore Home with PHP 674.75, the expense and budget, in dark mode.
