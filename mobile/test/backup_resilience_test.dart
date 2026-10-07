import 'dart:io';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pesoflow/core/storage/finance_database.dart';
import 'package:pesoflow/core/storage/financial_cipher.dart';
import 'package:pesoflow/features/backups/domain/finance_backup.dart';
import 'package:pesoflow/features/workspace/application/finance_controller.dart';
import 'package:pesoflow/features/workspace/data/finance_workspace_codec.dart';
import 'package:pesoflow/features/workspace/data/sqlite_finance_repository.dart';

import 'fixtures/finance_workspace_fixture.dart';
import 'support/finance_fakes.dart';

class UnavailableKeys extends MemoryEncryptionKeys {
  bool unavailable = false;
  @override
  Future<SecretKey> load({required bool createIfMissing}) {
    if (unavailable) throw const FileSystemException('Test key store locked');
    return super.load(createIfMissing: createIfMissing);
  }
}

void main() {
  for (final journal in ['delete', 'wal']) {
    test('SQLITE_FULL during restore rolls back and reopens ($journal)', () async {
      final dir = await Directory.systemTemp.createTemp('pf-full-');
      final file = File('${dir.path}/test.sqlite');
      final keys = MemoryEncryptionKeys();
      var db = FinanceDatabase(NativeDatabase(file));
      var repo = SqliteFinanceRepository(db, FinancialCipher(keys));
      ProviderContainer? container;
      try {
        await repo.load();
        await db.customStatement('PRAGMA journal_mode = $journal');
        final before = await repo.save(financeFixture(), expectedRevision: 0);
        await repo.saveReceiptImage('old', Uint8List.fromList([8, 9]));
        final pages = (await db.customSelect('PRAGMA page_count').getSingle())
            .read<int>('page_count');
        await db.customStatement('PRAGMA max_page_count = $pages');
        final backup = FinanceBackup(before.copyWith(ledger: [], budgets: []), {
          'new': Uint8List(1024 * 1024),
        }, DateTime.utc(2026, 10, 8));
        container = ProviderContainer(
          overrides: [
            financeRepositoryProvider.overrideWithValue(repo),
            initialWorkspaceProvider.overrideWithValue(before),
          ],
        );
        final commands = container.read(financeControllerProvider.notifier);
        await expectLater(
          commands.restoreBackup(backup, before.revision),
          throwsA(
            predicate<Object>(
              (e) => e.toString().contains('database or disk is full'),
            ),
          ),
        );
        expect(container.read(workspaceProvider), same(before));
        expect(container.read(financeControllerProvider).error, isNotNull);
        await commands.flush();
        container.dispose();
        container = null;
        await repo.close();
        db = FinanceDatabase(NativeDatabase(file));
        repo = SqliteFinanceRepository(db, FinancialCipher(keys));
        expect(
          FinanceWorkspaceCodec.encode(await repo.load()),
          FinanceWorkspaceCodec.encode(before),
        );
        expect(await repo.loadReceiptImage('old'), [8, 9]);
        expect(await repo.loadReceiptImage('new'), isNull);
        expect(
          (await db.customSelect('PRAGMA integrity_check').getSingle())
              .data
              .values
              .single,
          'ok',
        );
        // Removing only this temporary database's growth ceiling allows retry.
        await db.customStatement('PRAGMA max_page_count = 1073741823');
        final restored = await repo.restoreBackup(
          backup,
          expectedRevision: before.revision,
        );
        expect(restored.ledger, isEmpty);
        expect(await repo.loadReceiptImage('old'), isNull);
        expect(await repo.loadReceiptImage('new'), backup.images['new']);
      } finally {
        container?.dispose();
        await repo.close();
        await dir.delete(recursive: true);
      }
    });
  }
  test(
    'temporarily unavailable key never replaces records; unlock permits retry',
    () async {
      final keys = UnavailableKeys();
      final repo = SqliteFinanceRepository(
        FinanceDatabase(NativeDatabase.memory()),
        FinancialCipher(keys),
      );
      try {
        await repo.load();
        final before = await repo.save(financeFixture(), expectedRevision: 0);
        final backup = FinanceBackup(
          before.copyWith(ledger: []),
          {},
          DateTime.utc(2026, 10, 8),
        );
        keys.unavailable = true;
        await expectLater(
          repo.restoreBackup(backup, expectedRevision: 1),
          throwsA(isA<FileSystemException>()),
        );
        keys.unavailable = false;
        expect(
          FinanceWorkspaceCodec.encode(await repo.load()),
          FinanceWorkspaceCodec.encode(before),
        );
        expect(keys.creations, 1);
        await repo.restoreBackup(backup, expectedRevision: 1);
        expect((await repo.load()).ledger, isEmpty);
        expect(keys.creations, 1);
      } finally {
        await repo.close();
      }
    },
  );
}
