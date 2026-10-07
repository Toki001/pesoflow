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

The app starts with a three-step introduction and an explicit **Explore demo**
entry. Skip goes to the demo disclosure; it does not bypass it. Sample data and
edits are session-only, and no credentials or financial account connections are
requested. Explicit screen deep links remain available. Tap Home’s avatar to open Settings:
choose System, Light or Dark appearance for the current session, restore device
appearance, view sample accounts or revisit the introduction. Appearance changes
preserve demo edits and navigation. Home, Analytics and Budgets bells open a
session-only notification center: filter All/Unread, mark individual/all alerts
read, and open budgets, subscriptions, sample accounts or analytics. These are
fixed October 2024 snapshots, not live monitoring or delivered push messages.
Tap a sample account’s identity or Settings action to open Account Detail: inspect
its masked profile, reported balance/timestamp and related demo activity, run a
local check, or confirm removal. Manual activity never changes reported balances;
stale profiles remain labelled last known. Link Account opens a sample catalog;
selecting an unlisted profile opens Review Demo Access. Read the limits and check
“I understand this adds sample data only” before adding it. Cancel changes
nothing. This acknowledgment does not grant provider permissions or connect a
real account.

`mobile/` now contains the Android/iOS Flutter application, shared light/dark
theme, routing and native Stitch Home, Transactions, Transaction Detail,
Add Expense, Budgets, Analytics, Connected Accounts, Subscriptions and Receipt Review screens. Manual expenses, income and transfers update
a session-only demo ledger. Budget creation, editing, filters and reallocation
work with that ledger. Analytics supports date/period selection, category
percentages, chart details and session spending updates. Connected Accounts offers
masked sample profiles, local refresh checks, and confirmed session removal/restoration;
open it from Home's balance card. Tap Home's Upcoming Bills card for Subscriptions:
add/edit plans, sort renewals, pause/resume tracking, confirm removal and view
recorded recurring charges. Weekly/monthly/quarterly/yearly plans update session
commitments without posting expenses or cancelling services. `backend/` contains
only a NestJS health endpoint. Add Expense’s Scan action opens the native demo
receipt review: correct items, merchant/date, category and payment source, confirm
uncertain items, and save one receipt expense with its item snapshot. No camera,
upload, live OCR, receipt file storage or real bank/e-wallet integrations exist.

Run mobile: `cd mobile && flutter pub get && flutter run`.
Run backend: `cd backend && npm ci && npm run start:dev`.
Run local checks from root: `bash scripts/check.sh`.

See [approved UI inventory](docs/ui-reference.md) and
[architecture, dependencies and validation](docs/architecture.md).
