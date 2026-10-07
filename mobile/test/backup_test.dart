import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pesoflow/core/storage/finance_database.dart';
import 'package:pesoflow/core/storage/financial_cipher.dart';
import 'package:pesoflow/core/time/clock.dart';
import 'package:pesoflow/features/accounts/application/accounts_provider.dart';
import 'package:pesoflow/features/analytics/application/analytics_provider.dart';
import 'package:pesoflow/features/budgets/application/budgets_provider.dart';
import 'package:pesoflow/features/transactions/application/transactions_provider.dart';
import 'package:pesoflow/features/backups/data/backup_codec.dart';
import 'package:pesoflow/features/backups/data/transaction_csv.dart';
import 'package:pesoflow/features/backups/domain/finance_backup.dart';
import 'package:pesoflow/features/dashboard/application/dashboard_provider.dart';
import 'package:pesoflow/features/notifications/domain/financial_notice.dart';
import 'package:pesoflow/features/notifications/domain/notice_view.dart';
import 'package:pesoflow/features/receipts/domain/receipt_draft.dart';
import 'package:pesoflow/features/settings/domain/appearance.dart';
import 'package:pesoflow/features/transactions/domain/transaction.dart';
import 'package:pesoflow/features/workspace/application/finance_controller.dart';
import 'package:pesoflow/features/workspace/data/finance_workspace_codec.dart';
import 'package:pesoflow/features/workspace/data/sqlite_finance_repository.dart';
import 'package:pesoflow/features/workspace/domain/finance_workspace.dart';

import 'fixtures/finance_workspace_fixture.dart';
import 'fixtures/features/subscriptions/data/subscription_fixture.dart';
import 'support/finance_fakes.dart';

