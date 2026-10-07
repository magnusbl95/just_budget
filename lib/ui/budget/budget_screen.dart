import 'package:flutter/material.dart';
import '../../domain/models/budget_item.dart';
import '../../domain/models/budget_line.dart';
import '../../utils/currency_formatter.dart';
import '../../view_models/app_settings_view_model.dart';
import '../../view_models/budget_view_model.dart';
import 'add_budget_item_sheet.dart';
import 'add_budget_line_dialog.dart';
import 'budget_item_tile.dart';
import 'budget_line_card.dart';
import 'person_filter_bar.dart';

class BudgetScreen extends StatelessWidget {
  final BudgetViewModel budgetViewModel;
  final AppSettingsViewModel settingsViewModel;

  const BudgetScreen({
    super.key,
    required this.budgetViewModel,
    required this.settingsViewModel,
  });

  void _showAddItemSheet(BuildContext context, {BudgetItem? existingItem, String? lineId}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => AddBudgetItemSheet(
        existingItem: existingItem,
        categories: budgetViewModel.categories,
        lines: budgetViewModel.budget.lines,
        people: settingsViewModel.people,
        initialBudgetLineId: lineId,
        currencySymbol: settingsViewModel.currencySymbol,
        onSave: ({
          required name,
          required activity,
          required categoryId,
          required amount,
          required timeline,
          budgetLineId,
          required ownerIds,
          note,
        }) {
          if (existingItem != null) {
            budgetViewModel.updateBudgetItem(
              existingItem.copyWith(
                name: name,
                activity: activity,
                categoryId: categoryId,
                amount: amount,
                timeline: timeline,
                budgetLineId: budgetLineId,
                clearBudgetLine: budgetLineId == null,
                ownerIds: ownerIds,
                note: note,
              ),
            );
          } else {
            budgetViewModel.addBudgetItem(
              name: name,
              activity: activity,
              categoryId: categoryId,
              amount: amount,
              timeline: timeline,
              budgetLineId: budgetLineId,
              ownerIds: ownerIds,
              note: note,
            );
          }
        },
      ),
    );
  }

  void _showAddLineDialog(BuildContext context, {BudgetLine? existingLine}) {
    showDialog(
      context: context,
      builder: (ctx) => AddBudgetLineDialog(
        existingLine: existingLine,
        people: settingsViewModel.people,
        onSave: ({required name, required defaultOwnerIds}) {
          if (existingLine != null) {
            budgetViewModel.updateBudgetLine(
              existingLine.copyWith(
                name: name,
                defaultOwnerIds: defaultOwnerIds,
              ),
            );
          } else {
            budgetViewModel.addBudgetLine(
              name: name,
              defaultOwnerIds: defaultOwnerIds,
            );
          }
        },
      ),
    );
  }

  void _showAddOptionsSheet(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add to Budget',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.note_add_outlined),
                ),
                title: const Text('New Budget Item'),
                subtitle: const Text('Add an income, expense, saving, or investment line item'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showAddItemSheet(context);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.create_new_folder_outlined),
                ),
                title: const Text('New Budget Line'),
                subtitle: const Text('Create a grouped category to summarize multiple items'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showAddLineDialog(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([budgetViewModel, settingsViewModel]),
      builder: (context, _) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final currency = settingsViewModel.currencySymbol;

        final directItems = budgetViewModel.visibleDirectItems;
        final lines = budgetViewModel.visibleLines;
        final hasAny = directItems.isNotEmpty || lines.isNotEmpty;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // Running Cash Flow Summary Hero
              SliverToBoxAdapter(
                child: _buildSummaryHero(context, theme, colorScheme, currency),
              ),

              // Person Filter Bar
              SliverToBoxAdapter(
                child: PersonFilterBar(
                  people: settingsViewModel.people,
                  selectedPersonId: budgetViewModel.selectedPersonId,
                  onSelectPerson: budgetViewModel.selectPerson,
                ),
              ),

              // Empty State or List
              if (!hasAny)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(context, theme, colorScheme),
                )
              else ...[
                // Direct Standalone Items (if any)
                if (directItems.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 12, 18, 6),
                      child: Row(
                        children: [
                          Text(
                            'DIRECT BUDGET ITEMS',
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurfaceVariant,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${directItems.length}',
                              style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: directItems.length,
                        separatorBuilder: (context, index) => const Divider(
                          height: 1,
                          thickness: 0.5,
                          indent: 66,
                        ),
                        itemBuilder: (context, index) {
                          final item = directItems[index];
                          final cat = budgetViewModel.getCategory(item.categoryId);
                          return BudgetItemTile(
                            item: item,
                            category: cat,
                            allPeople: settingsViewModel.people,
                            currencySymbol: currency,
                            onEdit: () => _showAddItemSheet(context, existingItem: item),
                            onDelete: () => budgetViewModel.deleteBudgetItem(item.id),
                          );
                        },
                      ),
                    ),
                  ),
                ],

                // Budget Lines (if any)
                if (lines.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 6),
                      child: Row(
                        children: [
                          Text(
                            'BUDGET LINES & GROUPS',
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurfaceVariant,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${lines.length}',
                              style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final line = lines[index];
                        return BudgetLineCard(
                          line: line,
                          allPeople: settingsViewModel.people,
                          categories: budgetViewModel.categories,
                          currencySymbol: currency,
                          selectedPersonId: budgetViewModel.selectedPersonId,
                          onEditItem: (item) => _showAddItemSheet(context, existingItem: item),
                          onDeleteItem: (item) => budgetViewModel.deleteBudgetItem(item.id),
                          onAddItemToLine: () => _showAddItemSheet(context, lineId: line.id),
                          onEditLine: () => _showAddLineDialog(context, existingLine: line),
                          onDeleteLine: () => budgetViewModel.deleteBudgetLine(line.id),
                        );
                      },
                      childCount: lines.length,
                    ),
                  ),
                ],

                const SliverToBoxAdapter(
                  child: SizedBox(height: 80),
                ),
              ],
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddOptionsSheet(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Entry'),
          ),
        );
      },
    );
  }

  Widget _buildSummaryHero(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    String currency,
  ) {
    final income = budgetViewModel.totalMonthlyIncome;
    final expense = budgetViewModel.totalMonthlyExpense;
    final saving = budgetViewModel.totalMonthlySaving;
    final investing = budgetViewModel.totalMonthlyInvesting;
    final outflow = budgetViewModel.totalMonthlyOutflow;
    final net = budgetViewModel.netMonthlyCashflow;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RUNNING MONTHLY CASH FLOW',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurfaceVariant,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        CurrencyFormatter.format(net, symbol: currency),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: net >= 0 ? colorScheme.primary : colorScheme.error,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: (net >= 0 ? colorScheme.primary : colorScheme.error)
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          net >= 0 ? 'Surplus' : 'Deficit',
                          style: TextStyle(
                            color: net >= 0 ? colorScheme.primary : colorScheme.error,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, thickness: 0.5),
          const SizedBox(height: 14),

          // 4-Pillar Breakdown Chips / Columns
          Row(
            children: [
              _buildMiniPillar(
                theme: theme,
                title: 'Income',
                amount: income,
                currency: currency,
                color: const Color(0xFF1B6B38),
                icon: Icons.arrow_downward_rounded,
              ),
              _buildMiniPillar(
                theme: theme,
                title: 'Expenses',
                amount: expense,
                currency: currency,
                color: const Color(0xFFBA1A1A),
                icon: Icons.arrow_upward_rounded,
              ),
              _buildMiniPillar(
                theme: theme,
                title: 'Savings',
                amount: saving,
                currency: currency,
                color: const Color(0xFF0277BD),
                icon: Icons.savings_outlined,
              ),
              _buildMiniPillar(
                theme: theme,
                title: 'Investing',
                amount: investing,
                currency: currency,
                color: const Color(0xFF6A1B9A),
                icon: Icons.trending_up_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniPillar({
    required ThemeData theme,
    required String title,
    required double amount,
    required String currency,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 3),
              Text(
                title,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            CurrencyFormatter.formatCompact(amount, symbol: currency),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.account_balance_wallet_outlined,
                size: 48,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Budget Items Yet',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Start tracking your running budget by adding direct items or grouping them into budget lines.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: () => _showAddItemSheet(context),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add Budget Item'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _showAddLineDialog(context),
                  icon: const Icon(Icons.create_new_folder_outlined),
                  label: const Text('Add Budget Line'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
