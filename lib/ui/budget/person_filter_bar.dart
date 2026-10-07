import 'package:flutter/material.dart';
import '../../domain/models/person.dart';
import '../core/person_avatar_chip.dart';

class PersonFilterBar extends StatelessWidget {
  final List<Person> people;
  final String? selectedPersonId;
  final ValueChanged<String?> onSelectPerson;

  const PersonFilterBar({
    super.key,
    required this.people,
    required this.selectedPersonId,
    required this.onSelectPerson,
  });

  @override
  Widget build(BuildContext context) {
    if (people.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          FilterChip(
            selected: selectedPersonId == null,
            label: const Text('All People'),
            avatar: const Icon(Icons.people_alt_outlined, size: 16),
            onSelected: (_) => onSelectPerson(null),
          ),
          const SizedBox(width: 8),
          for (final person in people) ...[
            FilterChip(
              selected: selectedPersonId == person.id,
              label: Text(person.name),
              avatar: PersonAvatarChip(person: person, showName: false, size: 18),
              onSelected: (_) => onSelectPerson(person.id),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}
