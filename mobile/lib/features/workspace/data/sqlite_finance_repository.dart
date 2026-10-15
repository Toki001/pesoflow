import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/storage/finance_database.dart';
import '../../../core/storage/financial_cipher.dart';
import '../../receipts/domain/receipt_image_repository.dart';
import '../domain/finance_workspace.dart';
import 'finance_workspace_codec.dart';

class SqliteFinanceRepository
    implements FinanceRepository, ReceiptImageRepository {
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
    final previous = await load();
    final retainedImages = workspace.receipts.values
        .map((r) => r.evidence?.imageId)
        .whereType<String>()
        .toSet();
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
    for (final receipt in previous.receipts.values) {
      final imageId = receipt.evidence?.imageId;
      if (imageId != null && !retainedImages.contains(imageId)) {
        await deleteReceiptImage(imageId);
      }
    }
    return next;
  });

  @override
  Future<FinanceWorkspace> saveWithReceiptImage(
    FinanceWorkspace workspace, {
    required int expectedRevision,
    required String imageId,
    required Uint8List bytes,
  }) => database.transaction(() async {
    if (!workspace.receipts.values.any((r) => r.evidence?.imageId == imageId)) {
      throw const FormatException('Receipt image is not referenced.');
    }
    final saved = await save(workspace, expectedRevision: expectedRevision);
    await saveReceiptImage(imageId, bytes);
    return saved;
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

  @override
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
  Future<void> close() => database.close();
}
