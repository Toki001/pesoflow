import 'dart:isolate';
import 'dart:typed_data';

import 'package:image/image.dart' as image;

import '../domain/receipt_image.dart';

const maxReceiptInputBytes = 25 * 1024 * 1024;
Future<Uint8List> prepareReceiptImage(Uint8List bytes) => Isolate.run(() {
  try {
    if (bytes.isEmpty || bytes.length > maxReceiptInputBytes) {
      throw const ReceiptFailure('Choose an image smaller than 25 MB.');
    }
    final decoder = image.findDecoderForData(bytes);
    final info = decoder?.startDecode(bytes);
    if (info == null) {
      throw const ReceiptFailure(
        'This image cannot be read. Choose a JPEG or PNG image.',
      );
    }
    if (info.width * info.height > 40000000 ||
        info.width < 32 ||
        info.height < 32) {
      throw const ReceiptFailure(
        'Choose a clear receipt image up to 40 megapixels.',
      );
    }
    final decoded = decoder!.decodeFrame(0);
    if (decoded == null) {
      throw const ReceiptFailure('This image is incomplete or unreadable.');
    }
    var normalized = image.bakeOrientation(decoded);
    if (normalized.width > 3000 || normalized.height > 3000) {
      normalized = image.copyResize(
        normalized,
        width: normalized.width >= normalized.height ? 3000 : null,
        height: normalized.height > normalized.width ? 3000 : null,
        interpolation: image.Interpolation.average,
      );
    }
    normalized.exif = image.ExifData();
    normalized.textData = null;
    normalized.iccProfile = null;
    final result = image.encodeJpg(normalized, quality: 90);
    if (result.length > 20 * 1024 * 1024) {
      throw const ReceiptFailure(
        'The processed receipt is too large. Crop it to a smaller area.',
      );
    }
    return result;
  } on ReceiptFailure {
    rethrow;
  } catch (_) {
    throw const ReceiptFailure(
      'This image cannot be read. Choose another photo.',
    );
  }
});

Future<Uint8List> rotateReceiptImage(Uint8List bytes) => Isolate.run(() {
  final decoded = image.decodeImage(bytes);
  if (decoded == null) {
    throw const ReceiptFailure('The image could not be rotated.');
  }
  return image.encodeJpg(image.copyRotate(decoded, angle: 90), quality: 95);
});

/// OCR-only derivative. The original receipt remains the persisted evidence.
Future<Uint8List> enhanceReceiptForOcr(Uint8List bytes) => Isolate.run(() {
  var decoded = image.decodeImage(bytes);
  if (decoded == null) {
    throw const ReceiptFailure('The image could not be enhanced.');
  }
  final longest = decoded.width > decoded.height
      ? decoded.width
      : decoded.height;
  if (longest < 1800) {
    decoded = image.copyResize(
      decoded,
      width: decoded.width >= decoded.height ? 1800 : null,
      height: decoded.height > decoded.width ? 1800 : null,
      interpolation: image.Interpolation.cubic,
    );
  }
  image.grayscale(decoded);
  image.normalize(decoded, min: 0, max: 255);
  return image.encodePng(decoded);
});
