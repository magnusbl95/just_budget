import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../domain/enums/budget_activity.dart';
import '../../domain/enums/budget_item_timeline.dart';
import '../../domain/models/budget.dart';
import '../../domain/models/budget_item.dart';
import '../../domain/models/budget_line.dart';
import '../../domain/models/category.dart';
import '../data/repositories/budget_repository.dart';
import '../data/repositories/category_repository.dart';

class BudgetViewModel extends ChangeNotifier {
  final BudgetRepository _budgetRepo;
  final CategoryRepository _categoryRepo;
  final _uuid = const Uuid();

  String? _selectedPersonId; // null = All People

  BudgetViewModel({
    required BudgetRepository budgetRepo,
    required CategoryRepository categoryRepo,
  })  : _budgetRepo = budgetRepo,
        _categoryRepo = categoryRepo;

  String? get selectedPersonId => _selectedPersonId;

  void notifyDataChanged() => notifyListeners();

  void selectPerson(String? personId) {
    _selectedPersonId = personId;
    notifyListeners();
  }

  Budget get budget => _budgetRepo.getBudget();

  List<Category> get categories => _categoryRepo.getAll();

  Category? getCategory(String id) => _categoryRepo.getById(id);

  // --- Display lists respecting active person filter ---
  List<BudgetItem> get visibleDirectItems {
    final direct = budget.directItems;
    if (_selectedPersonId == null) return direct;
    return direct
        .where((i) => i.hasOwner(_selectedPersonId!, const []))
        .toList();
  }

  List<BudgetLine> get visibleLines {
    final lines = budget.lines;
    if (_selectedPersonId == null) return lines;
    // Show lines that have at least one item owned by this person or where the line has this person
    return lines.where((line) {
      return line.shareForPerson(_selectedPersonId!) > 0 ||
          line.defaultOwnerIds.contains(_selectedPersonId!);
    }).toList();
  }

  // --- Financial Metrics (filtered or total) ---
  double get totalMonthlyIncome {
    if (_selectedPersonId == null) return budget.totalMonthlyIncome;
    return budget.summaryForPerson(_selectedPersonId!).income;
  }

  double get totalMonthlyExpense {
    if (_selectedPersonId == null) return budget.totalMonthlyExpense;
    return budget.summaryForPerson(_selectedPersonId!).expense;
  }

  double get totalMonthlySaving {
    if (_selectedPersonId == null) return budget.totalMonthlySaving;
    return budget.summaryForPerson(_selectedPersonId!).saving;
  }

  double get totalMonthlyInvesting {
    if (_selectedPersonId == null) return budget.totalMonthlyInvesting;
    return budget.summaryForPerson(_selectedPersonId!).investing;
  }

  double get totalMonthlyOutflow =>
      totalMonthlyExpense + totalMonthlySaving + totalMonthlyInvesting;

  double get netMonthlyCashflow =>
      totalMonthlyIncome - totalMonthlyOutflow;

  // --- Budget Item CRUD ---
  Future<void> addBudgetItem({
    required String name,
    required BudgetActivity activity,
    required String categoryId,
    required double amount,
    required BudgetItemTimeline timeline,
    String? budgetLineId,
    List<String> ownerIds = const [],
    String? note,
  }) async {
    final item = BudgetItem(
      id: _uuid.v4(),
      name: name.trim(),
      budgetLineId: budgetLineId,
      activity: activity,
      categoryId: categoryId,
      amount: amount,
      timeline: timeline,
      ownerIds: ownerIds,
      note: note?.trim(),
    );
    await _budgetRepo.addBudgetItem(item);
    notifyListeners();
  }

  Future<void> updateBudgetItem(BudgetItem item) async {
    await _budgetRepo.updateBudgetItem(item);
    notifyListeners();
  }

  Future<void> deleteBudgetItem(String itemId) async {
    await _budgetRepo.deleteBudgetItem(itemId);
    notifyListeners();
  }

  // --- Budget Line CRUD ---
  Future<BudgetLine> addBudgetLine({
    required String name,
    List<String> defaultOwnerIds = const [],
  }) async {
    final line = BudgetLine(
      id: _uuid.v4(),
      name: name.trim(),
      defaultOwnerIds: defaultOwnerIds,
    );
    await _budgetRepo.addBudgetLine(line);
    notifyListeners();
    return line;
  }

  Future<void> updateBudgetLine(BudgetLine line) async {
    await _budgetRepo.updateBudgetLine(line);
    notifyListeners();
  }

  Future<void> deleteBudgetLine(String lineId, {bool deleteChildren = false}) async {
    await _budgetRepo.deleteBudgetLine(lineId, deleteChildren: deleteChildren);
    notifyListeners();
  }

  Future<void> clearAll() async {
    await _budgetRepo.clearAll();
    notifyListeners();
  }
}
