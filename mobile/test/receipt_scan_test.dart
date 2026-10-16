import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pesoflow/core/storage/finance_database.dart';
import 'package:pesoflow/core/storage/financial_cipher.dart';
import 'package:pesoflow/core/time/clock.dart';
import 'package:pesoflow/features/accounts/domain/ledger_account.dart';
import 'package:pesoflow/features/receipts/application/receipt_scan_controller.dart';
import 'package:pesoflow/features/receipts/domain/receipt_draft.dart';
import 'package:pesoflow/features/receipts/domain/receipt_image.dart';
import 'package:pesoflow/features/receipts/domain/receipt_parser.dart';
import 'package:pesoflow/features/transactions/domain/transaction.dart';
import 'package:pesoflow/features/workspace/application/finance_controller.dart';
import 'package:pesoflow/features/workspace/data/sqlite_finance_repository.dart';

import 'fixtures/finance_workspace_fixture.dart';
import 'support/finance_fakes.dart';
import 'support/receipt_fakes.dart';

void main() {
  late ProviderContainer c;
  late SqliteFinanceRepository repo;
  late FinanceDatabase db;
  late FakeReceiptImages images;
  late FakeReceiptOcr ocr;
  late ReceiptScanController scan;
  setUp(() async {
    db = FinanceDatabase(NativeDatabase.memory());
    repo = SqliteFinanceRepository(db, FinancialCipher(MemoryEncryptionKeys()));
    await repo.load();
    final workspace = await repo.save(financeFixture(), expectedRevision: 0);
    images = FakeReceiptImages();
    ocr = FakeReceiptOcr();
    c = ProviderContainer(
      overrides: [
        financeRepositoryProvider.overrideWithValue(repo),
        initialWorkspaceProvider.overrideWithValue(workspace),
        receiptImagesProvider.overrideWithValue(images),
        receiptOcrProvider.overrideWithValue(ocr),
        clockProvider.overrideWithValue(() => DateTime(2024, 10, 24, 12, 35)),
      ],
    );
    c.listen(receiptScanProvider, (_, _) {});
    scan = c.read(receiptScanProvider.notifier);
  });
  tearDown(() async {
    c.dispose();
    await repo.close();
  });
  test(
    'paper cash fallback is a suggestion and explicit electronic tender wins',
    () async {
      ocr.text = 'ACME NETWORK, INC. SERVICEINVOICE\nDate 10-15-26\nTOTAL 799';
      await scan.acquire(ReceiptImageSource.photos);
      var draft = c.read(receiptScanProvider).draft!;
      expect(draft.accountId, 'cash');
      expect(draft.evidence!.paymentMethod, 'CASH (suggested)');
      expect(draft.evidence!.confirmed, isFalse);
      ocr.text += '\nPaid via PAYMAYA';
      await scan.retry();
      draft = c.read(receiptScanProvider).draft!;
      expect(draft.accountId, 'maya');
      expect(draft.evidence!.paymentMethod, 'MAYA');
    },
  );
  test('ordinary gallery images do not assume cash; rotation resets confirmation and rereads', () async {
    ocr.text = 'STORE\nTOTAL 25';
    await scan.acquire(ReceiptImageSource.photos);
    expect(c.read(receiptScanProvider).draft!.evidence!.paymentMethod, isNull);
    scan.confirm(true);
    images.rotated = ReceiptImage('/test/rotated.jpg', images.next!.bytes);
    await scan.rotate();
    expect(c.read(receiptScanProvider).image!.path, '/test/rotated.jpg');
    expect(c.read(receiptScanProvider).draft!.evidence!.confirmed, isFalse);
    expect(ocr.calls, 2);
  });
  test('scan, corrections and explicit confirmation persist through production command once', () async {
    await scan.acquire(ReceiptImageSource.camera);
    var d = c.read(receiptScanProvider).draft!;
    expect(d.total, 29000);
    expect(d.category, TransactionCategory.food);
    expect(d.accountId, 'cash');
    expect(c.read(workspaceProvider).receipts, isEmpty);
    expect(await scan.save(), isNull);
    scan.setMerchant('Corrected shop');
    scan.setDate(DateTime(2024, 10, 23, 19, 15));
    scan.setCategory(TransactionCategory.groceries);
    scan.setAccount(const LedgerAccount(id: 'cash', label: 'Cash'));
    scan.saveItem(
      ReceiptItem(
        id: 'manual',
        name: 'Missing item',
        quantity: 2,
        unitPrice: 1500,
        reviewed: true,
      ),
    );
    expect(c.read(receiptScanProvider).draft!.total, 29000);
    scan.confirm(true);
    scan.setCategory(TransactionCategory.food);
    expect(c.read(receiptScanProvider).draft!.evidence!.confirmed, isFalse);
    scan.confirm(true);
    scan.rememberCategory(true);
    final ids = await Future.wait([scan.save(), scan.save()]);
    expect(ids.whereType<String>().length, 1);
    final id = ids.whereType<String>().single;
    d = (await repo.load()).receipts[id]!;
    expect(d.merchant, 'Corrected shop');
    expect(d.occurredAt.hour, 19);
    expect(d.items.last.quantity, 2);
    expect(d.evidence!.rawText, receiptText);
    expect(d.evidence!.parserVersion, ReceiptParser.version);
    expect(await repo.loadReceiptImage(d.id), images.next!.bytes);
    expect(await scan.save(), id);
    expect(images.released, contains(images.next!.path));
  });
  test(
    'remembered categories accept the full supported merchant name length',
    () async {
      await scan.acquire(ReceiptImageSource.photos);
      scan.setMerchant('A' * 100);
      scan.setCategory(TransactionCategory.food);
      scan.setAccount(const LedgerAccount(id: 'cash', label: 'Cash'));
      scan.rememberCategory(true);
      scan.confirm(true);
      expect(await scan.save(), isNotNull);
      expect(
        (await repo.load()).merchantRules['expense:${'a' * 100}'],
        TransactionCategory.food,
      );
    },
  );
  test(
    'receipt crossing a budget threshold persists one condition notice',
    () async {
      ocr.text = 'Jollibee\nOctober 24, 2024 12:30 PM\nTOTAL 9000.00';
      await scan.acquire(ReceiptImageSource.photos);
      scan.setAccount(const LedgerAccount(id: 'cash', label: 'Cash'));
      scan.confirm(true);
      expect(await scan.save(), isNotNull);
      final notices = (await repo.load()).notices.where(
        (n) => n.conditionKey.startsWith('budget:food:'),
      );
      expect(notices.length, 1);
      expect(notices.single.conditionKey, endsWith(':101'));
      await scan.save();
      expect(
        (await repo.load()).notices
            .where((n) => n.conditionKey.startsWith('budget:food:'))
            .length,
        1,
      );
    },
  );
  test(
    'cancel, denied capture and cancelled crop preserve current corrections',
    () async {
      await scan.acquire(ReceiptImageSource.photos);
      scan.setMerchant('Corrected merchant');
      final draft = c.read(receiptScanProvider).draft;
      images.next = null;
      await scan.acquire(ReceiptImageSource.camera);
      expect(c.read(receiptScanProvider).draft, same(draft));
      await scan.crop();
      expect(c.read(receiptScanProvider).draft, same(draft));
      images.error = const ReceiptFailure('Permission denied', settings: true);
      await scan.acquire(ReceiptImageSource.camera);
      expect(c.read(receiptScanProvider).draft, same(draft));
      expect(c.read(receiptScanProvider).error!.settings, isTrue);
    },
  );
  test('OCR failure keeps image for manual entry; retry and crop run real abstraction again', () async {
    ocr.error = const ReceiptFailure('Could not read');
    await scan.acquire(ReceiptImageSource.photos);
    expect(c.read(receiptScanProvider).image, isNotNull);
    expect(c.read(receiptScanProvider).draft!.evidence!.rawText, isEmpty);
    expect(
      c.read(receiptScanProvider).draft!.evidence!.warnings.join(),
      contains('Today is suggested only'),
    );
    ocr.error = null;
    await scan.retry();
    expect(c.read(receiptScanProvider).draft!.total, 29000);
    images.cropped = ReceiptImage('/test/cropped.png', images.next!.bytes);
    await scan.crop();
    expect(ocr.calls, 3);
    expect(images.released, contains('/test/receipt.png'));
    expect(c.read(receiptScanProvider).image!.path, '/test/cropped.png');
  });
  test(
    'empty OCR permits a verified manually entered total without fake items',
    () async {
      ocr.text = '';
      await scan.acquire(ReceiptImageSource.photos);
      final d = c.read(receiptScanProvider).draft!;
      expect(d.items, isEmpty);
      expect(d.total, 0);
      scan.setDraft(
        d.copyWith(
          merchant: 'Manual store',
          account: 'Cash',
          accountId: 'cash',
          evidence: d.evidence!.copyWith(total: 40000),
        ),
      );
      scan.confirm(true);
      expect(await scan.save(), isNotNull);
    },
  );
  test(
    'storage failure retains review and image; retry commits once',
    () async {
      await scan.acquire(ReceiptImageSource.photos);
      scan.setAccount(const LedgerAccount(id: 'cash', label: 'Cash'));
      scan.confirm(true);
      await db.customStatement(
        "CREATE TRIGGER fail_receipt BEFORE INSERT ON encrypted_receipts BEGIN SELECT RAISE(ABORT, 'full'); END",
      );
      final d = c.read(receiptScanProvider).draft;
      expect(await scan.save(), isNull);
      expect(c.read(receiptScanProvider).draft, same(d));
      expect(c.read(receiptScanProvider).image, isNotNull);
      expect(images.released, isEmpty);
      expect((await repo.load()).receipts, isEmpty);
      await db.customStatement('DROP TRIGGER fail_receipt');
      expect(await scan.save(), isNotNull);
      expect((await repo.load()).receipts.length, 1);
    },
  );
  test('Android recovered capture processed once and discarded session releases image', () async {
    images.recovered = images.next;
    await scan.recover();
    await scan.recover();
    expect(images.recoveries, 1);
    expect(c.read(receiptScanProvider).draft!.total, 29000);
    c.invalidate(receiptScanProvider);
    expect(images.released, contains('/test/receipt.png'));
  });
}
