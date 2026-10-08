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
