import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../features/notifications/presentation/widgets/notification_button.dart';

class MainAppBar extends StatelessWidget {
  const MainAppBar(this.title, {super.key});
  final String title;
  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 56),
    color: context.colors.surface,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    child: Row(
      children: [
        Expanded(child: Text(title, style: AppTypography.headlineSmall)),
        const NotificationButton(showUnreadDot: true),
        IconButton(
          tooltip: 'Settings',
          onPressed: () => context.push('/settings'),
          icon: const Icon(Icons.settings_outlined),
        ),
      ],
    ),
  );
}
