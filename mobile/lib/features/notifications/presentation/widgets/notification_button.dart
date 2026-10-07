import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../application/notifications_provider.dart';

/// Preserves each approved header's bell; Home alone uses its existing dot.
class NotificationButton extends ConsumerWidget {
  const NotificationButton({this.showUnreadDot = false, this.color, super.key});
  final bool showUnreadDot;
  final Color? color;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadNoticeCountProvider);
    final icon = Icon(Icons.notifications_none, size: 20, color: color);
    return IconButton(
      tooltip: 'Notifications',
      onPressed: () => context.push('/notifications'),
      icon: Semantics(
        label: '$unread unread demo alerts',
        child: showUnreadDot
            ? Badge(
                smallSize: 7,
                backgroundColor: context.colors.primary,
                isLabelVisible: unread > 0,
                child: icon,
              )
            : icon,
      ),
    );
  }
}
