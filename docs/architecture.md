# Local-first architecture

PesoFlow opens without login, profiles, a backend or backup/restore. The current
13-screen native integration is tracked in [progress](stitch-v7-progress.md).

`main.dart` composes FinanceDatabase, FinancialCipher and SqliteFinanceRepository.
FinanceBootstrap loads the encrypted workspace before creating Riverpod scope and
GoRouter. FinanceController serializes commands, validates relationships and
publishes only committed state. Feature providers derive balances, budget progress,
analytics, recurring plans and in-app notices from the same workspace and clock.
UI state such as filters/date selection stays in feature controllers.

Storage remains Drift schema 1 in `pesoflow`, with encrypted workspace and receipt
rows. AES-GCM associated data binds workspace revisions and image IDs. Keys stay in
platform secure storage under the existing key name. Version-1 JSON retains all
financial records and receipt evidence; obsolete optional identity/sync fields
from older installations are ignored. No local records are reset on update.

Receipt acquisition uses image_picker, image_cropper and permission_handler.
Private staging strips metadata and bounds images before bundled Latin ML Kit OCR.
Parser evidence and corrections remain distinct. Image/expense writes and deletion
are atomic. The persisted image does not depend on a temporary capture path.

`app/theme` and `core/widgets` own shared tokens/primitives; features own screen
composition and domain logic. GoRouter preserves main tab state and opens focused
forms/details above the shell. CSV export is a readable transaction report and has
no import/replacement operation. file_picker supports its native save dialog.
Cryptography and secure storage remain required by local persistence.

Tests inject clocks, repositories and receipt adapters. Production never loads test
fixtures. Golden comparisons use bundled Inter and Material icons. Use
`scripts/check.sh` for format/analyze/test and retained NestJS health checks. The
backend is an optional standalone liveness service, not a mobile dependency.

Settings stores category visibility and a default account as optional JSON fields.
A minimal `com.pesoflow/app_info` method channel reads installed Android package
and iOS bundle version metadata; it introduces no package or identity dependency.
Credit metadata and receipt notes are additive optional fields, not schema changes.
The unused Dio transport and obsolete projection/connection UI were removed.
