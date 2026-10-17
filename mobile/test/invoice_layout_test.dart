import 'package:flutter_test/flutter_test.dart';
import 'package:pesoflow/features/receipts/domain/ocr_document.dart';
import 'package:pesoflow/features/receipts/domain/receipt_parser.dart';

OcrLine cell(
  String text,
  double x,
  double y,
  double width, [
  double height = 12,
]) => OcrLine(text, box: OcrBox(x, y, width, height));
OcrDocument invoice({
  String amount = '425',
  bool secondRow = false,
  bool table = true,
  bool explicit = false,
  bool adjustment = false,
}) {
  final lines = [
    cell('EXAMPLE SERVICES, INC.', 10, 10, 220),
    cell('SERVICE INVOICE', 400, 10, 140),
    cell('Printing date 2020-01-01', 10, 32, 220),
    cell('No 123456', 420, 40, 100),
    cell('Date', 180, 70, 35),
    cell('11-18-25', 240, 64, 95, 18),
    cell('Received From', 180, 90, 100),
    cell('Example Customer', 300, 92, 140),
    if (table) cell('PARTICULARS', 180, 130, 100),
    cell('UNIT PRICE', 350, 130, 85),
    cell('AMOUNT', 480, 129, 65),
    cell('Repair service', 180, 165, 110),
    cell('425', 360, 165, 35),
    cell(amount, 500, 173, 35, 16),
    if (secondRow) ...[cell('Parts', 180, 200, 50), cell('50', 500, 200, 25)],
    cell(explicit ? 'TOTAL AMOUNT DUE 500' : 'TOTAL AMOUNT DUE', 300, 240, 240),
    if (adjustment) cell('VAT 25.00', 300, 260, 160),
    cell('Cash 1000', 300, 280, 160),
  ];
  return OcrDocument(lines.map((line) => line.text).join('\n'), [
    OcrBlock(lines),
  ]);
}

void main() {
  test('amount column associates offset row and date above Received From', () {
    final receipt = ReceiptParser.parse(invoice());
    expect(receipt.date, DateTime(2025, 11, 18));
    expect(receipt.total, 42500);
    expect(receipt.confidence['total'], lessThan(65));
    expect(receipt.warnings.join(), contains('Amount-column'));
    expect(receipt.items.single.total, 42500);
  });
  test('column values are variable; explicit totals win over row amounts', () {
    expect(ReceiptParser.parse(invoice(amount: '1,275.50')).total, 127550);
    expect(
      ReceiptParser.parse(invoice(amount: '1,275.50')).items.single.total,
      127550,
    );
    expect(ReceiptParser.parse(invoice(explicit: true)).total, 50000);
  });
  test('ambiguous rows, unreadable digits and adjustments never become guessed total', () {
    for (final document in [
      invoice(secondRow: true),
      invoice(amount: '4?5'),
      invoice(table: false),
      invoice(adjustment: true),
    ]) {
      expect(ReceiptParser.parse(document).total, isNull);
    }
  });
  test(
    'missing geometry cannot turn an arbitrary Amount number into a total',
    () {
      expect(
        ReceiptParser.parse(OcrDocument('STORE\nAMOUNT\n425', [])).total,
        isNull,
      );
    },
  );
  test('missing form date does not use printer registration date', () {
    final lines = invoice().blocks.single.lines
        .where((line) => line.text != '11-18-25')
        .toList();
    expect(
      ReceiptParser.parse(
        OcrDocument(lines.map((l) => l.text).join('\n'), [OcrBlock(lines)]),
      ).date,
      isNull,
    );
  });
  test('unreadable second row prevents a single-amount total suggestion', () {
    final lines = [
      for (final line in invoice(secondRow: true).blocks.single.lines)
        line.text == '50' ? cell('5?', 500, 200, 25) : line,
    ];
    expect(
      ReceiptParser.parse(
        OcrDocument(lines.map((l) => l.text).join('\n'), [OcrBlock(lines)]),
      ).total,
      isNull,
    );
  });
  test('native word elements retain column/date associations', () {
    final original = invoice();
    final lines = [
      for (final line in original.blocks.single.lines)
        OcrLine(
          line.text,
          box: line.box,
          elements: [OcrElement(line.text, box: line.box)],
        ),
    ];
    final result = ReceiptParser.parse(
      OcrDocument(original.text, [OcrBlock(lines)]),
    );
    expect(result.total, 42500);
    expect(result.date, DateTime(2025, 11, 18));
  });
  test('invalid labeled date is flagged instead of taking printer date', () {
    final original = invoice();
    final lines = [
      for (final line in original.blocks.single.lines)
        line.text == '11-18-25' ? cell('02-30-25', 240, 64, 95, 18) : line,
    ];
    final receipt = ReceiptParser.parse(
      OcrDocument(lines.map((l) => l.text).join('\n'), [OcrBlock(lines)]),
    );
    expect(receipt.date, isNull);
  });
}
