import 'package:flutter/material.dart';
import '../../domain/enums/budget_activity.dart';
import '../../domain/enums/budget_item_timeline.dart';
import '../../view_models/app_settings_view_model.dart';
import '../../view_models/budget_view_model.dart';

class FirstLaunchSetupSheet extends StatefulWidget {
  final AppSettingsViewModel settingsViewModel;
  final BudgetViewModel budgetViewModel;
  final VoidCallback onFinished;

  const FirstLaunchSetupSheet({
    super.key,
    required this.settingsViewModel,
    required this.budgetViewModel,
    required this.onFinished,
  });

  @override
  State<FirstLaunchSetupSheet> createState() => _FirstLaunchSetupSheetState();
}

class _FirstLaunchSetupSheetState extends State<FirstLaunchSetupSheet> {
  int _currentStep = 0;
  final _nameController = TextEditingController(text: 'Me');
  final _partnerController = TextEditingController();
  bool _addSecondPerson = false;

  // Starter items configuration
  bool _includeIncome = true;
  final _incomeAmountController = TextEditingController(text: '3000');
  BudgetItemTimeline _incomeTimeline = BudgetItemTimeline.monthly;

  bool _includeHousing = true;
  final _housingAmountController = TextEditingController(text: '1200');
  BudgetItemTimeline _housingTimeline = BudgetItemTimeline.monthly;

  bool _includeGroceries = true;
  final _groceriesAmountController = TextEditingController(text: '120');
  BudgetItemTimeline _groceriesTimeline = BudgetItemTimeline.weekly;

  bool _includeSavings = true;
  final _savingsAmountController = TextEditingController(text: '300');
  BudgetItemTimeline _savingsTimeline = BudgetItemTimeline.monthly;

  @override
  void dispose() {
    _nameController.dispose();
    _partnerController.dispose();
    _incomeAmountController.dispose();
    _housingAmountController.dispose();
    _groceriesAmountController.dispose();
    _savingsAmountController.dispose();
    super.dispose();
  }

