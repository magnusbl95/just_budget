import '../../domain/models/category.dart';
import '../services/storage_service.dart';

class CategoryRepository {
  final StorageService _storageService;
  List<Category> _categories = [];

  CategoryRepository(this._storageService);

  Future<void> init() async {
    final listJson = _storageService.getCategoriesJson();
    if (listJson.isEmpty) {
      _categories = Category.defaultCategories;
      await _persist();
    } else {
      _categories = listJson.map((e) => Category.fromJson(e)).toList();
    }
  }

  Future<void> reload() => init();

  List<Category> getAll() => List.unmodifiable(_categories);

  Category? getById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> add(Category category) async {
    _categories.add(category);
    await _persist();
  }

  Future<void> _persist() async {
    await _storageService.saveCategoriesJson(
      _categories.map((c) => c.toJson()).toList(),
    );
  }
}
