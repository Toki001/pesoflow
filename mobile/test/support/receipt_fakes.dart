import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:pesoflow/features/receipts/domain/ocr_document.dart';
import 'package:pesoflow/features/receipts/domain/receipt_image.dart';

const receiptText =
    'Jollibee\nOctober 24, 2024 12:30 PM\nChickenjoy 180.00\nFries 65.00\nCoke 45.00\nSUBTOTAL 290.00\nVAT 31.07\nGRAND TOTAL PHP 290.00\nCASH 500.00\nCHANGE 210.00';
Uint8List receiptPhoto() {
  final image = img.Image(width: 520, height: 700);
  img.fill(image, color: img.ColorRgb8(249, 247, 238));
  var y = 30;
  for (final line in receiptText.split('\n')) {
    img.drawString(
      image,
      line,
      font: img.arial24,
      x: 20,
      y: y,
      color: img.ColorRgb8(25, 25, 25),
    );
    y += 54;
  }
  return img.encodePng(image);
}

class FakeReceiptImages implements ReceiptImages {
  ReceiptImage? next = ReceiptImage('/test/receipt.png', receiptPhoto());
  ReceiptImage? recovered;
  ReceiptImage? cropped;
  ReceiptImage? rotated;
  ReceiptFailure? error;
  final released = <String>[];
  int acquisitions = 0, recoveries = 0, settings = 0;
  @override
  Future<ReceiptImage?> acquire(ReceiptImageSource source) async {
    acquisitions++;
    if (error != null) throw error!;
    return next;
  }

  @override
  Future<ReceiptImage?> recover() async {
    recoveries++;
    return recovered;
  }

  @override
  Future<ReceiptImage?> crop(ReceiptImage image) async => cropped;
  @override
  Future<ReceiptImage?> rotate(ReceiptImage image) async => rotated;
  @override
  Future<void> release(ReceiptImage image) async {
    released.add(image.path);
  }

  @override
  Future<void> openSettings() async {
    settings++;
  }
}

class FakeReceiptOcr implements ReceiptOcrService {
  String text = receiptText;
  ReceiptFailure? error;
  int calls = 0;
  @override
  Future<OcrDocument> recognize(String imagePath) async {
    calls++;
    if (error != null) throw error!;
    return OcrDocument(text, [
      OcrBlock([for (final line in text.split('\n')) OcrLine(line)]),
    ]);
  }
}
