import 'package:flutter/material.dart';
import '../../domain/enums/budget_activity.dart';
import '../../utils/currency_formatter.dart';
import '../../view_models/app_settings_view_model.dart';
import '../../view_models/budget_view_model.dart';
import '../core/person_avatar_chip.dart';

class InsightsScreen extends StatelessWidget {
  final BudgetViewModel budgetViewModel;
  final AppSettingsViewModel settingsViewModel;

  const InsightsScreen({
    super.key,
    required this.budgetViewModel,
    required this.settingsViewModel,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([budgetViewModel, settingsViewModel]),
      builder: (context, _) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final currency = settingsViewModel.currencySymbol;
        final budget = budgetViewModel.budget;
        final people = settingsViewModel.people;

        final income = budget.totalMonthlyIncome;
        final expense = budget.totalMonthlyExpense;
        final saving = budget.totalMonthlySaving;
        final investing = budget.totalMonthlyInvesting;
        final outflow = budget.totalMonthlyOutflow;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Insights & Breakdown'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Financial Flow Distribution Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'RUNNING CASH FLOW PILLARS',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: colorScheme.onSurfaceVariant,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildPillarBar(
                          theme: theme,
                          label: 'Living Expenses',
                          amount: expense,
                          total: income > 0 ? income : outflow,
                          color: const Color(0xFFBA1A1A),
                          currency: currency,
                        ),
                        const SizedBox(height: 14),
                        _buildPillarBar(
                          theme: theme,
                          label: 'Savings Reserves',
                          amount: saving,
                          total: income > 0 ? income : outflow,
                          color: const Color(0xFF0277BD),
                          currency: currency,
                        ),
                        const SizedBox(height: 14),
                        _buildPillarBar(
                          theme: theme,
                          label: 'Wealth Investments',
                          amount: investing,
                          total: income > 0 ? income : outflow,
                          color: const Color(0xFF6A1B9A),
                          currency: currency,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Person Share Breakdown Cards
                if (people.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 8),
                    child: Text(
                      'HOUSEHOLD RESPONSIBILITY BREAKDOWN',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurfaceVariant,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  for (final person in people) ...[
                    _buildPersonCard(
                      theme: theme,
                      colorScheme: colorScheme,
                      person: person,
                      budget: budget,
                      currency: currency,
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPillarBar({
    required ThemeData theme,
    required String label,
    required double amount,
    required double total,
    required Color color,
    required String currency,
  }) {
    final pct = total > 0 ? (amount / total).clamp(0.0, 1.0) : 0.0;
    final pctString = (pct * 100).toStringAsFixed(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            Text(
              '${CurrencyFormatter.format(amount, symbol: currency)}/mo ($pctString%)',
              style: TextStyle(fontWeight: FontWeight.w800, color: color, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 8,
            backgroundColor: color.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonCard({
    required ThemeData theme,
    required ColorScheme colorScheme,
    required person,
    required budget,
    required String currency,
  }) {
    final summary = budget.summaryForPerson(person.id);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                PersonAvatarChip(person: person, showName: true, size: 26),
                const Spacer(),
                Text(
                  'Net: ${CurrencyFormatter.format(summary.netCashflow, symbol: currency)}/mo',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: summary.netCashflow >= 0 ? colorScheme.primary : colorScheme.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, thickness: 0.5),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPersonMetric('Income', summary.income, const Color(0xFF1B6B38), currency),
                _buildPersonMetric('Expenses', summary.expense, const Color(0xFFBA1A1A), currency),
                _buildPersonMetric('Savings', summary.saving, const Color(0xFF0277BD), currency),
                _buildPersonMetric('Investing', summary.investing, const Color(0xFF6A1B9A), currency),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonMetric(String label, double amount, Color color, String currency) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
        ),
        const SizedBox(height: 2),
        Text(
          CurrencyFormatter.formatCompact(amount, symbol: currency),
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
        ),
      ],
    );
  }
}
