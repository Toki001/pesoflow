import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pesoflow/core/storage/demo_database.dart';
import 'package:pesoflow/core/storage/demo_workspace_codec.dart';
import 'package:pesoflow/core/storage/sqlite_demo_workspace_repository.dart';
import 'package:pesoflow/features/demo_workspace/application/demo_workspace_providers.dart';
import 'package:pesoflow/features/demo_workspace/domain/demo_workspace.dart';
import 'package:pesoflow/features/accounts/application/accounts_provider.dart';
import 'package:pesoflow/features/receipts/application/receipts_provider.dart';
import 'package:pesoflow/features/receipts/domain/receipt_draft.dart';
import 'package:pesoflow/features/settings/application/settings_provider.dart';
import 'package:pesoflow/features/settings/domain/appearance.dart';
import 'package:pesoflow/features/transactions/application/transactions_provider.dart';
import 'package:pesoflow/features/transactions/data/transaction_fixture.dart';
import 'package:pesoflow/features/transactions/domain/transaction.dart';

import 'add_expense_test.dart' show draft;

class ControlledWorkspaceRepository implements DemoWorkspaceRepository {
  DemoWorkspace workspace = initialDemoWorkspace();
  Future<void> Function(DemoWorkspace)? onSave;
  Future<DemoWorkspace> Function()? onLoad;
  final writes = <DemoWorkspace>[];
  @override
  Future<DemoWorkspace> load() async =>
      onLoad == null ? workspace : await onLoad!();
  @override
  Future<void> save(DemoWorkspace value) async {
    if (onSave != null) await onSave!(value);
    writes.add(value);
    workspace = value;
  }

  @override
  Future<void> close() async {}
}

ProviderContainer persistedContainer(
  DemoWorkspaceRepository repository,
  DemoWorkspace initial,
) {
  final container = ProviderContainer(
    overrides: [
      demoWorkspaceRepositoryProvider.overrideWithValue(repository),
      initialDemoWorkspaceProvider.overrideWithValue(initial),
    ],
  );
  container.read(demoPersistenceProvider);
  return container;
}

ReceiptItem reviewed(ReceiptItem item) => ReceiptItem(
  id: item.id,
  name: item.name,
  detail: item.detail,
  quantity: item.quantity,
  unitPrice: item.unitPrice,
  confidence: item.confidence,
  reviewed: true,
);

