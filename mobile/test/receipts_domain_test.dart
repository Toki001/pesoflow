import 'package:pesoflow/features/accounts/data/ledger_account_fixture.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pesoflow/features/receipts/application/receipts_provider.dart';
import 'package:pesoflow/features/dashboard/application/dashboard_provider.dart';
import 'package:pesoflow/features/receipts/data/receipt_fixture.dart';
import 'package:pesoflow/features/receipts/domain/receipt_draft.dart';
import 'package:pesoflow/features/transactions/application/transactions_provider.dart';
import 'package:pesoflow/features/transactions/domain/transaction.dart';

ReceiptItem confirmed(ReceiptItem i) => ReceiptItem(
  id: i.id,
  name: i.name,
  quantity: i.quantity,
  unitPrice: i.unitPrice,
  confidence: i.confidence,
  reviewed: true,
);
void main() {
  test('fixture items sum exactly; included VAT is not added to the total', () {
    final d = receiptFixture();
    expect(d.total, 52550);
    expect(d.includedVat, 5630);
    expect(d.uncertain.map((i) => i.id), ['beef']);
    expect(d.validationError, 'Review the flagged items before saving.');
    expect(() => d.items.clear(), throwsUnsupportedError);
    expect(() => d.toTransaction('test'), throwsArgumentError);
  });
  test(
    'confirmed receipt becomes one posted expense with receipt provenance',
    () {
      final d = receiptFixture().copyWith(
        items: receiptFixture().items.map(confirmed).toList(),
      );
      final t = d.toTransaction('test');
      expect(t.amount, 52550);
      expect(t.expenseImpact, 52550);
      expect(t.cashFlowImpact, -52550);
      expect(t.budgetImpact, 52550);
      expect(t.source, TransactionSource.receipt);
      expect(t.hasReceipt, true);
      expect(t.category, TransactionCategory.groceries);
      expect(t.status, TransactionStatus.posted);
      expect(t.occurredAt, DateTime(2024, 10, 24, 11, 42));
      expect(t.account, 'GCash');
    },
  );
  test('quantity and tax arithmetic use centavos and half-up rounding', () {
    final d = receiptFixture().copyWith(
      items: [
        ReceiptItem(
          id: 'x',
          name: 'x',
          quantity: 3,
          unitPrice: 101,
          reviewed: true,
        ),
      ],
    );
    expect(d.total, 303);
    expect(d.includedVat, 32);
    expect(
      receiptFixture()
          .copyWith(
            items: [
              ReceiptItem(
                id: 'x',
                name: 'x',
                quantity: 1,
                unitPrice: 14,
                reviewed: true,
              ),
            ],
          )
          .includedVat,
      2,
    );
  });
  test(
    'invalid inputs, duplicate IDs, unsupported totals and categories blocked',
    () {
      for (final qty in [0, -1, 1000]) {
        expect(
          () => ReceiptItem(id: 'x', name: 'x', quantity: qty, unitPrice: 1),
          throwsArgumentError,
        );
      }
      for (final price in [0, -1, 100000000000]) {
        expect(
          () => ReceiptItem(id: 'x', name: 'x', quantity: 1, unitPrice: price),
          throwsArgumentError,
        );
      }
      expect(
        () => ReceiptItem(id: 'x', name: ' ', quantity: 1, unitPrice: 1),
        throwsArgumentError,
      );
      expect(
        () => ReceiptItem(
          id: 'x',
          name: 'x',
          quantity: 1,
          unitPrice: 1,
          confidence: 101,
        ),
        throwsArgumentError,
      );
      final d = receiptFixture();
      expect(
        () => d.copyWith(items: [d.items.first, d.items.first]),
        throwsArgumentError,
      );
      expect(
        d.copyWith(items: []).validationError,
        'Add at least one receipt item.',
      );
      expect(
        d.copyWith(merchant: ' ').validationError,
        'Enter a valid merchant name.',
      );
      expect(
        d.copyWith(account: ' ').validationError,
        'Choose a payment source.',
      );
      expect(
        d.copyWith(category: TransactionCategory.transfer).validationError,
        'Choose an expense category.',
      );
      expect(
        d
            .copyWith(
              items: [
                ReceiptItem(
                  id: 'x',
                  name: 'x',
                  quantity: 999,
                  unitPrice: 99999999999,
                  reviewed: true,
                ),
              ],
            )
            .validationError,
        'Receipt total is outside the supported amount range.',
      );
    },
  );
  test('unknown and low confidence need review; explicit correction retains confidence', () {
    for (final confidence in [null, 81, 89]) {
      final item = ReceiptItem(
        id: 'x',
        name: 'x',
        quantity: 1,
        unitPrice: 1,
        confidence: confidence,
      );
      expect(item.needsReview, true);
      expect(confirmed(item).needsReview, false);
      expect(confirmed(item).confidence, confidence);
    }
    expect(
      ReceiptItem(
        id: 'x',
        name: 'x',
        quantity: 1,
        unitPrice: 1,
        confidence: 90,
      ).needsReview,
      false,
    );
  });
  test(
    'editing is ledger-free; save is idempotent across retries/reloads',
    () async {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      await c.read(receiptReviewProvider.future);
      final ledger = c.read(demoLedgerProvider);
      final overviewBefore = (await c.read(dashboardProvider.future))!;
      final controller = c.read(receiptReviewProvider.notifier);
      expect(controller.save, throwsArgumentError);
      expect(c.read(demoLedgerProvider), same(ledger));
      controller.setMerchant('Reviewed Store');
      controller.setAccount(DemoLedgerAccounts.cash);
      controller.setCategory(TransactionCategory.shopping);
      controller.saveItem(
        confirmed(c.read(receiptReviewProvider).value!.items.last),
      );
      expect(c.read(demoLedgerProvider), same(ledger));
      final id = controller.save();
      expect(c.read(demoLedgerProvider).first.accountId, 'cash');
      expect(c.read(receiptReviewProvider).value!.accountId, 'cash');
      expect(controller.save(), id);
      expect(c.read(demoLedgerProvider).length, ledger.length + 1);
      final overviewAfter = (await c.read(dashboardProvider.future))!;
      expect(overviewAfter.outflow, overviewBefore.outflow + 52550);
      expect(overviewAfter.budgetSpent, overviewBefore.budgetSpent! + 52550);
      expect(overviewAfter.balance, overviewBefore.balance);
      final saved = c.read(savedDemoReceiptsProvider)[id]!;
      expect(saved.merchant, 'Reviewed Store');
      expect(saved.account, 'Cash');
      expect(saved.category, TransactionCategory.shopping);
      controller.setMerchant('Ignored after save');
      expect(c.read(receiptReviewProvider).value!.merchant, 'Reviewed Store');
      c.invalidate(receiptReviewProvider);
      await c.read(receiptReviewProvider.future);
      expect(c.read(receiptReviewProvider.notifier).save(), id);
      expect(c.read(demoLedgerProvider).length, ledger.length + 1);
      expect(
        () => c.read(savedDemoReceiptsProvider).clear(),
        throwsUnsupportedError,
      );
    },
  );
  test(
    'item add/update/removal recalculates; empty receipt never saves',
    () async {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      await c.read(receiptReviewProvider.future);
      final controller = c.read(receiptReviewProvider.notifier);
      final id = controller.nextItemId();
      controller.saveItem(
        ReceiptItem(
          id: id,
          name: 'Extra',
          quantity: 2,
          unitPrice: 50,
          reviewed: true,
        ),
      );
      expect(c.read(receiptReviewProvider).value!.total, 52650);
      controller.saveItem(
        ReceiptItem(
          id: id,
          name: 'Extra',
          quantity: 3,
          unitPrice: 50,
          reviewed: true,
        ),
      );
      expect(c.read(receiptReviewProvider).value!.items.length, 5);
      expect(c.read(receiptReviewProvider).value!.total, 52700);
      for (final item in c.read(receiptReviewProvider).value!.items) {
        controller.removeItem(item.id);
      }
      expect(controller.save, throwsArgumentError);
      expect(c.read(demoLedgerProvider).length, 9);
    },
  );
  test('loader error and null state cannot create a transaction', () async {
    final c = ProviderContainer(
      overrides: [receiptLoaderProvider.overrideWithValue(() async => null)],
    );
    addTearDown(c.dispose);
    expect(await c.read(receiptReviewProvider.future), isNull);
    expect(c.read(receiptReviewProvider.notifier).save, throwsStateError);
    expect(c.read(demoLedgerProvider).length, 9);
  });
}
