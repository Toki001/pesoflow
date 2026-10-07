import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/time/clock.dart';
import '../../workspace/application/finance_controller.dart';
import '../../workspace/domain/finance_workspace.dart';
import '../data/backup_codec.dart';
import '../domain/finance_backup.dart';
import '../data/backup_files.dart';

final backupFilesProvider = Provider<BackupFiles>((ref) => NativeBackupFiles());
final backupActionsProvider = Provider<BackupActions>((ref) {
  final repository = ref.read(financeRepositoryProvider);
  if (repository is! BackupRepository) {
    throw const BackupFailure('Backup storage is not available.');
  }
  return BackupActions(
    files: ref.read(backupFilesProvider),
    transactions: () async {
      await ref.read(financeControllerProvider.notifier).flush();
      return repository.load();
    },
    capture: () async {
      await ref.read(financeControllerProvider.notifier).flush();
      return (repository as BackupRepository).captureBackup(
        ref.read(clockProvider)(),
      );
    },
    revision: () async {
      await ref.read(financeControllerProvider.notifier).flush();
      return ref.read(workspaceProvider).revision;
    },
    restore: (backup, revision) => ref
        .read(financeControllerProvider.notifier)
        .restoreBackup(backup, revision),
  );
});

class BackupActions {
  const BackupActions({
    required this.files,
    required this.capture,
    required this.transactions,
    required this.revision,
    required this.restore,
    this.seal = BackupCodec.seal,
    this.open = BackupCodec.open,
  });
  final Future<Uint8List> Function(FinanceBackup, String) seal;
  final Future<FinanceBackup> Function(Uint8List, String) open;
  final BackupFiles files;
  final Future<FinanceBackup> Function() capture;
  final Future<FinanceWorkspace> Function() transactions;
  final Future<int> Function() revision;
  final Future<void> Function(FinanceBackup, int) restore;
}
