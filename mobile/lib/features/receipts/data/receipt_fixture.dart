import '../../accounts/data/ledger_account_fixture.dart';
import '../domain/receipt_draft.dart';

ReceiptDraft receiptFixture() => ReceiptDraft(
  id: 'sm-megamall-demo',
  accountId: DemoLedgerAccounts.gcash.id,
  merchant: 'SM Supermarket Megamall',
  occurredAt: DateTime(2024, 10, 24, 11, 42),
  items: [
    ReceiptItem(
      id: 'milk',
      name: 'Select Fresh Milk 1L',
      quantity: 1,
      unitPrice: 10850,
      detail: 'Qty: 1 • Unit: ₱108.50',
      confidence: 99,
    ),
    ReceiptItem(
      id: 'bread',
      name: 'Gardenia Classic White Loaf',
      quantity: 1,
      unitPrice: 7500,
      detail: 'Qty: 1 • 600g',
      confidence: 98,
    ),
    ReceiptItem(
      id: 'apples',
      name: 'Fuji Apples (Pack of 4)',
      quantity: 1,
      unitPrice: 16000,
      detail: 'Fresh Produce • SM Bonus',
      confidence: 95,
    ),
    ReceiptItem(
      id: 'beef',
      name: 'Purefoods Corned Beef 210g x2',
      quantity: 2,
      unitPrice: 9100,
      detail: '₱91.00 each • Promo bundle',
      confidence: 81,
    ),
  ],
);
