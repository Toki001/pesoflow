import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/identity/new_id.dart';
import '../domain/receipt_image.dart';
import 'prepare_receipt_image.dart';

class NativeReceiptImages implements ReceiptImages {
  final _picker = ImagePicker();
  final _owned = <String>{};
  bool _cleaned = false;
  void _supported() {
    if (!Platform.isAndroid && !Platform.isIOS) {
      throw const ReceiptFailure(
        'Receipt scanning is supported on Android and iPhone.',
      );
    }
  }

  Future<Directory> _directory() async {
    final dir = Directory(
      '${(await getTemporaryDirectory()).path}/pesoflow-receipt-work',
    );
    await dir.create(recursive: true);
    if (!_cleaned) {
      _cleaned = true;
      // Previous process's unsaved staging files. Android picker recovery is
      // elsewhere in its own cache and is not removed here.
      await for (final file in dir.list()) {
        if (file is File && !_owned.contains(file.path)) await file.delete();
      }
    }
    return dir;
  }

  Future<void> _removePluginCopy(String path) async {
    final temp = (await getTemporaryDirectory()).absolute.path;
    final file = File(path).absolute;
    // Never remove a gallery original or an external file-provider document.
    if (file.path.startsWith('$temp/') && await file.exists()) {
      await file.delete();
    }
  }

  Future<ReceiptImage> _prepare(String path) async {
    try {
      final source = File(path);
      if (await source.length() > maxReceiptInputBytes) {
        throw const ReceiptFailure('Choose an image smaller than 25 MB.');
      }
      final bytes = await prepareReceiptImage(await source.readAsBytes());
      final dir = await _directory();
      final file = File('${dir.path}/${newId()}.jpg');
      _owned.add(file.path);
      try {
        await file.writeAsBytes(bytes, flush: true);
      } catch (_) {
        _owned.remove(file.path);
        try {
          if (await file.exists()) await file.delete();
        } catch (_) {
          // Retry any partial staging-file cleanup next session.
        }
        rethrow;
      }
      return ReceiptImage(file.path, bytes);
    } finally {
      try {
        await _removePluginCopy(path);
      } catch (_) {
        // Cleanup failure must not discard the prepared image.
      }
    }
  }

  Future<T> _safe<T>(Future<T> Function() action) async {
    try {
      _supported();
      return await action();
    } on ReceiptFailure {
      rethrow;
    } on PlatformException catch (e) {
      throw imagePlatformFailure(e.code);
    } catch (_) {
      throw const ReceiptFailure(
        'The image could not be prepared. Please try another photo.',
      );
    }
  }

  @override
  Future<ReceiptImage?> acquire(ReceiptImageSource source) => _safe(() async {
    if (source == ReceiptImageSource.camera) {
      var status = await Permission.camera.status;
      if (status.isPermanentlyDenied || status.isRestricted) {
        throw const ReceiptFailure(
          'Camera access is disabled. Allow Camera for PesoFlow in device Settings, or select a photo.',
          settings: true,
        );
      }
      if (!status.isGranted) status = await Permission.camera.request();
      if (!status.isGranted) {
        throw ReceiptFailure(
          status.isPermanentlyDenied || status.isRestricted
              ? 'Camera access is disabled. Open device Settings to allow it, or select a photo.'
              : 'Camera permission was denied. Try again or select a photo.',
          settings: status.isPermanentlyDenied || status.isRestricted,
        );
      }
    }
    final file = await _picker.pickImage(
      source: source == ReceiptImageSource.camera
          ? ImageSource.camera
          : ImageSource.gallery,
      maxWidth: 4000,
      maxHeight: 4000,
      imageQuality: 95,
      requestFullMetadata: false,
    );
    return file == null ? null : _prepare(file.path);
  });
  @override
  Future<ReceiptImage?> recover() => _safe(() async {
    await _directory();
    if (!Platform.isAndroid) return null;
    final result = await _picker.retrieveLostData();
    if (result.exception != null) throw result.exception!;
    final files = result.files;
    if (files == null || files.isEmpty) return null;
    return _prepare(files.first.path);
  });
  @override
  Future<ReceiptImage?> crop(ReceiptImage receipt) => _safe(() async {
    final file = await ImageCropper().cropImage(
      sourcePath: receipt.path,
      maxWidth: 3000,
      maxHeight: 3000,
      compressQuality: 95,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Adjust receipt',
          lockAspectRatio: false,
        ),
        IOSUiSettings(title: 'Adjust receipt'),
      ],
    );
    return file == null ? null : _prepare(file.path);
  });
  @override
  Future<void> release(ReceiptImage image) async {
    if (_owned.remove(image.path)) {
      try {
        final file = File(image.path);
        if (await file.exists()) await file.delete();
      } catch (_) {
        /* Retry stale-file cleanup on next scan session. */
      }
    }
  }

  @override
  Future<void> openSettings() async {
    if (!await openAppSettings()) {
      throw const ReceiptFailure(
        'Open device Settings and choose PesoFlow to manage Camera access.',
      );
    }
  }
}

ReceiptFailure imagePlatformFailure(String code) => switch (code) {
  'camera_access_denied' => const ReceiptFailure(
    'Camera permission was denied. Allow Camera in device Settings or select a photo.',
    settings: true,
  ),
  'camera_access_restricted' ||
  'photo_access_restricted' => const ReceiptFailure(
    'Access is restricted by device settings. Choose another input method or review Settings.',
    settings: true,
  ),
  'photo_access_denied' => const ReceiptFailure(
    'Photo access was denied. Choose an allowed photo or review device Settings.',
    settings: true,
  ),
  'no_available_camera' || 'camera_unavailable' => const ReceiptFailure(
    'No camera is available. Select an existing receipt photo.',
  ),
  _ => const ReceiptFailure(
    'Capture could not finish. Your current review is unchanged. Please try again.',
  ),
};
