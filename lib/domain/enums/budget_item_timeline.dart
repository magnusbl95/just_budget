enum BudgetItemTimeline {
  daily,
  weekly,
  biWeekly,
  monthly,
  quarterly,
  halfYearly,
  yearly;

  String get displayName {
    switch (this) {
      case BudgetItemTimeline.daily:
        return 'Daily';
      case BudgetItemTimeline.weekly:
        return 'Weekly';
      case BudgetItemTimeline.biWeekly:
        return 'Bi-Weekly';
      case BudgetItemTimeline.monthly:
        return 'Monthly';
      case BudgetItemTimeline.quarterly:
        return 'Quarterly';
      case BudgetItemTimeline.halfYearly:
        return 'Half-Yearly';
      case BudgetItemTimeline.yearly:
        return 'Yearly';
    }
  }

  String get suffix {
    switch (this) {
      case BudgetItemTimeline.daily:
        return '/day';
      case BudgetItemTimeline.weekly:
        return '/wk';
      case BudgetItemTimeline.biWeekly:
        return '/2wks';
      case BudgetItemTimeline.monthly:
        return '/mo';
      case BudgetItemTimeline.quarterly:
        return '/qtr';
      case BudgetItemTimeline.halfYearly:
        return '/half-yr';
      case BudgetItemTimeline.yearly:
        return '/yr';
    }
  }

  /// Factor to convert an amount at this frequency to a monthly normalized amount
  double get monthlyFactor {
    switch (this) {
      case BudgetItemTimeline.daily:
        return 365.0 / 12.0;
      case BudgetItemTimeline.weekly:
        return 52.0 / 12.0;
      case BudgetItemTimeline.biWeekly:
        return 26.0 / 12.0;
      case BudgetItemTimeline.monthly:
        return 1.0;
      case BudgetItemTimeline.quarterly:
        return 1.0 / 3.0;
      case BudgetItemTimeline.halfYearly:
        return 1.0 / 6.0;
      case BudgetItemTimeline.yearly:
        return 1.0 / 12.0;
    }
  }

  /// Factor to convert an amount at this frequency to an annual normalized amount
  double get annualFactor {
    switch (this) {
      case BudgetItemTimeline.daily:
        return 365.0;
      case BudgetItemTimeline.weekly:
        return 52.0;
      case BudgetItemTimeline.biWeekly:
        return 26.0;
      case BudgetItemTimeline.monthly:
        return 12.0;
      case BudgetItemTimeline.quarterly:
        return 4.0;
      case BudgetItemTimeline.halfYearly:
        return 2.0;
      case BudgetItemTimeline.yearly:
        return 1.0;
    }
  }

  /// Helper to convert a raw amount into normalized monthly amount
  double toMonthly(double amount) => amount * monthlyFactor;

  /// Helper to convert a raw amount into normalized annual amount
  double toAnnual(double amount) => amount * annualFactor;
}
