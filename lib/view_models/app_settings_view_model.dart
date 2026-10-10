import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../domain/enums/theme_preference.dart';
import '../../domain/models/app_settings.dart';
import '../../domain/models/person.dart';
import '../data/repositories/settings_repository.dart';

class AppSettingsViewModel extends ChangeNotifier {
  final SettingsRepository _repository;
  final _uuid = const Uuid();

  AppSettingsViewModel(this._repository);

  AppSettings get settings => _repository.current;

  void notifyDataChanged() => notifyListeners();

  ThemeMode get themeMode {
    switch (settings.themePreference) {
      case ThemePreference.light:
        return ThemeMode.light;
      case ThemePreference.dark:
        return ThemeMode.dark;
      case ThemePreference.system:
        return ThemeMode.system;
    }
  }

  String get currencySymbol => settings.currencySymbol;
  String get currencyCode => settings.currencyCode;
  List<Person> get people => settings.people;
  bool get isFirstLaunchCompleted => settings.isFirstLaunchCompleted;

  Future<void> setThemePreference(ThemePreference pref) async {
    await _repository.update(settings.copyWith(themePreference: pref));
    notifyListeners();
  }

  Future<void> setCurrency(String symbol, String code) async {
    await _repository.update(settings.copyWith(
      currencySymbol: symbol,
      currencyCode: code,
    ));
    notifyListeners();
  }

  Future<void> setSeedColor(int colorHex) async {
    await _repository.update(settings.copyWith(seedColorHex: colorHex));
    notifyListeners();
  }

  Future<Person> addPerson(String name, [int colorHex = 0xFF006C4C]) async {
    final person = Person(
      id: _uuid.v4(),
      name: name.trim(),
      colorHex: colorHex,
    );
    await _repository.addPerson(person);
    notifyListeners();
    return person;
  }

  Future<void> updatePerson(Person updated) async {
    await _repository.updatePerson(updated);
    notifyListeners();
  }

  Future<void> deletePerson(String personId) async {
    await _repository.deletePerson(personId);
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    await _repository.update(settings.copyWith(isFirstLaunchCompleted: true));
    notifyListeners();
  }

  Person? getPersonById(String id) {
    try {
      return people.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
