// Synthetic pixels only. Compile with dart compile exe for AOT measurements.
import 'dart:convert';
import 'dart:io';

import 'package:image/image.dart' as image;
import 'package:pesoflow/features/receipts/data/receipt_luminance.dart';

void main() {
  final source = image.Image(width: 3000, height: 2250, numChannels: 1);
  for (final pixel in source) {
    pixel.r = (pixel.x * 173 + pixel.y * 31) % 256;
  }
  final paper = image.Image(width: 256, height: 192, numChannels: 1);
  for (final pixel in paper) {
    pixel.r = (pixel.x * 13 + pixel.y * 7) % 256;
  }
  for (var run = 0; run < 5; run++) {
    final reference = image.Image.from(source);
    final candidate = image.Image.from(source);
    final timer = Stopwatch()..start();
    final background = image.copyResize(
      paper,
      width: source.width,
      height: source.height,
      interpolation: image.Interpolation.linear,
    );
    for (final pixel in reference) {
      final light = background.getPixel(pixel.x, pixel.y).r.clamp(1, 255);
      pixel.r = (pixel.r * 245 / light).round().clamp(0, 255);
    }
    image.normalize(reference, min: 0, max: 255);
    final before = timer.elapsedMicroseconds;
    timer.reset();
    correctReceiptIllumination(candidate, paper);
    normalizeReceiptLuminance(candidate);
    final after = timer.elapsedMicroseconds;
    timer.stop();
    final expected = reference.toUint8List();
    final actual = candidate.toUint8List();
    for (var i = 0; i < expected.length; i++) {
      if (expected[i] != actual[i]) {
        throw StateError('Pixel mismatch; performance result rejected.');
      }
    }
    stdout.writeln(
      jsonEncode({
        'run': run,
        'reference_us': before,
        'optimized_us': after,
        'identical_pixels': true,
      }),
    );
  }
}
