import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:pesoflow/features/receipts/data/prepare_receipt_image.dart';
import 'package:pesoflow/features/receipts/data/native_receipt_images.dart';
import 'package:pesoflow/features/receipts/data/mlkit_receipt_ocr.dart';
import 'package:pesoflow/features/receipts/domain/receipt_image.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'rotation swaps dimensions and enhancement leaves source bytes unchanged',
    () async {
      final source = img.Image(width: 100, height: 60);
      img.fill(source, color: img.ColorRgb8(80, 80, 80));
      img.fillRect(
        source,
        x1: 0,
        y1: 0,
        x2: 20,
        y2: 20,
        color: img.ColorRgb8(200, 200, 200),
      );
      final bytes = img.encodeJpg(source);
      final original = Uint8List.fromList(bytes);
      final rotated = img.decodeJpg(await rotateReceiptImage(bytes))!;
      expect((rotated.width, rotated.height), (60, 100));
      final enhanced = img.decodePng(await enhanceReceiptForOcr(bytes))!;
      expect(enhanced.width, 1800);
      expect(bytes, original);
    },
  );
  test(
    'preprocessing bakes orientation, strips metadata and bounds dimensions',
    () async {
      final source = img.Image(width: 60, height: 100);
      source.exif.imageIfd.orientation = 6;
      source.exif.imageIfd.imageDescription = 'private metadata';
      final result = img.decodeJpg(
        await prepareReceiptImage(img.encodeJpg(source)),
      )!;
      expect((result.width, result.height), (100, 60));
      expect(result.exif.imageIfd.imageDescription, isNull);
      expect(result.exif.imageIfd.orientation, isNull);
      final large = img.Image(width: 3200, height: 160);
      final small = img.decodeJpg(
        await prepareReceiptImage(img.encodePng(large)),
      )!;
      expect((small.width, small.height), (3000, 150));
    },
  );
  test('corrupt, oversized and tiny inputs produce safe failures', () async {
    for (final bytes in [
      Uint8List(0),
      Uint8List.fromList([1, 2, 3]),
      Uint8List(maxReceiptInputBytes + 1),
      img.encodePng(img.Image(width: 10, height: 10)),
    ]) {
      await expectLater(
        prepareReceiptImage(bytes),
        throwsA(isA<ReceiptFailure>()),
      );
    }
  });
  test(
    'platform permission and unavailable errors offer appropriate recovery',
    () {
      expect(imagePlatformFailure('camera_access_denied').settings, isTrue);
      expect(imagePlatformFailure('photo_access_restricted').settings, isTrue);
      expect(
        imagePlatformFailure('no_available_camera').message,
        contains('Select'),
      );
      expect(
        imagePlatformFailure('sensitive platform error').message,
        isNot(contains('sensitive')),
      );
    },
  );
  const channel = MethodChannel('google_mlkit_text_recognizer');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  tearDown(() => messenger.setMockMethodCallHandler(channel, null));
  test('ML Kit adapter maps geometry and optional confidence then closes native recognizer', () async {
    final calls = <String>[];
    final base = <String, Object?>{
      'text': 'TOTAL',
      'rect': {'left': 2.0, 'top': 3.0, 'right': 102.0, 'bottom': 23.0},
      'recognizedLanguages': ['en'],
      'points': [],
      'confidence': .92,
    };
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call.method);
      if (call.method.contains('close')) return null;
      expect((call.arguments as Map)['script'], 0);
      return {
        'text': 'TOTAL',
        'blocks': [
          {
            ...base,
            'lines': [
              {
                ...base,
                'elements': [
                  {...base, 'symbols': []},
                ],
              },
            ],
          },
        ],
      };
    });
    final doc = await MlKitReceiptOcr().recognize('/private/receipt.jpg');
    final line = doc.blocks.single.lines.single;
    expect(doc.text, 'TOTAL');
    expect(line.box!.width, 100);
    expect(line.elements.single.confidence, .92);
    expect(calls, ['vision#startTextRecognizer', 'vision#closeTextRecognizer']);
  });
  for (final conflict in [false, true]) {
    test(
      'enhanced OCR pass preserves evidence and rejects conflicting totals: $conflict',
      () async {
        final dir = await Directory.systemTemp.createTemp('receipt-ocr-test-');
        addTearDown(() => dir.delete(recursive: true));
        final source = File('${dir.path}/original.jpg');
        final bytes = img.encodeJpg(img.Image(width: 100, height: 60));
        await source.writeAsBytes(bytes);
        var passes = 0;
        messenger.setMockMethodCallHandler(channel, (call) async {
          if (call.method.contains('close')) return null;
          passes++;
          return {
            'text': passes == 1
                ? (conflict ? 'STORE\nTOTAL 25' : 'STORE')
                : 'STORE\nTOTAL 799\n10-15-26',
            'blocks': [],
          };
        });
        final doc = await MlKitReceiptOcr().recognize(source.path);
        expect(passes, conflict ? 3 : 2);
        expect(doc.text, contains(conflict ? 'TOTAL 25' : 'TOTAL 799'));
        expect(await source.readAsBytes(), bytes);
        expect(await dir.list().length, 1); // derivative removed
      },
    );
  }
  test(
    'shadow correction lifts paper shadows while retaining ink and source',
    () async {
      final source = img.Image(width: 1800, height: 500);
      for (final pixel in source) {
        final light = 60 + (pixel.x * 160 ~/ source.width);
        pixel.setRgb(light, light, light);
      }
      for (final x in [300, 1500]) {
        img.fillRect(
          source,
          x1: x,
          y1: 200,
          x2: x + 8,
          y2: 300,
          color: img.ColorRgb8(15, 15, 15),
        );
      }
      final bytes = img.encodePng(source);
      final original = Uint8List.fromList(bytes);
      final corrected = img.decodePng(
        await enhanceReceiptForOcr(bytes, correctShadows: true),
      )!;
      final leftPaper = corrected.getPixel(300, 100).r;
      final rightPaper = corrected.getPixel(1500, 100).r;
      expect((leftPaper - rightPaper).abs(), lessThan(25));
      expect(leftPaper, greaterThan(200));
      expect(corrected.getPixel(303, 250).r, lessThan(leftPaper - 150));
      expect(corrected.getPixel(1503, 250).r, lessThan(rightPaper - 150));
      expect(bytes, original);
    },
  );
  for (final failsContrast in [false, true]) {
    test(
      'shadow retry recovers missing fields and cleans up; contrast failure: $failsContrast',
      () async {
        final dir = await Directory.systemTemp.createTemp(
          'receipt-shadow-test-',
        );
        addTearDown(() => dir.delete(recursive: true));
        final source = File('${dir.path}/original.jpg');
        await source.writeAsBytes(
          img.encodeJpg(img.Image(width: 100, height: 60)),
        );
        var passes = 0;
        messenger.setMockMethodCallHandler(channel, (call) async {
          if (call.method.contains('close')) return null;
          passes++;
          if (passes == 2 && failsContrast) {
            throw PlatformException(code: 'unavailable');
          }
          return {
            'text': passes < 3 ? 'STORE' : 'STORE\nTOTAL 42\n10-15-26',
            'blocks': [],
          };
        });
        final doc = await MlKitReceiptOcr().recognize(source.path);
        expect(passes, 3);
        expect(doc.text, contains('TOTAL 42'));
        expect(await dir.list().length, 1);
      },
    );
  }
  for (final originalText in [
    'STORE\n10-15-26\nPAID VIA MAYA',
    'STORE\nPAID VIA MAYA',
  ]) {
    test(
      'enhancement cannot replace a recognized date or lose payment: $originalText',
      () async {
        final dir = await Directory.systemTemp.createTemp(
          'receipt-conflict-test-',
        );
        addTearDown(() => dir.delete(recursive: true));
        final source = File('${dir.path}/original.jpg');
        await source.writeAsBytes(
          img.encodeJpg(img.Image(width: 100, height: 60)),
        );
        var passes = 0;
        messenger.setMockMethodCallHandler(channel, (call) async {
          if (call.method.contains('close')) return null;
          passes++;
          return {
            'text': passes == 1 ? originalText : 'STORE\nTOTAL 42\n10-16-26',
            'blocks': [],
          };
        });
        final doc = await MlKitReceiptOcr().recognize(source.path);
        expect(passes, 3);
        expect(doc.text, originalText);
        expect(await dir.list().length, 1);
      },
    );
  }
  test('native OCR failure is sanitized and releases the recognizer', () async {
    var closed = false;
    messenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method.contains('close')) {
        closed = true;
        return null;
      }
      throw PlatformException(code: 'private receipt details');
    });
    await expectLater(
      MlKitReceiptOcr().recognize('/private/receipt.jpg'),
      throwsA(
        isA<ReceiptFailure>().having(
          (e) => e.message,
          'safe message',
          isNot(contains('private receipt')),
        ),
      ),
    );
    expect(closed, isTrue);
  });
}
