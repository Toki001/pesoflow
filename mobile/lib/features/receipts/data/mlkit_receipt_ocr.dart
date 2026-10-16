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
      final original = _document(result);
      final parsed = ReceiptParser.parse(original);
      if (parsed.total != null &&
          parsed.date != null &&
          parsed.merchant.isNotEmpty) {
        return original;
      }
      Directory? staging;
      try {
        // Private OCR derivative; the original remains the saved evidence.
        staging = await Directory(File(imagePath).parent.path)
            .createTemp('ocr-');
        final enhanced = File('${staging.path}/contrast.png');
        await enhanced.writeAsBytes(
          await enhanceReceiptForOcr(await File(imagePath).readAsBytes()),
          flush: true,
        );
        result = await recognizer.processImage(
          ml.InputImage.fromFilePath(enhanced.path),
        );
        if (result.text.length > 200000) return original;
        final alternative = _document(result);
        final candidate = ReceiptParser.parse(alternative);
        int score(ParsedReceipt r) =>
            (r.total != null ? 4 : 0) +
            (r.date != null ? 2 : 0) +
            (r.merchant.isNotEmpty ? 1 : 0);
        // Do not replace an explicit amount with a contradictory second pass.
        if (parsed.total != null &&
            candidate.total != null &&
            parsed.total != candidate.total) {
          return original;
        }
        return score(candidate) > score(parsed) ? alternative : original;
      } catch (_) {
        return original;
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
