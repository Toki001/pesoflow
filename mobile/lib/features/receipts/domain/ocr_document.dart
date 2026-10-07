/// Engine-independent OCR geometry. Confidence is optional native recognition
/// confidence, distinct from the parser's field-selection confidence.
class OcrBox {
  const OcrBox(this.left, this.top, this.width, this.height);
  final double left, top, width, height;
}

class OcrElement {
  const OcrElement(this.text, {this.box, this.confidence});
  final String text;
  final OcrBox? box;
  final double? confidence;
}

class OcrLine {
  OcrLine(
    this.text, {
    this.box,
    this.confidence,
    List<OcrElement> elements = const [],
  }) : elements = List.unmodifiable(elements);
  final String text;
  final OcrBox? box;
  final double? confidence;
  final List<OcrElement> elements;
}

class OcrBlock {
  OcrBlock(List<OcrLine> lines, {this.box}) : lines = List.unmodifiable(lines);
  final List<OcrLine> lines;
  final OcrBox? box;
}

class OcrDocument {
  OcrDocument(this.text, List<OcrBlock> blocks)
    : blocks = List.unmodifiable(blocks);
  final String text;
  final List<OcrBlock> blocks;
}

abstract interface class ReceiptOcrService {
  Future<OcrDocument> recognize(String imagePath);
}
