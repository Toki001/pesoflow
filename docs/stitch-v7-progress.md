# Stitch v7 implementation — 15 October 2026

Status: in progress. Source baseline `694ba26`.

## Authority and inventory

All 28 exported files now under `design/stitch/` match the version 7 ZIP byte for
byte (13 PNG/HTML pairs and two DESIGN.md files). All screenshots, HTML structures
and both design guides were inspected. The explicit product palette overrides
conflicting generated Material tokens. Earlier designs remain in Git history.

The production app already initializes encrypted Drift storage before Riverpod
and GoRouter. Accounts, transactions, budgets, analytics, subscriptions, receipt
OCR/image persistence and in-app notices use the real workspace. There is no
runtime fixture injection, implemented login server, OAuth session or profile
editor. The NestJS backend contains only health/configuration infrastructure.

| Area | Retain | Change |
| --- | --- | --- |
| Storage | Database `pesoflow`, schema 1, AES-GCM, secure key name, receipt table, atomic saves | Remove portable backup capture/replacement methods only |
| Commands | Account/transaction/budget/plan/preferences/notices and receipt writes | Remove backup command |
| Startup | Encrypted load, safe error/retry | Open Home immediately; remove introduction gate/recovery route |
| Identity | FinancialAccount and masked account metadata | Remove name/avatar, unused identity/sync state and obsolete onboarding |
| Presentation | Existing providers and financial engines | Translate all 13 latest designs using shared tokens/components |
| Receipts | Native camera/gallery/crop, ML Kit, parser, explicit correction/save | Separate scanner and review presentation; preserve image reopen |
| Settings | Appearance, currency/locale, financial alert preferences | Remove backup; implement supported category/default account controls and actual version |
| Tests | Financial/domain/encryption/restart/receipt regressions and deterministic fixtures | Remove backup-only tests; replace obsolete visual baselines with v7 coverage |
| Backend | Health endpoint, build/lint/test setup | No app dependency on a server; remove obsolete identity configuration |

## Data safety

No uninstall, app-data clear, database reset, reseeding, application-ID or key
change is permitted. Old optional serialization fields must remain readable.
Saved external documents are outside this task and must not be touched.

## Milestones

- [x] Inspect/import authoritative references and inventory existing implementation.
- [x] Remove obsolete features and prove old financial data remains readable.
- [x] Consolidate tokens/components and implement Home/navigation.
- [x] Implement transaction, account, budget/analytics and subscription designs.
- [x] Implement scanner/review, notifications and Settings designs.
- [ ] Review all 13 goldens, run full checks and native builds.
- [ ] Attempt non-destructive physical upgrade only if device is connected.

No v7 UI/build/device completion is claimed at this checkpoint.

Removal checkpoint: analyzer clean; 22 focused encrypted-repository, financial
command, receipt and pre-v7 compatibility tests pass. The upgrade test opens old
optional identity/sync fields from an encrypted file without rewriting ciphertext,
then saves normally and checks records/image bytes. First-run now routes directly
to Home. Previous Home goldens require replacement because the identity greeting
was removed; v7 visual verification remains pending. No device mutation performed.

## Main-screen checkpoint — 16 October

Native v7 hierarchy now covers Home, Transactions, Expense/Income/Transfer,
grouped Accounts, Budgets and Analytics. Shared app bars/cards/inputs/blue tokens
replace older styling. Category allocation uses a real-data ring; payment-source
totals share posted/as-of/refund semantics. CSV export is independently reachable
from Transactions. Credit limit and card metadata are optional JSON fields;
limits never enter cash balances and older encrypted records remain readable.

Reviewed captures against the approved Home, Expense, Transactions, Accounts,
Budgets and Analytics references. Differences retained for product truth: manual
account icons instead of unavailable licensed logos, actual financial totals,
explicit date/filter controls and real budget projections. Remaining detail,
subscription, receipt, notification and settings work and full final visual/build
checks are still pending. No physical device changes have been made.

## Secondary-screen checkpoint

Transaction Detail, recurring subscriptions/bills, Notifications, Settings and
separate scanner/review layouts now use v7 structure. Settings persists visible
categories/default payment account and supported alert preferences. Installed
version comes from native Android package/iOS bundle metadata. Receipt notes
persist with reviewed expenses; confirmation and atomic image writes are retained.
Account Detail retains edit/removal/archive/re-enable commands. Dead account
connection UI and unused Dio transport/dependency were removed.

Full Flutter suite: **206 passing tests**, including 29 golden comparisons
(12 screens × light/dark plus 5 receipt-review states). Analyzer is clean.
An intermediate release APK built successfully; final APK/AAB and iOS checks are
being run after cleanup. ADB discovery returned no attached devices on 16 October;
physical v7 upgrade/restart is **NOT TESTED**, with no device data changed.
