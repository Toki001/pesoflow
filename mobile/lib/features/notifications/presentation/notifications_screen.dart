import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pesoflow/app/theme/app_colors.dart';
import 'package:pesoflow/app/theme/app_spacing.dart';
import 'package:pesoflow/app/theme/app_typography.dart';
import 'package:pesoflow/core/formatting/date_formatter.dart';
import 'package:pesoflow/core/widgets/finance_card.dart';
import 'package:pesoflow/core/widgets/task_screen.dart';

import 'package:pesoflow/features/notifications/application/notifications_provider.dart';
import 'package:pesoflow/features/notifications/domain/notice_view.dart';
import 'package:pesoflow/features/notifications/presentation/widgets/notice_card.dart';

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
      actions: [
        TextButton(
          onPressed: !state.hasValue || unread == 0
              ? null
              : () async {
                  try {
                    await ref.read(noticeReadProvider.notifier).markAllRead();
                  } catch (_) {}
                },
          child: const Text('Mark all read'),
        ),
      ],
      child: SingleChildScrollView(
        key: const PageStorageKey('notifications-scroll'),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                      child: Text(switch (option) {
                        NoticeFilter.all => 'All',
                        NoticeFilter.budget => 'Budget Alerts',
                        NoticeFilter.renewal => 'Bill Reminders',
                        NoticeFilter.unread => 'Unread',
                      }),
                    ),
                  ),
              ],
            ),
            if (state.hasValue) ...[
              const SizedBox(height: AppSpacing.xs),
              Semantics(
                liveRegion: true,
                child: Text(
                  '$unread unread · ${state.value!.length} alerts',
                  style: AppTypography.labelMedium.copyWith(color: c.mutedInk),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            state.when(
              loading: () => Semantics(
                label: 'Loading alerts',
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
                title: "We couldn't load your alerts.",
                message:
                    'Please try again. No financial institution was contacted.',
                action: 'Try Again',
                onAction: () => ref.invalidate(notificationsProvider),
              ),
              data: (notices) {
                final visible = notices
                    .where(
                      (n) => switch (filter) {
                        NoticeFilter.all => true,
                        NoticeFilter.budget => n.kind == NoticeKind.budget,
                        NoticeFilter.renewal => n.kind == NoticeKind.renewal,
                        NoticeFilter.unread => !read.contains(n.id),
                      },
                    )
                    .toList();
                if (notices.isEmpty) {
                  return const _InboxMessage(
                    title: 'No alerts',
                    message: 'There are no financial notices to show.',
                  );
                }
                if (visible.isEmpty) {
                  return _InboxMessage(
                    title: 'No alerts in this filter',
                    message: 'Choose All to see other financial notices.',
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
                        onToggleRead: () async {
                          try {
                            await ref
                                .read(noticeReadProvider.notifier)
                                .setRead(
                                  visible[i].id,
                                  !read.contains(visible[i].id),
                                );
                          } catch (_) {}
                        },
                        onOpen: () async {
                          try {
                            await ref
                                .read(noticeReadProvider.notifier)
                                .setRead(visible[i].id, true);
                          } catch (_) {}
                          if (context.mounted) {
                            await context.push<void>(
                              visible[i].destination.route,
                            );
                          }
                        },
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            TextButton(
              onPressed: () => context.push('/settings'),
              child: const Text('Notification Preferences →'),
            ),
            Text(
              'Alerts appear inside PesoFlow. Device push delivery is not enabled.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(color: c.mutedInk),
            ),
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
