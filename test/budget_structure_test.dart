import 'package:flutter_test/flutter_test.dart';
import 'package:just_budget/domain/enums/budget_activity.dart';
import 'package:just_budget/domain/enums/budget_item_timeline.dart';
import 'package:just_budget/domain/models/budget.dart';
import 'package:just_budget/domain/models/budget_item.dart';
import 'package:just_budget/domain/models/budget_line.dart';
import 'package:just_budget/domain/models/person.dart';

void main() {
  group('BudgetItemTimeline Normalization Tests', () {
    test('weekly normalizes accurately to monthly and annual', () {
      const weekly = BudgetItemTimeline.weekly;
      final monthly = weekly.toMonthly(100.0);
      final annual = weekly.toAnnual(100.0);

      expect(monthly, closeTo(433.33, 0.01));
      expect(annual, equals(5200.0));
    });

    test('biWeekly normalizes accurately', () {
      const biWeekly = BudgetItemTimeline.biWeekly;
      final monthly = biWeekly.toMonthly(2500.0);
      final annual = biWeekly.toAnnual(2500.0);

      expect(monthly, closeTo(5416.67, 0.01));
      expect(annual, equals(65000.0));
    });

    test('quarterly and halfYearly normalize accurately', () {
      expect(BudgetItemTimeline.quarterly.toMonthly(300.0), equals(100.0));
      expect(BudgetItemTimeline.halfYearly.toMonthly(600.0), equals(100.0));
      expect(BudgetItemTimeline.yearly.toMonthly(1200.0), equals(100.0));
    });
  });

  group('Multi-Owner Equal Split & Inheritance Tests', () {
    const personA = Person(id: 'person_a', name: 'Alice');
    const personB = Person(id: 'person_b', name: 'Bob');

    test('standalone item splits equally between designated owners', () {
      const item = BudgetItem(
        id: 'item_1',
        name: 'Supermarket Groceries',
        activity: BudgetActivity.expense,
        categoryId: 'cat_groceries',
        amount: 600.0,
        timeline: BudgetItemTimeline.monthly,
        ownerIds: ['person_a', 'person_b'],
      );

      expect(item.sharePerOwner(const []), equals(300.0));
      expect(item.hasOwner('person_a', const []), isTrue);
      expect(item.hasOwner('person_b', const []), isTrue);
      expect(item.hasOwner('person_c', const []), isFalse);
    });

    test('item in BudgetLine inherits default line owners if none specified', () {
      const item = BudgetItem(
        id: 'item_nested',
        name: 'Home Fiber Internet',
        budgetLineId: 'line_household',
        activity: BudgetActivity.expense,
        categoryId: 'cat_utilities',
        amount: 80.0,
        timeline: BudgetItemTimeline.monthly,
        ownerIds: [], // Empty => should inherit line default
      );

      final lineDefaults = ['person_a', 'person_b'];
      expect(item.getEffectiveOwners(lineDefaults), equals(['person_a', 'person_b']));
      expect(item.sharePerOwner(lineDefaults), equals(40.0));
      expect(item.hasOwner('person_a', lineDefaults), isTrue);
    });

    test('item in BudgetLine overrides line default owners when explicitly set', () {
      const item = BudgetItem(
        id: 'item_personal',
        name: 'Alice Personal Gym',
        budgetLineId: 'line_household',
        activity: BudgetActivity.expense,
        categoryId: 'cat_health',
        amount: 50.0,
        timeline: BudgetItemTimeline.monthly,
        ownerIds: ['person_a'], // Explicit single owner
      );

      final lineDefaults = ['person_a', 'person_b'];
      expect(item.getEffectiveOwners(lineDefaults), equals(['person_a']));
      expect(item.sharePerOwner(lineDefaults), equals(50.0));
      expect(item.hasOwner('person_b', lineDefaults), isFalse);
    });
  });

  group('Composite BudgetLine and Budget Cashflow Tests', () {
    const personA = Person(id: 'p_a', name: 'Alice');
    const personB = Person(id: 'p_b', name: 'Bob');

    test('BudgetLine summarizes child items correctly', () {
      final item1 = const BudgetItem(
        id: 'i1',
        name: 'Groceries',
        activity: BudgetActivity.expense,
        categoryId: 'cat_groceries',
        amount: 100.0,
        timeline: BudgetItemTimeline.weekly, // ~433.33/mo
        ownerIds: ['p_a', 'p_b'],
      );

      final item2 = const BudgetItem(
        id: 'i2',
        name: 'Electric Bill',
        activity: BudgetActivity.expense,
        categoryId: 'cat_utilities',
        amount: 150.0,
        timeline: BudgetItemTimeline.monthly,
        ownerIds: ['p_a', 'p_b'],
      );

      final line = BudgetLine(
        id: 'l1',
        name: 'Living Essentials',
        defaultOwnerIds: const ['p_a', 'p_b'],
        items: [item1, item2],
      );

      expect(line.totalNormalizedMonthly, closeTo(583.33, 0.01));
      expect(line.shareForPerson('p_a'), closeTo(291.67, 0.01));
    });

    test('Budget calculates 4 pillars and per-person summary', () {
      final salary = const BudgetItem(
        id: 'sal',
        name: 'Job Salary',
        activity: BudgetActivity.income,
        categoryId: 'cat_income_career',
        amount: 4000.0,
        timeline: BudgetItemTimeline.monthly,
        ownerIds: ['p_a'],
      );

      final rent = const BudgetItem(
        id: 'rent',
        name: 'Rent',
        activity: BudgetActivity.expense,
        categoryId: 'cat_housing',
        amount: 1600.0,
        timeline: BudgetItemTimeline.monthly,
        ownerIds: ['p_a', 'p_b'],
      );

      final investing = const BudgetItem(
        id: 'inv',
        name: 'Index Fund',
        activity: BudgetActivity.investing,
        categoryId: 'cat_investing',
        amount: 500.0,
        timeline: BudgetItemTimeline.monthly,
        ownerIds: ['p_a'],
      );

      final budget = Budget(
        id: 'b1',
        name: 'Running Budget',
        directItems: [salary, rent, investing],
      );

      expect(budget.totalMonthlyIncome, equals(4000.0));
      expect(budget.totalMonthlyExpense, equals(1600.0));
      expect(budget.totalMonthlyInvesting, equals(500.0));
      expect(budget.netMonthlyCashflow, equals(1900.0));

      final aliceSummary = budget.summaryForPerson('p_a');
      expect(aliceSummary.income, equals(4000.0));
      expect(aliceSummary.expense, equals(800.0)); // 50% of 1600 rent
      expect(aliceSummary.investing, equals(500.0));
      expect(aliceSummary.netCashflow, equals(2700.0));

      final bobSummary = budget.summaryForPerson('p_b');
      expect(bobSummary.income, equals(0.0));
      expect(bobSummary.expense, equals(800.0)); // 50% of 1600 rent
      expect(bobSummary.netCashflow, equals(-800.0));
    });
  });
}
