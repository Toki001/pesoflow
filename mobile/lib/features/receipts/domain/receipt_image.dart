import 'dart:typed_data';

enum ReceiptImageSource { camera, photos }

class ReceiptFailure implements Exception {
  const ReceiptFailure(this.message, {this.settings = false});
  final String message;
  final bool settings;
}

class ReceiptImage {
  ReceiptImage(this.path, Uint8List bytes)
    : bytes = Uint8List.fromList(bytes).asUnmodifiableView();
  final String path;
  final Uint8List bytes;
}

abstract interface class ReceiptImages {
  Future<ReceiptImage?> acquire(ReceiptImageSource source);
  Future<ReceiptImage?> recover();
  Future<ReceiptImage?> crop(ReceiptImage image);
  Future<ReceiptImage?> rotate(ReceiptImage image);
  Future<void> release(ReceiptImage image);
  Future<void> openSettings();
}
