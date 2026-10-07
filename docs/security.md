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

## Deferred services

The NestJS API still exposes liveness only. Helmet and validation are configured;
production authentication, ownership checks, TLS deployment, server persistence,
rate limits and audit controls are not implemented. Provider connections/consent,
external financial data, cloud sync, camera/OCR and OS notification delivery remain
unavailable. Local in-app notices do not represent provider monitoring or delivery
receipts. Introduction completion is a navigation preference, not authorization.

Environment files, signing keys, database files and build output stay out of
source control. Commit lockfiles and review dependency changes. The backup feature
adds file_picker for native document dialogs; it does not add broad-storage,
camera or photo access requests in application code. Native permission behavior
still needs physical-device verification.
