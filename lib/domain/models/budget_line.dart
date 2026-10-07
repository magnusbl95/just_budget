import '../enums/budget_activity.dart';
import 'budget_item.dart';

class BudgetLine {
  final String id;
  final String name;
  final List<String> defaultOwnerIds;
  final List<BudgetItem> items;

  const BudgetLine({
    required this.id,
    required this.name,
    this.defaultOwnerIds = const [],
    this.items = const [],
  });

  /// Total monthly normalized sum of all child budget items
  double get totalNormalizedMonthly =>
      items.fold(0.0, (sum, item) => sum + item.normalizedMonthlyAmount);

  /// Total annual normalized sum of all child budget items
  double get totalNormalizedAnnual =>
      items.fold(0.0, (sum, item) => sum + item.normalizedAnnualAmount);

  /// Computes this line's total share for a specific person
  double shareForPerson(String personId) {
    double total = 0.0;
    for (final item in items) {
      if (item.hasOwner(personId, defaultOwnerIds)) {
        total += item.sharePerOwner(defaultOwnerIds);
      }
    }
    return total;
  }

  /// Breakdown of monthly amounts by activity (income, expense, saving, investing)
  Map<BudgetActivity, double> get activityBreakdown {
    final map = <BudgetActivity, double>{
      BudgetActivity.income: 0.0,
      BudgetActivity.expense: 0.0,
      BudgetActivity.saving: 0.0,
      BudgetActivity.investing: 0.0,
    };
    for (final item in items) {
      map[item.activity] = (map[item.activity] ?? 0.0) + item.normalizedMonthlyAmount;
    }
    return map;
  }

  /// All unique owners across this budget line and its children
  List<String> get allInvolvedOwners {
    final set = <String>{...defaultOwnerIds};
    for (final item in items) {
      set.addAll(item.getEffectiveOwners(defaultOwnerIds));
    }
    return set.toList();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'defaultOwnerIds': defaultOwnerIds,
      };

  factory BudgetLine.fromJson(
    Map<String, dynamic> json, {
    List<BudgetItem> items = const [],
  }) =>
      BudgetLine(
        id: json['id'] as String,
        name: json['name'] as String,
        defaultOwnerIds: (json['defaultOwnerIds'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            const [],
        items: items,
      );

  BudgetLine copyWith({
    String? id,
    String? name,
    List<String>? defaultOwnerIds,
    List<BudgetItem>? items,
  }) =>
      BudgetLine(
        id: id ?? this.id,
        name: name ?? this.name,
        defaultOwnerIds: defaultOwnerIds ?? this.defaultOwnerIds,
        items: items ?? this.items,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BudgetLine && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
