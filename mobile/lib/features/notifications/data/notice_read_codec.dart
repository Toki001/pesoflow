import 'notification_fixture.dart';

/// Read markers for a fixed demo catalog, never notification delivery state.
abstract final class NoticeReadCodec {
  static Map<String, dynamic> encode(Set<String> readIds) {
    _validate(readIds);
    return {
      'version': 1,
      'catalogVersion': demoNoticeCatalogVersion,
      'readIds': readIds.toList()..sort(),
    };
  }

  static Set<String> decode(Map<String, dynamic> json) {
    if (json['version'] is! int ||
        json['version'] != 1 ||
        json['catalogVersion'] is! int ||
        json['catalogVersion'] != demoNoticeCatalogVersion) {
      throw const FormatException('Unsupported demo alert catalog.');
    }
    final ids = (json['readIds'] as List).cast<String>();
    final readIds = ids.toSet();
    if (ids.length != readIds.length) {
      throw const FormatException('Duplicate demo alert marker.');
    }
    _validate(readIds);
    return Set.unmodifiable(readIds);
  }

  static void _validate(Set<String> readIds) {
    final known = notificationFixture().map((notice) => notice.id).toSet();
    if (!known.containsAll(readIds)) {
      throw const FormatException('Unknown demo alert marker.');
    }
  }
}
