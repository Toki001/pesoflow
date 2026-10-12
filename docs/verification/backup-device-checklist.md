# Backup resilience verification — historical host baseline, 8 October 2026

Test implementation: `df6a41c`; application behavior remains the checkpoint 5
backup implementation (`a608c86`).

At this historical checkpoint, physical-device verification was **blocked by
unavailable hardware**, not passed. Physical Android results from 12 October 2026
are now recorded in [the backup/restore device report](backup-restore-device-test.md).
That report supersedes Android availability and completed local-device checks;
iPhone, cross-device, cloud-provider and physical low-storage checks remain pending.
Read-only discovery found no Android device (`adb devices -l`) and no physical iOS
device (`xcrun devicectl list devices`); Flutter reported only macOS and Chrome.
The owner confirmed physical devices cannot be connected at this time. Simulator
builds and host tests do not establish phone, cloud-file-provider or Keychain/
Keystore behavior. No personal device was modified or filled with test files.

## Evidence obtained on the host

| Check | Result | Boundary |
| --- | --- | --- |
| SQLite restore runs out of database pages | Passed, DELETE and WAL | Real `SQLITE_FULL` in bounded temporary files; not exhaustion of the device filesystem |
| Reopen after failed restore | Passed | Exact original workspace and images remain; `integrity_check` returns `ok` |
| Retry after removing the growth limit | Passed | Replacement succeeds; old images are removed and new image bytes match |
| Key temporarily unavailable | Passed | Injected key-store error; records and key remain unchanged, retry works; not a real device lock |
| Process killed during restore | Passed, DELETE and WAL | Real worker process terminated after workspace replacement, old-image deletion and first new-image insertion; fresh process finds original data |
| Process killed after restore commit | Passed, DELETE and WAL | Fresh process finds complete restored workspace and images |
| File-provider read/write failure | Passed | Injected native-style exceptions; safe error, no success claim or restore, retry works |
| Background/resume while restore is pending | Passed | Widget lifecycle events with pending action; duplicate restore disabled; not native OS suspension |
| Stale restore preview | Passed | Review discarded; reopening and confirmation required |
| Native local/cloud save and pick dialogs | Blocked | No physical Android/iOS devices |
| Android → iOS and iOS → Android transfer | Blocked | No physical Android/iOS devices |
| Actual phone lock/unlock, force-stop, filesystem exhaustion | Blocked | Requires dedicated hardware and hands-on operation |

`backup_resilience_test.dart` exercises the real repository/controller with a
SQLite page ceiling. SQLite documents that exceeding `max_page_count` returns
[`SQLITE_FULL`](https://www.sqlite.org/limits.html#max_page_count). This constrains
only each test database; it does not consume all free disk space.

The interruption runner starts isolated Flutter test processes with test-only
keys and temporary databases. It waits for an explicit transaction boundary,
checks that the target PID belongs to its own process group, then sends SIGKILL.
A small SQLite page cache forces image writes to spill before commit. Verification
runs in a new process and compares the full workspace, image bytes and database
integrity. This tests process termination, not power loss or hardware faults.

Run from the repository root (Flutter and Python 3 on PATH):

```sh
bash scripts/check.sh
python3 scripts/check_backup_interruptions.py
```

The four process-kill cases are separate from the standard Flutter test count.
The worker target must be invoked by its runner, not added as a normal test suite.
It is never imported by the shipped application. The script creates and cleans
only its own temporary directory/process group. No production database, real key,
backup password or provider credential is used.

## Pending physical-device procedure

Use dedicated test installations and invented records only. Record app commit,
phone model, OS version, file-provider name/version, direction of transfer, expected
values, observed result, date and non-sensitive screenshots for every case. Do not
record backup passwords, real financial records or raw platform identifiers.
Keep an untouched external backup before replacement, uninstall or fault testing.

### Deterministic records and expected results

On the source device, complete onboarding and create records dated today:

1. Manual **Test cash**, PHP 1,000.00 opening balance.
2. Manual **Test wallet**, PHP 0.00 opening balance.
3. Income **Test pay**, PHP 500.00 into Test cash.
4. Expense **Test lunch**, PHP 325.25 from Test cash, Food & Dining.
5. Transfer PHP 200.00 from Test cash to Test wallet.
6. Monthly overall budget PHP 2,000.00; Food & Dining allowance PHP 500.00.
7. Set dark appearance and add a manually tracked subscription if exercising plans.

Expected: two accounts, three transactions, Test cash PHP 974.75, Test wallet
PHP 200.00, aggregate balance PHP 1,174.75, income PHP 500.00, expense PHP 325.25,
net flow PHP 174.75, overall remaining budget PHP 1,674.75 and food remaining
PHP 174.75. Transfers must not inflate income or expense. Receipt capture was unavailable at this historical baseline; the current app
supports it. Include a consented/redacted saved receipt when repeating this
procedure to check physical image portability.

### File dialogs and portable restore

For **each** Android and iOS source/destination pairing:

1. Open Settings → Backup & export. Save a `.pfbackup` with a strong, separately
   retained test password to local Files. Cancel once before saving; no saved
   success should appear after cancellation. Repeat with an available cloud
   document provider. Note whether the provider actually finished uploading.
2. Select the saved file, unlock it and compare preview counts/date/currency.
   Cancel selection, discard preview and cancel replacement separately. Verify
   unchanged balances after each. Try a wrong password and a truncated copy;
   neither may replace records or expose file paths in an error message.
3. Export CSV after acknowledging plaintext disclosure. Open the saved CSV and
   verify three records, exact integer minor units, transfer source/destination
   and text fields. Canceling its save must not report success.
4. Transfer the encrypted backup outside PesoFlow to the destination test phone.
   Do not transfer device encryption keys. Enter the password separately. Use a
   destination containing a clearly different test account so replacement can
   be distinguished from merging; save that destination first if it is needed.
5. Confirm restore and compare every expected value above in Home, Transactions,
   Accounts, Budgets and Analytics, plus saved plan and appearance. Restore twice;
   counts must remain two accounts and three transactions.
6. Force-stop/quit and reopen the production entry point. Compare again. Repeat in
   the reverse Android/iOS direction. Record both outcomes; one direction is not
   evidence for the other.

### Interruptions and unavailable storage

On dedicated phones only, with the original backup retained elsewhere:

- Background/resume and lock/unlock during file selection, unlock/review and
  restore. Check responsiveness, no duplicate submission and safe errors. A
  failed read must not fabricate an empty workspace or replace the local key.
- Terminate during restore and after success, reopen, and compare with the known
  original/restored snapshots. The result must be one complete snapshot, never a
  mix. Native manual timing alone cannot prove the exact commit boundary; the
  host process-barrier test supplies that controlled evidence.
- Disable connectivity while requesting a cloud-only file, revoke provider access
  or make the destination unwritable. No successful export should be claimed
  after an error. Retry once the provider is available. Check whether a partial
  output remains and verify that import rejects it.
- Test actual low-storage behavior only on a disposable test device/profile with
  an agreed cleanup plan. Do not fill this Mac or a personal phone. Exercise both
  export and restore failure, then free test space and retry. The original local
  workspace must survive failed restore; externally staged partial exports may
  need manual cleanup. This remains unverified until real hardware is available.

A missing backup or forgotten password is not recoverable by this feature.
Uninstall/key-loss testing must retain both outside the test installation first;
reinstall behavior alone does not establish that an iOS Keychain key was removed.
