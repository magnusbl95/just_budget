import 'package:flutter_test/flutter_test.dart';
import 'package:just_budget/domain/models/person.dart';

void main() {
  group('Person', () {
    test('initials use only the first letter', () {
      const alice = Person(id: 'p1', name: 'Alice');
      const maryJane = Person(id: 'p2', name: 'Mary Jane');
      const single = Person(id: 'p3', name: 'A');
      const blank = Person(id: 'p4', name: '   ');

      expect(alice.initials, equals('A'));
      expect(maryJane.initials, equals('M'));
      expect(single.initials, equals('A'));
      expect(blank.initials, equals('?'));
    });

    test('copyWith updates name and color without changing the id', () {
      const person = Person(id: 'p1', name: 'Alex', colorHex: 0xFF006C4C);

      final updated = person.copyWith(name: 'Alicia', colorHex: 0xFF0277BD);

      expect(updated.id, equals('p1'));
      expect(updated.name, equals('Alicia'));
      expect(updated.colorHex, equals(0xFF0277BD));
    });
  });
}
