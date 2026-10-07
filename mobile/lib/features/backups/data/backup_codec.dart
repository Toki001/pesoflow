import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import '../../workspace/data/finance_workspace_codec.dart';
import '../../workspace/domain/finance_workspace.dart';
import '../domain/finance_backup.dart';

/// Portable envelope v1. Device keys, sync ownership and biometric enrollment
/// are deliberately not transferable. All financial data is authenticated.
abstract final class BackupCodec {
  static const iterations = 600000;
  static const header =
      'PesoFlow backup v1|PBKDF2-HMAC-SHA256:600000|AES-256-GCM';
  static Future<Uint8List> seal(FinanceBackup backup, String password) =>
      Isolate.run(() => _seal(backup, password));
  static Future<FinanceBackup> open(Uint8List bytes, String password) =>
      Isolate.run(() => _open(bytes, password));

  static void _password(String value) {
    if (value.trim().length < 12 || utf8.encode(value).length > 1024) {
      throw const BackupFailure(
        'Use a password of at least 12 characters (up to 1,024 UTF-8 bytes).',
      );
    }
  }

  static Future<SecretKey> _key(String password, List<int> salt) =>
      Pbkdf2.hmacSha256(
        iterations: iterations,
        bits: 256,
      ).deriveKey(secretKey: SecretKey(utf8.encode(password)), nonce: salt);
  static Future<Uint8List> _seal(FinanceBackup b, String password) async {
    _password(password);
    final w = b.workspace.copyWith(
      revision: 0,
      sync: const SyncMetadata(),
      preferences: b.workspace.preferences.copyWith(biometrics: false),
    );
    final plain = utf8.encode(
      jsonEncode({
        'createdAt': b.createdAt.toUtc().toIso8601String(),
        'workspace': FinanceWorkspaceCodec.toJson(w),
        'images': {
          for (final e in b.images.entries) e.key: base64Encode(e.value),
        },
      }),
    );
    if (plain.length > maxBackupPlaintextBytes) {
      throw const BackupFailure(
        'This workspace exceeds the 32 MB backup limit.',
      );
    }
    final random = Random.secure();
    final salt = List<int>.generate(16, (_) => random.nextInt(256));
    final box = await AesGcm.with256bits().encrypt(
      plain,
      secretKey: await _key(password, salt),
      aad: utf8.encode(header),
    );
    return Uint8List.fromList(
      utf8.encode(
        jsonEncode({
          'format': 'pesoflow-backup',
          'version': 1,
          'salt': base64Encode(salt),
          'payload': base64Encode(box.concatenation()),
        }),
      ),
    );
  }

  static Future<FinanceBackup> _open(Uint8List bytes, String password) async {
    _password(password);
    try {
      if (bytes.isEmpty || bytes.length > maxBackupBytes) {
        throw const FormatException();
      }
      final e = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
      if (e.length != 4 ||
          e['format'] != 'pesoflow-backup' ||
          e['version'] is! int ||
          e['version'] != 1) {
        throw const FormatException();
      }
      final salt = base64Decode(e['salt'] as String);
      final payload = base64Decode(e['payload'] as String);
      if (salt.length != 16 ||
          payload.length < 28 ||
          payload.length > maxBackupPlaintextBytes + 28) {
        throw const FormatException();
      }
      final plain = await AesGcm.with256bits().decrypt(
        SecretBox.fromConcatenation(payload, nonceLength: 12, macLength: 16),
        secretKey: await _key(password, salt),
        aad: utf8.encode(header),
      );
      final data = jsonDecode(utf8.decode(plain)) as Map<String, dynamic>;
      if (data.length != 3) throw const FormatException();
      final date = DateTime.parse(data['createdAt'] as String);
      if (!date.isUtc || date.toIso8601String() != data['createdAt']) {
        throw const FormatException();
      }
      final raw = data['workspace'] as Map<String, dynamic>;
      final workspace = FinanceWorkspaceCodec.fromJson(raw);
      // Reject fields that an older decoder would silently drop or default.
      if (_canonical(raw) !=
              _canonical(FinanceWorkspaceCodec.toJson(workspace)) ||
          workspace.revision != 0 ||
          workspace.sync.ownerId != null ||
          workspace.sync.serverRevision != 0 ||
          workspace.sync.lastSyncedAt != null ||
          workspace.sync.localRevisionAtSync != 0 ||
          workspace.preferences.biometrics) {
        throw const FormatException();
      }
      return FinanceBackup(workspace, {
        for (final e in (data['images'] as Map<String, dynamic>).entries)
          e.key: base64Decode(e.value as String),
      }, date);
    } catch (_) {
      throw const BackupFailure(
        'Could not open this backup. Check the password and use a complete, supported PesoFlow backup file.',
      );
    }
  }

  static String _canonical(Object? value) => jsonEncode(_sorted(value));
  static Object? _sorted(Object? value) {
    if (value is Map) {
      final keys = value.keys.cast<String>().toList()..sort();
      return {for (final k in keys) k: _sorted(value[k])};
    }
    if (value is List) return value.map(_sorted).toList();
    return value;
  }
}
