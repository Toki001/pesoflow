# Persisted financial data model

`FinanceWorkspace` is the immutable aggregate committed by `FinanceController`.
Its encrypted JSON format remains version 1, inside Drift schema 1. A revision
check prevents stale writers; state publishes only after a successful commit.
Fresh collections are empty. No migration seeds or resets financial records.

- `FinancialAccount`: stable ID, name, type, currency, integer opening balance,
  masked identifier/institution/notes and archived state. Optional credit limit,
  card network and four final digits support card presentation. A debit card is
  metadata, not a duplicate account. A credit limit never contributes to balances.
  Historical provider observation fields remain readable but there is no provider
  connection flow. Posted ledger impacts calculate manually tracked balances.
- `TransactionRecord`: exact integer minor-unit amount, kind, category, timestamps,
  stable source/destination IDs, status, note/tags, provenance and budget exclusion.
  Transfers subtract/add across two accounts and count as neither income nor
  expenses. Refunds offset expense totals. Pending records do not affect balances.
- `SpendingBudget`: period/start, overall or category scope, integer limit,
  enabled state and threshold list. Projections use posted budget impacts in the
  selected cycle. Missing overall limits stay absent. Forecasts use actual pacing.
- `SubscriptionPlan`: tracked amount/cycle/next renewal/payment label/category and
  enabled state. Monthly equivalents derive from exact annualized amounts. A due
  date never creates a charge; recorded recurring transactions supply history.
- `ReceiptDraft` and `ReceiptEvidence`: reviewed merchant/date/category/account,
  optional items/notes, independent total/tax/discount, original OCR, parser
  warnings/confidence, confirmation and stable image/transaction associations.
  Saved encrypted image bytes live in the receipt table. Expense/image/metadata
  insertion and explicit transaction deletion are atomic.
- `FinancialNotice`: stable ID/condition key, kind, message, date and destination.
  Read IDs persist; period/condition keys prevent repeated notices on every rebuild.
- `LocalPreferences`: appearance, PHP currency/format metadata, supported alert
  switches, optional default account and hidden categories. A hidden category
  remains on existing transactions/reports. Archived/deleted defaults fall back
  to an active manual account. No identity, membership or authentication fields.
- Merchant-category rules and dismissed recurring keys preserve user choices.

Old optional identity/sync JSON is ignored without rewriting financial rows at
startup. New card/preferences/receipt-note fields have backward-compatible defaults.
The database name, application ID, encryption key name and associated data are
unchanged. Tests reopen pre-v7 ciphertext and receipt images and perform normal
post-upgrade writes. Older prototype storage is left untouched and never imported.

There is no portable import/replacement format or Backup/Restore feature. CSV is
one-way readable transaction export with integer minor units, delimiter quoting
and spreadsheet-formula neutralization. The finance engine remains independent
of presentation, file dialogs and optional backend infrastructure.
