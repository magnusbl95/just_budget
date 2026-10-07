import 'package:flutter/material.dart';
import '../../domain/enums/budget_activity.dart';
import '../../domain/enums/budget_item_timeline.dart';
import '../../domain/models/budget_item.dart';
import '../../domain/models/budget_line.dart';
import '../../domain/models/category.dart';
import '../../domain/models/person.dart';
import '../../utils/currency_formatter.dart';
import '../core/activity_badge.dart';
import '../core/person_avatar_chip.dart';

class AddBudgetItemSheet extends StatefulWidget {
  final BudgetItem? existingItem;
  final List<Category> categories;
  final List<BudgetLine> lines;
  final List<Person> people;
  final String? initialBudgetLineId;
  final String currencySymbol;
  final void Function({
    required String name,
    required BudgetActivity activity,
    required String categoryId,
    required double amount,
    required BudgetItemTimeline timeline,
    String? budgetLineId,
    required List<String> ownerIds,
    String? note,
  }) onSave;

  const AddBudgetItemSheet({
    super.key,
    this.existingItem,
    required this.categories,
    required this.lines,
    required this.people,
    this.initialBudgetLineId,
    this.currencySymbol = r'$',
    required this.onSave,
  });

  @override
  State<AddBudgetItemSheet> createState() => _AddBudgetItemSheetState();
}

