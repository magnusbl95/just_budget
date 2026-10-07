import 'package:flutter/material.dart';
import '../../domain/models/person.dart';

class PersonAvatarChip extends StatelessWidget {
  final Person person;
  final bool showName;
  final double size;

  const PersonAvatarChip({
    super.key,
    required this.person,
    this.showName = true,
    this.size = 22,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final personColor = Color(person.colorHex);

    final avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: personColor.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(color: personColor, width: 1.2),
      ),
      alignment: Alignment.center,
      child: Text(
        person.initials,
        style: TextStyle(
          color: personColor,
          fontSize: size * 0.44,
          fontWeight: FontWeight.w800,
        ),
      ),
    );

    if (!showName) return avatar;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          avatar,
          const SizedBox(width: 5),
          Text(
            person.name,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class MultiOwnerStack extends StatelessWidget {
  final List<Person> owners;
  final double size;

  const MultiOwnerStack({
    super.key,
    required this.owners,
    this.size = 22,
  });

  @override
  Widget build(BuildContext context) {
    if (owners.isEmpty) return const SizedBox.shrink();

    if (owners.length == 1) {
      return PersonAvatarChip(person: owners.first, showName: true, size: size);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: size,
            width: size + (owners.length - 1) * (size * 0.6),
            child: Stack(
              children: [
                for (int i = 0; i < owners.length; i++)
                  Positioned(
                    left: i * (size * 0.6),
                    child: PersonAvatarChip(
                      person: owners[i],
                      showName: false,
                      size: size,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '${owners.length} owners (shared)',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
