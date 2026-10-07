# Data export, backup and restore

Open **Settings → Backup & export**. Everything operates locally; no server
account, external financial provider or PesoFlow upload is involved. A location
chosen in the operating system's file picker may belong to a cloud file provider.

## Save a backup

Enter and confirm a strong password of at least 12 characters, then choose
**Save encrypted backup** and a location outside the app's private storage.
Keep the password separately. PesoFlow never saves the password and cannot reset
it or recover a backup if it is forgotten. A canceled save is not a backup.

The `.pfbackup` file contains accounts (including archived accounts), exact
integer amounts, transaction IDs and relationships, budgets, subscriptions,
receipt metadata and stored image bytes, categorization rules, recurring-dismissal
keys, notices/read markers and preferences. Device encryption keys, sync ownership
and biometric enrollment are excluded. No credentials or live connections are
created by restoring. Old `pesoflow_demo` databases are not exported or imported.

## Restore

Choose a backup file, enter its password, then **Unlock and review**. Check the
creation date, currency and record counts. **Review replacement** opens a final
confirmation. Restore replaces the entire current workspace and image collection;
it does not merge. Export the current workspace first if you need to keep it.
Canceling or discarding a preview changes no stored financial records.

Successful restore refreshes the app's financial screens and appearance and
returns to Home. If data changed after the preview, PesoFlow requires another
review. Unsupported versions, damaged files, invalid financial relationships and
incorrect passwords are rejected before replacement. A failed database write
rolls back both workspace and image changes.

If startup cannot decrypt local data, **Recover from backup** opens the same
review/confirmation workflow. A saved portable backup can be restored under a new
device key when the original key has been lost. This does not recover records
absent from the backup. Physical SQLite corruption, inaccessible secure storage,
or a device with no writable storage may still prevent restore; the app does not
delete the existing database to bypass an error. Replacing records is not forensic
erasure of old SQLite pages or separately saved files.

## Readable transaction export

**Export transaction CSV** asks you to acknowledge that the output is unencrypted.
The file includes transaction identities, ISO dates, kinds/statuses, merchant,
integer minor-unit amounts and currency, account/transfer references, category,
source, budget exclusion, notes and tags. Divide PHP `amount_minor` by 100 to
obtain pesos. Amounts are positive; `kind` specifies income, expense or transfer.
It is a UTF-8 CSV with BOM, CRLF records and quoted/escaped cells; spreadsheet
formula-leading values are prefixed with an apostrophe. Tags are JSON arrays in
one cell. CSV contains transactions only and cannot restore PesoFlow. Protect the
saved file and delete unwanted copies yourself. CSV export does not load images.

## Portable format v1

- JSON envelope: exactly `format: "pesoflow-backup"`, integer `version: 1`,
  base64 `salt` (16 random bytes), base64 `payload` (12-byte nonce, ciphertext,
  16-byte authentication tag).
- AES-256-GCM authenticates the complete payload with associated data
  `PesoFlow backup v1|PBKDF2-HMAC-SHA256:600000|AES-256-GCM`.
- PBKDF2-HMAC-SHA256 derives a 256-bit key with 600,000 iterations. The password
  is UTF-8 without trimming or Unicode normalization; leading/trailing whitespace
  does not count toward the 12-character minimum. Maximum: 1,024 UTF-8 bytes.
  A fresh secure random salt and nonce are used for every save. Version fixes the
  algorithm/work factor; the file cannot request arbitrary derivation work.
- Decrypted JSON contains UTC `createdAt`, the existing versioned `workspace`
  codec, and `images` mapping stored image IDs to base64 bytes. Revision and sync
  metadata are reset, biometric enrollment is false. Unknown/defaulted fields
  that would be silently dropped on re-encoding are rejected.
- Limits: 48 MiB input file, 32 MiB decrypted JSON, 20 MiB per image and 24 MiB
  aggregate raw images (encrypted capture also counts per-image overhead).
  Base64 and financial metadata count toward the JSON limit. Oversized backups
  fail explicitly; this version does not split or compress them.

Crypto uses the existing [cryptography package](https://pub.dev/documentation/cryptography/latest/cryptography/Pbkdf2-class.html)
in a worker isolate. Native file selection/save uses
[file_picker](https://pub.dev/documentation/file_picker/latest/file_picker/FilePicker-class.html).
The adapter bounds streamed reads as well as reported file size. File extensions
are not trusted. No plaintext backup or receipt-image temporary file is created
by PesoFlow; the native file provider/plugin may retain encrypted file copies.
Plaintext exists in app memory while exporting/reviewing; memory zeroization is
not guaranteed by Dart. CSV is deliberately plaintext, including any native
file-provider staging copies.

Restore reuses the existing Drift schema and local encryption. The workspace and
all images are encrypted with the destination device key in one SQLite transaction.
The existing command queue checks the reviewed revision and publishes the result
only after commit. A missing device key is generated only during confirmed restore,
never to pretend the old ciphertext was empty. There is no sync or engine rewrite.

## Verification and device checks

Automated tests cover complete encrypted round trips, fresh salts/nonces, wrong
passwords, tampering, malformed/unsupported/oversized payloads, strict financial
validation, new-key recovery, atomic rollback after an image insert failure,
stale previews, repeated replacement without duplicates, financial projection
refresh and reopening a file-backed encrypted database. Widget tests cover
confirmation, cancel, retry, CSV disclosure, accessible narrow layouts and
light/dark goldens. They inject file dialogs, not native picker UI.

Before release, perform this round trip on physical Android and iOS devices:
save to local Files and an available cloud document provider; cancel dialogs;
restore to a separate test installation; compare account balances, transactions,
budgets, plans and theme; force-stop/relaunch and compare again. Exercise lock/
unlock, provider download failures, interruption and storage exhaustion. Keep
source backups throughout. No physical-device or cloud-provider verification is
claimed by automated tests or simulator builds.
