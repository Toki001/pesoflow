# Financial and UI verification

Production initializes an encrypted `FinanceWorkspace`/repository before rendering.
Fixtures and controlled failures live only under `test/fixtures` and `test/support`.
No runtime sample provider or reset control exists.

`production_app_test.dart` covers 12 v7 states in light/dark goldens; the receipt
suite adds five review states (normal, uncertain, missing items, OCR failure, dark).
Together these cover all 13 approved screens. Fresh-install/large-text and form
checks accompany captures. `v7_preferences_test.dart` verifies real persisted
preferences, default account/category selection, read states, removed routes and
native installed-version lookup. The version platform adapter is mocked only in
widget tests; native builds compile the actual implementation.

Financial tests cover integer arithmetic, transfers/refunds/pending records,
account identity, edits/deletion/archiving, budget and analytics projections,
revision conflicts, failed writes and encrypted file-backed restart. Pre-v7
compatibility opens old optional JSON fields without rewriting ciphertext and
retains financial rows/images after a normal write. Receipt tests cover parsing,
image preparation, cancellation/denial/retry, explicit confirmation, duplicate
save protection and atomic image/expense persistence/reopen/delete.

Two retained prototype helpers under `legacy/` support historical financial domain
regressions only; obsolete UI, identity/demo storage and old golden PNGs were removed.
Current golden names are `production_*` and `receipt_production_*`.

Run `flutter test`. Update captures only after reviewing changes against Stitch:
`flutter test test/production_app_test.dart test/receipt_screen_test.dart --update-goldens`.
Physical device results remain separate; fake-adapter tests do not validate native
camera/file dialogs. Never run a seeding harness on an existing installation.
