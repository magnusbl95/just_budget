import '../enums/theme_preference.dart';
import 'person.dart';

class AppSettings {
  final String currencySymbol;
  final String currencyCode;
  final ThemePreference themePreference;
  final int seedColorHex;
  final bool isFirstLaunchCompleted;
  final List<Person> people;

  const AppSettings({
    this.currencySymbol = r'$',
    this.currencyCode = 'USD',
    this.themePreference = ThemePreference.system,
    this.seedColorHex = 0xFF006C4C, // Material 3 Emerald
    this.isFirstLaunchCompleted = false,
    this.people = const [],
  });

  Map<String, dynamic> toJson() => {
        'currencySymbol': currencySymbol,
        'currencyCode': currencyCode,
        'themePreference': themePreference.name,
        'seedColorHex': seedColorHex,
        'isFirstLaunchCompleted': isFirstLaunchCompleted,
        'people': people.map((p) => p.toJson()).toList(),
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        currencySymbol: json['currencySymbol'] as String? ?? r'$',
        currencyCode: json['currencyCode'] as String? ?? 'USD',
        themePreference: ThemePreference.values.firstWhere(
          (e) => e.name == json['themePreference'],
          orElse: () => ThemePreference.system,
        ),
        seedColorHex: json['seedColorHex'] as int? ?? 0xFF006C4C,
        isFirstLaunchCompleted: json['isFirstLaunchCompleted'] as bool? ?? false,
        people: (json['people'] as List<dynamic>?)
                ?.map((e) => Person.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
      );

  AppSettings copyWith({
    String? currencySymbol,
    String? currencyCode,
    ThemePreference? themePreference,
    int? seedColorHex,
    bool? isFirstLaunchCompleted,
    List<Person>? people,
  }) =>
      AppSettings(
        currencySymbol: currencySymbol ?? this.currencySymbol,
        currencyCode: currencyCode ?? this.currencyCode,
        themePreference: themePreference ?? this.themePreference,
        seedColorHex: seedColorHex ?? this.seedColorHex,
        isFirstLaunchCompleted:
            isFirstLaunchCompleted ?? this.isFirstLaunchCompleted,
        people: people ?? this.people,
      );
}
