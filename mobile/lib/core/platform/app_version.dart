import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Reads installed package metadata without substituting a sample version.
final appVersionProvider = FutureProvider<String>((ref) async {
  final value = await const MethodChannel('com.pesoflow/app_info')
      .invokeMapMethod<String, String>('version');
  final version = value?['version'];
  final build = value?['build'];
  if (version == null || version.isEmpty || build == null || build.isEmpty) {
    throw StateError('Installed version unavailable.');
  }
  return '$version (Build $build)';
}, retry: (_, _) => null);
