import 'package:flutter/material.dart';
import '../../domain/models/person.dart';
import '../../view_models/app_settings_view_model.dart';
import '../../view_models/budget_view_model.dart';
import '../core/person_avatar_chip.dart';

class ManagePeopleDialog extends StatefulWidget {
  final AppSettingsViewModel settingsViewModel;
  final BudgetViewModel budgetViewModel;

  const ManagePeopleDialog({
    super.key,
    required this.settingsViewModel,
    required this.budgetViewModel,
  });

  @override
  State<ManagePeopleDialog> createState() => _ManagePeopleDialogState();
}

class _ManagePeopleDialogState extends State<ManagePeopleDialog> {
  final _nameController = TextEditingController();
  int _selectedColorHex = 0xFF006C4C;

  static const List<int> _palette = [
    0xFF006C4C, // Emerald
    0xFF0277BD, // Blue
    0xFFC2185B, // Rose
    0xFF7B1FA2, // Purple
    0xFFE65100, // Orange
    0xFF00838F, // Cyan
    0xFF4E342E, // Brown
    0xFF37474F, // Slate
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _editPerson(Person person) async {
    final nameController = TextEditingController(text: person.name);
    var selectedColorHex = person.colorHex;

    final updatedPerson = await showDialog<Person>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Person'),
              content: SizedBox(
                width: 360,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      autofocus: true,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Person Name',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Color',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final c in _palette)
                          GestureDetector(
                            onTap: () =>
                                setDialogState(() => selectedColorHex = c),
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: Color(c),
                                shape: BoxShape.circle,
                                border: selectedColorHex == c
                                    ? Border.all(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                        width: 2.2)
                                    : Border.all(
                                        color: Colors.transparent, width: 2.2),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final updatedName = nameController.text.trim();
                    if (updatedName.isEmpty) {
                      return;
                    }
                    Navigator.of(context).pop(person.copyWith(
                      name: updatedName,
                      colorHex: selectedColorHex,
                    ));
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (updatedPerson != null) {
      await widget.settingsViewModel.updatePerson(updatedPerson);
      setState(() {});
    }
  }

  Future<void> _confirmDeletePerson(Person person) async {
    if (widget.budgetViewModel.budget.isPersonAssignedToItem(person.id)) return;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${person.name}?'),
        content: const Text('This person will be removed from your household.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true &&
        !widget.budgetViewModel.budget.isPersonAssignedToItem(person.id)) {
      await widget.settingsViewModel.deletePerson(person.id);
      if (mounted) setState(() {});
    }
  }

  void _addPerson() {
    final text = _nameController.text.trim();
    if (text.isNotEmpty) {
      widget.settingsViewModel.addPerson(text, _selectedColorHex);
      _nameController.clear();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return ListenableBuilder(
      listenable: widget.budgetViewModel,
      builder: (context, _) {
        final people = widget.settingsViewModel.people;
        return AlertDialog(
          title: const Text('Manage People & Household'),
          content: SizedBox(
            width: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Add people to track individual shares on budget items and lines.',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 16),

                // Input to add new person
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Add Person Name',
                          hintText: 'e.g. Alex, Sam',
                          prefixIcon: Icon(Icons.person_add_alt_rounded),
                        ),
                        onSubmitted: (_) => _addPerson(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _addPerson,
                      child: const Text('Add'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Color choice for new person
                Row(
                  children: [
                    Text(
                      'Color: ',
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                    for (final c in _palette)
                      GestureDetector(
                        onTap: () => setState(() => _selectedColorHex = c),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: Color(c),
                            shape: BoxShape.circle,
                            border: _selectedColorHex == c
                                ? Border.all(
                                    color: colorScheme.onSurface, width: 2.2)
                                : null,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 8),

                // Existing People List
                if (people.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        'No people added yet.',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: colorScheme.outline),
                      ),
                    ),
                  )
                else
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 220),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: people.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final p = people[index];
                        final isAssigned = widget.budgetViewModel.budget
                            .isPersonAssignedToItem(p.id);
                        return ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: PersonAvatarChip(
                              person: p, showName: false, size: 28),
                          title: Text(p.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Edit person',
                                icon: const Icon(Icons.edit_outlined, size: 20),
                                onPressed: () => _editPerson(p),
                              ),
                              IconButton(
                                tooltip: isAssigned
                                    ? 'Cannot delete: assigned to budget items'
                                    : 'Delete person',
                                icon: const Icon(Icons.delete_outline_rounded,
                                    size: 20, color: Colors.red),
                                onPressed: isAssigned
                                    ? null
                                    : () => _confirmDeletePerson(p),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }
}