  Future<void> _completeSetup({bool addStarters = true}) async {
    // 1. Create People
    final person1 = await widget.settingsViewModel.addPerson(
      _nameController.text.trim().isEmpty ? 'Me' : _nameController.text.trim(),
      0xFF006C4C, // Emerald
    );

    String? person2Id;
    if (_addSecondPerson && _partnerController.text.trim().isNotEmpty) {
      final person2 = await widget.settingsViewModel.addPerson(
        _partnerController.text.trim(),
        0xFF0277BD, // Blue
      );
      person2Id = person2.id;
    }

    final allOwnerIds = [person1.id, if (person2Id != null) person2Id];

    // 2. Add Starter Items if requested
    if (addStarters) {
      if (_includeIncome && _incomeAmountController.text.isNotEmpty) {
        final amount = double.tryParse(_incomeAmountController.text) ?? 3000;
        await widget.budgetViewModel.addBudgetItem(
          name: 'Primary Income',
          activity: BudgetActivity.income,
          categoryId: 'cat_income_career',
          amount: amount,
          timeline: _incomeTimeline,
          ownerIds: [person1.id],
        );
      }

      // Group Household Living into a BudgetLine if Groceries & Housing are both selected
      if (_includeHousing || _includeGroceries) {
        final line = await widget.budgetViewModel.addBudgetLine(
          name: 'Household & Living',
          defaultOwnerIds: allOwnerIds,
        );

        if (_includeHousing && _housingAmountController.text.isNotEmpty) {
          final amount = double.tryParse(_housingAmountController.text) ?? 1200;
          await widget.budgetViewModel.addBudgetItem(
            name: 'Rent / Mortgage',
            activity: BudgetActivity.expense,
            categoryId: 'cat_housing',
            amount: amount,
            timeline: _housingTimeline,
            budgetLineId: line.id,
            ownerIds: [], // Inherits default line owners
          );
        }

        if (_includeGroceries && _groceriesAmountController.text.isNotEmpty) {
          final amount = double.tryParse(_groceriesAmountController.text) ?? 120;
          await widget.budgetViewModel.addBudgetItem(
            name: 'Groceries & Market',
            activity: BudgetActivity.expense,
            categoryId: 'cat_groceries',
            amount: amount,
            timeline: _groceriesTimeline,
            budgetLineId: line.id,
            ownerIds: [], // Inherits default line owners
          );
        }
      }

      if (_includeSavings && _savingsAmountController.text.isNotEmpty) {
        final amount = double.tryParse(_savingsAmountController.text) ?? 300;
        await widget.budgetViewModel.addBudgetItem(
          name: 'Emergency Savings',
          activity: BudgetActivity.saving,
          categoryId: 'cat_savings',
          amount: amount,
          timeline: _savingsTimeline,
          ownerIds: allOwnerIds,
        );
      }
    }

    // 3. Mark Onboarding Completed
    await widget.settingsViewModel.completeOnboarding();
    widget.onFinished();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: Dialog(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.account_balance_wallet_rounded,
                          color: colorScheme.onPrimaryContainer,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome to Just Budget',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              _currentStep == 0
                                  ? 'Step 1 of 2: Who is this budget for?'
                                  : 'Step 2 of 2: Add your initial budget items',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (_currentStep == 0) _buildStep1(theme, colorScheme),
                  if (_currentStep == 1) _buildStep2(theme, colorScheme),
                  const SizedBox(height: 28),
                  _buildActions(colorScheme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep1(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personalize Your Budget',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Budgets can be individual or shared. Enter your name below to track who owns which budget items.',
          style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 18),
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Your Name or Display Label',
            prefixIcon: Icon(Icons.person_rounded),
            hintText: 'e.g. Alex, Me',
          ),
        ),
        const SizedBox(height: 14),
        CheckboxListTile(
          value: _addSecondPerson,
          contentPadding: EdgeInsets.zero,
          title: const Text('Add a partner or roommate to split items with'),
          onChanged: (val) {
            setState(() {
              _addSecondPerson = val ?? false;
            });
          },
        ),
        if (_addSecondPerson) ...[
          const SizedBox(height: 8),
          TextField(
            controller: _partnerController,
            decoration: const InputDecoration(
              labelText: 'Second Person Name',
              prefixIcon: Icon(Icons.people_outline_rounded),
              hintText: 'e.g. Sam, Partner',
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStep2(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Budget Setup',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          'Configure your recurring items and timelines. You can also skip this and start completely blank.',
          style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),

        // Income item
        _buildStarterItemCard(
          theme: theme,
          colorScheme: colorScheme,
          title: 'Primary Income',
          icon: Icons.work_outline,
          enabled: _includeIncome,
          onToggle: (v) => setState(() => _includeIncome = v),
          amountController: _incomeAmountController,
          timeline: _incomeTimeline,
          onTimelineChanged: (t) => setState(() => _incomeTimeline = t),
        ),
        const SizedBox(height: 10),

        // Housing item
        _buildStarterItemCard(
          theme: theme,
          colorScheme: colorScheme,
          title: 'Rent / Housing',
          icon: Icons.home_outlined,
          enabled: _includeHousing,
          onToggle: (v) => setState(() => _includeHousing = v),
          amountController: _housingAmountController,
          timeline: _housingTimeline,
          onTimelineChanged: (t) => setState(() => _housingTimeline = t),
        ),
        const SizedBox(height: 10),

        // Groceries item
        _buildStarterItemCard(
          theme: theme,
          colorScheme: colorScheme,
          title: 'Groceries',
          icon: Icons.shopping_cart_outlined,
          enabled: _includeGroceries,
          onToggle: (v) => setState(() => _includeGroceries = v),
          amountController: _groceriesAmountController,
          timeline: _groceriesTimeline,
          onTimelineChanged: (t) => setState(() => _groceriesTimeline = t),
        ),
        const SizedBox(height: 10),

        // Savings item
        _buildStarterItemCard(
          theme: theme,
          colorScheme: colorScheme,
          title: 'Emergency Savings',
          icon: Icons.savings_outlined,
          enabled: _includeSavings,
          onToggle: (v) => setState(() => _includeSavings = v),
          amountController: _savingsAmountController,
          timeline: _savingsTimeline,
          onTimelineChanged: (t) => setState(() => _savingsTimeline = t),
        ),
      ],
    );
  }

  Widget _buildStarterItemCard({
    required ThemeData theme,
    required ColorScheme colorScheme,
    required String title,
    required IconData icon,
    required bool enabled,
    required ValueChanged<bool> onToggle,
    required TextEditingController amountController,
    required BudgetItemTimeline timeline,
    required ValueChanged<BudgetItemTimeline> onTimelineChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: enabled
            ? colorScheme.surfaceContainerHigh.withValues(alpha: 0.5)
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: enabled
              ? colorScheme.outlineVariant
              : colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: enabled,
            onChanged: (v) => onToggle(v ?? false),
          ),
          Icon(icon, size: 20, color: enabled ? colorScheme.primary : colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: enabled ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          if (enabled) ...[
            SizedBox(
              width: 90,
              height: 40,
              child: TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.right,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                decoration: InputDecoration(
                  prefixText: widget.settingsViewModel.currencySymbol,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
              ),
            ),
            const SizedBox(width: 6),
            DropdownButton<BudgetItemTimeline>(
              value: timeline,
              underline: const SizedBox.shrink(),
              items: BudgetItemTimeline.values.map((t) {
                return DropdownMenuItem(
                  value: t,
                  child: Text(t.suffix, style: const TextStyle(fontSize: 12)),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) onTimelineChanged(val);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActions(ColorScheme colorScheme) {
    if (_currentStep == 0) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FilledButton.icon(
            onPressed: () {
              setState(() => _currentStep = 1);
            },
            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
            label: const Text('Next: Budget Items'),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () => _completeSetup(addStarters: false),
          child: const Text('Start from Blank Slate'),
        ),
        FilledButton(
          onPressed: () => _completeSetup(addStarters: true),
          child: const Text('Save & Open Budget'),
        ),
      ],
    );
  }
}
