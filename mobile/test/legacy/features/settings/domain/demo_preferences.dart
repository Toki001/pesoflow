import 'package:pesoflow/features/settings/domain/appearance.dart';

/// Device demo preferences, never authentication or financial-provider consent.
class DemoPreferences {
  const DemoPreferences({
    this.appearance = Appearance.system,
    this.introductionCompleted = false,
  });

  final Appearance appearance;
  final bool introductionCompleted;
}
