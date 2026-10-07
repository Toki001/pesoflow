import '../../../core/serialization/values.dart';

/// Reviewed extraction evidence, encrypted with the financial workspace.
/// Field confidence is parser confidence, never a claim of verified accuracy.
class ReceiptEvidence {
  ReceiptEvidence({
    required this.imageId,
    required this.rawText,
    required this.createdAt,
    required this.total,
    this.subtotal,
    this.tax,
    this.discount,
    this.currency = 'PHP',
    this.paymentMethod,
    this.parserVersion = 1,
    this.confirmed = false,
    Map<String, int> confidence = const {},
    List<String> warnings = const [],
  }) : confidence = Map.unmodifiable(confidence),
       warnings = List.unmodifiable(warnings) {
    if (imageId.isEmpty ||
        imageId.length > 200 ||
        rawText.length > 200000 ||
        parserVersion != 1 ||
        !['PHP', 'UNKNOWN'].contains(currency) ||
        [
          total,
          subtotal,
          tax,
          discount,
        ].whereType<int>().any((v) => v < 0 || v > maxMoney) ||
        confidence.keys.any(
          (k) => !['merchant', 'date', 'total'].contains(k),
        ) ||
        confidence.values.any((v) => v < 0 || v > 100) ||
        warnings.length > 30 ||
        warnings.any((w) => w.length > 500) ||
        (paymentMethod?.length ?? 0) > 50) {
      throw const FormatException('Invalid receipt evidence.');
    }
  }
  final String imageId, rawText, currency;
  final String? paymentMethod;
  final DateTime createdAt;
  final int total, parserVersion;
  final int? subtotal, tax, discount;
  final bool confirmed;
  final Map<String, int> confidence;
  final List<String> warnings;
  ReceiptEvidence copyWith({
    int? total,
    int? subtotal,
    int? tax,
    int? discount,
    bool? confirmed,
    String? currency,
  }) => ReceiptEvidence(
    imageId: imageId,
    rawText: rawText,
    createdAt: createdAt,
    total: total ?? this.total,
    subtotal: subtotal ?? this.subtotal,
    tax: tax ?? this.tax,
    discount: discount ?? this.discount,
    currency: currency ?? this.currency,
    paymentMethod: paymentMethod,
    parserVersion: parserVersion,
    confirmed: confirmed ?? this.confirmed,
    confidence: confidence,
    warnings: warnings,
  );
  Json toJson() => {
    'imageId': imageId,
    'rawText': rawText,
    'createdAt': createdAt.toIso8601String(),
    'total': total,
    'subtotal': subtotal,
    'tax': tax,
    'discount': discount,
    'currency': currency,
    'paymentMethod': paymentMethod,
    'parserVersion': parserVersion,
    'confirmed': confirmed,
    'confidence': confidence,
    'warnings': warnings,
  };
  factory ReceiptEvidence.fromJson(Json j) => ReceiptEvidence(
    imageId: jsonString(j, 'imageId', max: 200),
    rawText: jsonString(j, 'rawText', max: 200000, empty: true),
    createdAt: jsonDate(j, 'createdAt'),
    total: jsonInt(j, 'total', min: 0, max: maxMoney),
    subtotal: j['subtotal'] == null
        ? null
        : jsonInt(j, 'subtotal', min: 0, max: maxMoney),
    tax: j['tax'] == null ? null : jsonInt(j, 'tax', min: 0, max: maxMoney),
    discount: j['discount'] == null
        ? null
        : jsonInt(j, 'discount', min: 0, max: maxMoney),
    currency: jsonString(j, 'currency'),
    paymentMethod: j['paymentMethod'] as String?,
    parserVersion: jsonInt(j, 'parserVersion'),
    confirmed: j['confirmed'] as bool,
    confidence: (j['confidence'] as Map<String, dynamic>).map(
      (k, v) => MapEntry(k, v as int),
    ),
    warnings: (j['warnings'] as List).cast<String>(),
  );
}
