# Production readiness

PesoFlow is a local-first expense tracker without login, profiles or backup/restore.
This tracker is not release certification. Current work: the approved 13-screen
Stitch v7 migration on 15 October 2026. See [milestone inventory](stitch-v7-progress.md).

## Verified foundations retained

The production runtime opens encrypted Drift storage before rendering financial
screens. FinanceController serializes atomic writes and Riverpod derives Home,
accounts, transactions, budgets, analytics, subscriptions and in-app notices from
persisted records. Fresh financial collections are empty. Transfers remain neutral
to aggregate income/expenses; refunds and exact integer monetary arithmetic are
covered by tests. Manual account creation/editing and transaction/budget/plan
commands already work. Failed saves preserve prior records and form inputs.

Receipt capture/gallery import/manual crop and bundled Latin ML Kit OCR run on
device. Merchant/date/items/total/category/account corrections require review.
Images and expenses commit together; saved receipt images reopen after restart.
Parser confidence is heuristic and real receipts often require corrections.

The 12 October physical Redmi release verified local finances and receipt image
persistence at PHP 5,195 across three accounts/four transactions, one budget and
one receipt. Those results precede v7 and do not certify the new UI. See
[Android report](verification/android-device-test.md).

## V7 migration in progress

- Authoritative 13 PNG/HTML pairs and both design guides imported and inspected.
- Portable backup UI, password cryptography, file selection, repository replacement
  commands, startup recovery and feature-only tests/docs removed. External saved
  documents are untouched. Transaction CSV export is retained independently.
- No login/authentication backend existed. Unused name/biometric/sync preferences,
  ownership state and introduction gate removed; old optional fields remain
  readable without requiring a database/key migration. Fresh startup opens Home.
- Encrypted database name/schema/application ID/key handling stay unchanged.
- UI modernization, settings completion, visual review and final checks are pending.

## Acceptance still required

All 13 screens need final v7 light/dark widget/golden review and native builds.
Physical v7 upgrade/restart checks must run only if an authorized device is
connected; no data clear or uninstall is allowed. iPhone runtime, ordinary camera
denial/Settings recovery, offline first scan, wider receipt corpus, accessibility,
large collections and controlled low-storage handling remain acceptance gaps.
OS notification delivery is not implemented; notices currently appear in-app.
There are no cloud accounts, external provider connections or payment operations.
Release signing/store configuration is separate and unavailable in this task.
