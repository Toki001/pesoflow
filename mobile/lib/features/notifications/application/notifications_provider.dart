import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pesoflow/features/workspace/application/finance_controller.dart';
import 'package:pesoflow/features/notifications/domain/notice_view.dart';

final notificationsProvider = FutureProvider<List<NoticeView>>(
  (ref) async => [
    for (final n in ref.watch(workspaceProvider).notices)
      NoticeView(
        id: n.id,
        title: n.title,
        message: n.message,
        createdAt: n.createdAt,
        kind: n.kind,
        destination: n.destination,
      ),
  ],
  retry: (_, _) => null,
);

class NoticeReadController extends Notifier<Set<String>> {
  @override
  Set<String> build() => ref.watch(workspaceProvider).noticeReadIds;
  Future<void> setRead(String id, bool read) =>
      ref.read(financeControllerProvider.notifier).setNoticeRead(id, read);
  Future<void> markAllRead() =>
      ref.read(financeControllerProvider.notifier).markAllRead();
}

final noticeReadProvider = NotifierProvider<NoticeReadController, Set<String>>(
  NoticeReadController.new,
);
final unreadNoticeCountProvider = Provider<int>((ref) {
  final w = ref.watch(workspaceProvider);
  return w.notices.where((n) => !w.noticeReadIds.contains(n.id)).length;
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
