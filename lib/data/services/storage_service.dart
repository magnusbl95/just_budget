import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  static const String _keySettings = 'just_budget_settings_v1';
  static const String _keyBudgetLines = 'just_budget_lines_v1';
  static const String _keyBudgetItems = 'just_budget_items_v1';
  static const String _keyCategories = 'just_budget_categories_v1';

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
  }

  // --- Clear / Reset ---
  Future<void> clearAll() async {
    await _prefs.remove(_keySettings);
    await _prefs.remove(_keyBudgetLines);
    await _prefs.remove(_keyBudgetItems);
    await _prefs.remove(_keyCategories);
  }
}
