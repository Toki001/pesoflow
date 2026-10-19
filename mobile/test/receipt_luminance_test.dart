import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'package:pesoflow/features/receipts/data/receipt_luminance.dart';

void main() {
  test('byte normalization matches library across every luminance range', () {
    for (var low = 0; low <= 255; low++) {
      final source = image.Image(width: 256 - low, height: 1, numChannels: 1);
      for (var high = low; high <= 255; high++) {
        for (final pixel in source) {
          pixel.r = low + pixel.x % (high - low + 1);
        }
        final expected = image.Image.from(source);
        image.normalize(expected, min: 0, max: 255);
        normalizeReceiptLuminance(source);
        expect(source.toUint8List(), expected.toUint8List());
      }
    }
  });

  for (final dimensions in [
    (1, 1, 1, 1),
    (67, 39, 1, 1),
    (101, 53, 7, 5),
    (53, 101, 5, 7),
    (256, 193, 256, 193),
    (37, 19, 71, 31),
    (601, 453, 256, 193),
  ]) {
    test('illumination matches library resize at $dimensions', () {
      final (width, height, paperWidth, paperHeight) = dimensions;
      final random = Random(237);
      final source = image.Image(width: width, height: height, numChannels: 1);
      final paper = image.Image(
        width: paperWidth,
        height: paperHeight,
        numChannels: 1,
      );
      for (final pixel in source) {
        pixel.r = random.nextInt(256);
      }
      for (final pixel in paper) {
        pixel.r = random.nextInt(256);
      }
      final originalPaper = paper.toUint8List().toList();
      final expected = image.Image.from(source);
      final background = image.copyResize(
        paper,
        width: width,
        height: height,
        interpolation: image.Interpolation.linear,
      );
      for (final pixel in expected) {
        final light = background.getPixel(pixel.x, pixel.y).r.clamp(1, 255);
        pixel.r = (pixel.r * 245 / light).round().clamp(0, 255);
      }
      correctReceiptIllumination(source, paper);
      expect(source.toUint8List(), expected.toUint8List());
      expect(paper.toUint8List(), originalPaper);
    });
  }

  test('non-byte and color normalization retain the library path', () {
    for (final format in [image.Format.uint8, image.Format.uint16]) {
      for (final channels in [1, 3]) {
        final source = image.Image(
          width: 31,
          height: 17,
          format: format,
          numChannels: channels,
        );
        for (final pixel in source) {
          pixel.setRgb(pixel.x + 20, pixel.y + 40, pixel.x + pixel.y + 60);
        }
        final expected = image.Image.from(source);
        image.normalize(expected, min: 0, max: 255);
        normalizeReceiptLuminance(source);
        expect(source.toUint8List(), expected.toUint8List());
      }
    }
  });

  test(
    'illumination retains color, high-depth and oriented-paper behavior',
    () {
      for (final mode in [
        'color',
        'high_depth',
        'orientation',
        'black_paper',
      ]) {
        final source = image.Image(
          width: 31,
          height: 17,
          format: mode == 'high_depth'
              ? image.Format.uint16
              : image.Format.uint8,
          numChannels: mode == 'color' ? 3 : 1,
        );
        for (final pixel in source) {
          pixel.setRgb(pixel.x * 3, pixel.y * 5, 60);
        }
        final paper = image.Image(width: 5, height: 3, numChannels: 1);
        if (mode != 'black_paper') {
          for (final pixel in paper) {
            pixel.r = 70 + pixel.x * 20;
          }
        }
        if (mode == 'orientation') paper.exif.imageIfd.orientation = 6;
        final expected = image.Image.from(source);
        final background = image.copyResize(
          paper,
          width: source.width,
          height: source.height,
          interpolation: image.Interpolation.linear,
        );
        for (final pixel in expected) {
          final light = background.getPixel(pixel.x, pixel.y).r.clamp(1, 255);
          final value = (pixel.r * 245 / light).round().clamp(0, 255);
          pixel.setRgb(value, value, value);
        }
        correctReceiptIllumination(source, paper);
        expect(source.toUint8List(), expected.toUint8List(), reason: mode);
      }
    },
  );
}
