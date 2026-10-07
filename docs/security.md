# Foundation security boundary

The application contains only deterministic sample financial data. It collects
no secrets, bank credentials, receipt images or personal financial records.
Inter and icons are bundled locally. Dio is reserved and unused; payload/token
logging is not configured. Provider sync status is explicitly labeled Demo.

The API binds `127.0.0.1` and exposes only liveness. Helmet and validation are
configured, but this scaffold is not a production financial API. Authentication,
object authorization, TLS deployment, storage encryption, secure token storage,
rate limits and audit controls remain prerequisites for real financial features.
No certification or regulatory compliance is claimed.

Environment files, native signing keys, build output and test artifacts are
ignored. Commit lockfiles and review dependency changes. CI runs npm audit;
the resolved backend tree had zero findings at foundation verification.

Connected Accounts keeps masked sample identifiers only. Its catalog and
reauthentication explanation have no credential inputs, provider permissions,
external redirects, network calls or secret storage. Removing a demo profile
requires confirmation and leaves transaction history intact; it is not a remote
consent revocation. Live connection consent/revocation and secure adapter work
remain deferred. Local refresh errors use generic UI copy and do not log payloads
or mark unchanged/stale balances as freshly synced. Unverified Stitch security,
certification and provider-support claims are replaced by accurate demo wording.


Receipt Review contains a native synthetic preview and in-memory demo corrections
only. It requests no camera/photo permissions, loads no remote receipt image,
performs no OCR and uploads/stores no receipt files. Sample confidence and the
demo boundary are visible; uncertain lines cannot silently create an expense.
Discard/reload requires confirmation and preserves posted records. Snapshots are
session-only with immutable item lists; errors expose generic copy, not payloads.
Actual receipt capture, parsing, file access/retention and protected persistence
remain separate prerequisites before accepting real receipt imagery.


Onboarding provides an explicit demo disclosure and entry action. It requests
no credentials, permissions or personal information, makes no network request
and does not establish authentication or provider consent. Deep links remain
accessible deliberately; introduction routing is not an access-control boundary.
Protected routes, secure authentication and provider consent require separate
implementation before real financial data is accepted. The disclosure states
that balances are illustrative, edits reset on restart, and real account
connections, money movement, camera capture and OCR are unavailable.


Settings controls session-only appearance and exposes existing sample-account
and introduction routes. It collects no personal data, credentials or permission
and writes nothing to disk or a server. Theme changes and restoring the device
appearance do not erase or transmit financial demo edits. Formatting is fixed
to PHP and English (Philippines). No biometric lock, security certification,
notification delivery, account connection or persistence is implied by these
controls. Real authentication and protected storage remain later milestones.


The notification center loads local illustrative events only. It requests no
notification permission, obtains no push token, sends no network request and
logs no financial payload. Typed destinations link only to existing internal
screens. Read actions affect local inbox state and never initiate financial
operations, connection consent or money movement. Alerts disclose their sample
date and static nature; expired-connection copy does not request credentials.
Actual alerts require authenticated event ownership, protected persistence,
deduplication/cooldowns and delivery/privacy controls in a separate milestone.


Account Detail reads masked sample profiles and session activity only. Its local
check contacts no financial institution and changes no balance timestamp; expired
profiles remain stale. Reconnection is an explanation with no credential fields
or authorization redirect. Removal requires the existing confirmation and leaves
ledger history intact. Unknown/removed account links expose a safe unavailable
state. No permissions, real account identifiers, remote connection revocation,
authentication or production account-ownership guarantees are introduced.


The demo access review requires an explicit sample-only acknowledgment. Its
application guard rechecks profile uniqueness, loaded account state, local-check
status and existing membership before adding; the CTA alone is not the guard.
Acknowledgment is disposed on leaving the review, is never persisted and cannot
serve as provider/legal consent. The route accepts only a matching catalog ID;
there is no external URL, credential field, remote authorization or permission
request. Cancel changes nothing; removal preserves ledger history. Production
consent ownership, scope, expiry, audit and revocation are unimplemented.


Stable ledger account references replace name-based associations. Missing legacy
references remain unresolved rather than matching a financial institution by
label. Local IDs confer no authorization or ownership and expose no raw account
numbers. Future authenticated storage/API work must verify account ownership and
scope independently; this milestone adds neither persistence nor network access.

## Local demo storage boundary

The native app now writes demo transactions, notes, tags and reviewed receipt
item snapshots into its application documents SQLite file. The database is not
encrypted and has no authenticated ownership model; the UI explicitly says to
use sample data only. There are no receipt images, account numbers, credentials,
tokens, remote uploads or real-provider requests. Platform backups may include
app data; encrypted storage, backup policy and authenticated access are required
before real personal/financial data support.

Exact-centavo validation and complete transactional snapshots prevent fractional
money truncation and partial ledger/receipt commits. Invalid or future-version
stored data is refused; it is not logged, silently deleted or overwritten with
fixtures. Startup retry and confirmed reset expose only safe messages. Failed
writes preserve memory and the previous committed database row with explicit
retry; pending saves have no durability guarantee until completion.

Reset requires confirmation and publishes fixtures only after a successful write.
It logically removes added/edited activity and saved receipt snapshots, preserves
unrelated session state and initiates no provider operation. This is a logical
reset, not a promise of forensic erasure of SQLite pages/platform backups. Database
files and financial payloads must never be checked into source control.


Local demo budget limits and subscription tracking now share the same unencrypted
SQLite boundary. They contain sample planning metadata, not credentials, provider
consent, authenticated ownership or automated charges. Only sample data is
supported. Strict version/integer/identity validation rejects corruption without
logging payloads or silently replacing stored data. A failed v1 migration rolls
back atomically. Activity and planning resets have separate confirmations and
preserve the other domain; startup recovery explicitly confirms a full reset.
Logical reset does not guarantee forensic erasure or removal from platform backups.


Saved appearance and demo introduction completion use the same versioned local
snapshot. Completion is only a navigation preference: it grants no authentication,
financial-provider consent, permission or protected access. Reopening the intro
does not erase that preference. Existing scoped resets preserve preferences;
startup full-reset confirmation explicitly names their default restoration.
Storage remains unencrypted and sample-only; no credentials or real data are added.
