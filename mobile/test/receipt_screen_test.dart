import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pesoflow/app/app.dart';
import 'package:pesoflow/app/router.dart';
import 'package:pesoflow/core/storage/finance_database.dart';
import 'package:pesoflow/core/storage/financial_cipher.dart';
import 'package:pesoflow/core/time/clock.dart';
import 'package:pesoflow/features/receipts/application/receipt_scan_controller.dart';
import 'package:pesoflow/features/receipts/domain/receipt_image.dart';
import 'package:pesoflow/features/transactions/domain/transaction.dart';
import 'package:pesoflow/features/workspace/application/finance_controller.dart';
import 'package:pesoflow/features/workspace/data/sqlite_finance_repository.dart';
import 'package:pesoflow/features/workspace/domain/finance_workspace.dart';

import 'fixtures/finance_workspace_fixture.dart';
import 'support/finance_fakes.dart';
import 'support/receipt_fakes.dart';

void size(WidgetTester tester, Size size) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<ProviderContainer> screen(
  WidgetTester tester,
  FakeReceiptImages images,
  FakeReceiptOcr ocr, {
  ThemeMode theme = ThemeMode.light,
  FinanceRepository? repository,
  FinanceWorkspace? workspace,
}) async {
  final initial = workspace ?? financeFixture();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        financeRepositoryProvider.overrideWithValue(
          repository ?? FakeFinanceRepository(initial),
        ),
        initialWorkspaceProvider.overrideWithValue(initial),
        clockProvider.overrideWithValue(() => DateTime(2024, 10, 24, 12, 35)),
        receiptImagesProvider.overrideWithValue(images),
        receiptOcrProvider.overrideWithValue(ocr),
        routerProvider.overrideWith((ref) {
          final router = createRouter(initialLocation: '/receipt');
          ref.onDispose(router.dispose);
          return router;
        }),
      ],
      child: RepaintBoundary(
        key: const ValueKey('receipt-golden'),
        child: PesoFlowApp(themeMode: theme),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return ProviderScope.containerOf(tester.element(find.byType(PesoFlowApp)));
}

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> waitForScan(ProviderContainer c) async {
  await Future.doWhile(() async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    return c.read(receiptScanProvider).busy;
  }).timeout(const Duration(seconds: 10));
}

