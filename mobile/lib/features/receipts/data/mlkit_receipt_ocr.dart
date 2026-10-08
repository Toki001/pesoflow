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
      final result = await recognizer.processImage(
        ml.InputImage.fromFilePath(imagePath),
      );
      if (result.text.length > 200000) {
        throw const ReceiptFailure(
          'Too much text was found. Crop to one receipt and try again.',
        );
      }
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
}
