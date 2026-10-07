import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class EncryptionKeyStore {
  Future<SecretKey> load({required bool createIfMissing});
}

class MissingEncryptionKey implements Exception {
  const MissingEncryptionKey();
}

/// Keys never enter SQLite, backups, exports, logs or API requests.
class SecureEncryptionKeyStore implements EncryptionKeyStore {
  SecureEncryptionKeyStore({FlutterSecureStorage? storage})
    : storage =
          storage ??
          const FlutterSecureStorage(
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.unlocked_this_device,
            ),
          );
  final FlutterSecureStorage storage;
  static const _keyName = 'pesoflow.financial-data-key.v1';
  @override
  Future<SecretKey> load({required bool createIfMissing}) async {
    final encoded = await storage.read(key: _keyName);
    if (encoded != null) {
      final bytes = base64Decode(encoded);
      if (bytes.length != 32) {
        throw const FormatException('Invalid storage key.');
      }
      return SecretKey(bytes);
    }
    if (!createIfMissing) throw const MissingEncryptionKey();
    final key = await AesGcm.with256bits().newSecretKey();
    await storage.write(
      key: _keyName,
      value: base64Encode(await key.extractBytes()),
    );
    return key;
  }
}

class FinancialCipher {
  FinancialCipher(this.keys);
  final EncryptionKeyStore keys;
  final _algorithm = AesGcm.with256bits();

  Future<Uint8List> seal(
    List<int> bytes, {
    required String context,
    bool createKey = false,
  }) async {
    final key = await keys.load(createIfMissing: createKey);
    final box = await _algorithm.encrypt(
      bytes,
      secretKey: key,
      aad: utf8.encode(context),
    );
    return Uint8List.fromList([1, ...box.concatenation()]);
  }

  Future<Uint8List> open(List<int> bytes, {required String context}) async {
    if (bytes.length < 29 || bytes.first != 1) {
      throw const FormatException('Unsupported encrypted financial data.');
    }
    final box = SecretBox.fromConcatenation(
      bytes.sublist(1),
      nonceLength: 12,
      macLength: 16,
    );
    final plain = await _algorithm.decrypt(
      box,
      secretKey: await keys.load(createIfMissing: false),
      aad: utf8.encode(context),
    );
    return Uint8List.fromList(plain);
  }
}