void main() {
  for (final variant in [
    'normal',
    'uncertain',
    'missing_items',
    'error',
    'dark',
  ]) {
    testWidgets('receipt $variant Stitch review golden', (tester) async {
      size(tester, const Size(427, 1900));
      final images = FakeReceiptImages();
      final ocr = FakeReceiptOcr();
      if (variant == 'uncertain') {
        ocr.text =
            'Jollibee\n10/08/2026\nTOTAL 325.00\nTOTAL 350.00\nCASH 500.00';
      }
      if (variant == 'missing_items') {
        ocr.text =
            'Jollibee\nOctober 24, 2024 12:30 PM\nAMOUNT DUE PHP 325.00\nGCASH';
      }
      if (variant == 'error') {
        ocr.error = const ReceiptFailure(
          'Text recognition could not finish. Keep this image and retry, adjust the frame, or enter the details manually.',
        );
      }
      final c = await screen(
        tester,
        images,
        ocr,
        theme: variant == 'dark' ? ThemeMode.dark : ThemeMode.light,
      );
      await tester.runAsync(
        () => c
            .read(receiptScanProvider.notifier)
            .acquire(ReceiptImageSource.photos),
      );
      await tester.runAsync(
        () => precacheImage(
          MemoryImage(images.next!.bytes),
          tester.element(find.byType(PesoFlowApp)),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byKey(const ValueKey('receipt-golden')),
        matchesGoldenFile('goldens/receipt_production_$variant.png'),
      );
    });
  }
  testWidgets(
    'review edits, account choice, confirmation, save and saved receipt reopening',
    (tester) async {
      await tester.runAsync(() async {
        size(tester, const Size(427, 900));
        final db = FinanceDatabase(NativeDatabase.memory());
        final repo = SqliteFinanceRepository(
          db,
          FinancialCipher(MemoryEncryptionKeys()),
        );
        addTearDown(repo.close);
        late FinanceWorkspace initial;
        {
          await repo.load();
          initial = await repo.save(financeFixture(), expectedRevision: 0);
        }
        final images = FakeReceiptImages();
        final ocr = FakeReceiptOcr();
        final c = await screen(
          tester,
          images,
          ocr,
          repository: repo,
          workspace: initial,
        );
        await tester.tap(find.text('Choose receipt photo'));
        await waitForScan(c);
        await tester.pumpAndSettle();
        expect(find.text('Review Extracted Receipt'), findsOneWidget);
        await tapVisible(tester, find.byTooltip('Edit merchant name'));
        await tester.enterText(
          find.byKey(const ValueKey('receipt-merchant')),
          'Local restaurant',
        );
        await tester.tap(find.text('Apply'));
        await tester.pumpAndSettle();
        await tapVisible(tester, find.text('Edit totals & currency'));
        await tester.enterText(
          find.byKey(const ValueKey('receipt-total-0')),
          '325.25',
        );
        await tester.enterText(
          find.byKey(const ValueKey('receipt-total-2')),
          '',
        );
        await tapVisible(tester, find.text('Apply totals'));
        expect(c.read(receiptScanProvider).draft!.evidence!.tax, isNull);
        await tapVisible(
          tester,
          find.byKey(const ValueKey('receipt-paid-with')),
        );
        await tapVisible(tester, find.text('Cash').last);
        expect(c.read(receiptScanProvider).draft!.accountId, 'cash');
        await tapVisible(tester, find.byKey(const ValueKey('receipt-confirm')));
        expect(c.read(receiptScanProvider).draft!.evidence!.confirmed, isTrue);
        await tester.ensureVisible(find.byKey(const ValueKey('save-receipt')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('save-receipt')));
        await waitForScan(c);
        await tester.pumpAndSettle();
        expect(find.text('Transaction Detail'), findsOneWidget);
        expect(
          c.read(workspaceProvider).ledger.last.source,
          TransactionSource.receipt,
        );
        expect(c.read(workspaceProvider).ledger.last.amount, 32525);
        await tapVisible(tester, find.text('View image and extracted details'));

        await tester.pumpAndSettle();
        expect(find.text('Saved receipt'), findsOneWidget);
        expect(find.text('Local restaurant'), findsOneWidget);
        expect(find.byType(Image), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    },
  );
  testWidgets(
    'denied camera offers Settings; cancellation leaves empty state without saving',
    (tester) async {
      size(tester, const Size(390, 844));
      final images = FakeReceiptImages()
        ..error = const ReceiptFailure(
          'Camera access is disabled.',
          settings: true,
        );
      final c = await screen(tester, images, FakeReceiptOcr());
      await tester.tap(find.text('Take receipt photo'));
      await tester.pumpAndSettle();
      expect(find.text('Camera access is disabled.'), findsOneWidget);
      await tapVisible(tester, find.text('Open device Settings'));
      expect(images.settings, 1);
      images.error = null;
      images.next = null;
      await tapVisible(tester, find.text('Choose receipt photo'));
      expect(c.read(receiptScanProvider).draft, isNull);
      expect(c.read(workspaceProvider).receipts, isEmpty);
    },
  );
  testWidgets('create an account without discarding the receipt review', (
    tester,
  ) async {
    size(tester, const Size(390, 844));
    final c = await screen(
      tester,
      FakeReceiptImages(),
      FakeReceiptOcr(),
      workspace: FinanceWorkspace(),
    );
    await tester.runAsync(
      () => c
          .read(receiptScanProvider.notifier)
          .acquire(ReceiptImageSource.photos),
    );
    await tester.pumpAndSettle();
    final receiptId = c.read(receiptScanProvider).draft!.id;
    await tapVisible(tester, find.byKey(const ValueKey('receipt-paid-with')));
    await tapVisible(tester, find.text('Create manual account'));
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Account name'),
      'Travel cash',
    );
    await tapVisible(tester, find.text('Save Account'));
    await tapVisible(tester, find.text('Travel cash'));
    expect(c.read(receiptScanProvider).draft!.id, receiptId);
    expect(c.read(receiptScanProvider).draft!.account, 'Travel cash');
    expect(c.read(workspaceProvider).accounts.single.name, 'Travel cash');
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'small screen and large text remain scrollable with no overflows',
    (tester) async {
      size(tester, const Size(320, 844));
      tester.platformDispatcher.textScaleFactorTestValue = 1.7;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final c = await screen(tester, FakeReceiptImages(), FakeReceiptOcr());
      await tester.runAsync(
        () => c
            .read(receiptScanProvider.notifier)
            .acquire(ReceiptImageSource.photos),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('save-receipt')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
