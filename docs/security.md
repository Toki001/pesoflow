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
