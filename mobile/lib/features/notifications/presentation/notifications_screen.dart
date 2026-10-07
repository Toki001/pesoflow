import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/formatting/date_formatter.dart';
import '../../../core/widgets/finance_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/task_screen.dart';
import '../../demo_workspace/application/demo_workspace_providers.dart';
import '../application/notifications_provider.dart';
import '../domain/demo_notice.dart';
import 'widgets/notice_card.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationsProvider);
    final read = ref.watch(noticeReadProvider);
    final unread = ref.watch(unreadNoticeCountProvider);
    final filter = ref.watch(noticeFilterProvider);
    final c = context.colors;
    return TaskScreen(
      title: 'Notifications',
      backIcon: Icons.arrow_back,
      backTooltip: 'Back',
      fallbackRoute: '/home',
      child: SingleChildScrollView(
        key: const PageStorageKey('notifications-scroll'),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FinanceCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StatusBadge(
                    'Demo alerts',
                    foreground: c.primary,
                    background: c.soft(c.primary, AppColors.primarySoft),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'A calm place to catch up',
                    style: AppTypography.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    ref.watch(demoPersistenceEnabledProvider)
                        ? 'Fixed sample events from October 2024. These snapshots do not update with your edits. Read markers stay on this device after restart. No push notifications or live financial monitoring are active.'
                        : 'Fixed sample events from October 2024. These snapshots do not update with your edits. No push notifications or live financial monitoring are active.',
                    style: AppTypography.bodySmall.copyWith(
                      color: c.secondaryInk,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                for (final option in NoticeFilter.values)
                  Semantics(
                    selected: option == filter,
                    child: OutlinedButton(
                      onPressed: () => ref
                          .read(noticeFilterProvider.notifier)
                          .select(option),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: option == filter
                            ? c.soft(c.primary, AppColors.primarySoft)
                            : c.surface,
                        foregroundColor: option == filter
                            ? c.primary
                            : c.secondaryInk,
                      ),
                      child: Text(
                        option == NoticeFilter.all ? 'All' : 'Unread',
                      ),
                    ),
                  ),
                TextButton(
                  onPressed: !state.hasValue || unread == 0
                      ? null
                      : ref.read(noticeReadProvider.notifier).markAllRead,
                  child: const Text('Mark all read'),
                ),
              ],
            ),
            if (state.hasValue) ...[
              const SizedBox(height: AppSpacing.xs),
              Semantics(
                liveRegion: true,
                child: Text(
                  '$unread unread · ${state.value!.length} sample alerts',
                  style: AppTypography.labelMedium.copyWith(color: c.mutedInk),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            state.when(
              loading: () => Semantics(
                label: 'Loading demo alerts',
                child: Column(
                  children: [
                    for (var i = 0; i < 3; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: FinanceCard(
                          child: SizedBox(
                            height: 100,
                            width: double.infinity,
                            child: ColoredBox(color: c.mutedSurface),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              error: (_, _) => _InboxMessage(
                title: "We couldn't load your sample alerts.",
                message:
                    'Please try again. No financial institution was contacted.',
                action: 'Try Again',
                onAction: () => ref.invalidate(notificationsProvider),
              ),
              data: (notices) {
                final visible = notices
                    .where(
                      (n) => filter == NoticeFilter.all || !read.contains(n.id),
                    )
                    .toList();
                if (notices.isEmpty) {
                  return const _InboxMessage(
                    title: 'No demo alerts',
                    message: 'There are no sample events to show.',
                  );
                }
                if (visible.isEmpty) {
                  return _InboxMessage(
                    title: 'You’re all caught up',
                    message: 'All sample alerts are marked as read.',
                    action: 'View all alerts',
                    onAction: () => ref
                        .read(noticeFilterProvider.notifier)
                        .select(NoticeFilter.all),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < visible.length; i++) ...[
                      if (i == 0 ||
                          DateUtils.dateOnly(visible[i].createdAt) !=
                              DateUtils.dateOnly(visible[i - 1].createdAt))
                        Padding(
                          padding: const EdgeInsets.only(
                            top: AppSpacing.xs,
                            bottom: AppSpacing.sm,
                          ),
                          child: Semantics(
                            header: true,
                            child: Text(
                              DateFormatter.header(visible[i].createdAt),
                              style: AppTypography.labelMedium.copyWith(
                                color: c.mutedInk,
                              ),
                            ),
                          ),
                        ),
                      NoticeCard(
                        notice: visible[i],
                        read: read.contains(visible[i].id),
                        onToggleRead: () => ref
                            .read(noticeReadProvider.notifier)
                            .setRead(
                              visible[i].id,
                              !read.contains(visible[i].id),
                            ),
                        onOpen: () {
                          ref
                              .read(noticeReadProvider.notifier)
                              .setRead(visible[i].id, true);
                          context.push(visible[i].destination.route);
                        },
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _InboxMessage extends StatelessWidget {
  const _InboxMessage({
    required this.title,
    required this.message,
    this.action,
    this.onAction,
  });
  final String title;
  final String message;
  final String? action;
  final VoidCallback? onAction;
  @override
  Widget build(BuildContext context) => FinanceCard(
    padding: const EdgeInsets.all(AppSpacing.lg),
    child: Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTypography.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          message,
          textAlign: TextAlign.center,
          style: AppTypography.bodySmall.copyWith(
            color: context.colors.secondaryInk,
          ),
        ),
        if (action != null)
          TextButton(onPressed: onAction, child: Text(action!)),
      ],
    ),
  );
}
