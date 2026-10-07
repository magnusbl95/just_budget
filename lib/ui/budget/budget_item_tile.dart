import 'package:flutter/material.dart';
import '../../domain/models/budget_item.dart';
import '../../domain/models/category.dart';
import '../../domain/models/person.dart';
import '../../utils/currency_formatter.dart';
import '../core/activity_badge.dart';
import '../core/person_avatar_chip.dart';
import '../core/timeline_badge.dart';

class BudgetItemTile extends StatelessWidget {
  final BudgetItem item;
  final Category? category;
  final List<Person> allPeople;
  final List<String> parentLineDefaultOwners;
  final String currencySymbol;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const BudgetItemTile({
    super.key,
    required this.item,
    required this.category,
    required this.allPeople,
    this.parentLineDefaultOwners = const [],
    this.currencySymbol = r'$',
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Resolve owners
    final effectiveOwnerIds = item.getEffectiveOwners(parentLineDefaultOwners);
    final owners = effectiveOwnerIds
        .map((id) => allPeople.firstWhere((p) => p.id == id, orElse: () => Person(id: id, name: 'Unknown')))
        .toList();

    final isInherited = item.ownerIds.isEmpty && parentLineDefaultOwners.isNotEmpty;
    final splitAmount = item.sharePerOwner(parentLineDefaultOwners);

    return InkWell(
      onTap: onEdit,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Icon Badge
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Color(category?.colorHex ?? 0xFF006C4C).withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: Icon(
                category?.icon ?? Icons.label_outline_rounded,
                color: Color(category?.colorHex ?? 0xFF006C4C),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // Item Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      // Nominal amount & timeline
                      Text(
                        '${CurrencyFormatter.format(item.amount, symbol: currencySymbol)} ${item.timeline.suffix}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),

                  // Sub-row: Activity + Timeline + Normalized Monthly
                  Row(
                    children: [
                      ActivityBadge(activity: item.activity, compact: true),
                      const SizedBox(width: 6),
                      TimelineBadge(timeline: item.timeline),
                      const Spacer(),
                      // If not monthly, show normalized monthly impact
                      if (item.timeline.name != 'monthly')
                        Text(
                          '~${CurrencyFormatter.format(item.normalizedMonthlyAmount, symbol: currencySymbol)}/mo',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),

                  // Owners & Split Info
                  if (owners.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        MultiOwnerStack(owners: owners, size: 20),
                        if (owners.length > 1) ...[
                          const SizedBox(width: 6),
                          Text(
                            '(${CurrencyFormatter.format(splitAmount, symbol: currencySymbol)} each)',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                        if (isInherited) ...[
                          const SizedBox(width: 4),
                          Text(
                            '• inherited',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.outline,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Action menu
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert_rounded, size: 18, color: colorScheme.onSurfaceVariant),
              padding: EdgeInsets.zero,
              onSelected: (val) {
                if (val == 'edit') onEdit();
                if (val == 'delete') onDelete();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('Edit Item'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 18, color: Colors.red),
                      const SizedBox(width: 8),
                      Text('Delete Item', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
