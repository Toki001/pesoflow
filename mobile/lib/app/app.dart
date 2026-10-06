import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';
import 'theme/app_theme.dart';

class PesoFlowApp extends ConsumerWidget {
  const PesoFlowApp({this.themeMode = ThemeMode.system, super.key});
  final ThemeMode themeMode;
  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
    title: 'PesoFlow Demo',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    themeMode: themeMode,
    routerConfig: ref.watch(routerProvider),
  );
}
