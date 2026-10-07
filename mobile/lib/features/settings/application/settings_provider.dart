import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../demo_workspace/application/demo_workspace_providers.dart';
import '../domain/appearance.dart';

/// Hydrated appearance; the workspace coordinator handles durable demo saves.
class SettingsController extends Notifier<Appearance> {
  @override
  Appearance build() =>
      ref.watch(initialDemoWorkspaceProvider)?.preferences.appearance ??
      Appearance.system;

  void setAppearance(Appearance appearance) => state = appearance;
  void restoreAppearance() => state = Appearance.system;
}

final settingsProvider = NotifierProvider<SettingsController, Appearance>(
  SettingsController.new,
);
