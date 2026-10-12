# Physical Android backup and restore — 12 October 2026

Status: **completed single-device Android workflow; wider device/provider matrix
remains unverified**. This report separates observed phone behavior from host
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
notices. Counts were also checked against the authenticated preview.

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
No app data had been cleared at this preflight checkpoint.

## Results

| Check | Result |
| --- | --- |
| Redmi discovery/authorization and installed version | PASS |
| Backup creation and external file existence | PASS; authenticated preview checked before reset |
| Android save dialog | PASS; DocumentsUI Downloads destination directly observed, original save owner-assisted |
| Android restore picker and valid-file selection | PASS |
| Envelope metadata / encrypted payload | PASS; AES-GCM authentication and financial/image-reference validation passed |
| Empty/mismatched password validation | PASS on phone; no file created |
| Clean-state reset and restore | PASS; app-only `pm clear`, verified empty state, authenticated external restore |
| Accounts / metadata / balances restored | PASS; three original accounts and balances match |
| Transactions / expenses / income / transfers / categories | PASS; final CSV preserves all four original records and identities |
| Budgets restored | PASS; one Food & Dining allowance, PHP 325/400 |
| Receipt metadata restored | PASS; August date, reviewed fields and PHP 480 expense |
| Receipt image restored | PASS; actual image opens after app-data reset and restart |
| Analytics restored | PASS; October PHP 325, transfer excluded |
| Preferences restored | PASS; Light selected, PHP currency, introduction and two unread notices |
| Populated subscriptions / recurring-dismissal state | NOT TESTED physically; source had zero plans, covered by host round trip |
| Restart/background after restore | PASS; scoped force-stop/cold launch and Home-key resume |
| Continued writes | PASS; PHP 1 expense, projections and restart checked |
| Wrong password / invalid file | PASS; newer five-record state preserved |
| Corrupted copy | PASS; changed ciphertext rejected, same password subsequently unlocks original |
| Save/selection/replacement cancellation | PASS; explicit canceled states, no output or ledger change |
| Restore over existing data | PASS; 5 records replaced by original 4, no merge |
| Repeated restore | PASS; confirmation/restart leaves 3 accounts, 4 exact original records, one budget and receipt/image |
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


## Clean-state recovery milestone

After successful preflight, external size and SHA-256 were checked again and
matched the protected host copy. The exact reset command was targeted ADB
`pm clear com.pesoflow.pesoflow`; Android returned Success. No uninstall,
factory reset, other-package reset or unrelated file deletion occurred. The same
installed release launched its introduction; after completing it, Home showed
PHP 0, 0 accounts, 0 transactions, no budgets and 0 notices. The external backup
remained 1,587,055 bytes. This proves original local finances were removed.

The freshly initialized installation selected the external file again through
Android DocumentsUI, entered the password on the phone, authenticated its preview
and confirmed the explicit replacement dialog. Home restored PHP 5,195, three
accounts, October PHP 325 spending/PHP 1,000 income/+PHP 675 net flow, the
PHP 400 food budget with PHP 325 spent, and two unread notices. October
Transactions showed expense/income and a neutral PHP 500 transfer. August showed
the separate PHP 480 receipt. Transaction Detail → Saved receipt displayed the
actual restored image and reviewed fields; it does not rely on the deleted
original capture/staging path. Analytics returned PHP 325 October expense.

Home-key background/resume and app-scoped force-stop/cold relaunch passed with
the same Home financial values, budget and notices. The backup did not need an
old app-private URI cache or the original installation's secure-storage key.
Separate recents dismissal was not tested. Empty plan state is observed, not
proof of restoring a populated recurring-plan collection on hardware.


## Continued-use and failure-preservation checkpoint

A UI-created **Backup restore write check**, PHP 1 expense from GCash in Food &
Dining, saved successfully after recovery. Home changed to PHP 5,194, October
expense to PHP 326 and net flow to +PHP 674. Food usage became PHP 326/400,
PHP 74 remaining (82% rounded); Analytics showed PHP 326. Transactions displayed
the new PHP 1 expense. After force-stop/cold relaunch, Backup & export reported
3 accounts and 5 transactions, and Settings had Light explicitly selected.
This temporary record was later removed by verified replacement with the original
backup, not by deleting an unrelated user's record.

