# Security boundary

PesoFlow supports real, manually entered financial records in a local encrypted
workspace. Runtime sample injection has been removed; deterministic examples and
prototype helpers live only in tests. The [production tracker](production-readiness.md)
records historical checkpoints and remaining work. No security certification or
regulatory compliance is claimed.

## Local storage

Financial records and stored receipt images use authenticated AES-256-GCM before
SQLite persistence, with fresh nonces and record-bound associated data. Drift
stores ciphertext; the key lives in platform secure storage (device-bound iOS
Keychain). Android platform app-data backup is disabled. The app exposes no raw
bank credentials or account numbers; manual accounts keep optional masked labels.
Inter/icons are bundled; the unused network transport has been removed. Payloads, passwords, keys
and tokens are not logged.

Startup fails closed when ciphertext cannot be opened. It never replaces damaged
or unsupported data with empty records or fixtures. Saves check revisions and
publish only after successful commits. User financial values remain integer minor
units with validated identities and associations. The separate old unencrypted
`pesoflow_demo` database is preserved, never silently adopted or erased.

Encryption at rest does not supply an app lock, authenticated user identity,
screenshot protection or defense against a compromised/unlocked device. Biometric
locking is not implemented. No forensic-erasure guarantee is made for SQLite,
file-provider caches or OS copies. Physical-device interruption, secure-storage
and lock/unlock checks remain required before release.

## Export and data retention

Backup/Restore and their password-based portable cryptography have been removed.
Encrypted local storage and device-bound keys remain. Saved external documents
are untouched by the migration. The app has no cloud recovery service or automatic
reset when data/key access fails. Removing app data can make records unrecoverable.

Transactions can export a readable CSV after disclosure through a native save
dialog. CSV and possible file-provider staging copies are not encrypted by
PesoFlow. The user chooses the destination; no PesoFlow server receives the data.
Quoting and formula-prefix neutralization constrain spreadsheet interpretation.

## Receipt capture and OCR

ML Kit reads Latin text on the device; PesoFlow does not upload receipt images or
OCR text. Native camera/photo and crop plugins use private temporary files. The
app normalizes images in a worker isolate, strips image metadata and saves the
reviewed image only as encrypted bytes in Drift. Receipt text, confidence and
corrections share the encrypted workspace. No receipt-content logging is added.

The image must temporarily exist in plaintext in app-private cache for native OCR.
Prepared files are cleaned after replacement/discard/successful save, with stale
staging cleanup on the next scan after restart. Plugin/OS caches may survive a
crash; no forensic-erasure guarantee is made. Unsaved review edits are session-only.
A single database transaction commits the expense, metadata and encrypted image;
transaction deletion removes the associated image atomically. See [receipt architecture and
limitations](receipts.md) and the [device acceptance checklist](verification/receipt-device-checklist.md).

## Deferred services

The optional NestJS API exposes liveness only; it receives no financial data.
Provider connections, external financial data, cloud sync and OS notification
delivery are unavailable. Local in-app notices do not represent provider monitoring.

Environment files, signing keys, database files and build output stay out of
source control. Native CSV export retains file_picker. Receipt capture requests
Camera only on user action and uses the system photo picker without broad-storage
access. Physical permission/runtime acceptance is documented separately.
