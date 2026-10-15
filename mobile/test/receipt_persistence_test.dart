import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pesoflow/core/storage/finance_database.dart';
import 'package:pesoflow/core/storage/financial_cipher.dart';
import 'package:pesoflow/core/time/clock.dart';
import 'package:pesoflow/features/receipts/domain/receipt_draft.dart';
import 'package:pesoflow/features/receipts/domain/receipt_evidence.dart';
import 'package:pesoflow/features/dashboard/application/dashboard_provider.dart';
import 'package:pesoflow/features/analytics/application/analytics_provider.dart';
import 'package:pesoflow/features/budgets/application/budgets_provider.dart';
import 'package:pesoflow/features/transactions/domain/categorization.dart';
import 'package:pesoflow/features/transactions/domain/transaction.dart';
import 'package:pesoflow/features/workspace/application/finance_controller.dart';
import 'package:pesoflow/features/workspace/data/finance_workspace_codec.dart';
import 'package:pesoflow/features/workspace/data/sqlite_finance_repository.dart';

import 'fixtures/finance_workspace_fixture.dart';
import 'support/finance_fakes.dart';

ReceiptDraft captured({bool confirmed = true}) => ReceiptDraft(
  id: 'real-image',
  merchant: 'Jollibee',
  accountId: 'cash',
  account: 'Cash',
  occurredAt: DateTime(2024, 10, 24, 11),
  items: [],
  category: TransactionCategory.food,
  evidence: ReceiptEvidence(
    imageId: 'real-image',
    rawText: 'Jollibee\nTOTAL 325.25',
    createdAt: DateTime(2024, 10, 24, 12),
    total: 32525,
    tax: 3485,
    confirmed: confirmed,
    confidence: {'merchant': 80, 'date': 45, 'total': 90},
    warnings: ['Verify numeric date.'],
  ),
);
void main() {
  test('captured total permits missing items and never invents tax; requires review', () {
    expect(captured().validationError, isNull);
    expect(captured().total, 32525);
    expect(captured().includedVat, 3485);
    expect(captured(confirmed: false).validationError, contains('Verify'));
    final json = FinanceWorkspaceCodec.receiptToJson(captured());
    expect(
      FinanceWorkspaceCodec.receiptToJson(
        FinanceWorkspaceCodec.receiptFromJson(json),
      ),
      json,
    );
  });
  test('receipt image, expense and metadata commit atomically and survive reopen/delete', () async {
    final dir = await Directory.systemTemp.createTemp('pf-receipt-');
    final file = File('${dir.path}/test.sqlite');
    final keys = MemoryEncryptionKeys();
    var db = FinanceDatabase(NativeDatabase(file));
    var repo = SqliteFinanceRepository(db, FinancialCipher(keys));
    ProviderContainer? c;
    try {
      await repo.load();
      final initial = await repo.save(financeFixture(), expectedRevision: 0);
      c = ProviderContainer(
        overrides: [
          financeRepositoryProvider.overrideWithValue(repo),
          initialWorkspaceProvider.overrideWithValue(initial),
          clockProvider.overrideWithValue(() => DateTime(2024, 10, 24, 12, 35)),
        ],
      );
      final commands = c.read(financeControllerProvider.notifier);
      final before = (await c.read(dashboardProvider.future))!;
      final analytics = (await c.read(analyticsProvider.future)).totalExpense;
      final spent = (await c.read(budgetsProvider.future)).spent;
      await db.customStatement(
        "CREATE TRIGGER fail_image BEFORE INSERT ON encrypted_receipts BEGIN SELECT RAISE(ABORT, 'test'); END",
      );
      final bytes = Uint8List.fromList([1, 2, 3, 4]);
      await expectLater(
        commands.saveReceipt(captured(), imageBytes: bytes),
        throwsA(isA<Exception>()),
      );
      expect(c.read(workspaceProvider), same(initial));
      expect((await repo.load()).ledger, initial.ledger);
      expect(await repo.loadReceiptImage('real-image'), isNull);
      await db.customStatement('DROP TRIGGER fail_image');
      final id = await commands.saveReceipt(
        captured(),
        imageBytes: bytes,
        rememberCategory: true,
      );
      expect(
        c.read(workspaceProvider).ledger.last.source,
        TransactionSource.receipt,
      );
      expect(
        (await c.read(dashboardProvider.future))!.balance,
        before.balance - 32525,
      );
      expect(
        (await c.read(analyticsProvider.future)).totalExpense,
        analytics + 32525,
      );
      expect((await c.read(budgetsProvider.future)).spent, spent + 32525);
      expect(
        c.read(workspaceProvider).merchantRules[merchantRuleKey(
          TransactionKind.expense,
          'Jollibee',
        )],
        TransactionCategory.food,
      );
      await expectLater(
        commands.saveReceipt(captured(), imageBytes: bytes),
        throwsArgumentError,
      );
      expect(
        c.read(workspaceProvider).ledger.length,
        initial.ledger.length + 1,
      );
      final durable = FinanceWorkspaceCodec.encode(c.read(workspaceProvider));
      c.dispose();
      c = null;
      await repo.close();
      db = FinanceDatabase(NativeDatabase(file));
      repo = SqliteFinanceRepository(db, FinancialCipher(keys));
      expect(FinanceWorkspaceCodec.encode(await repo.load()), durable);
      expect(await repo.loadReceiptImage('real-image'), bytes);
      final reopened = await repo.load();
      c = ProviderContainer(
        overrides: [
          financeRepositoryProvider.overrideWithValue(repo),
          initialWorkspaceProvider.overrideWithValue(reopened),
        ],
      );
      await c.read(financeControllerProvider.notifier).deleteTransaction(id);
      expect(await repo.loadReceiptImage('real-image'), isNull);
      expect((await repo.load()).receipts, isEmpty);
    } finally {
      c?.dispose();
      await repo.close();
      await dir.delete(recursive: true);
    }
  });
}
