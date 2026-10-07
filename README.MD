# PesoFlow

PesoFlow is a native Flutter personal-finance app based on the approved
[Stitch UI](design/stitch/). Engineering instructions live in [CODEX.md](CODEX.md).

## Current application

The app opens an encrypted, device-local financial workspace. New installations
start with an introduction and empty finances. Create a manual account, then add
expenses, income or transfers. Home, Transactions, Accounts, monthly Budgets and
Analytics use your saved records; edits and deletions recalculate their totals.
Account history is preserved by archiving used accounts. Appearance, introduction
completion, manual subscription plans and in-app notice read status also persist.

Balances are manually tracked, not bank-reported. No backend account or credentials
are required. Receipt scanning, external providers, backend authentication, cloud
sync, export/recovery and release distribution are not implemented. Keep the app
installed to retain local records. Old `pesoflow_demo` databases are preserved but
are never imported automatically into real finances.

## Run and verify

```sh
cd mobile
flutter pub get
flutter run
```

From the repository root, `bash scripts/check.sh` runs mobile and backend checks.
The backend remains a minimal NestJS health service; run it with
`cd backend && npm ci && npm run start:dev` when needed.

The mobile stack uses Riverpod, GoRouter, Drift, platform secure storage,
AES-256-GCM, Freezed and json_serializable. Dio is reserved for future API work.
Test fixtures are confined to `mobile/test/`; production has no sample-data entry
or reset controls.

See [production readiness](docs/production-readiness.md) for verified checkpoints,
limitations and the next task, and [UI references](docs/ui-reference.md) for the
approved visual patterns.
