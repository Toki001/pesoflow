# Physical Android backup and restore — 12 October 2026

Status: **in progress**. This report separates observed phone behavior from host
checks; it is not release certification. Baseline application commit `6833a2a`.
Device: physical Redmi 14C (`2409BRN2CA`), Android 16/API 36, ARM64,
ADB ID `NBDEXCJNL7JR9DIJ`. Explicitly targeted package `com.pesoflow.pesoflow`,
installed version `0.1.0+1`. Flutter and ADB report it connected and authorized.
No other device or application is targeted.

## Implementation and security audit

The production UI is `BackupSettingsScreen`/`BackupScreen`; `BackupActions`
flushes the financial command queue before capture or revision checks.
`SqliteFinanceRepository.captureBackup` captures workspace plus decrypted stored
image bytes in one Drift transaction. `BackupCodec` performs password encryption
and authentication in a worker isolate. `NativeBackupFiles` uses the installed
`file_picker` Android adapter: `ACTION_CREATE_DOCUMENT` for save and
`ACTION_OPEN_DOCUMENT` for ordinary file selection. The native implementation
uses ContentResolver streams, not a content URI treated as a filesystem path.
Restore reads bounded bytes into memory; no ongoing external URI permission is
needed once the file is read. Subsequent restore selects the external file anew.
No broad storage or all-files permission is needed for these document flows.

Portable envelope and workspace codec are both version 1. The envelope has only
format/version, a random 16-byte salt and the base64 encrypted payload. PBKDF2-
HMAC-SHA256 uses 600,000 iterations and a 256-bit key; AES-256-GCM includes a
12-byte nonce and 16-byte authentication tag, with fixed version/algorithm/work
factor authenticated as associated data. The cryptography package generates a
fresh nonce per encryption. Passwords are not exported or stored; the test password
is owner-entered and retained separately, never placed in commands, logs or this
report. Dart memory zeroization is not guaranteed.

Contents: accounts/metadata, integer-money ledger including transfers, monthly
budgets, manually tracked plans, receipts/extraction evidence and image bytes,
categorization rules, dismissed recurring suggestions, notices/read state and
preferences (including currency/appearance/introduction). Product categories are
enum identities; no separate user category table is exported. Device encryption
keys, sync ownership/revision and biometric enrollment are excluded/reset. No
backend/provider session credentials are implemented or exported. A destination
uses its own secure-storage key; it does not need the original Android Keystore.

Unlock authenticates the file, validates the canonical workspace encoding,
financial relationships, supported version, size bounds and required receipt
image references before exposing a preview. Unsupported versions are rejected;
there is no general older-schema migration claim. Legacy receipt evidence parser
version 1 remains supported alongside version 2. Restore confirmation explains
whole-workspace replacement rather than merging. The reviewed revision is checked
again; workspace and images are re-encrypted under the destination key and
replaced in one SQLite transaction. UI state publishes only after commit. This
transaction is the staging/rollback boundary; it does not delete the database
before validation or create a separate plaintext staging database.

Encrypted backups and decoded receipt images stay in memory for review; the
backup flow does not write decrypted temporary files. Native document providers
can keep encrypted copies. CSV is deliberately plaintext and requires disclosure;
its native staging copies must be protected like the output. Failed provider
writes show failure, but provider-owned partial files may remain and require user
cleanup; automatic deletion of arbitrary external documents is not promised.

## Pre-reset evidence

Existing UI-created records are the source of truth, not injected fixtures:
three accounts, four transactions, one category budget and one saved receipt.
Home shows PHP 5,195; GCash PHP 5,175, Cash PHP 500, Maya PHP -480.
October income PHP 1,000, spending PHP 325 and net flow +PHP 675. Food & Dining
limit PHP 400, spending PHP 325, remaining PHP 75 (81% rounded usage).
The saved receipt is an August PHP 480 expense; its image must be portable.
Appearance is Light; workspace currency is PHP. There are two unread in-app
notices. Counts will also be checked against the authenticated preview.

The owner saved `pesoflow-20261012-222029.pfbackup` in Android Downloads through
the production UI. PesoFlow reported backup saved and cleared password fields.
External file size is **1,587,055 bytes**. Outer-envelope inspection validates
format/version, salt length and payload framing without logging decrypted data.
The picker briefly showed stale 0 B metadata; actual filesystem size and bytes
are nonzero. This is not evidence of a failed write. A protected encrypted copy
was retained outside the phone before any destructive step. Password-based
preflight authentication passed in the production UI: the owner-entered password
opened the validated preview with 3 accounts, 4 transactions, 1 budget, 0 plans,
1 receipt, 1 image and PHP currency. The owner confirmed preview appearance.
No app data has been cleared at this checkpoint.

## Results

| Check | Result |
| --- | --- |
| Redmi discovery/authorization and installed version | PASS |
| Backup creation and external file existence | PASS; authenticated preview checked before reset |
| Android save dialog | Owner confirmation pending |
| Android restore picker and valid-file selection | PASS |
| Envelope metadata / encrypted payload | PASS; AES-GCM authentication and financial/image-reference validation passed |
| Empty/mismatched password validation | PASS on phone; no file created |
| Clean-state reset and restore | NOT TESTED yet |
| Accounts/transactions/budgets/receipts/images/analytics/preferences restored | NOT TESTED yet |
| Restart/background after restore / continued writes | NOT TESTED yet |
| Wrong password / corrupted copy / invalid file | NOT TESTED yet |
| Save/selection/replacement cancellation | NOT TESTED yet |
| Restore over existing data / repeated restore | NOT TESTED yet |
| Cross-device restore | NOT TESTED — second physical device required |
| iPhone | NOT TESTED — physical iPhone required |
| Physical low storage | NOT TESTED — dedicated controlled storage required |
| Cloud document provider | NOT TESTED — available configured provider required |

## Automated evidence

`bash scripts/check.sh` passes: 186 formatted files unchanged, analysis clean,
**198 Flutter tests including 21 golden comparisons**, backend formatting/lint/
build and one health test. Existing tests cover complete/empty encrypted round
trips, salts/nonces, wrong password/tamper/truncation/version rejection, malformed
financial relationships, missing image references, new-key recovery, atomic
image-insert rollback, revision conflicts, repeated replacement, exact image
bytes and file-backed reopen. Widget tests cover confirmation/cancellation,
provider failures/retry and plaintext CSV disclosure.

`python3 scripts/check_backup_interruptions.py` passes all four isolated host
cases: before/after commit in DELETE/WAL journaling, with fresh-process complete
workspace/image verification. Bounded-database SQLITE_FULL tests pass; neither
host nor phone storage was filled. These do not certify phone power-loss,
filesystem exhaustion or native provider upload/download behavior.

## Later cross-device procedure

Device A: save an encrypted backup externally, authenticate its preview, retain
the file and password separately. Transfer only the encrypted backup, not device
keys. Device B: install PesoFlow, select the file through its native document
picker, enter the password, review counts and confirm replacement after backing
up any destination data. Compare all finances, receipt metadata/images and
preferences; force-stop/relaunch and verify again. Repeat the reverse direction.
Only the actually exercised source/destination pairing can be marked PASS.
