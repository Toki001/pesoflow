import 'dart:io';

import 'prepare_receipt_image.dart';
import '../domain/receipt_parser.dart';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart'
    as ml;

import '../domain/ocr_document.dart';
import '../domain/receipt_image.dart';

class MlKitReceiptOcr implements ReceiptOcrService {
  @override
  Future<OcrDocument> recognize(String imagePath) async {
    final recognizer = ml.TextRecognizer(
      script: ml.TextRecognitionScript.latin,
    );
    try {
      var result = await recognizer.processImage(
        ml.InputImage.fromFilePath(imagePath),
      );
      if (result.text.length > 200000) {
        throw const ReceiptFailure(
          'Too much text was found. Crop to one receipt and try again.',
        );
      }
      var best = _document(result);
      var parsed = ReceiptParser.parse(best);
      if (_complete(parsed)) return best;
      Directory? staging;
      try {
        // Private OCR derivatives; the original remains the saved evidence.
        staging = await Directory(File(imagePath).parent.path)
            .createTemp('ocr-');
        final bytes = await File(imagePath).readAsBytes();
        for (final correctShadows in [false, true]) {
          try {
            final enhanced = File('${staging.path}/contrast.png');
            await enhanced.writeAsBytes(
              await enhanceReceiptForOcr(bytes, correctShadows: correctShadows),
              flush: true,
            );
            result = await recognizer.processImage(
              ml.InputImage.fromFilePath(enhanced.path),
            );
            if (result.text.length > 200000) continue;
            final alternative = _document(result);
            final candidate = ReceiptParser.parse(alternative);
            // Select one whole recognition, never splice contradictory fields
            // or lose a previously recognized amount/date/payment method.
            if (_compatible(parsed, candidate) &&
                _score(candidate) > _score(parsed)) {
              best = alternative;
              parsed = candidate;
            }
            if (_complete(parsed)) break;
          } catch (_) {
            // An optional enhancement failure must not discard readable text.
          }
        }
        return best;
      } catch (_) {
        return best;
      } finally {
        try {
          await staging?.delete(recursive: true);
        } catch (_) {}
      }
    } on ReceiptFailure {
      rethrow;
    } catch (_) {
      throw const ReceiptFailure(
        'Text recognition could not finish. Keep this image and retry, adjust the frame, or enter the details manually.',
      );
    } finally {
      try {
        await recognizer.close();
      } catch (_) {
        // Cleanup failure must not discard successfully recognized text.
      }
    }
  }

  bool _complete(ParsedReceipt receipt) =>
      receipt.total != null &&
      receipt.date != null &&
      receipt.merchant.isNotEmpty;

  bool _compatible(ParsedReceipt previous, ParsedReceipt candidate) =>
      (previous.total == null || previous.total == candidate.total) &&
      (previous.date == null || previous.date == candidate.date) &&
      (previous.paymentMethod == null ||
          previous.paymentMethod == candidate.paymentMethod);

  double _score(ParsedReceipt receipt) =>
      (receipt.total != null ? 4 : 0) +
      (receipt.date != null ? 2 : 0) +
      (receipt.merchant.isNotEmpty ? 1 : 0) +
      RegExp(
                r'\b(TOTAL|AMOUNT|WORDS|DATE|INVOICE|CASH)\b',
                caseSensitive: false,
              )
              .allMatches(receipt.rawText)
              .map((match) => match[0]!.toUpperCase())
              .toSet()
              .length /
          10;

  OcrDocument _document(ml.RecognizedText result) {
    return OcrDocument(result.text, [
      for (final b in result.blocks)
        OcrBlock(
          [
            for (final l in b.lines)
              OcrLine(
                l.text,
                box: OcrBox(
                  l.boundingBox.left,
                  l.boundingBox.top,
                  l.boundingBox.width,
                  l.boundingBox.height,
                ),
                confidence: l.confidence,
                elements: [
                  for (final e in l.elements)
                    OcrElement(
                      e.text,
                      box: OcrBox(
                        e.boundingBox.left,
                        e.boundingBox.top,
                        e.boundingBox.width,
                        e.boundingBox.height,
                      ),
                      confidence: e.confidence,
                    ),
                ],
              ),
          ],
          box: OcrBox(
            b.boundingBox.left,
            b.boundingBox.top,
            b.boundingBox.width,
            b.boundingBox.height,
          ),
        ),
    ]);
  }
}
