import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/finance_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/demo_notice.dart';

class NoticeCard extends StatelessWidget {
  const NoticeCard({
    required this.notice,
    required this.read,
    required this.onToggleRead,
    required this.onOpen,
    super.key,
  });
  final DemoNotice notice;
  final bool read;
  final VoidCallback onToggleRead;
  final VoidCallback onOpen;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final color = switch (notice.kind) {
      NoticeKind.budget || NoticeKind.connection => c.warning,
      NoticeKind.renewal => c.primary,
      NoticeKind.report => c.accent,
    };
    final soft = switch (notice.kind) {
      NoticeKind.budget || NoticeKind.connection => AppColors.warningSoft,
      NoticeKind.renewal => AppColors.primarySoft,
      NoticeKind.report => AppColors.accentSoft,
    };
    final icon = switch (notice.kind) {
      NoticeKind.budget => Icons.account_balance_wallet_outlined,
      NoticeKind.renewal => Icons.event_repeat_outlined,
      NoticeKind.connection => Icons.account_balance_outlined,
      NoticeKind.report => Icons.analytics_outlined,
    };
    return FinanceCard(
      key: ValueKey('notice-${notice.id}'),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: c.soft(color, soft),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(notice.title, style: AppTypography.merchant),
                    const SizedBox(height: AppSpacing.xs),
                    StatusBadge(
                      read ? 'Read' : 'Unread',
                      foreground: read ? c.mutedInk : c.primary,
                      background: read
                          ? c.mutedSurface
                          : c.soft(c.primary, AppColors.primarySoft),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            notice.message,
            style: AppTypography.bodySmall.copyWith(color: c.secondaryInk),
          ),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xxs,
            children: [
              TextButton(
                key: ValueKey('open-${notice.id}'),
                onPressed: onOpen,
                child: Text(notice.destination.action),
              ),
              TextButton(
                key: ValueKey('read-${notice.id}'),
                onPressed: onToggleRead,
                child: Text(read ? 'Mark unread' : 'Mark read'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
