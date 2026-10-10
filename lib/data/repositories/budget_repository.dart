import '../../domain/models/budget.dart';
import '../../domain/models/budget_item.dart';
import '../../domain/models/budget_line.dart';
import '../services/storage_service.dart';

class BudgetRepository {
  final StorageService _storageService;

  List<BudgetItem> _items = [];
  List<BudgetLine> _lines = [];

  BudgetRepository(this._storageService);

  Future<void> init() async {
    final linesJson = _storageService.getBudgetLinesJson();
    final itemsJson = _storageService.getBudgetItemsJson();

    _items = itemsJson.map((e) => BudgetItem.fromJson(e)).toList();
    _lines = linesJson.map((e) => BudgetLine.fromJson(e)).toList();
  }

  Future<void> reload() => init();

  /// Reassembles the living Budget aggregate
  Budget getBudget({String name = 'Running Budget'}) {
    final direct = _items.where((i) => i.isStandalone).toList();

    final assembledLines = _lines.map((line) {
      final childItems = _items.where((i) => i.budgetLineId == line.id).toList();
      return line.copyWith(items: childItems);
    }).toList();

    return Budget(
      id: 'default_running_budget',
      name: name,
      directItems: direct,
      lines: assembledLines,
    );
  }

  List<BudgetItem> getAllItems() => List.unmodifiable(_items);
  List<BudgetLine> getAllLines() => List.unmodifiable(_lines);

  // --- BudgetItem CRUD ---
  Future<void> addBudgetItem(BudgetItem item) async {
    _items.add(item);
    await _persistItems();
  }

  Future<void> updateBudgetItem(BudgetItem updated) async {
    final index = _items.indexWhere((i) => i.id == updated.id);
    if (index != -1) {
      _items[index] = updated;
      await _persistItems();
    }
  }

  Future<void> deleteBudgetItem(String itemId) async {
    _items.removeWhere((i) => i.id == itemId);
    await _persistItems();
  }

  // --- BudgetLine CRUD ---
  Future<void> addBudgetLine(BudgetLine line) async {
    _lines.add(line);
    await _persistLines();
  }

  Future<void> updateBudgetLine(BudgetLine updated) async {
    final index = _lines.indexWhere((l) => l.id == updated.id);
    if (index != -1) {
      _lines[index] = updated;
      await _persistLines();
    }
  }

  Future<void> deleteBudgetLine(String lineId, {bool deleteChildren = false}) async {
    _lines.removeWhere((l) => l.id == lineId);
    if (deleteChildren) {
      _items.removeWhere((i) => i.budgetLineId == lineId);
    } else {
      // Revert children to standalone
      _items = _items.map((i) {
        if (i.budgetLineId == lineId) {
          return i.copyWith(clearBudgetLine: true);
        }
        return i;
      }).toList();
    }
    await _persistLines();
    await _persistItems();
  }

  Future<void> clearAll() async {
    _items.clear();
    _lines.clear();
    await _persistItems();
    await _persistLines();
  }

  Future<void> _persistItems() async {
    await _storageService.saveBudgetItemsJson(
      _items.map((i) => i.toJson()).toList(),
    );
  }

  Future<void> _persistLines() async {
    await _storageService.saveBudgetLinesJson(
      _lines.map((l) => l.toJson()).toList(),
    );
  }
}
