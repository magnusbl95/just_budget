class Person {
  final String id;
  final String name;
  final int colorHex;

  const Person({
    required this.id,
    required this.name,
    this.colorHex = 0xFF006C4C,
  });

  String get initials {
    if (name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'colorHex': colorHex,
      };

  factory Person.fromJson(Map<String, dynamic> json) => Person(
        id: json['id'] as String,
        name: json['name'] as String,
        colorHex: json['colorHex'] as int? ?? 0xFF006C4C,
      );

  Person copyWith({
    String? id,
    String? name,
    int? colorHex,
  }) =>
      Person(
        id: id ?? this.id,
        name: name ?? this.name,
        colorHex: colorHex ?? this.colorHex,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Person && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
