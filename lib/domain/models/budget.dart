import '../enums/budget_activity.dart';
import 'budget_item.dart';
import 'budget_line.dart';
import 'person.dart';

class PersonSummary {
  final String personId;
  final double income;
  final double expense;
  final double saving;
  final double investing;

  const PersonSummary({
    required this.personId,
    required this.income,
    required this.expense,
    required this.saving,
    required this.investing,
  });

  double get totalOutflow => expense + saving + investing;
  double get netCashflow => income - totalOutflow;
}

class Budget {
  final String id;
  final String name;
  final List<BudgetItem> directItems;
  final List<BudgetLine> lines;

  const Budget({
    required this.id,
    required this.name,
    this.directItems = const [],
    this.lines = const [],
  });

  /// All budget items (both direct standalone items and items nested in lines)
  List<BudgetItem> get allItems {
    final list = <BudgetItem>[...directItems];
    for (final line in lines) {
      list.addAll(line.items);
    }
    return list;
  }

  /// Total monthly income across all direct items and lines
  double get totalMonthlyIncome =>
      _sumActivity(BudgetActivity.income);

  /// Total monthly living expenses across all direct items and lines
  double get totalMonthlyExpense =>
      _sumActivity(BudgetActivity.expense);

  /// Total monthly savings across all direct items and lines
  double get totalMonthlySaving =>
      _sumActivity(BudgetActivity.saving);

  /// Total monthly investments across all direct items and lines
  double get totalMonthlyInvesting =>
      _sumActivity(BudgetActivity.investing);

  /// Total combined monthly outflow (expense + saving + investing)
  double get totalMonthlyOutflow =>
      totalMonthlyExpense + totalMonthlySaving + totalMonthlyInvesting;

  /// Net running cashflow (income minus outflow)
  double get netMonthlyCashflow =>
      totalMonthlyIncome - totalMonthlyOutflow;

  double _sumActivity(BudgetActivity activity) {
    double total = 0.0;
    for (final item in directItems) {
      if (item.activity == activity) {
        total += item.normalizedMonthlyAmount;
      }
    }
    for (final line in lines) {
      for (final item in line.items) {
        if (item.activity == activity) {
          total += item.normalizedMonthlyAmount;
        }
      }
    }
    return total;
  }

  /// Calculates total financial breakdown for a specific person
  PersonSummary summaryForPerson(String personId) {
    double inc = 0.0;
    double exp = 0.0;
    double sav = 0.0;
    double inv = 0.0;

    for (final item in directItems) {
      if (item.hasOwner(personId, const [])) {
        final share = item.sharePerOwner(const []);
        switch (item.activity) {
          case BudgetActivity.income:
            inc += share;
            break;
          case BudgetActivity.expense:
            exp += share;
            break;
          case BudgetActivity.saving:
            sav += share;
            break;
          case BudgetActivity.investing:
            inv += share;
            break;
        }
      }
    }

    for (final line in lines) {
      for (final item in line.items) {
        if (item.hasOwner(personId, line.defaultOwnerIds)) {
          final share = item.sharePerOwner(line.defaultOwnerIds);
          switch (item.activity) {
            case BudgetActivity.income:
              inc += share;
              break;
            case BudgetActivity.expense:
              exp += share;
              break;
            case BudgetActivity.saving:
              sav += share;
              break;
            case BudgetActivity.investing:
              inv += share;
              break;
          }
        }
      }
    }

    return PersonSummary(
      personId: personId,
      income: inc,
      expense: exp,
      saving: sav,
      investing: inv,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };

  factory Budget.fromJson(
    Map<String, dynamic> json, {
    List<BudgetItem> directItems = const [],
    List<BudgetLine> lines = const [],
  }) =>
      Budget(
        id: json['id'] as String,
        name: json['name'] as String,
        directItems: directItems,
        lines: lines,
      );

  Budget copyWith({
    String? id,
    String? name,
    List<BudgetItem>? directItems,
    List<BudgetLine>? lines,
  }) =>
      Budget(
        id: id ?? this.id,
        name: name ?? this.name,
        directItems: directItems ?? this.directItems,
        lines: lines ?? this.lines,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Budget && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
