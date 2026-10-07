import '../enums/budget_activity.dart';
import '../enums/budget_item_timeline.dart';

class BudgetItem {
  final String id;
  final String name;
  final String? budgetLineId;
  final BudgetActivity activity;
  final String categoryId;
  final double amount;
  final BudgetItemTimeline timeline;
  final List<String> ownerIds;
  final String? note;

  const BudgetItem({
    required this.id,
    required this.name,
    this.budgetLineId,
    required this.activity,
    required this.categoryId,
    required this.amount,
    required this.timeline,
    this.ownerIds = const [],
    this.note,
  });

  bool get isStandalone => budgetLineId == null;

  /// Monthly normalized amount
  double get normalizedMonthlyAmount => timeline.toMonthly(amount);

  /// Annual normalized amount
  double get normalizedAnnualAmount => timeline.toAnnual(amount);

  /// Resolves the actual effective owners, inheriting from line default owners if item has none
  List<String> getEffectiveOwners(List<String> lineDefaultOwners) {
    if (ownerIds.isNotEmpty) {
      return ownerIds;
    }
    return lineDefaultOwners;
  }

  /// Calculates the equal share per owner for this item
  double sharePerOwner(List<String> lineDefaultOwners) {
    final owners = getEffectiveOwners(lineDefaultOwners);
    if (owners.isEmpty) return normalizedMonthlyAmount;
    return normalizedMonthlyAmount / owners.length;
  }

  /// Check if a specific person is an effective owner of this item
  bool hasOwner(String personId, List<String> lineDefaultOwners) {
    final owners = getEffectiveOwners(lineDefaultOwners);
    return owners.contains(personId);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'budgetLineId': budgetLineId,
        'activity': activity.name,
        'categoryId': categoryId,
        'amount': amount,
        'timeline': timeline.name,
        'ownerIds': ownerIds,
        'note': note,
      };

  factory BudgetItem.fromJson(Map<String, dynamic> json) => BudgetItem(
        id: json['id'] as String,
        name: json['name'] as String,
        budgetLineId: json['budgetLineId'] as String?,
        activity: BudgetActivity.values.firstWhere(
          (e) => e.name == json['activity'],
          orElse: () => BudgetActivity.expense,
        ),
        categoryId: json['categoryId'] as String,
        amount: (json['amount'] as num).toDouble(),
        timeline: BudgetItemTimeline.values.firstWhere(
          (e) => e.name == json['timeline'],
          orElse: () => BudgetItemTimeline.monthly,
        ),
        ownerIds: (json['ownerIds'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            const [],
        note: json['note'] as String?,
      );

  BudgetItem copyWith({
    String? id,
    String? name,
    String? budgetLineId,
    bool clearBudgetLine = false,
    BudgetActivity? activity,
    String? categoryId,
    double? amount,
    BudgetItemTimeline? timeline,
    List<String>? ownerIds,
    String? note,
  }) =>
      BudgetItem(
        id: id ?? this.id,
        name: name ?? this.name,
        budgetLineId: clearBudgetLine ? null : (budgetLineId ?? this.budgetLineId),
        activity: activity ?? this.activity,
        categoryId: categoryId ?? this.categoryId,
        amount: amount ?? this.amount,
        timeline: timeline ?? this.timeline,
        ownerIds: ownerIds ?? this.ownerIds,
        note: note ?? this.note,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BudgetItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
