/// Strict decoding at storage and API boundaries. Never truncate money from num.
typedef Json = Map<String, dynamic>;

int jsonInt(Json json, String key, {int? min, int? max}) {
  final value = json[key];
  if (value is! int ||
      (min != null && value < min) ||
      (max != null && value > max)) {
    throw FormatException('Invalid integer: $key.');
  }
  return value;
}

String jsonString(Json json, String key, {int max = 1000, bool empty = false}) {
  final value = json[key];
  if (value is! String ||
      value.length > max ||
      (!empty && value.trim().isEmpty)) {
    throw FormatException('Invalid text: $key.');
  }
  return value;
}

DateTime jsonDate(Json json, String key) {
  final value = jsonString(json, key);
  final date = DateTime.tryParse(value);
  if (date == null || date.toIso8601String() != value) {
    throw FormatException('Invalid date: $key.');
  }
  return date;
}

List<Json> jsonObjects(Json json, String key) =>
    (json[key] as List).map((e) => e as Json).toList();

const maxMoney = 99999999999;
