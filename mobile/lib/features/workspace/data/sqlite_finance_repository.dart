import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/storage/finance_database.dart';
import '../../../core/storage/financial_cipher.dart';
import '../../backups/domain/finance_backup.dart';
import '../domain/finance_workspace.dart';
import 'finance_workspace_codec.dart';

class SqliteFinanceRepository implements FinanceRepository, BackupRepository {
  SqliteFinanceRepository(this.database, this.cipher);
  final FinanceDatabase database;
  final FinancialCipher cipher;

  @override
  Future<FinanceWorkspace> load() => database.transaction(() async {
    final row = await database
        .select(database.encryptedWorkspaces)
        .getSingleOrNull();
    if (row == null) {
      // Product defaults only. No demo database or sample catalog is consulted.
      final empty = FinanceWorkspace();
      final payload = await cipher.seal(
        utf8.encode(FinanceWorkspaceCodec.encode(empty)),
        context: 'workspace:1:0',
        createKey: true,
      );
      await database
          .into(database.encryptedWorkspaces)
          .insert(
            EncryptedWorkspacesCompanion.insert(
              id: const Value(1),
              revision: 0,
              payload: payload,
            ),
          );
      return empty;
    }
    final bytes = await cipher.open(
      row.payload,
      context: 'workspace:1:${row.revision}',
    );
    final workspace = FinanceWorkspaceCodec.decode(utf8.decode(bytes));
    if (workspace.revision != row.revision) {
      throw const FormatException('Inconsistent financial revision.');
    }
    return workspace;
  });

  @override
  Future<FinanceWorkspace> save(
    FinanceWorkspace workspace, {
    required int expectedRevision,
  }) => database.transaction(() async {
    final row = await database.select(database.encryptedWorkspaces).getSingle();
    if (row.revision != expectedRevision ||
        workspace.revision != expectedRevision) {
      throw const WorkspaceConflict();
    }
    final next = workspace.copyWith(revision: expectedRevision + 1);
    final payload = await cipher.seal(
      utf8.encode(FinanceWorkspaceCodec.encode(next)),
      context: 'workspace:1:${next.revision}',
    );
    await database
        .update(database.encryptedWorkspaces)
        .replace(
          EncryptedWorkspacesCompanion.insert(
            id: const Value(1),
            revision: next.revision,
            payload: payload,
          ),
        );
    return next;
  });

  Future<void> saveReceiptImage(String id, Uint8List bytes) async {
    if (id.isEmpty || bytes.isEmpty || bytes.length > 20 * 1024 * 1024) {
      throw ArgumentError('Invalid receipt image.');
    }
    final encrypted = await cipher.seal(bytes, context: 'receipt:$id');
    await database
        .into(database.encryptedReceipts)
        .insertOnConflictUpdate(
          EncryptedReceiptsCompanion.insert(id: id, payload: encrypted),
        );
  }

  Future<Uint8List?> loadReceiptImage(String id) async {
    final row = await (database.select(
      database.encryptedReceipts,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null
        ? null
        : cipher.open(row.payload, context: 'receipt:$id');
  }

  Future<void> deleteReceiptImage(String id) => (database.delete(
    database.encryptedReceipts,
  )..where((t) => t.id.equals(id))).go();

  @override
  Future<int> backupRevision() async =>
      (await database.select(database.encryptedWorkspaces).getSingleOrNull())
          ?.revision ??
      0;

  @override
  Future<FinanceBackup> captureBackup(DateTime now) =>
      database.transaction(() async {
        final workspace = await load();
        final images = <String, Uint8List>{};
        var size = 0;
        for (final row
            in await database.select(database.encryptedReceipts).get()) {
          size += row.payload.length;
          if (size > 24 * 1024 * 1024) {
            throw const BackupFailure(
              'Receipt images exceed the supported backup size.',
            );
          }
          images[row.id] = await cipher.open(
            row.payload,
            context: 'receipt:${row.id}',
          );
        }
        return FinanceBackup(workspace, images, now);
      });

  @override
  Future<FinanceWorkspace> restoreBackup(
    FinanceBackup backup, {
    required int expectedRevision,
  }) => database.transaction(() async {
    if (await backupRevision() != expectedRevision) {
      throw const WorkspaceConflict();
    }
    final next = backup.workspace.copyWith(
      revision: expectedRevision + 1,
      sync: const SyncMetadata(),
      preferences: backup.workspace.preferences.copyWith(biometrics: false),
    );
    final payload = await cipher.seal(
      utf8.encode(FinanceWorkspaceCodec.encode(next)),
      context: 'workspace:1:${next.revision}',
      createKey: true,
    );
    // One SQLite transaction covers both tables. Failure preserves the old
    // ciphertext; no empty workspace or partially restored images are published.
    await database
        .into(database.encryptedWorkspaces)
        .insertOnConflictUpdate(
          EncryptedWorkspacesCompanion.insert(
            id: const Value(1),
            revision: next.revision,
            payload: payload,
          ),
        );
    await database.delete(database.encryptedReceipts).go();
    for (final e in backup.images.entries) {
      await saveReceiptImage(e.key, e.value);
    }
    return next;
  });

  @override
  Future<void> close() => database.close();
}
