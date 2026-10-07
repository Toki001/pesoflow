import '../../../core/serialization/values.dart';
import 'demo_notice.dart';

class FinancialNotice {
  const FinancialNotice({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.kind,
    required this.destination,
    required this.conditionKey,
  });
  final String id, title, message, conditionKey;
  final DateTime createdAt;
  final NoticeKind kind;
  final NoticeDestination destination;
  Json toJson() => {
    'id': id,
    'title': title,
    'message': message,
    'createdAt': createdAt.toIso8601String(),
    'kind': kind.name,
    'destination': destination.name,
    'conditionKey': conditionKey,
  };
  factory FinancialNotice.fromJson(Json json) => FinancialNotice(
    id: jsonString(json, 'id'),
    title: jsonString(json, 'title', max: 160),
    message: jsonString(json, 'message'),
    createdAt: jsonDate(json, 'createdAt'),
    kind: NoticeKind.values.byName(json['kind'] as String),
    destination: NoticeDestination.values.byName(json['destination'] as String),
    conditionKey: jsonString(json, 'conditionKey'),
  );
}
