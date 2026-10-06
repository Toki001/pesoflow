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

## Foundation available

`mobile/` now contains the Android/iOS Flutter application, shared light/dark
theme, routing, components and a deterministic Stitch Home demo. Other tabs
are explicit placeholders. `backend/` contains only a NestJS health endpoint.
There are no real bank/e-wallet integrations.

Run mobile: `cd mobile && flutter pub get && flutter run`.
Run backend: `cd backend && npm ci && npm run start:dev`.
Run local checks from root: `bash scripts/check.sh`.

See [approved UI inventory](docs/ui-reference.md) and
[architecture, dependencies and validation](docs/architecture.md).