const password = 'separate backup password 123!';
final now = DateTime.utc(2026, 10, 7);
void main() {
  late FinanceBackup snapshot;
  late Uint8List encrypted;
  setUpAll(() async {
    final source = financeFixture();
    final tx = source.ledger.first;
    final receipt = ReceiptDraft(
      id: 'receipt-image',
      merchant: tx.merchant,
      accountId: tx.accountId!,
      account: tx.account,
      occurredAt: tx.occurredAt,
      savedTransactionId: tx.id,
      items: [
        ReceiptItem(
          id: 'line',
          name: 'Lunch',
          quantity: 1,
          unitPrice: tx.amount,
          reviewed: true,
        ),
      ],
    );
    final w = source.copyWith(
      ledger: [
        tx.copyWith(source: TransactionSource.receipt, hasReceipt: true),
        ...source.ledger.skip(1),
      ],
      receipts: {tx.id: receipt},
      merchantRules: {'lunch': TransactionCategory.food},
      dismissedRecurringKeys: {'dismissed-plan'},
      notices: [
        FinancialNotice(
          id: 'notice',
          title: 'Budget reached',
          message: 'Review spending',
          createdAt: now,
          kind: NoticeKind.budget,
          destination: NoticeDestination.budgets,
          conditionKey: 'budget:oct',
        ),
      ],
      noticeReadIds: {'notice'},
      subscriptions: subscriptionFixture(),
      preferences: financeFixture().preferences.copyWith(
        appearance: Appearance.dark,
        biometrics: true,
      ),
      sync: const SyncMetadata(
        ownerId: 'never-export-this-owner',
        serverRevision: 27,
      ),
    );
    snapshot = FinanceBackup(w, {
      'receipt-image': Uint8List.fromList([1, 2, 3, 4, 255]),
    }, now);
    encrypted = await BackupCodec.seal(snapshot, password);
  });
  test('portable encryption preserves exact finances and images without device credentials', () async {
    final raw = utf8.decode(encrypted);
    for (final secret in [
      'Jollibee',
      'never-export-this-owner',
      password,
      'receipt-image',
    ]) {
      expect(raw, isNot(contains(secret)));
    }
    final restored = await BackupCodec.open(encrypted, password);
    final expected = snapshot.workspace.copyWith(
      revision: 0,
      sync: const SyncMetadata(),
      preferences: snapshot.workspace.preferences.copyWith(biometrics: false),
    );
    expect(
      FinanceWorkspaceCodec.encode(restored.workspace),
      FinanceWorkspaceCodec.encode(expected),
    );
    expect(restored.images['receipt-image'], [1, 2, 3, 4, 255]);
    expect(restored.createdAt, now);
    final second = await BackupCodec.seal(snapshot, password);
    expect(second, isNot(orderedEquals(encrypted)));
    expect(
      () => restored.images['receipt-image']![0] = 9,
      throwsUnsupportedError,
    );
  });
  test('wrong password and authenticated ciphertext/salt modifications are rejected', () async {
    await expectLater(
      BackupCodec.open(encrypted, 'incorrect password 123'),
      throwsA(isA<BackupFailure>()),
    );
    for (final field in ['payload', 'salt']) {
      final json = jsonDecode(utf8.decode(encrypted)) as Map<String, dynamic>;
      final bytes = base64Decode(json[field] as String);
      bytes[0] ^= 1;
      json[field] = base64Encode(bytes);
      await expectLater(
        BackupCodec.open(
          Uint8List.fromList(utf8.encode(jsonEncode(json))),
          password,
        ),
        throwsA(isA<BackupFailure>()),
      );
    }
  });
  test('truncation, future formats, legacy JSON and excessive sizes fail before restore', () async {
    final envelope = jsonDecode(utf8.decode(encrypted)) as Map<String, dynamic>;
    for (final bytes in [
      Uint8List(0),
      Uint8List.fromList(encrypted.take(100).toList()),
      Uint8List(maxBackupBytes + 1),
      Uint8List.fromList(
        utf8.encode(FinanceWorkspaceCodec.encode(snapshot.workspace)),
      ),
      Uint8List.fromList(utf8.encode(jsonEncode({...envelope, 'version': 2}))),
      Uint8List.fromList(
        utf8.encode(jsonEncode({...envelope, 'extra': 'unknown'})),
      ),
    ]) {
      await expectLater(
        BackupCodec.open(bytes, password),
        throwsA(isA<BackupFailure>()),
      );
    }
    await expectLater(
      BackupCodec.seal(snapshot, 'too short'),
      throwsA(isA<BackupFailure>()),
    );
  });
  test(
    'authenticated but invalid financial payloads are rejected before restore',
    () async {
      final envelope =
          jsonDecode(utf8.decode(encrypted)) as Map<String, dynamic>;
      final salt = base64Decode(envelope['salt'] as String);
      final key = await Pbkdf2.hmacSha256(
        iterations: BackupCodec.iterations,
        bits: 256,
      ).deriveKey(secretKey: SecretKey(utf8.encode(password)), nonce: salt);
      final algorithm = AesGcm.with256bits();
      final aad = utf8.encode(BackupCodec.header);
      final original = await algorithm.decrypt(
        SecretBox.fromConcatenation(
          base64Decode(envelope['payload'] as String),
          nonceLength: 12,
          macLength: 16,
        ),
        secretKey: key,
        aad: aad,
      );
      for (final change in <void Function(Map<String, dynamic>)>[
        (w) => (w['ledger'] as List).add((w['ledger'] as List).first),
        (w) => (w['ledger'] as List).first['accountId'] = 'missing',
        (w) => (w['ledger'] as List).first['amount'] = 32500.5,
        (w) => w['unknown'] = 'unsupported field',
        (w) => (w['preferences'] as Map)['biometrics'] = true,
        (w) => (w['receipts'] as Map).values.first['savedTransactionId'] =
            'missing',
      ]) {
        final payload =
            jsonDecode(utf8.decode(original)) as Map<String, dynamic>;
        change(payload['workspace'] as Map<String, dynamic>);
        final box = await algorithm.encrypt(
          utf8.encode(jsonEncode(payload)),
          secretKey: key,
          aad: aad,
        );
        final malformed = Uint8List.fromList(
          utf8.encode(
            jsonEncode({
              ...envelope,
              'payload': base64Encode(box.concatenation()),
            }),
          ),
        );
        await expectLater(
          BackupCodec.open(malformed, password),
          throwsA(isA<BackupFailure>()),
        );
      }
    },
  );
  test(
    'restore into a new device key survives close/reopen with exact balances',
    () async {
      final dir = await Directory.systemTemp.createTemp('pf-backup-');
      final file = File('${dir.path}/data.sqlite');
      final keys = MemoryEncryptionKeys();
      var repo = SqliteFinanceRepository(
        FinanceDatabase(NativeDatabase(file)),
        FinancialCipher(keys),
      );
      final backup = await BackupCodec.open(encrypted, password);
      await repo.load();
      await repo.restoreBackup(backup, expectedRevision: 0);
      await repo.close();
      repo = SqliteFinanceRepository(
        FinanceDatabase(NativeDatabase(file)),
        FinancialCipher(keys),
      );
      try {
        final loaded = await repo.load();
        expect(loaded.revision, 1);
        expect(loaded.ledger, backup.workspace.ledger);
        expect(
          FinanceWorkspaceCodec.encode(loaded.copyWith(revision: 0)),
          FinanceWorkspaceCodec.encode(backup.workspace),
        );
        expect(loaded.preferences.appearance, Appearance.dark);
        expect(loaded.sync.ownerId, isNull);
        expect(
          await repo.loadReceiptImage('receipt-image'),
          backup.images['receipt-image'],
        );
        final c = ProviderContainer(
          overrides: [
            financeRepositoryProvider.overrideWithValue(repo),
            initialWorkspaceProvider.overrideWithValue(loaded),
            clockProvider.overrideWithValue(
              () => DateTime(2024, 10, 24, 12, 35),
            ),
          ],
        );
        expect((await c.read(dashboardProvider.future))!.balance, 4576550);
        c.dispose();
      } finally {
        await repo.close();
        await dir.delete(recursive: true);
      }
    },
  );
  test('atomic restore rolls back workspace and all receipt images after insert failure', () async {
    final db = FinanceDatabase(NativeDatabase.memory());
    final repo = SqliteFinanceRepository(
      db,
      FinancialCipher(MemoryEncryptionKeys()),
    );
    await repo.load();
    final before = await repo.save(financeFixture(), expectedRevision: 0);
    await repo.saveReceiptImage('old', Uint8List.fromList([8]));
    await db.customStatement(
      "CREATE TRIGGER reject_images BEFORE INSERT ON encrypted_receipts BEGIN SELECT RAISE(ABORT, 'test failure'); END",
    );
    await expectLater(
      repo.restoreBackup(snapshot, expectedRevision: 1),
      throwsA(isA<Exception>()),
    );
    expect(
      FinanceWorkspaceCodec.encode(await repo.load()),
      FinanceWorkspaceCodec.encode(before),
    );
    expect(await repo.loadReceiptImage('old'), [8]);
    expect(await repo.loadReceiptImage('receipt-image'), isNull);
    await db.customStatement('DROP TRIGGER reject_images');
    await repo.restoreBackup(snapshot, expectedRevision: 1);
    expect(await repo.loadReceiptImage('old'), isNull);
    expect(
      (await repo.captureBackup(now)).images['receipt-image'],
      snapshot.images['receipt-image'],
    );
    await expectLater(
      repo.restoreBackup(snapshot, expectedRevision: 1),
      throwsA(isA<WorkspaceConflict>()),
    );
    expect((await repo.load()).ledger, snapshot.workspace.ledger);
    await repo.close();
  });
  test('recovery can replace unreadable ciphertext when original device key is lost', () async {
    final db = FinanceDatabase(NativeDatabase.memory());
    final keys = MemoryEncryptionKeys();
    final repo = SqliteFinanceRepository(db, FinancialCipher(keys));
    await repo.load();
    await repo.save(financeFixture(), expectedRevision: 0);
    keys.key = null;
    await expectLater(repo.load(), throwsA(isA<MissingEncryptionKey>()));
    final revision = await repo.backupRevision();
    expect(keys.creations, 1);
    await repo.restoreBackup(
      await BackupCodec.open(encrypted, password),
      expectedRevision: revision,
    );
    expect(keys.creations, 2);
    expect((await repo.load()).ledger, snapshot.workspace.ledger);
    await repo.close();
  });
  test('queued controller restore publishes once, replaces instead of merging, and rejects stale review', () async {
    final repo = SqliteFinanceRepository(
      FinanceDatabase(NativeDatabase.memory()),
      FinancialCipher(MemoryEncryptionKeys()),
    );
    final initial = await repo.load();
    final c = ProviderContainer(
      overrides: [
        financeRepositoryProvider.overrideWithValue(repo),
        initialWorkspaceProvider.overrideWithValue(initial),
        clockProvider.overrideWithValue(() => DateTime(2024, 10, 24, 12, 35)),
      ],
    );
    final commands = c.read(financeControllerProvider.notifier);
    expect((await c.read(accountsProvider.future)).availableBalance, 0);
    expect((await c.read(analyticsProvider.future)).totalExpense, 0);
    expect(await c.read(transactionsProvider.future), isEmpty);
    await commands.restoreBackup(snapshot, 0);
    expect(c.read(workspaceProvider).ledger, snapshot.workspace.ledger);
    expect((await c.read(accountsProvider.future)).availableBalance, 4576550);
    expect((await c.read(dashboardProvider.future))!.balance, 4576550);
    expect(
      (await c.read(analyticsProvider.future)).totalExpense,
      greaterThan(0),
    );
    expect(
      await c.read(transactionsProvider.future),
      snapshot.workspace.ledger,
    );
    expect((await c.read(budgetsProvider.future)).monthlyLimit, 2500000);
    await commands.restoreBackup(snapshot, 1);
    expect(
      c.read(workspaceProvider).ledger.length,
      snapshot.workspace.ledger.length,
    );
    await expectLater(
      commands.restoreBackup(snapshot, 1),
      throwsA(isA<WorkspaceConflict>()),
    );
    expect(c.read(workspaceProvider).revision, 2);
    c.dispose();
    await repo.close();
  });
  test('CSV keeps exact minor units, transfer identity and quoted notes; formulas are neutralized', () {
    final w = financeFixture();
    final tx = w.ledger.first.copyWith(
      merchant: '=HYPERLINK("bad")',
      note: 'line 1, "note"\nline 2',
    );
    final csv = utf8.decode(
      transactionCsv(w.copyWith(ledger: [tx, ...w.ledger.skip(1)])),
    );
    expect(csv, contains('amount_minor,currency'));
    expect(csv, contains('"32500","PHP"'));
    expect(csv, contains('"\'=HYPERLINK(""bad"")"'));
    expect(csv, contains('"line 1, ""note""\nline 2"'));
    expect(csv, contains('"bdo-savings","BDO Savings","gcash","GCash"'));
    expect(
      utf8.decode(transactionCsv(FinanceWorkspace())).split('\r\n'),
      hasLength(2),
    );
  });
}
