import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pesoflow/core/storage/finance_database.dart';
import 'package:pesoflow/core/storage/financial_cipher.dart';
import 'package:pesoflow/features/accounts/domain/financial_account.dart';
import 'package:pesoflow/features/transactions/domain/transaction.dart';
import 'package:pesoflow/features/workspace/data/finance_workspace_codec.dart';
import 'package:pesoflow/features/workspace/data/sqlite_finance_repository.dart';
import 'package:pesoflow/features/workspace/domain/finance_workspace.dart';

import 'support/finance_fakes.dart';

FinancialAccount account() => FinancialAccount(
  id: 'cash',
  name: 'My cash',
  type: AccountType.cash,
  startingBalance: 123456,
  currency: 'PHP',
  createdAt: DateTime(2026, 10, 7),
);

void main() {
  late FinanceDatabase db;
  late MemoryEncryptionKeys keys;
  late SqliteFinanceRepository repository;
  setUp(() {
    db = FinanceDatabase(NativeDatabase.memory());
    keys = MemoryEncryptionKeys();
    repository = SqliteFinanceRepository(db, FinancialCipher(keys));
  });
  tearDown(() => repository.close());

  test(
    'fresh storage contains preferences but no seeded financial records',
    () async {
      final w = await repository.load();
      expect(w.accounts, isEmpty);
      expect(w.ledger, isEmpty);
      expect(w.budgets, isEmpty);
      expect(w.subscriptions, isEmpty);
      expect(w.receipts, isEmpty);
      expect(w.notices, isEmpty);
      expect(w.preferences.onboardingCompleted, isFalse);
      expect(w.preferences.currency, 'PHP');
      expect(keys.creations, 1);
      await repository.load();
      expect(keys.creations, 1);
    },
  );

  test('commit is encrypted and stale writers cannot overwrite data', () async {
    final empty = await repository.load();
    final saved = await repository.save(
      empty.copyWith(accounts: [account()]),
      expectedRevision: 0,
    );
    expect(saved.revision, 1);
    expect((await repository.load()).accounts.single.startingBalance, 123456);
    final row = await db.select(db.encryptedWorkspaces).getSingle();
    expect(
      utf8.decode(row.payload, allowMalformed: true),
      isNot(contains('My cash')),
    );
    expect(
      utf8.decode(row.payload, allowMalformed: true),
      isNot(contains('123456')),
    );
    await expectLater(
      repository.save(empty, expectedRevision: 0),
      throwsA(isA<WorkspaceConflict>()),
    );
    expect((await repository.load()).accounts.single.name, 'My cash');
  });

  test(
    'tampered payload fails closed without overwriting the saved row',
    () async {
      await repository.load();
      final row = await db.select(db.encryptedWorkspaces).getSingle();
      final bytes = Uint8List.fromList(row.payload);
      bytes[20] ^= 1;
      await db
          .update(db.encryptedWorkspaces)
          .write(EncryptedWorkspacesCompanion(payload: Value(bytes)));
      await expectLater(repository.load(), throwsA(isA<Exception>()));
      expect(
        (await db.select(db.encryptedWorkspaces).getSingle()).payload,
        bytes,
      );
    },
  );

  test(
    'missing key never silently creates a replacement for existing data',
    () async {
      await repository.load();
      keys.key = null;
      await expectLater(
        repository.load(),
        throwsA(isA<MissingEncryptionKey>()),
      );
      expect(keys.creations, 1);
      expect(await db.select(db.encryptedWorkspaces).get(), hasLength(1));
    },
  );

  test('receipt images are encrypted and bound to their identity', () async {
    await repository.load();
    final bytes = Uint8List.fromList(List.generate(64, (i) => i));
    await repository.saveReceiptImage('receipt-a', bytes);
    expect(await repository.loadReceiptImage('receipt-a'), bytes);
    final encrypted =
        (await db.select(db.encryptedReceipts).getSingle()).payload;
    expect(encrypted, isNot(bytes));
    await db
        .into(db.encryptedReceipts)
        .insert(
          EncryptedReceiptsCompanion.insert(
            id: 'receipt-b',
            payload: encrypted,
          ),
        );
    await expectLater(
      repository.loadReceiptImage('receipt-b'),
      throwsA(isA<Exception>()),
    );
    await repository.deleteReceiptImage('receipt-a');
    expect(await repository.loadReceiptImage('receipt-a'), isNull);
  });

  test(
    'real file survives closing and reopening without touching demo file',
    () async {
      await repository.close();
      final directory = await Directory.systemTemp.createTemp(
        'pesoflow-storage-test-',
      );
      final file = File('${directory.path}/pesoflow.sqlite');
      final legacy = File('${directory.path}/pesoflow_demo.sqlite');
      await legacy.writeAsString('preserve legacy records');
      final first = SqliteFinanceRepository(
        FinanceDatabase(NativeDatabase(file)),
        FinancialCipher(keys),
      );
      final empty = await first.load();
      await first.save(
        empty.copyWith(accounts: [account()]),
        expectedRevision: 0,
      );
      await first.close();
      final reopened = SqliteFinanceRepository(
        FinanceDatabase(NativeDatabase(file)),
        FinancialCipher(keys),
      );
      try {
        final loaded = await reopened.load();
        expect(loaded.accounts.single.name, 'My cash');
        expect(loaded.revision, 1);
        expect(await legacy.readAsString(), 'preserve legacy records');
      } finally {
        await reopened.close();
        await directory.delete(recursive: true);
      }
    },
  );

  test('future format and fractional money are rejected, not repaired or truncated', () {
    final empty = FinanceWorkspaceCodec.toJson(FinanceWorkspace());
    expect(
      () => FinanceWorkspaceCodec.fromJson({...empty, 'formatVersion': 2}),
      throwsFormatException,
    );
    final withAccount = FinanceWorkspaceCodec.toJson(
      FinanceWorkspace(accounts: [account()]),
    );
    final t = TransactionRecord(
      id: 'expense',
      merchant: 'Actual merchant',
      metadata: '',
      amount: 100,
      occurredAt: DateTime(2026, 10, 7),
      kind: TransactionKind.expense,
      category: TransactionCategory.food,
      account: 'My cash',
      accountId: 'cash',
    ).toJson();
    expect(
      () => FinanceWorkspaceCodec.fromJson({
        ...withAccount,
        'ledger': [
          {...t, 'amount': 1.5},
        ],
      }),
      throwsFormatException,
    );
    expect(
      () => FinanceWorkspaceCodec.fromJson({
        ...withAccount,
        'ledger': [
          {...t, 'accountId': 'unknown'},
        ],
      }),
      throwsFormatException,
    );
  });

  test('schema downgrade is rejected without destroying data', () async {
    await repository.close();
    final futureDb = FinanceDatabase(
      NativeDatabase.memory(
        setup: (raw) {
          raw.execute('PRAGMA user_version = 99');
          raw.execute('CREATE TABLE retained (value TEXT)');
          raw.execute("INSERT INTO retained VALUES ('keep')");
        },
      ),
    );
    try {
      await expectLater(
        futureDb.select(futureDb.encryptedWorkspaces).get(),
        throwsA(isA<Exception>()),
      );
    } finally {
      await futureDb.close();
    }
  });
}