void main() {
  test(
    'SQLite seeds once and reopens edited activity with exact IDs and money',
    () async {
      final dir = await Directory.systemTemp.createTemp('pesoflow-storage-');
      addTearDown(() => dir.delete(recursive: true));
      final file = File('${dir.path}/demo.sqlite');
      final repository = SqliteDemoWorkspaceRepository(
        DemoDatabase(NativeDatabase(file)),
      );
      final seed = await repository.load();
      final container = persistedContainer(repository, seed);
      container.read(demoLedgerProvider.notifier).createManual(draft());
      final original = container
          .read(demoLedgerProvider)
          .firstWhere((t) => t.id == 'jollibee');
      container
          .read(demoLedgerProvider.notifier)
          .update(
            original.copyWith(note: 'Sample note', excludedFromBudget: true),
          );
      await container.read(demoPersistenceProvider.notifier).flush();
      expect(container.read(demoPersistenceProvider), DemoSaveStatus.saved);
      container.dispose();
      await repository.close();
      final reopened = SqliteDemoWorkspaceRepository(
        DemoDatabase(NativeDatabase(file)),
      );
      final restored = await reopened.load();
      expect(restored.ledger, hasLength(10));
      expect(restored.ledger.first.amount, 32500);
      expect(restored.ledger.first.accountId, 'gcash');
      expect(
        restored.ledger.firstWhere((t) => t.id == 'jollibee').note,
        'Sample note',
      );
      expect(
        restored.ledger
            .firstWhere((t) => t.id == 'jollibee')
            .excludedFromBudget,
        true,
      );
      final fresh = persistedContainer(reopened, restored);
      fresh.read(demoLedgerProvider.notifier).createManual(draft());
      expect(fresh.read(demoLedgerProvider).first.id, 'demo-2');
      await fresh.read(demoPersistenceProvider.notifier).flush();
      fresh.dispose();
      await reopened.close();
    },
  );

  test('receipt and ledger snapshot persist atomically and receipt save stays idempotent on restart', () async {
    final repository = SqliteDemoWorkspaceRepository(
      DemoDatabase(NativeDatabase.memory()),
    );
    addTearDown(repository.close);
    final initial = await repository.load();
    final container = persistedContainer(repository, initial);
    await container.read(receiptReviewProvider.future);
    final review = container.read(receiptReviewProvider.notifier);
    review.saveItem(
      reviewed(container.read(receiptReviewProvider).value!.items.last),
    );
    final id = review.save();
    await container.read(demoPersistenceProvider.notifier).flush();
    final stored = await repository.load();
    expect(stored.receipts[id]!.total, 52550);
    expect(stored.receipts[id]!.items.last.reviewed, true);
    expect(stored.ledger.singleWhere((t) => t.id == id).accountId, 'gcash');
    container.dispose();
    final fresh = persistedContainer(repository, stored);
    await fresh.read(receiptReviewProvider.future);
    expect(fresh.read(receiptReviewProvider.notifier).save(), id);
    expect(fresh.read(demoLedgerProvider), hasLength(10));
    expect(fresh.read(savedDemoReceiptsProvider)[id]!.items, hasLength(4));
    fresh.dispose();
  });

  test('failed SQLite update retains the previous complete snapshot', () async {
    final database = DemoDatabase(NativeDatabase.memory());
    final repository = SqliteDemoWorkspaceRepository(database);
    addTearDown(repository.close);
    final original = await repository.load();
    await database.customStatement(
      "CREATE TRIGGER reject_demo_update BEFORE UPDATE ON demo_snapshots BEGIN SELECT RAISE(ABORT, 'test failure'); END;",
    );
    await expectLater(
      repository.save(
        DemoWorkspace(ledger: [draft().toRecord('demo-1'), ...original.ledger]),
      ),
      throwsA(anything),
    );
    expect((await repository.load()).ledger, original.ledger);
    expect((await repository.load()).receipts, isEmpty);
  });

  test('corrupt, fractional money and future payload versions are refused without reseeding', () async {
    final database = DemoDatabase(NativeDatabase.memory());
    final repository = SqliteDemoWorkspaceRepository(database);
    addTearDown(repository.close);
    await repository.load();
    for (final payload in [
      '{invalid',
      DemoWorkspaceCodec.encode(initialDemoWorkspace())
          .replaceFirst('"amount":32500', '"amount":32500.5'),
      DemoWorkspaceCodec.encode(initialDemoWorkspace())
          .replaceFirst('"formatVersion":3', '"formatVersion":4'),
    ]) {
      await database
          .into(database.demoSnapshots)
          .insertOnConflictUpdate(
            DemoSnapshotsCompanion.insert(id: const Value(1), payload: payload),
          );
      await expectLater(repository.load(), throwsA(anything));
      expect(
        (await database.select(database.demoSnapshots).getSingle()).payload,
        payload,
      );
    }
  });

  test('codec preserves transfers, legacy null IDs and rejects duplicate or orphaned records', () {
    final initial = initialDemoWorkspace();
    final roundTrip = DemoWorkspaceCodec.decode(
      DemoWorkspaceCodec.encode(initial),
    );
    expect(roundTrip.ledger, initial.ledger);
    final transfer = roundTrip.ledger.firstWhere(
      (t) => t.kind == TransactionKind.transfer,
    );
    expect(transfer.accountId, 'bdo-savings');
    expect(transfer.destinationAccountId, 'gcash');
    expect(transfer.expenseImpact, 0);
    final json =
        jsonDecode(DemoWorkspaceCodec.encode(initial)) as Map<String, dynamic>;
    (json['ledger'] as List).first.remove('accountId');
    expect(
      DemoWorkspaceCodec.decode(jsonEncode(json)).ledger.first.accountId,
      isNull,
    );
    (json['ledger'] as List).add((json['ledger'] as List).first);
    expect(
      () => DemoWorkspaceCodec.decode(jsonEncode(json)),
      throwsFormatException,
    );
  });

  test(
    'queued saves finish in order and failed save retries the latest activity',
    () async {
      final repository = ControlledWorkspaceRepository();
      final pending = Completer<void>();
      repository.onSave = (_) => pending.future;
      final container = persistedContainer(repository, repository.workspace);
      addTearDown(container.dispose);
      container.read(demoLedgerProvider.notifier).createManual(draft());
      final flushing = container.read(demoPersistenceProvider.notifier).flush();
      expect(container.read(demoPersistenceProvider), DemoSaveStatus.saving);
      container.read(demoLedgerProvider.notifier).createManual(draft());
      await Future<void>.delayed(Duration.zero);
      pending.completeError(Exception('private SQLite path'));
      await flushing;
      expect(container.read(demoPersistenceProvider), DemoSaveStatus.error);
      expect(container.read(demoLedgerProvider), hasLength(11));
      expect(repository.workspace.ledger, hasLength(9));
      repository.onSave = null;
      await container.read(demoPersistenceProvider.notifier).flush();
      expect(repository.workspace.ledger, hasLength(11));
      expect(repository.workspace.ledger.first.id, 'demo-2');
      expect(container.read(demoPersistenceProvider), DemoSaveStatus.saved);
    },
  );

  test('reset publishes only after durable success and leaves unrelated session state intact', () async {
    final repository = ControlledWorkspaceRepository();
    final container = persistedContainer(repository, repository.workspace);
    addTearDown(container.dispose);
    await container.read(accountsProvider.future);
    container.read(accountsProvider.notifier).disconnect('gcash');
    container.read(settingsProvider.notifier).setAppearance(Appearance.dark);
    await container.read(receiptReviewProvider.future);
    container
        .read(receiptReviewProvider.notifier)
        .saveItem(
          reviewed(container.read(receiptReviewProvider).value!.items.last),
        );
    container.read(receiptReviewProvider.notifier).save();
    container.read(demoLedgerProvider.notifier).createManual(draft());
    await container.read(demoPersistenceProvider.notifier).flush();
    repository.onSave = (_) async => throw Exception('private failure');
    expect(
      await container.read(demoPersistenceProvider.notifier).resetActivity(),
      false,
    );
    expect(container.read(demoLedgerProvider), hasLength(11));
    expect(container.read(savedDemoReceiptsProvider), hasLength(1));
    repository.onSave = null;
    expect(
      await container.read(demoPersistenceProvider.notifier).resetActivity(),
      true,
    );
    expect(container.read(demoLedgerProvider), transactionFixture());
    expect(repository.workspace.ledger, transactionFixture());
    expect(container.read(savedDemoReceiptsProvider), isEmpty);
    expect(container.read(settingsProvider), Appearance.dark);
    expect(
      container
          .read(accountsProvider)
          .value!
          .accounts
          .any((a) => a.id == 'gcash'),
      false,
    );
  });
  test(
    'future database schema is refused and its version is preserved',
    () async {
      final dir = await Directory.systemTemp.createTemp('pesoflow-schema-');
      addTearDown(() => dir.delete(recursive: true));
      final file = File('${dir.path}/future.sqlite');
      final initial = SqliteDemoWorkspaceRepository(
        DemoDatabase(NativeDatabase(file)),
      );
      await initial.load();
      await initial.database.customStatement('PRAGMA user_version = 2');
      await initial.close();
      for (var attempt = 0; attempt < 2; attempt++) {
        var observedVersion = 0;
        final repository = SqliteDemoWorkspaceRepository(
          DemoDatabase(
            NativeDatabase(
              file,
              setup: (raw) {
                observedVersion = raw.userVersion;
              },
            ),
          ),
        );
        await expectLater(repository.load(), throwsA(anything));
        expect(observedVersion, 2);
        await repository.close();
      }
    },
  );

  test(
    'successful queued writes cannot let an older snapshot replace newer edits',
    () async {
      final repository = ControlledWorkspaceRepository();
      final firstWrite = Completer<void>();
      var calls = 0;
      repository.onSave = (_) =>
          calls++ == 0 ? firstWrite.future : Future.value();
      final container = persistedContainer(repository, repository.workspace);
      addTearDown(container.dispose);
      container.read(demoLedgerProvider.notifier).createManual(draft());
      final flushing = container.read(demoPersistenceProvider.notifier).flush();
      container.read(demoLedgerProvider.notifier).createManual(draft());
      await Future<void>.delayed(Duration.zero);
      expect(repository.writes, isEmpty);
      firstWrite.complete();
      await flushing;
      expect(repository.writes.map((s) => s.ledger.length), [10, 11]);
      expect(repository.workspace.ledger.first.id, 'demo-2');
      expect(container.read(demoPersistenceProvider), DemoSaveStatus.saved);
    },
  );

  test('codec refuses orphaned and inconsistent saved receipt snapshots', () {
    final json = jsonDecode(
      DemoWorkspaceCodec.encode(initialDemoWorkspace()),
    ) as Map<String, dynamic>;
    json['receipts'] = {
      'missing': {
        'id': 'receipt',
        'merchant': 'Sample shop',
        'account': 'GCash',
        'accountId': 'gcash',
        'occurredAt': demoClock.toIso8601String(),
        'category': 'groceries',
        'savedTransactionId': 'missing',
        'items': [
          {
            'id': 'item',
            'name': 'Sample item',
            'detail': '',
            'quantity': 1,
            'unitPrice': 100,
            'confidence': 100,
            'reviewed': true,
          },
        ],
      },
    };
    expect(
      () => DemoWorkspaceCodec.decode(jsonEncode(json)),
      throwsFormatException,
    );
  });
}
