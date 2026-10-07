import 'dart:typed_data';

import '../../workspace/domain/finance_workspace.dart';

abstract interface class ReceiptImageRepository {
  Future<FinanceWorkspace> saveWithReceiptImage(
    FinanceWorkspace workspace, {
    required int expectedRevision,
    required String imageId,
    required Uint8List bytes,
  });
  Future<Uint8List?> loadReceiptImage(String id);
}
