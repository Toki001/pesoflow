import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/appearance.dart';

/// Local appearance preference. No disk writes or financial state changes.
class SettingsController extends Notifier<Appearance> {
  @override
  Appearance build() => Appearance.system;

  void setAppearance(Appearance appearance) => state = appearance;
  void restoreAppearance() => state = Appearance.system;
}

final settingsProvider = NotifierProvider<SettingsController, Appearance>(
  SettingsController.new,
);
