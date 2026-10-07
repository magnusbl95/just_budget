import 'package:flutter/material.dart';
import '../../domain/models/budget_line.dart';
import '../../domain/models/person.dart';
import '../core/person_avatar_chip.dart';

class AddBudgetLineDialog extends StatefulWidget {
  final BudgetLine? existingLine;
  final List<Person> people;
  final void Function({
    required String name,
    required List<String> defaultOwnerIds,
  }) onSave;

  const AddBudgetLineDialog({
    super.key,
    this.existingLine,
    required this.people,
    required this.onSave,
  });

  @override
  State<AddBudgetLineDialog> createState() => _AddBudgetLineDialogState();
}

class _AddBudgetLineDialogState extends State<AddBudgetLineDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late List<String> _selectedOwnerIds;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existingLine?.name ?? '');
    _selectedOwnerIds = widget.existingLine != null
        ? List.from(widget.existingLine!.defaultOwnerIds)
        : [];
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: Text(widget.existingLine != null ? 'Edit Budget Line' : 'New Budget Line'),
      content: SizedBox(
        width: 440,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'A Budget Line groups multiple budget items together and summarizes their totals on the main budget list.',
                style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Budget Line Name',
                  hintText: 'e.g. Household & Living, Wealth Building',
                  prefixIcon: Icon(Icons.folder_outlined),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Please enter a name';
                  return null;
                },
              ),
              const SizedBox(height: 18),
              Text(
                'Default Owners (Inherited by child items)',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              if (widget.people.isEmpty)
                Text(
                  'No people defined yet. Add people in Settings to enable automatic owner inheritance.',
                  style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.outline),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: widget.people.map((p) {
                    final isSelected = _selectedOwnerIds.contains(p.id);
                    return FilterChip(
                      selected: isSelected,
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
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              widget.onSave(
                name: _nameController.text.trim(),
                defaultOwnerIds: _selectedOwnerIds,
              );
              Navigator.of(context).pop();
            }
          },
          child: Text(widget.existingLine != null ? 'Update' : 'Create Line'),
        ),
      ],
    );
  }
}
