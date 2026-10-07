import 'package:pesoflow/core/formatting/money_formatter.dart';
import 'package:pesoflow/features/notifications/domain/notice_view.dart';

// Bump and explicitly migrate when removing IDs or changing their event meaning.
const demoNoticeCatalogVersion = 1;
const initialNoticeReadIds = <String>{'spending-review'};

List<NoticeView> notificationFixture() => [
  NoticeView(
    id: 'food-limit',
    title: 'Food budget is approaching its limit',
    message:
        'Sample snapshot: ${MoneyFormatter.php(690000)} spent against an ${MoneyFormatter.php(800000)} Food & Dining limit. Review your plan for the rest of October.',
    createdAt: DateTime(2024, 10, 24, 12),
    kind: NoticeKind.budget,
    destination: NoticeDestination.budgets,
  ),
  NoticeView(
    id: 'netflix-renewal',
    title: 'Netflix renewal is coming up',
    message:
        'Sample plan: Netflix Standard renews on October 28 for ${MoneyFormatter.php(54900)}. Review the recorded plan and payment source.',
    createdAt: DateTime(2024, 10, 24, 9),
    kind: NoticeKind.renewal,
    destination: NoticeDestination.subscriptions,
  ),
  NoticeView(
    id: 'bpi-attention',
    title: 'A sample account needs attention',
    message: 'The BPI Savings profile demonstrates an expired connection. View its sample status; no real bank session or credentials are involved.',
    createdAt: DateTime(2024, 10, 23, 15),
    kind: NoticeKind.connection,
    destination: NoticeDestination.accounts,
  ),
  NoticeView(
    id: 'spending-review',
    title: 'Review your October spending',
    message: 'Explore the sample category breakdown, spending trajectory and comparisons in Analytics.',
    createdAt: DateTime(2024, 10, 23, 10),
    kind: NoticeKind.report,
    destination: NoticeDestination.analytics,
  ),
];
