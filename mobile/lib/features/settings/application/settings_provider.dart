import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pesoflow/features/workspace/application/finance_controller.dart';
import 'package:pesoflow/features/settings/domain/appearance.dart';

class SettingsController extends Notifier<Appearance> {
  @override
  Appearance build() => ref.watch(workspaceProvider).preferences.appearance;
  Future<void> setAppearance(Appearance appearance) => ref
      .read(financeControllerProvider.notifier)
      .savePreferences(
        ref
            .read(workspaceProvider)
            .preferences
            .copyWith(appearance: appearance),
      );
  Future<void> restoreAppearance() => setAppearance(Appearance.system);
}

final settingsProvider = NotifierProvider<SettingsController, Appearance>(
  SettingsController.new,
);
