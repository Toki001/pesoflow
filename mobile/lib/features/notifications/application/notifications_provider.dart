import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../demo_workspace/application/demo_workspace_providers.dart';
import '../data/notification_fixture.dart';
import '../domain/demo_notice.dart';

final notificationLoaderProvider =
    Provider<Future<List<DemoNotice>> Function()>(
      (ref) =>
          () async => notificationFixture(),
    );

final notificationsProvider = FutureProvider<List<DemoNotice>>((ref) async {
  final notices = await ref.watch(notificationLoaderProvider)();
  final ids = notices.map((n) => n.id).toSet();
  if (ids.length != notices.length || ids.contains('')) {
    throw StateError('Notification identities must be unique and nonempty.');
  }
  final sorted = [...notices]
    ..sort((a, b) {
      final time = b.createdAt.compareTo(a.createdAt);
      return time == 0 ? a.id.compareTo(b.id) : time;
    });
  return List.unmodifiable(sorted);
}, retry: (_, _) => null);

/// Read state hydrates from local storage; previews remain memory-only.
class NoticeReadController extends Notifier<Set<String>> {
  @override
  Set<String> build() => Set.unmodifiable(
    ref.watch(initialDemoWorkspaceProvider)?.noticeReadIds ??
        initialNoticeReadIds,
  );

  void restore(Set<String> readIds) => state = Set.unmodifiable(readIds);

  void setRead(String id, bool read) {
    final notices = ref.read(notificationsProvider).value;
    if (notices == null || !notices.any((n) => n.id == id)) return;
    state = Set.unmodifiable(
      read ? {...state, id} : (state.toSet()..remove(id)),
    );
  }

  void markAllRead() {
    final notices = ref.read(notificationsProvider).value;
    if (notices == null) return;
    state = Set.unmodifiable({...state, ...notices.map((n) => n.id)});
  }
}

final noticeReadProvider = NotifierProvider<NoticeReadController, Set<String>>(
  NoticeReadController.new,
);
final unreadNoticeCountProvider = Provider<int>((ref) {
  final notices =
      ref.watch(notificationsProvider).value ?? const <DemoNotice>[];
  final read = ref.watch(noticeReadProvider);
  return notices.where((n) => !read.contains(n.id)).length;
});

class NoticeFilterController extends Notifier<NoticeFilter> {
  @override
  NoticeFilter build() => NoticeFilter.all;
  void select(NoticeFilter filter) => state = filter;
}

final noticeFilterProvider =
    NotifierProvider<NoticeFilterController, NoticeFilter>(
      NoticeFilterController.new,
    );
