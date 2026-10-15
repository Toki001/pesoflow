import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pesoflow/core/storage/finance_database.dart';
import 'package:pesoflow/core/storage/financial_cipher.dart';
import 'package:pesoflow/features/workspace/data/finance_workspace_codec.dart';
import 'package:pesoflow/features/workspace/data/sqlite_finance_repository.dart';

import 'fixtures/finance_workspace_fixture.dart';
import 'support/finance_fakes.dart';

void main() {
  test('pre-v7 encrypted workspace opens without rewriting financial records or keys', () async {
    final directory = await Directory.systemTemp.createTemp('pf-v7-upgrade-');
    final file = File('${directory.path}/pesoflow.sqlite');
    final keys = MemoryEncryptionKeys();
    final cipher = FinancialCipher(keys);
    var database = FinanceDatabase(NativeDatabase(file));
    var repository = SqliteFinanceRepository(database, cipher);
    try {
      final old = FinanceWorkspaceCodec.toJson(financeFixture());
      // Exact optional fields written by the pre-v7 codec. No owner ever gates
      // the local records, and obsolete preferences do not block their decoding.
      (old['preferences'] as Map<String, dynamic>).addAll({
        'name': 'Previous local display name',
        'onboardingCompleted': true,
        'biometrics': false,
        'syncAlerts': true,
      });
      for (final account in old['accounts'] as List) {
        (account as Map)
          ..remove('creditLimit')
          ..remove('cardNetwork')
          ..remove('cardLastFour');
      }
      old['sync'] = {
        'ownerId': null,
        'serverRevision': 0,
        'localRevisionAtSync': 0,
        'lastSyncedAt': null,
      };
      final payload = await cipher.seal(
        utf8.encode(jsonEncode(old)),
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
      await repository.saveReceiptImage(
        'existing-image',
        Uint8List.fromList([10, 20, 30]),
      );
      await repository.close();
      database = FinanceDatabase(NativeDatabase(file));
      repository = SqliteFinanceRepository(database, cipher);
      final loaded = await repository.load();
      expect(loaded.ledger, financeFixture().ledger);
      expect(
        loaded.accounts.map((a) => a.toJson()),
        financeFixture().accounts.map((a) => a.toJson()),
      );
      expect(loaded.budgets.map((b) => b.toJson()), old['budgets']);
      expect(
        (await database.select(database.encryptedWorkspaces).getSingle())
            .payload,
        payload,
      );
      expect(await repository.loadReceiptImage('existing-image'), [10, 20, 30]);
      final saved = await repository.save(loaded, expectedRevision: 0);
      expect(saved.revision, 1);
      expect(saved.ledger, loaded.ledger);
      expect(await repository.loadReceiptImage('existing-image'), [10, 20, 30]);
      expect(FinanceWorkspaceCodec.toJson(saved).containsKey('sync'), isFalse);
    } finally {
      await repository.close();
      await directory.delete(recursive: true);
    }
  });
}
