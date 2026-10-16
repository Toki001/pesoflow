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
Future<Uint8List> enhanceReceiptForOcr(
  Uint8List bytes, {
  bool correctShadows = false,
}) => Isolate.run(() {
  var decoded = image.decodeImage(bytes);
  if (decoded == null) {
    throw const ReceiptFailure('The image could not be enhanced.');
  }
  // Work in one luminance channel before resizing. Linear interpolation avoids
  // the costly per-pixel cubic allocations on lower-powered Android phones.
  decoded = image.grayscale(decoded).convert(numChannels: 1);
  final longest = decoded.width > decoded.height
      ? decoded.width
      : decoded.height;
  if (longest < 1800) {
    decoded = image.copyResize(
      decoded,
      width: decoded.width >= decoded.height ? 1800 : null,
      height: decoded.height > decoded.width ? 1800 : null,
      interpolation: image.Interpolation.linear,
    );
  }
  if (correctShadows) {
    // Estimate the paper illumination at low resolution. A local maximum
    // suppresses narrow ink strokes in that estimate; smoothing avoids seams.
    // Dividing by the estimate lifts shadows without binarizing faint writing.
    final thumbnail = image.copyResize(
      decoded,
      width: decoded.width >= decoded.height ? 256 : null,
      height: decoded.height > decoded.width ? 256 : null,
      interpolation: image.Interpolation.average,
    );
    final paper = image.Image.from(thumbnail);
    for (final pixel in paper) {
      var brightest = 1;
      for (var dy = -4; dy <= 4; dy++) {
        for (var dx = -4; dx <= 4; dx++) {
          final value = thumbnail
              .getPixelClamped(pixel.x + dx, pixel.y + dy)
              .r
              .toInt();
          if (value > brightest) brightest = value;
        }
      }
      pixel.setRgb(brightest, brightest, brightest);
    }
    image.gaussianBlur(paper, radius: 3);
    final background = image.copyResize(
      paper,
      width: decoded.width,
      height: decoded.height,
      interpolation: image.Interpolation.linear,
    );
    for (final pixel in decoded) {
      final illumination = background
          .getPixel(pixel.x, pixel.y)
          .r
          .clamp(1, 255);
      final value = (pixel.r * 245 / illumination).round().clamp(0, 255);
      pixel.setRgb(value, value, value);
    }
  }
  image.normalize(decoded, min: 0, max: 255);
  // Temporary lossless input does not need archival PNG compression.
  return image.encodePng(decoded, level: 1, filter: image.PngFilter.none);
});
