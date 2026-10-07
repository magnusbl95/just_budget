import '../../domain/models/app_settings.dart';
import '../../domain/models/person.dart';
import '../services/storage_service.dart';

class SettingsRepository {
  final StorageService _storageService;
  AppSettings _settings = const AppSettings();

  SettingsRepository(this._storageService);

  Future<void> init() async {
    final json = _storageService.getSettingsJson();
    if (json != null) {
      _settings = AppSettings.fromJson(json);
    } else {
      _settings = const AppSettings();
    }
  }

  AppSettings get current => _settings;

  Future<void> update(AppSettings newSettings) async {
    _settings = newSettings;
    await _storageService.saveSettingsJson(_settings.toJson());
  }

  Future<void> addPerson(Person person) async {
    final updatedPeople = [..._settings.people, person];
    await update(_settings.copyWith(people: updatedPeople));
  }

  Future<void> updatePerson(Person updated) async {
    final updatedPeople = _settings.people.map((p) {
      return p.id == updated.id ? updated : p;
    }).toList();
    await update(_settings.copyWith(people: updatedPeople));
  }

  Future<void> deletePerson(String personId) async {
    final updatedPeople = _settings.people.where((p) => p.id != personId).toList();
    await update(_settings.copyWith(people: updatedPeople));
  }
}
