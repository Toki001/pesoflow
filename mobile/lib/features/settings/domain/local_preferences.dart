import '../../../core/serialization/values.dart';
import 'appearance.dart';

const supportedCurrencies = ['PHP', 'USD', 'EUR', 'GBP', 'SGD', 'AUD'];
const supportedLocales = ['en_PH', 'en_US'];

class LocalPreferences {
  const LocalPreferences({
    this.currency = 'PHP',
    this.locale = 'en_PH',
    this.appearance = Appearance.system,
    this.notifications = true,
    this.budgetAlerts = true,
    this.renewalAlerts = true,
    this.unusualSpendingAlerts = true,
  });
  final String currency, locale;
  final Appearance appearance;
  final bool notifications, budgetAlerts, renewalAlerts, unusualSpendingAlerts;

  LocalPreferences copyWith({
    String? currency,
    String? locale,
    Appearance? appearance,
    bool? notifications,
    bool? budgetAlerts,
    bool? renewalAlerts,
    bool? unusualSpendingAlerts,
  }) => LocalPreferences(
    currency: currency ?? this.currency,
    locale: locale ?? this.locale,
    appearance: appearance ?? this.appearance,
    notifications: notifications ?? this.notifications,
    budgetAlerts: budgetAlerts ?? this.budgetAlerts,
    renewalAlerts: renewalAlerts ?? this.renewalAlerts,
    unusualSpendingAlerts: unusualSpendingAlerts ?? this.unusualSpendingAlerts,
  );

  void validate() {
    if (!supportedCurrencies.contains(currency) ||
        !supportedLocales.contains(locale)) {
      throw const FormatException('Unsupported preferences.');
    }
  }

  Json toJson() => {
    'currency': currency,
    'locale': locale,
    'appearance': appearance.name,
    'notifications': notifications,
    'budgetAlerts': budgetAlerts,
    'renewalAlerts': renewalAlerts,
    'unusualSpendingAlerts': unusualSpendingAlerts,
  };
  factory LocalPreferences.fromJson(Json json) => LocalPreferences(
    currency: jsonString(json, 'currency'),
    locale: jsonString(json, 'locale'),
    appearance: Appearance.values.byName(json['appearance'] as String),
    notifications: json['notifications'] as bool,
    budgetAlerts: json['budgetAlerts'] as bool,
    renewalAlerts: json['renewalAlerts'] as bool,
    unusualSpendingAlerts: json['unusualSpendingAlerts'] as bool,
  );
}
