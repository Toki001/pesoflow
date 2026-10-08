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
Inter/icons are bundled; Dio is reserved and unused. Payloads, passwords, keys
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

## User-controlled backups

Settings can save a password-encrypted portable backup independently of the device
key, or export an explicitly disclosed plaintext transaction CSV. See
[backup format, recovery and limits](backup.md). PBKDF2-HMAC-SHA256 (600,000
iterations, random 16-byte salt) and AES-256-GCM protect the portable payload.
Passwords are never persisted and cannot be recovered. Sync ownership, device
keys and biometric enrollment are never transferred. Strong passwords remain
necessary because anyone holding a backup can attempt offline password guesses.

Restore decrypts/validates before preview and explicit replacement confirmation.
A reviewed revision prevents stale replacement; workspace and image changes
commit atomically under the destination key. Wrong passwords, tampering, malformed
records, save cancellation and failed transactions do not replace committed data.
Missing-key recovery requires a previously saved backup and confirmation. There
is no automatic destructive reset and no cloud recovery service.

Backup plaintext/receipt bytes remain in app memory; Dart cannot promise memory
zeroization. Native pickers/providers may retain encrypted backup copies. CSV and
its possible staging files are readable without a password. Users select the
save destination, which can include a third-party cloud document provider. No
PesoFlow server receives exported data. File size/decrypted size/image bounds and
fixed algorithm/version checks constrain untrusted import work.

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
transaction deletion removes the associated image atomically. Backups include
required image references, validate them before restore, and remain subject to
[existing size limits](backup.md). See [receipt architecture and
limitations](receipts.md) and the [device acceptance checklist](verification/receipt-device-checklist.md).

## Deferred services

The NestJS API still exposes liveness only. Helmet and validation are configured;
production authentication, ownership checks, TLS deployment, server persistence,
rate limits and audit controls are not implemented. Provider connections/consent,
external financial data, cloud sync and OS notification delivery remain
unavailable. Local in-app notices do not represent provider monitoring or delivery
receipts. Introduction completion is a navigation preference, not authorization.

Environment files, signing keys, database files and build output stay out of
source control. Commit lockfiles and review dependency changes. The backup feature
uses file_picker for native document dialogs. Receipt capture requests Camera only
on user action and uses the system photo picker without broad-storage access.
Native permission behavior still needs physical-device verification.
