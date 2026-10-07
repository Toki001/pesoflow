import 'dart:typed_data';

import '../../workspace/domain/finance_workspace.dart';

const maxBackupBytes = 48 * 1024 * 1024;
const maxBackupPlaintextBytes = 32 * 1024 * 1024;

class BackupFailure implements Exception {
  const BackupFailure(this.message);
  final String message;
}

/// Complete snapshot; receipt bytes never become plaintext temporary files.
class FinanceBackup {
  FinanceBackup(this.workspace, Map<String, Uint8List> images, this.createdAt)
    : images = Map.unmodifiable({
        for (final e in images.entries)
          e.key: Uint8List.fromList(e.value).asUnmodifiableView(),
      }) {
    workspace.validate();
    if (images.entries.any(
          (e) =>
              e.key.isEmpty ||
              e.key.length > 200 ||
              e.value.isEmpty ||
              e.value.length > 20 * 1024 * 1024,
        ) ||
        images.values.fold<int>(0, (sum, b) => sum + b.length) >
            24 * 1024 * 1024) {
      throw const BackupFailure(
        'Receipt images exceed the supported backup size.',
      );
    }
  }
  final FinanceWorkspace workspace;
  final Map<String, Uint8List> images;
  final DateTime createdAt;
}

/// Separate capability: reading and replacing workspace + images is atomic.
abstract interface class BackupRepository {
  Future<FinanceBackup> captureBackup(DateTime now);
  Future<int> backupRevision();
  Future<FinanceWorkspace> restoreBackup(
    FinanceBackup backup, {
    required int expectedRevision,
  });
}
