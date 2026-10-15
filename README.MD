# PesoFlow

PesoFlow is a native, local-first Flutter expense tracker based on the approved
[13 Stitch v7 screens](design/stitch/). Read [CODEX.md](CODEX.md) before changes.

The app opens Home after initializing encrypted local storage, with no login,
registration or profile. Fresh finances are empty. Create a manual account,
record expenses/income/internal transfers, manage budgets and recurring bills,
and inspect actual account balances and analytics. Appearance, category visibility,
default payment account and in-app alert preferences persist on the device.

Camera/gallery and on-device Latin ML Kit OCR support receipt review. Correct and
confirm the extracted fields before saving; expense, metadata and encrypted image
commit together. Saved images reopen after restart. See [receipt behavior](docs/receipts.md).

Backup and Restore have been removed. CSV export is available from Transactions
as a readable report. There are no bank connections, cloud accounts, payment
operations or OS notification delivery. Existing financial data is preserved on
normal updates; no update resets the database or changes its key.

```sh
cd mobile
flutter pub get
flutter run
```

`bash scripts/check.sh` runs Flutter formatting/analysis/tests and the retained
NestJS health-service checks. The backend is optional and is not used by mobile
startup. Run it with `cd backend && npm ci && npm run start:dev` when needed.

The mobile stack uses Riverpod, GoRouter, Drift, secure storage, AES-256-GCM,
Freezed/json_serializable and native receipt/file-picker adapters. Deterministic
fixtures live only in `mobile/test/`. No new runtime demo controls are present.

See [production readiness](docs/production-readiness.md) for build/test results,
physical-device limits and the recommended next task, and
[UI mapping](docs/ui-reference.md) for design decisions and deliberate differences.
