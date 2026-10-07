import 'package:flutter/material.dart';
import '../../domain/models/budget_item.dart';
import '../../domain/models/budget_line.dart';
import '../../domain/models/category.dart';
import '../../domain/models/person.dart';
import '../../utils/currency_formatter.dart';
import '../core/person_avatar_chip.dart';
import 'budget_item_tile.dart';

class BudgetLineCard extends StatefulWidget {
  final BudgetLine line;
  final List<Person> allPeople;
  final List<Category> categories;
  final String currencySymbol;
  final String? selectedPersonId;
  final ValueChanged<BudgetItem> onEditItem;
  final ValueChanged<BudgetItem> onDeleteItem;
  final VoidCallback onAddItemToLine;
  final VoidCallback onEditLine;
  final VoidCallback onDeleteLine;

  const BudgetLineCard({
    super.key,
    required this.line,
    required this.allPeople,
    required this.categories,
    this.currencySymbol = r'$',
    this.selectedPersonId,
    required this.onEditItem,
    required this.onDeleteItem,
    required this.onAddItemToLine,
    required this.onEditLine,
    required this.onDeleteLine,
  });

  @override
  State<BudgetLineCard> createState() => _BudgetLineCardState();
}

class _BudgetLineCardState extends State<BudgetLineCard> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Filter items if a person is selected
    final visibleItems = widget.selectedPersonId == null
        ? widget.line.items
        : widget.line.items
            .where((i) => i.hasOwner(widget.selectedPersonId!, widget.line.defaultOwnerIds))
            .toList();

    final lineTotal = widget.selectedPersonId == null
        ? widget.line.totalNormalizedMonthly
        : widget.line.shareForPerson(widget.selectedPersonId!);

    final defaultOwners = widget.line.defaultOwnerIds
        .map((id) => widget.allPeople.firstWhere((p) => p.id == id, orElse: () => Person(id: id, name: 'Unknown')))
        .toList();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(16),
              bottom: _isExpanded ? Radius.zero : const Radius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.folder_outlined,
                      color: colorScheme.onSecondaryContainer,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.line.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${widget.line.items.length} items',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (defaultOwners.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                'Line default: ',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              MultiOwnerStack(owners: defaultOwners, size: 16),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Total amount
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${CurrencyFormatter.format(lineTotal, symbol: widget.currencySymbol)}/mo',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colorScheme.primary,
                        ),
                      ),
                      if (widget.selectedPersonId != null)
                        Text(
                          'their share',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.outline,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 4),

                  // Expand Chevron
                  Icon(
                    _isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                    color: colorScheme.onSurfaceVariant,
                  ),

                  // Line Menu
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert_rounded, size: 18, color: colorScheme.onSurfaceVariant),
                    padding: EdgeInsets.zero,
                    onSelected: (val) {
                      if (val == 'add') widget.onAddItemToLine();
                      if (val == 'edit') widget.onEditLine();
                      if (val == 'delete') widget.onDeleteLine();
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'add',
                        child: Row(
                          children: [
                            Icon(Icons.add_rounded, size: 18),
                            SizedBox(width: 8),
                            Text('Add Item to Line'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 18),
                            SizedBox(width: 8),
                            Text('Edit Line'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, size: 18, color: Colors.red),
                            const SizedBox(width: 8),
                            Text('Delete Line', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Child Items List
          if (_isExpanded) ...[
            const Divider(height: 1, thickness: 0.8),
            if (visibleItems.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        widget.line.items.isEmpty
                            ? 'No items in this line yet.'
                            : 'No items owned by this person in this line.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: widget.onAddItemToLine,
                        icon: const Icon(Icons.add_rounded, size: 16),
                        label: const Text('Add First Item'),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: visibleItems.length,
                separatorBuilder: (context, index) => const Divider(
                  height: 1,
                  thickness: 0.5,
                  indent: 66,
                ),
                itemBuilder: (context, index) {
                  final item = visibleItems[index];
                  final cat = widget.categories.firstWhere(
                    (c) => c.id == item.categoryId,
                    orElse: () => widget.categories.first,
                  );

                  return BudgetItemTile(
                    item: item,
                    category: cat,
                    allPeople: widget.allPeople,
                    parentLineDefaultOwners: widget.line.defaultOwnerIds,
                    currencySymbol: widget.currencySymbol,
                    onEdit: () => widget.onEditItem(item),
                    onDelete: () => widget.onDeleteItem(item),
                  );
                },
              ),
          ],
        ],
      ),
    );
  }
}