class _AddBudgetItemSheetState extends State<AddBudgetItemSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late TextEditingController _noteController;

  late BudgetActivity _activity;
  late String _categoryId;
  late BudgetItemTimeline _timeline;
  late String? _budgetLineId;
  late List<String> _selectedOwnerIds;

  @override
  void initState() {
    super.initState();
    final item = widget.existingItem;
    _nameController = TextEditingController(text: item?.name ?? '');
    _amountController = TextEditingController(
      text: item != null ? item.amount.toStringAsFixed(2) : '',
    );
    _noteController = TextEditingController(text: item?.note ?? '');

    _activity = item?.activity ?? BudgetActivity.expense;
    _categoryId = item?.categoryId ??
        (widget.categories.isNotEmpty ? widget.categories.first.id : 'cat_other');
    _timeline = item?.timeline ?? BudgetItemTimeline.monthly;
    _budgetLineId = item?.budgetLineId ?? widget.initialBudgetLineId;
    _selectedOwnerIds = item != null ? List.from(item.ownerIds) : [];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  double get _currentAmount => double.tryParse(_amountController.text) ?? 0.0;
  double get _normalizedMonthly => _timeline.toMonthly(_currentAmount);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Resolve parent line for inheritance info
    BudgetLine? parentLine;
    if (_budgetLineId != null) {
      try {
        parentLine = widget.lines.firstWhere((l) => l.id == _budgetLineId);
      } catch (_) {}
    }

    final effectiveOwners = _selectedOwnerIds.isNotEmpty
        ? _selectedOwnerIds
        : (parentLine?.defaultOwnerIds ?? []);

    final splitAmount = effectiveOwners.isEmpty
        ? _normalizedMonthly
        : _normalizedMonthly / effectiveOwners.length;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Title
                Row(
                  children: [
                    Text(
                      widget.existingItem != null ? 'Edit Budget Item' : 'New Budget Item',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Activity SegmentedButton (Income, Expense, Saving, Investing)
                Text(
                  'Financial Activity',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                SegmentedButton<BudgetActivity>(
                  segments: const [
                    ButtonSegment(
                      value: BudgetActivity.expense,
                      label: Text('Expense'),
                      icon: Icon(Icons.arrow_upward_rounded, size: 16),
                    ),
                    ButtonSegment(
                      value: BudgetActivity.income,
                      label: Text('Income'),
                      icon: Icon(Icons.arrow_downward_rounded, size: 16),
                    ),
                    ButtonSegment(
                      value: BudgetActivity.saving,
                      label: Text('Saving'),
                      icon: Icon(Icons.savings_outlined, size: 16),
                    ),
                    ButtonSegment(
                      value: BudgetActivity.investing,
                      label: Text('Investing'),
                      icon: Icon(Icons.trending_up_rounded, size: 16),
                    ),
                  ],
                  selected: {_activity},
                  onSelectionChanged: (set) {
                    setState(() => _activity = set.first);
                  },
                ),
                const SizedBox(height: 18),

                // Name input
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Item Name',
                    hintText: 'e.g. Groceries, Rent, Salary',
                    prefixIcon: Icon(Icons.edit_note_rounded),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Mandatory Category Picker
                Text(
                  'Category (Required)',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cat = widget.categories[index];
                      final isSelected = cat.id == _categoryId;
                      final catColor = Color(cat.colorHex);

                      return FilterChip(
                        selected: isSelected,
                        avatar: Icon(
                          cat.icon,
                          size: 16,
                          color: isSelected ? colorScheme.onPrimaryContainer : catColor,
                        ),
                        label: Text(cat.name),
                        onSelected: (_) {
                          setState(() => _categoryId = cat.id);
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 18),

                // Amount & Timeline
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Amount',
                          prefixText: '${widget.currencySymbol} ',
                        ),
                        onChanged: (_) => setState(() {}),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Enter amount';
                          }
                          if (double.tryParse(val) == null || double.parse(val) <= 0) {
                            return 'Must be > 0';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<BudgetItemTimeline>(
                        value: _timeline,
                        decoration: const InputDecoration(
                          labelText: 'Timeline',
                        ),
                        items: BudgetItemTimeline.values.map((t) {
                          return DropdownMenuItem(
                            value: t,
                            child: Text(t.displayName),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _timeline = val);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Real-time normalized run-rate preview
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.functions_rounded, size: 18, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Normalized monthly run-rate:',
                          style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Text(
                        '${CurrencyFormatter.format(_normalizedMonthly, symbol: widget.currencySymbol)}/mo',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Organization: Standalone or in BudgetLine
                Text(
                  'Placement on Budget List',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String?>(
                  value: _budgetLineId,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.account_tree_outlined),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Direct (Standalone on Budget List)'),
                    ),
                    for (final line in widget.lines)
                      DropdownMenuItem(
                        value: line.id,
                        child: Text('Under Budget Line: ${line.name}'),
                      ),
                  ],
                  onChanged: (val) {
                    setState(() => _budgetLineId = val);
                  },
                ),
                const SizedBox(height: 18),

                // Owners & Equal Splitting
                Row(
                  children: [
                    Text(
                      'Assigned Owners',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (_selectedOwnerIds.isEmpty && parentLine != null && parentLine.defaultOwnerIds.isNotEmpty)
                      Text(
                        '(Inheriting from line)',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.outline,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                if (widget.people.isEmpty)
                  Text(
                    'No people defined in settings yet. Add yourself and family in Settings to track splits.',
                    style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: widget.people.map((p) {
                      final isSelected = _selectedOwnerIds.contains(p.id);
                      final isInheritedOnly = _selectedOwnerIds.isEmpty &&
                          (parentLine?.defaultOwnerIds.contains(p.id) ?? false);

                      return FilterChip(
                        selected: isSelected || isInheritedOnly,
                        avatar: PersonAvatarChip(person: p, showName: false, size: 18),
                        label: Text(p.name),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedOwnerIds.add(p.id);
                            } else {
                              _selectedOwnerIds.remove(p.id);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),

                if (effectiveOwners.length > 1) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Equal split: ${CurrencyFormatter.format(splitAmount, symbol: widget.currencySymbol)}/mo for each of the ${effectiveOwners.length} owners.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Save button
                FilledButton.icon(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      widget.onSave(
                        name: _nameController.text.trim(),
                        activity: _activity,
                        categoryId: _categoryId,
                        amount: double.parse(_amountController.text),
                        timeline: _timeline,
                        budgetLineId: _budgetLineId,
                        ownerIds: _selectedOwnerIds,
                        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
                      );
                      Navigator.of(context).pop();
                    }
                  },
                  icon: const Icon(Icons.check_rounded),
                  label: Text(widget.existingItem != null ? 'Update Item' : 'Add Item'),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
