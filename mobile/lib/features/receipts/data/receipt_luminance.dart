import 'dart:typed_data';

import 'package:image/image.dart' as image;

bool _isByteLuminance(image.Image value) =>
    value.format == image.Format.uint8 &&
    value.numChannels == 1 &&
    !value.hasPalette &&
    value.frames.length == 1;

/// Same normalization as image.normalize, specialized for OCR luminance bytes.
void normalizeReceiptLuminance(image.Image source) {
  if (!_isByteLuminance(source)) {
    image.normalize(source, min: 0, max: 255);
    return;
  }
  final pixels = source.toUint8List();
  var low = 255;
  var high = 0;
  for (final value in pixels) {
    if (value < low) low = value;
    if (value > high) high = value;
  }
  if (low == high || (low == 0 && high == 255)) return;
  final lookup = Uint8List(256);
  for (var value = low; value <= high; value++) {
    lookup[value] = ((value - low) / (high - low) * 255).toInt();
  }
  for (var i = 0; i < pixels.length; i++) {
    pixels[i] = lookup[pixels[i]];
  }
}

/// Apply the existing bilinear paper estimate without allocating a full-size
/// background. Truncate interpolation to a byte before dividing, exactly as the
/// image-library resize did. Keeping that quantization preserves OCR input pixels.
void correctReceiptIllumination(image.Image source, image.Image paper) {
  if (!_isByteLuminance(source) ||
      !_isByteLuminance(paper) ||
      (paper.exif.imageIfd.hasOrientation &&
          paper.exif.imageIfd.orientation != 1)) {
    final background = image.copyResize(
      paper,
      width: source.width,
      height: source.height,
      interpolation: image.Interpolation.linear,
    );
    for (final pixel in source) {
      final light = background.getPixel(pixel.x, pixel.y).r.clamp(1, 255);
      final value = (pixel.r * 245 / light).round().clamp(0, 255);
      pixel.setRgb(value, value, value);
    }
    return;
  }
  final pixels = source.toUint8List();
  final lighting = paper.toUint8List();
  final dx = paper.width / source.width;
  final dy = paper.height / source.height;
  final left = Int32List(source.width);
  final right = Int32List(source.width);
  final weight = Float64List(source.width);
  for (var x = 0; x < source.width; x++) {
    final position = x * dx;
    left[x] = position.toInt();
    right[x] = (left[x] + 1).clamp(0, paper.width - 1);
    weight[x] = position - left[x];
  }
  for (var y = 0; y < source.height; y++) {
    final position = y * dy;
    final top = position.toInt();
    final bottom = (top + 1).clamp(0, paper.height - 1);
    final fy = position - top;
    final topOffset = top * paper.width;
    final bottomOffset = bottom * paper.width;
    final row = y * source.width;
    for (var x = 0; x < source.width; x++) {
      final a = lighting[topOffset + left[x]].toDouble();
      final b = lighting[topOffset + right[x]].toDouble();
      final c = lighting[bottomOffset + left[x]].toDouble();
      final d = lighting[bottomOffset + right[x]].toDouble();
      final light =
          (a + weight[x] * (b - a + fy * (a + d - c - b)) + fy * (c - a))
              .toInt()
              .clamp(1, 255);
      pixels[row + x] = (pixels[row + x] * 245 / light).round().clamp(0, 255);
    }
  }
}
