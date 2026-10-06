import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pesoflow/app/app.dart';
import 'package:pesoflow/app/router.dart';
import 'package:pesoflow/features/receipts/application/receipts_provider.dart';
import 'package:pesoflow/features/receipts/data/receipt_fixture.dart';
import 'package:pesoflow/features/receipts/domain/receipt_draft.dart';
import 'package:pesoflow/features/transactions/application/transactions_provider.dart';
import 'package:pesoflow/features/transactions/domain/transaction.dart';

import 'home_test.dart' show viewport;
import 'add_expense_test.dart' show pumpAdd;

Future<void> pumpReceipt(
  WidgetTester tester, {
  ThemeMode theme = ThemeMode.light,
  Future<ReceiptDraft?> Function()? load,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        routerProvider.overrideWith((ref) {
          final r = createRouter(initialLocation: '/receipt');
          ref.onDispose(r.dispose);
          return r;
        }),
        if (load != null) receiptLoaderProvider.overrideWithValue(load),
      ],
      child: RepaintBoundary(
        key: const ValueKey('receipt-golden'),
        child: PesoFlowApp(themeMode: theme),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

ProviderContainer containerOf(WidgetTester t) =>
    ProviderScope.containerOf(t.element(find.byType(PesoFlowApp)));
Future<void> tapVisible(WidgetTester t, Finder finder) async {
  await t.ensureVisible(finder);
  await t.tap(finder);
  await t.pumpAndSettle();
}

void main() {
  for (final theme in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('Receipt ${theme.name} golden', (tester) async {
      viewport(tester, const Size(427, 1600));
      await pumpReceipt(tester, theme: theme);
      expect(find.text('Review Extracted Receipt'), findsOneWidget);
      expect(find.text('₱56.30'), findsOneWidget);
      expect(find.text('CONF: 81%'), findsOneWidget);
      expect(find.byKey(const ValueKey('nav-Home')), findsNothing);
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byKey(const ValueKey('receipt-golden')),
        matchesGoldenFile('goldens/receipt_${theme.name}_427x1600.png'),
      );
    });
  }
  testWidgets(
    'Add opens review; discard confirmation preserves entry and scroll',
    (tester) async {
      viewport(tester, const Size(390, 844));
      await pumpAdd(tester);
      await tester.scrollUntilVisible(
        find.text('Scan'),
        350,
        scrollable: find.byType(Scrollable).first,
      );
      final scroll = tester.state<ScrollableState>(
        find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Scan'));
      await tester.pumpAndSettle();
      final before = scroll.position.pixels;
      await tester.tap(find.byTooltip('Dismiss review'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Keep reviewing'));
      await tester.pumpAndSettle();
      expect(find.text('Review Extracted Receipt'), findsOneWidget);
      await tester.tap(find.byTooltip('Dismiss review'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Discard review'));
      await tester.pumpAndSettle();
      expect(scroll.position.pixels, before);
      expect(find.text('Save Expense — ₱325.00'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('merchant-input')),
        -350,
        scrollable: find.byType(Scrollable).first,
      );
      expect(
        tester
            .widget<TextFormField>(find.byKey(const ValueKey('merchant-input')))
            .controller!
            .text,
        'Jollibee',
      );
      expect(containerOf(tester).read(demoLedgerProvider).length, 9);
    },
  );
  testWidgets(
    'Save guides uncertain review; confirmation posts once and retains items',
    (tester) async {
      viewport(tester, const Size(390, 844));
      await pumpReceipt(tester);
      await tapVisible(tester, find.byKey(const ValueKey('save-receipt')));
      expect(find.text('Review receipt item'), findsOneWidget);
      expect(containerOf(tester).read(demoLedgerProvider).length, 9);
      await tapVisible(tester, find.text('Confirm item'));
      expect(find.text('Ready to save'), findsOneWidget);
      await tapVisible(tester, find.byKey(const ValueKey('save-receipt')));
      expect(find.text('Transaction Detail'), findsOneWidget);
      expect(
        find.text('Review the flagged items before saving.'),
        findsNothing,
      );
      final c = containerOf(tester);
      expect(c.read(demoLedgerProvider).length, 10);
      expect(
        c.read(demoLedgerProvider).first.source,
        TransactionSource.receipt,
      );
      await tester.ensureVisible(find.text('Reviewed demo • 4 items'));
      expect(find.text('2x Purefoods Corned Beef 210g x2'), findsOneWidget);
      expect(tester.takeException(), isNull);
      c.read(routerProvider).go('/receipt');
      await tester.pumpAndSettle();
      expect(find.text('Saved'), findsOneWidget);
      await tapVisible(tester, find.text('View saved transaction'));
      expect(c.read(demoLedgerProvider).length, 10);
    },
  );
  testWidgets(
    'item validation, quantity edit, add and confirmed removal recalculate',
    (tester) async {
      viewport(tester, const Size(390, 844));
      await pumpReceipt(tester);
      await tapVisible(tester, find.byKey(const ValueKey('receipt-item-beef')));
      await tester.enterText(
        find.byKey(const ValueKey('receipt-item-quantity')),
        '0',
      );
      await tester.enterText(
        find.byKey(const ValueKey('receipt-item-price')),
        '1.234',
      );
      await tapVisible(tester, find.text('Confirm item'));
      expect(
        find.text('Enter a whole quantity from 1 to 999.'),
        findsOneWidget,
      );
      expect(
        find.text('Enter a positive price with up to 2 decimals.'),
        findsOneWidget,
      );
      await tester.enterText(
        find.byKey(const ValueKey('receipt-item-quantity')),
        '3',
      );
      await tester.enterText(
        find.byKey(const ValueKey('receipt-item-price')),
        '91.00',
      );
      await tapVisible(tester, find.text('Confirm item'));
      expect(
        containerOf(tester).read(receiptReviewProvider).value!.total,
        61650,
      );
      await tapVisible(tester, find.text('Add Missing Item'));
      await tester.enterText(
        find.byKey(const ValueKey('receipt-item-name')),
        'Test item',
      );
      await tester.enterText(
        find.byKey(const ValueKey('receipt-item-price')),
        '0.01',
      );
      await tapVisible(tester, find.text('Confirm item'));
      final id = containerOf(tester)
          .read(receiptReviewProvider)
          .value!
          .items
          .last
          .id;
      expect(
        containerOf(tester).read(receiptReviewProvider).value!.total,
        61651,
      );
      await tapVisible(tester, find.byKey(ValueKey('receipt-item-$id')));
      await tapVisible(tester, find.text('Remove item'));
      await tester.tap(find.text('Remove item').last);
      await tester.pumpAndSettle();
      expect(
        containerOf(tester).read(receiptReviewProvider).value!.total,
        61650,
      );
    },
  );
  testWidgets('merchant, category and source corrections are retained', (
    tester,
  ) async {
    viewport(tester, const Size(390, 844));
    await pumpReceipt(tester);
    await tapVisible(tester, find.byTooltip('Edit merchant name'));
    await tester.enterText(find.byKey(const ValueKey('receipt-merchant')), '');
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid merchant name.'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('receipt-merchant')),
      'Reviewed Shop',
    );
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.byKey(const ValueKey('receipt-category')));
    await tapVisible(tester, find.text('Shopping'));
    await tapVisible(tester, find.byKey(const ValueKey('receipt-paid-with')));
    await tester.tap(find.text('Cash'));
    await tester.pumpAndSettle();
    final d = containerOf(tester).read(receiptReviewProvider).value!;
    expect(d.merchant, 'Reviewed Shop');
    expect(d.category, TransactionCategory.shopping);
    expect(d.account, 'Cash');
    expect(containerOf(tester).read(demoLedgerProvider).length, 9);
  });
  testWidgets(
    'retake restores sample only after confirmation; frame and flash disclose demo',
    (tester) async {
      viewport(tester, const Size(390, 844));
      await pumpReceipt(tester);
      await tester.tap(find.text('Adjust Frame'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Cropping and camera capture'),
        findsOneWidget,
      );
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Auto'));
      await tester.pumpAndSettle();
      expect(find.text('Off'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      containerOf(tester)
          .read(receiptReviewProvider.notifier)
          .setMerchant('Changed');
      await tester.pumpAndSettle();
      await tapVisible(tester, find.text('Retake Photo'));
      await tester.tap(find.text('Keep reviewing'));
      await tester.pumpAndSettle();
      expect(find.text('Changed'), findsOneWidget);
      await tapVisible(tester, find.text('Retake Photo'));
      await tester.tap(find.text('Reload sample'));
      await tester.pumpAndSettle();
      expect(
        containerOf(tester).read(receiptReviewProvider).value!.merchant,
        'SM Supermarket Megamall',
      );
      expect(containerOf(tester).read(demoLedgerProvider).length, 9);
    },
  );
  testWidgets('calendar/time corrections persist without posting', (
    tester,
  ) async {
    viewport(tester, const Size(390, 844));
    await pumpReceipt(tester);
    await tapVisible(tester, find.byKey(const ValueKey('receipt-date')));
    await tester.tap(find.byTooltip('Switch to input'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.descendant(
        of: find.byType(DatePickerDialog),
        matching: find.byType(TextField),
      ),
      '11/25/2024',
    );
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Switch to text input mode'));
    await tester.pumpAndSettle();
    final fields = find.descendant(
      of: find.byType(TimePickerDialog),
      matching: find.byType(TextFormField),
    );
    await tester.enterText(fields.at(0), '9');
    await tester.enterText(fields.at(1), '15');
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(
      containerOf(tester).read(receiptReviewProvider).value!.occurredAt,
      DateTime(2024, 11, 25, 9, 15),
    );
    expect(containerOf(tester).read(demoLedgerProvider).length, 9);
  });
  testWidgets(
    'system back asks before discard; direct link falls back to Add',
    (tester) async {
      viewport(tester, const Size(390, 844));
      await pumpReceipt(tester);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Discard receipt review?'), findsOneWidget);
      await tester.tap(find.text('Keep reviewing'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Dismiss review'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Discard review'));
      await tester.pumpAndSettle();
      expect(find.text('Save Expense — ₱325.00'), findsOneWidget);
      expect(containerOf(tester).read(demoLedgerProvider).length, 9);
    },
  );
  testWidgets('loading, empty and errors are safe and support retry', (
    tester,
  ) async {
    final gate = Completer<ReceiptDraft?>();
    await pumpReceipt(tester, load: () => gate.future);
    expect(find.bySemanticsLabel('Loading demo receipt'), findsOneWidget);
    gate.complete(receiptFixture());
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox());
    var calls = 0;
    await pumpReceipt(
      tester,
      load: () async {
        if (calls++ == 0) throw Exception('private payload');
        return null;
      },
    );
    expect(find.text("We couldn't load this receipt."), findsOneWidget);
    expect(find.textContaining('private payload'), findsNothing);
    await tester.tap(find.text('Load sample'));
    await tester.pumpAndSettle();
    expect(find.text('No receipt to review'), findsOneWidget);
  });
  for (final size in [
    const Size(320, 844),
    const Size(430, 932),
    const Size(844, 390),
  ]) {
    testWidgets('receipt and editor scroll at $size', (tester) async {
      viewport(tester, size);
      await pumpReceipt(tester);
      await tapVisible(tester, find.byKey(const ValueKey('receipt-item-beef')));
      await tester.ensureVisible(find.text('Cancel'));
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('200 percent text, safe areas and keyboard keep review usable', (
    tester,
  ) async {
    viewport(tester, const Size(320, 844));
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    tester.view.padding = const FakeViewPadding(top: 44, bottom: 34);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    addTearDown(tester.view.resetPadding);
    await pumpReceipt(tester);
    await tapVisible(tester, find.byKey(const ValueKey('receipt-item-beef')));
    tester.view.viewInsets = const FakeViewPadding(bottom: 250);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Cancel'));
    expect(find.text('Cancel').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
