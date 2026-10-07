enum BudgetActivity {
  income,
  expense,
  saving,
  investing;

  String get displayName {
    switch (this) {
      case BudgetActivity.income:
        return 'Income';
      case BudgetActivity.expense:
        return 'Expense';
      case BudgetActivity.saving:
        return 'Saving';
      case BudgetActivity.investing:
        return 'Investing';
    }
  }

  bool get isOutflow => this != BudgetActivity.income;
}
