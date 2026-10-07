import '../domain/appearance.dart';
import '../domain/demo_preferences.dart';

abstract final class DemoPreferencesCodec {
  static Map<String, dynamic> encode(DemoPreferences preferences) => {
    'version': 1,
    'appearance': preferences.appearance.name,
    'introductionCompleted': preferences.introductionCompleted,
  };

  static DemoPreferences decode(Map<String, dynamic> json) {
    if (json['version'] is! int || json['version'] != 1) {
      throw const FormatException('Unsupported demo preference format.');
    }
    return DemoPreferences(
      appearance: Appearance.values.byName(json['appearance'] as String),
      introductionCompleted: json['introductionCompleted'] as bool,
    );
  }
}
