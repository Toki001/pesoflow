import 'package:flutter_test/flutter_test.dart';
import 'package:pesoflow/features/receipts/domain/ocr_document.dart';
import 'package:pesoflow/features/receipts/domain/receipt_parser.dart';
import 'package:pesoflow/features/receipts/domain/receipt_evidence.dart';

ParsedReceipt parse(String text) => ReceiptParser.parse(OcrDocument(text, []));
void main() {
  test('paper invoice strips adjacent document title and accepts whole pesos and short year', () {
    final r = parse(
      'ACME NETWORK, INC. SERVICEINVOICE\nDate 10-15-26\nInternet 799\nTOTAL AMOUNT DUE 799',
    );
    expect(r.merchant, 'ACME NETWORK, INC.');
    expect(r.date, DateTime(2026, 10, 15));
    expect(r.total, 79900);
    expect(r.items.single.total, 79900);
    expect(r.warnings.join(), contains('Two-digit year'));
  });
  test(
    'amount in words is a reviewable fallback, never an unlabeled guess',
    () {
      final r = parse(
        'ACME STORE\nAMOUNT IN WORDS Seven hundred ninety-nine pesos only',
      );
      expect(r.total, 79900);
      expect(r.confidence['total'], lessThan(80));
      expect(parse('Store\nSeven hundred ninety-nine').total, isNull);
      expect(
        parse('Store\nAmount in words Seven hundred unreadable').total,
        isNull,
      );
      expect(parse('Store\nCASH 1000\nCHANGE 201').total, isNull);
      expect(parse('Store\nInvoice No 799').total, isNull);
    },
  );
  test('blank payment options are not a selected payment method', () {
    expect(parse('Store\nCash [] Check [] Bank Debit').paymentMethod, isNull);
    expect(parse('Store\nCash\nPaid via PAYMAYA').paymentMethod, 'MAYA');
  });

  test('electronic tender is not an item or a fallback expense total', () {
    final r = parse('''TEST STORE
15 x Test product 480.00
TOTAL 480.00
AMOUNT TENDERED
eM-PAY 480.00
PAYMAYA QR REF. NO: 123
AMOUNT 480.00''');
    expect(r.items.single.name, 'Test product');
    expect(r.items.single.quantity, 15);
    expect(r.items.single.unitPrice, 3200);
    expect(r.total, 48000);
    expect(r.paymentMethod, 'MAYA');
    for (final label in ['eM-PAY', 'EM PAY', 'EMPAY', 'PAYMAYA']) {
      final tenderOnly = parse('TEST STORE\n$label 480.00');
      expect(tenderOnly.items, isEmpty);
      expect(tenderOnly.total, isNull);
    }
  });
  test(
    'receipt evidence retains old parser versions and rejects future ones',
    () {
      for (final version in [1, 2, ReceiptParser.version]) {
        final evidence = ReceiptEvidence(
          imageId: 'test-image',
          rawText: '',
          createdAt: DateTime(2026),
          total: 48000,
          parserVersion: version,
        );
        final restored = ReceiptEvidence.fromJson(evidence.toJson());
        expect(restored.parserVersion, version);
        expect(restored.copyWith(confirmed: true).parserVersion, version);
      }
      expect(
        () => ReceiptEvidence(
          imageId: 'test-image',
          rawText: '',
          createdAt: DateTime(2026),
          total: 48000,
          parserVersion: ReceiptParser.version + 1,
        ),
        throwsFormatException,
      );
    },
  );
  test(
    'Philippine receipt separates amount due from VAT, discount and tender',
    () {
      final r = parse('''JOLLIBEE
TIN 123-456-789
123 Main Street
October 8, 2026 11:42 AM
Chickenjoy 180.00
Fries 65.00
Coke 45.00
SUBTOTAL PHP 290.00
VAT 31.07
DISCOUNT 20.00
AMOUNT DUE ₱270.00
CASH 500.00
CHANGE 230.00''');
      expect(r.merchant, 'JOLLIBEE');
      expect(r.date, DateTime(2026, 10, 8, 11, 42));
      expect(r.total, 27000);
      expect(r.subtotal, 29000);
      expect(r.tax, 3107);
      expect(r.discount, 2000);
      expect(r.items.map((i) => i.total), [18000, 6500, 4500]);
      expect(r.paymentMethod, 'CASH');
      expect(r.currency, 'PHP');
    },
  );
  test('total label priority beats largest number and flags conflicts', () {
    final r = parse(
      'Store\nTOTAL 800.00\nGRAND TOTAL P 325.00\nCASH 1000.00\nCHANGE 675.00',
    );
    expect(r.total, 32500);
    expect(r.confidence['total'], 55);
    expect(r.warnings.join(), contains('Several totals'));
    expect(
      parse('Store\nSUBTOTAL 500.00\nCASH 1000.00\nCHANGE 500.00\nVAT 53.57')
          .total,
      isNull,
    );
  });
  test('VAT sales classifications are not tax or final total', () {
    final r = parse(
      'Store\nVATABLE SALES 100.00\nVAT EXEMPT SALES 200.00\nVAT ZERO-RATED 0.00\nTOTAL DUE 300.00',
    );
    expect(r.total, 30000);
    expect(r.tax, isNull);
    expect(r.items, isEmpty);
  });
  for (final label in [
    'GRAND TOTAL',
    'TOTAL DUE',
    'AMOUNT DUE',
    'NET TOTAL',
    'TOTAL',
  ]) {
    for (final currency in ['₱', 'PHP ', 'P ', '']) {
      test('$label accepts $currency and grouped centavos', () {
        expect(parse('Store\n$label ${currency}1,234.56').total, 123456);
      });
    }
  }
  test('merchant excludes common header boilerplate', () {
    expect(
      parse(
        'TIN 123\nOfficial Receipt\nTerminal ID 4\n45 Street\nSM SUPERMARKET\nTOTAL 10.00',
      ).merchant,
      'SM SUPERMARKET',
    );
  });
  for (final (text, expected) in [
    ('10/08/2026', DateTime(2026, 10, 8)),
    ('08/10/2026', DateTime(2026, 8, 10)),
    ('24/10/2026', DateTime(2026, 10, 24)),
    ('2026-10-08', DateTime(2026, 10, 8)),
    ('Oct 8 2026', DateTime(2026, 10, 8)),
    ('October 8, 2026', DateTime(2026, 10, 8)),
  ]) {
    test(
      'date $text parsed without replacing with clock',
      () => expect(parse('Store\n$text').date, expected),
    );
  }
  test('ambiguous dates and invalid/missing dates require review', () {
    expect(parse('Store\n08/10/2026').confidence['date'], 45);
    expect(parse('Store\n2026-02-31').date, isNull);
    expect(parse('Store\n2026-10-08 28:99').date, isNull);
    expect(parse('Store').warnings.join(), contains('Today is suggested only'));
    expect(
      parse('Store\n2026-10-08 12:30 AM').date,
      DateTime(2026, 10, 8, 0, 30),
    );
  });
  test('line quantities and prices preserve exact centavos', () {
    final r = parse(
      'Store\nMilk 2 x 91.00 182.00\n2 x Bread 150.00\nTOTAL 332.00',
    );
    expect(r.items.map((i) => i.quantity), [2, 2]);
    expect(r.items.map((i) => i.unitPrice), [9100, 7500]);
    expect(r.items.map((i) => i.total), [18200, 15000]);
  });
  test('empty/malformed text and missing items preserve manual path', () {
    for (final text in ['', '123\n???\nTIN 123', 'Store\nTOTAL abc']) {
      final r = parse(text);
      expect(r.total, isNull);
      expect(r.rawText, text);
      expect(r.confidence['total'], 0);
    }
    expect(parse('Store\nTOTAL 325.00').items, isEmpty);
    expect(parse('Store\nTOTAL USD 325.00').currency, 'UNKNOWN');
    expect(() => parse('x' * 200001), throwsFormatException);
  });
  test('OCR geometry joins price columns into the same row', () {
    final doc = OcrDocument('Store\nBread\nTOTAL\n75.00\n75.00', [
      OcrBlock([
        OcrLine('Store', box: const OcrBox(0, 0, 100, 12)),
        OcrLine('Bread', box: const OcrBox(0, 25, 50, 12)),
        OcrLine('TOTAL', box: const OcrBox(0, 50, 50, 12)),
      ]),
      OcrBlock([
        OcrLine('75.00', box: const OcrBox(150, 26, 40, 12)),
        OcrLine('75.00', box: const OcrBox(150, 51, 40, 12)),
      ]),
    ]);
    final r = ReceiptParser.parse(doc);
    expect(r.total, 7500);
    expect(r.items.single.name, 'Bread');
  });
}
