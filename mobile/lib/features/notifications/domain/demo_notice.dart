enum NoticeDestination {
  budgets('/budgets', 'View budgets'),
  subscriptions('/budgets/subscriptions', 'View subscriptions'),
  accounts('/accounts', 'View accounts'),
  analytics('/analytics', 'View analytics');

  const NoticeDestination(this.route, this.action);
  final String route;
  final String action;
}

enum NoticeKind { budget, renewal, connection, report }

enum NoticeFilter { all, unread }

/// Immutable snapshot of a sample event, never a live financial assessment.
class DemoNotice {
  const DemoNotice({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.kind,
    required this.destination,
  });
  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  final NoticeKind kind;
  final NoticeDestination destination;
}
