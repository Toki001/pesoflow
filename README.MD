# PesoFlow

PesoFlow is a cross-platform personal finance and expense tracking application built with Flutter.

The approved UI design is located in:

`design/stitch/`

Engineering and implementation instructions are defined in:

`CODEX.md`

## Planned Stack

### Mobile
- Flutter
- Dart
- Riverpod
- GoRouter
- Dio
- Drift

### Backend
- NestJS
- TypeScript
- PostgreSQL
- Redis

### Major Features
- Expense tracking
- Income tracking
- Transfers
- Bank/e-wallet connectivity
- Receipt OCR
- Budgets
- Analytics
- Subscriptions
- Notifications

## App demo available

`mobile/` now contains the Android/iOS Flutter application, shared light/dark
theme, routing and native Stitch Home, Transactions, Transaction Detail,
Add Expense, Budgets, Analytics and Connected Accounts screens. Manual expenses, income and transfers update
a session-only demo ledger. Budget creation, editing, filters and reallocation
work with that ledger. Analytics supports date/period selection, category
percentages, chart details and session spending updates. Connected Accounts offers
masked sample profiles, local refresh checks, and confirmed session removal/restoration;
open it from Home's balance card. `backend/` contains only a NestJS health endpoint.
There are no real bank/e-wallet integrations.

Run mobile: `cd mobile && flutter pub get && flutter run`.
Run backend: `cd backend && npm ci && npm run start:dev`.
Run local checks from root: `bash scripts/check.sh`.

See [approved UI inventory](docs/ui-reference.md) and
[architecture, dependencies and validation](docs/architecture.md).
