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