The native restore picker was canceled: the app reported selection canceled and
3 accounts/5 transactions remained. With the valid backup selected, a disposable
random wrong password (never printed or stored) failed authentication. The app
showed its safe password/complete-supported-file error, with no restore preview.
Home still showed PHP 5,194 and PHP 326/400 food usage. The original backup was
not modified. A plain text verification file was also selected through DocumentsUI
and rejected with the same safe error. Home remained PHP 5,194 and food usage
PHP 326/400. Corrupted-copy authentication was subsequently rejected below.


## Integrity, cancellation and export evidence

A separate copy changed one ciphertext byte while preserving the valid envelope
and salt. The owner entered the correct password on the phone; corrupted-copy
unlock failed with the safe complete-supported-file error and no preview. CSV
export afterward contained exactly 5 records, including the newer PHP 1 expense,
with 3 expenses, 1 income and 1 transfer. Checked in memory without printing
records: all-period expense PHP 806, income PHP 1,000, transfer PHP 500 and
October expense PHP 326. The unmodified backup subsequently authenticated with
the same masked password, proving corruption rejection independently of wrong
password rejection. Original backup bytes were not changed.

The Android save dialog was directly observed in Downloads. Canceling it returned
“Save canceled. No backup was saved.” The two canceled destination names had no
output file; no successful-save message or partial document was produced. Native
restore-picker cancellation and final replacement-dialog cancellation also left
records unchanged. Ordinary storage permission denial is not applicable to this
SAF workflow: the release manifest requests no broad storage/all-files permission.
This does not close the separate camera permission/Settings acceptance gap.

CSV requires the plaintext disclosure before entering the Android save picker.
A uniquely named verification CSV was saved externally; the app reported success
and its 1,323 bytes parsed correctly. Export diagnostics printed only counts,
currency and verification flags; CSV rows, receipt photos and raw OCR were not
committed. This readable export is not a restorable backup.

After authenticated preview showed current 3 accounts/5 transactions versus
backup 3 accounts/4 transactions, replacement confirmation clearly warned against
merging. Successful restore returned Home to PHP 5,195, October PHP 325 spending,
+PHP 675 net flow and PHP 325/400 food usage. This removed only the temporary test
expense via the requested whole-workspace replacement. The repeated replacement
checkpoint follows.


## Final state, cleanup and limits

The same backup was selected, authenticated and confirmed for replacement again.
After a subsequent scoped force-stop/cold launch, Home still showed PHP 5,195,
three accounts, PHP 325 October spending, +PHP 675 net flow and the unchanged
category allowance. Accounts showed Cash PHP 500 and Maya PHP -480, matching
GCash PHP 5,175 and the aggregate. Saved receipt opened its actual image again
through the August transaction after restart.

A second production CSV export after repeated replacement contained exactly four
unique transaction IDs. Comparing all columns in memory against the earlier
five-record CSV minus the temporary test expense showed exact equality: IDs,
dates, amounts, types/statuses, accounts/destination references, categories,
source, budget exclusion, notes and tags. No CSV rows were printed or committed.
This verifies replacement rather than duplicate/partial merge and continued
production export after recovery. Plans were empty; a populated plan collection
was not separately tested on hardware.

The original encrypted Downloads backup was re-read and its SHA-256 still matched
the pre-reset protected copy. No password or encryption key was recorded. Only
this run's corrupted copy, invalid-file document and two plaintext verification
CSVs were removed from Downloads after verification. The valid encrypted backup
is retained. Private receipt screenshots used for visual checks were not committed.
The app is left on light-theme Home at **PHP 5,195**, with original records intact.

Final release build checks pass: APK 100.0 MB and App Bundle 81.0 MB, with existing
debug signing unchanged. No backup code, architecture, dependency, financial
engine, schema, backend or approved UI change was needed; this run adds evidence
and documentation only. No defect was identified in the tested local backup path.

Not tested: a second physical Android or iPhone destination, cloud document
providers, safely isolated device filesystem exhaustion, exact physical restore
commit-boundary interruption, recents removal and phone lock/unlock. Host
interruption/SQLITE_FULL coverage must not be mislabeled physical verification.
The ordinary camera-denial/Settings gap belongs to the earlier receipt task and
was not retested here. Current format supports envelope/workspace version 1;
unsupported versions fail, not migrate silently. Forgotten passwords/missing files
and existing size bounds remain product limitations, not repaired by this test.
No external-service credential is needed for local backup; testing a cloud
provider requires its configured account.

Next recommended task: execute the documented cross-device round trip on a
second dedicated Android/iPhone installation, then cloud-provider and isolated
low-storage/interruption acceptance. Keep a verified backup and its password
separately before any destructive test.
