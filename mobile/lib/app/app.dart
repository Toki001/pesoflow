import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';
import 'theme/app_theme.dart';
import '../features/settings/application/settings_provider.dart';
import '../features/settings/domain/appearance.dart';

class PesoFlowApp extends ConsumerWidget {
  const PesoFlowApp({this.themeMode, super.key});

  /// Optional fixed appearance for previews and visual regression tests.
  final ThemeMode? themeMode;
  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
    title: 'PesoFlow Demo',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    themeMode:
        themeMode ??
        switch (ref.watch(settingsProvider)) {
          Appearance.system => ThemeMode.system,
          Appearance.light => ThemeMode.light,
          Appearance.dark => ThemeMode.dark,
        },
    routerConfig: ref.watch(routerProvider),
  );
}
