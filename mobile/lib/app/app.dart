import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pesoflow/app/router.dart';
import 'package:pesoflow/app/theme/app_theme.dart';
import 'package:pesoflow/app/theme/app_colors.dart';
import 'package:pesoflow/features/settings/application/settings_provider.dart';
import 'package:pesoflow/features/settings/domain/appearance.dart';
import 'package:pesoflow/features/workspace/presentation/finance_storage_boundary.dart';

class PesoFlowApp extends ConsumerWidget {
  const PesoFlowApp({this.themeMode, super.key});

  /// Optional fixed appearance for previews and visual regression tests.
  final ThemeMode? themeMode;
  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
    title: 'PesoFlow',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.forAccessibility(
      Brightness.light,
      reduceMotion: MediaQuery.maybeDisableAnimationsOf(context) ?? false,
    ),
    darkTheme: AppTheme.forAccessibility(
      Brightness.dark,
      reduceMotion: MediaQuery.maybeDisableAnimationsOf(context) ?? false,
    ),
    themeAnimationDuration:
        (MediaQuery.maybeDisableAnimationsOf(context) ?? false)
        ? Duration.zero
        : kThemeAnimationDuration,
    themeMode:
        themeMode ??
        switch (ref.watch(settingsProvider)) {
          Appearance.system => ThemeMode.system,
          Appearance.light => ThemeMode.light,
          Appearance.dark => ThemeMode.dark,
        },
    routerConfig: ref.watch(routerProvider),
    builder: (context, child) {
      final dark = context.colors.canvas.computeLuminance() < .5;
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemStatusBarContrastEnforced: false,
          statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
          statusBarBrightness: dark ? Brightness.dark : Brightness.light,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarDividerColor: Colors.transparent,
          systemNavigationBarContrastEnforced: false,
          systemNavigationBarIconBrightness: dark
              ? Brightness.light
              : Brightness.dark,
        ),
        child: FinanceStorageBoundary(child: child!),
      );
    },
  );
}
