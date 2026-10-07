// Host-only subprocess target. Run via scripts/check_backup_interruptions.py.
// Test storage and key are isolated; this never opens the production database.
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pesoflow/core/storage/finance_database.dart';
import 'package:pesoflow/core/storage/financial_cipher.dart';
import 'package:pesoflow/features/backups/domain/finance_backup.dart';
import 'package:pesoflow/features/workspace/data/finance_workspace_codec.dart';
import 'package:pesoflow/features/workspace/data/sqlite_finance_repository.dart';

import '../fixtures/finance_workspace_fixture.dart';
import '../support/finance_fakes.dart';

Future<void> barrier(Directory directory, String phase) async {
  // The runner checks this PID belongs to its own process group before killing.
  final temporary = File('${directory.path}/ready.tmp');
  await temporary.writeAsString(
    jsonEncode({'pid': pid, 'phase': phase}),
    flush: true,
  );
  await temporary.rename('${directory.path}/ready.json');
  await Completer<void>().future;
}

class InterruptCipher extends FinancialCipher {
  InterruptCipher(super.keys, this.directory, this.phase);
  final Directory directory;
  final String phase;
  @override
  Future<Uint8List> seal(
    List<int> bytes, {
    required String context,
    bool createKey = false,
  }) async {
    // Workspace replacement, old-image deletion and one new image insertion
    // have already executed inside the real repository transaction at this point.
    if (phase == 'before-commit' && context == 'receipt:new-second') {
      await barrier(directory, phase);
    }
    return super.seal(bytes, context: context, createKey: createKey);
  }
}

void main() {
  test('isolated restore crash/reopen worker', () async {
    final path = Platform.environment['PF_INTERRUPT_DIR'];
    final phase = Platform.environment['PF_INTERRUPT_PHASE'];
    final journal = Platform.environment['PF_INTERRUPT_JOURNAL'];
    if (path == null ||
        ![
          'before-commit',
          'after-commit',
          'verify-before',
          'verify-after',
        ].contains(phase) ||
        !['delete', 'wal'].contains(journal)) {
      fail('Run this target through scripts/check_backup_interruptions.py.');
    }
    final directory = Directory(path);
    if (!await File('$path/isolated-test-marker').exists()) {
      fail('Refusing an unmarked test directory.');
    }
    final keys = MemoryEncryptionKeys()
      ..key = SecretKey(List<int>.filled(32, 17));
    final db = FinanceDatabase(NativeDatabase(File('$path/test.sqlite')));
    final repo = SqliteFinanceRepository(
      db,
      InterruptCipher(keys, directory, phase!),
    );
    final before = financeFixture().copyWith(revision: 1);
    final backup = FinanceBackup(before.copyWith(ledger: [], budgets: []), {
      'new-first': Uint8List(1024 * 1024),
      'new-second': Uint8List.fromList([2, 3]),
    }, DateTime.utc(2026, 10, 8));
    if (phase.startsWith('verify-')) {
      try {
        final after = phase == 'verify-after';
        final expected = after
            ? backup.workspace.copyWith(revision: 2)
            : before;
        expect(
          FinanceWorkspaceCodec.encode(await repo.load()),
          FinanceWorkspaceCodec.encode(expected),
        );
        expect(await repo.loadReceiptImage('old'), after ? null : [8, 9]);
        expect(
          await repo.loadReceiptImage('new-first'),
          after ? backup.images['new-first'] : null,
        );
        expect(
          await repo.loadReceiptImage('new-second'),
          after ? [2, 3] : null,
        );
        expect(
          (await db.customSelect('PRAGMA integrity_check').getSingle())
              .data
              .values
              .single,
          'ok',
        );
      } finally {
        await repo.close();
      }
      return;
    }
    // Only the runner's newly created, empty directory can be initialized.
    expect((await repo.load()).revision, 0);
    await db.customStatement('PRAGMA journal_mode = $journal');
    // Force the 1 MiB image to spill from SQLite's cache before commit so the
    // interruption exercises journal recovery, not only discarded memory.
    await db.customStatement('PRAGMA cache_size = 16');
    await repo.save(before.copyWith(revision: 0), expectedRevision: 0);
    await repo.saveReceiptImage('old', Uint8List.fromList([8, 9]));
    await repo.restoreBackup(backup, expectedRevision: 1);
    await barrier(directory, 'after-commit');
  }, timeout: const Timeout(Duration(minutes: 2)));
}
