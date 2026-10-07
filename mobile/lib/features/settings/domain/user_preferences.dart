import '../../../core/serialization/values.dart';
import 'appearance.dart';

const supportedCurrencies = ['PHP', 'USD', 'EUR', 'GBP', 'SGD', 'AUD'];
const supportedLocales = ['en_PH', 'en_US'];

class UserPreferences {
  const UserPreferences({
    this.name = '',
    this.currency = 'PHP',
    this.locale = 'en_PH',
    this.appearance = Appearance.system,
    this.onboardingCompleted = false,
    this.biometrics = false,
    this.notifications = true,
    this.budgetAlerts = true,
    this.renewalAlerts = true,
    this.unusualSpendingAlerts = true,
    this.syncAlerts = true,
  });
  final String name, currency, locale;
  final Appearance appearance;
  final bool onboardingCompleted,
      biometrics,
      notifications,
      budgetAlerts,
      renewalAlerts,
      unusualSpendingAlerts,
      syncAlerts;

  UserPreferences copyWith({
    String? name,
    String? currency,
    String? locale,
    Appearance? appearance,
    bool? onboardingCompleted,
    bool? biometrics,
    bool? notifications,
    bool? budgetAlerts,
    bool? renewalAlerts,
    bool? unusualSpendingAlerts,
    bool? syncAlerts,
  }) => UserPreferences(
    name: name ?? this.name,
    currency: currency ?? this.currency,
    locale: locale ?? this.locale,
    appearance: appearance ?? this.appearance,
    onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    biometrics: biometrics ?? this.biometrics,
    notifications: notifications ?? this.notifications,
    budgetAlerts: budgetAlerts ?? this.budgetAlerts,
    renewalAlerts: renewalAlerts ?? this.renewalAlerts,
    unusualSpendingAlerts: unusualSpendingAlerts ?? this.unusualSpendingAlerts,
    syncAlerts: syncAlerts ?? this.syncAlerts,
  );

  void validate() {
    if (name.length > 80 ||
        !supportedCurrencies.contains(currency) ||
        !supportedLocales.contains(locale)) {
      throw const FormatException('Unsupported preferences.');
    }
  }

  Json toJson() => {
    'name': name,
    'currency': currency,
    'locale': locale,
    'appearance': appearance.name,
    'onboardingCompleted': onboardingCompleted,
    'biometrics': biometrics,
    'notifications': notifications,
    'budgetAlerts': budgetAlerts,
    'renewalAlerts': renewalAlerts,
    'unusualSpendingAlerts': unusualSpendingAlerts,
    'syncAlerts': syncAlerts,
  };
  factory UserPreferences.fromJson(Json json) => UserPreferences(
    name: jsonString(json, 'name', empty: true, max: 80),
    currency: jsonString(json, 'currency'),
    locale: jsonString(json, 'locale'),
    appearance: Appearance.values.byName(json['appearance'] as String),
    onboardingCompleted: json['onboardingCompleted'] as bool,
    biometrics: json['biometrics'] as bool,
    notifications: json['notifications'] as bool,
    budgetAlerts: json['budgetAlerts'] as bool,
    renewalAlerts: json['renewalAlerts'] as bool,
    unusualSpendingAlerts: json['unusualSpendingAlerts'] as bool,
    syncAlerts: json['syncAlerts'] as bool,
  );
}
