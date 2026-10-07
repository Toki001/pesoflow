import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

import '../domain/finance_backup.dart';

abstract interface class BackupFiles {
  Future<Uint8List?> pick();
  Future<bool> save(String name, Uint8List bytes, {bool csv = false});
}

class NativeBackupFiles implements BackupFiles {
  @override
  Future<Uint8List?> pick() async {
    final files = await FilePicker.pickFiles(
      dialogTitle: 'Choose PesoFlow backup',
    );
    if (files.isEmpty) return null;
    if (files.length != 1) throw const BackupFailure('Choose one backup file.');
    final file = files.single;
    final size = await file.length();
    if (size != null && size > maxBackupBytes) {
      throw const BackupFailure('Choose a backup smaller than 48 MB.');
    }
    final bytes = BytesBuilder(copy: false);
    await for (final chunk in file.readAsByteStream()) {
      if (bytes.length + chunk.length > maxBackupBytes) {
        throw const BackupFailure('Choose a backup smaller than 48 MB.');
      }
      bytes.add(chunk);
    }
    return bytes.takeBytes();
  }

  @override
  Future<bool> save(String name, Uint8List bytes, {bool csv = false}) async =>
      await FilePicker.saveFile(
        fileName: name,
        bytes: bytes,
        mimeType: csv ? 'text/csv' : 'application/octet-stream',
        dialogTitle: csv ? 'Export transactions' : 'Save encrypted backup',
      ) !=
      null;
}
