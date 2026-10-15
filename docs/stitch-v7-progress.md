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
- [ ] Remove obsolete features and prove old financial data remains readable.
- [ ] Consolidate tokens/components and implement Home/navigation.
- [ ] Implement transaction, account, budget/analytics and subscription designs.
- [ ] Implement scanner/review, notifications and Settings designs.
- [ ] Review all 13 goldens, run full checks and native builds.
- [ ] Attempt non-destructive physical upgrade only if device is connected.

No v7 UI/build/device completion is claimed at this checkpoint.

Removal checkpoint: analyzer clean; 22 focused encrypted-repository, financial
command, receipt and pre-v7 compatibility tests pass. The upgrade test opens old
optional identity/sync fields from an encrypted file without rewriting ciphertext,
then saves normally and checks records/image bytes. First-run now routes directly
to Home. Previous Home goldens require replacement because the identity greeting
was removed; v7 visual verification remains pending. No device mutation performed.
