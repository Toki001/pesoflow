import 'package:cryptography/cryptography.dart';
import 'package:pesoflow/core/storage/financial_cipher.dart';
import 'package:pesoflow/features/workspace/domain/finance_workspace.dart';

/// Test infrastructure only. Production never imports this directory.
class MemoryEncryptionKeys implements EncryptionKeyStore {
  SecretKey? key;
  int creations = 0;
  @override
  Future<SecretKey> load({required bool createIfMissing}) async {
    if (key == null) {
      if (!createIfMissing) throw const MissingEncryptionKey();
      key = await AesGcm.with256bits().newSecretKey();
      creations++;
    }
    return key!;
  }
}

class FakeFinanceRepository implements FinanceRepository {
  FakeFinanceRepository([FinanceWorkspace? initial])
    : workspace = initial ?? FinanceWorkspace();
  FinanceWorkspace workspace;
  bool failSave = false;
  @override
  Future<FinanceWorkspace> load() async => workspace;
  @override
  Future<FinanceWorkspace> save(
    FinanceWorkspace next, {
    required int expectedRevision,
  }) async {
    if (failSave) throw StateError('Injected storage failure');
    if (expectedRevision != workspace.revision ||
        next.revision != expectedRevision) {
      throw const WorkspaceConflict();
    }
    workspace = next.copyWith(revision: expectedRevision + 1);
    return workspace;
  }

  @override
  Future<void> close() async {}
}
