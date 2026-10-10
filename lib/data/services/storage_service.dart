import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  final SharedPreferences _prefs;
  void Function()? _onChanged;
  bool _applyingRemoteSnapshot = false;

  StorageService(this._prefs);

  static Future<StorageService> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  static const String _keySettings = 'just_budget_settings_v1';
  static const String _keyBudgetLines = 'just_budget_lines_v1';
  static const String _keyBudgetItems = 'just_budget_items_v1';
  static const String _keyCategories = 'just_budget_categories_v1';

  void setChangeListener(void Function()? listener) {
    _onChanged = listener;
  }

  Map<String, dynamic> exportSnapshot() => {
        'settings': getSettingsJson(),
        'budgetLines': getBudgetLinesJson(),
        'budgetItems': getBudgetItemsJson(),
        'categories': getCategoriesJson(),
      };

  bool get hasMeaningfulLocalData {
    final settings = getSettingsJson();
    final hasCustomizedSettings = settings != null &&
        ((settings['people'] as List<dynamic>?)?.isNotEmpty == true ||
            settings['isFirstLaunchCompleted'] == true ||
            (settings['currencyCode'] != null &&
                settings['currencyCode'] != 'USD') ||
            (settings['currencySymbol'] != null &&
                settings['currencySymbol'] != r'$') ||
            (settings['themePreference'] != null &&
                settings['themePreference'] != 'system') ||
            (settings['seedColorHex'] != null &&
                settings['seedColorHex'] != 0xFF006C4C));
    return getBudgetLinesJson().isNotEmpty ||
        getBudgetItemsJson().isNotEmpty ||
        getCategoriesJson().any((category) => category['isDefault'] == false) ||
        hasCustomizedSettings;
  }

  Future<void> applySnapshot(Map<String, dynamic> snapshot) async {
    _applyingRemoteSnapshot = true;
    try {
      final settings = snapshot['settings'];
      await saveSettingsJson(
        settings is Map<String, dynamic> ? settings : <String, dynamic>{},
      );
      await saveBudgetLinesJson(_decodeList(snapshot['budgetLines']));
      await saveBudgetItemsJson(_decodeList(snapshot['budgetItems']));
      await saveCategoriesJson(_decodeList(snapshot['categories']));
    } finally {
      _applyingRemoteSnapshot = false;
    }
  }

  List<Map<String, dynamic>> _decodeList(dynamic value) {
    if (value is! List) return [];
    return value
        .whereType<Map>()
        .map((entry) => Map<String, dynamic>.from(entry))
        .toList();
  }

  void _notifyChanged() {
    if (!_applyingRemoteSnapshot) _onChanged?.call();
  }

  // --- Settings ---
  Map<String, dynamic>? getSettingsJson() {
    final raw = _prefs.getString(_keySettings);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveSettingsJson(Map<String, dynamic> data) async {
    await _prefs.setString(_keySettings, jsonEncode(data));
    _notifyChanged();
  }

  // --- Budget Lines ---
  List<Map<String, dynamic>> getBudgetLinesJson() {
    final raw = _prefs.getString(_keyBudgetLines);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => e as Map<String, dynamic>).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveBudgetLinesJson(List<Map<String, dynamic>> list) async {
    await _prefs.setString(_keyBudgetLines, jsonEncode(list));
    _notifyChanged();
  }

  // --- Budget Items ---
  List<Map<String, dynamic>> getBudgetItemsJson() {
    final raw = _prefs.getString(_keyBudgetItems);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => e as Map<String, dynamic>).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveBudgetItemsJson(List<Map<String, dynamic>> list) async {
    await _prefs.setString(_keyBudgetItems, jsonEncode(list));
    _notifyChanged();
  }

  // --- Categories ---
  List<Map<String, dynamic>> getCategoriesJson() {
    final raw = _prefs.getString(_keyCategories);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => e as Map<String, dynamic>).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveCategoriesJson(List<Map<String, dynamic>> list) async {
    await _prefs.setString(_keyCategories, jsonEncode(list));
    _notifyChanged();
  }

  // --- Clear / Reset ---
  Future<void> clearAll() async {
    await _prefs.remove(_keySettings);
    await _prefs.remove(_keyBudgetLines);
    await _prefs.remove(_keyBudgetItems);
    await _prefs.remove(_keyCategories);
    _notifyChanged();
  }
}
