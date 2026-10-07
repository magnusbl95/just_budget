import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final int iconCodePoint;
  final int colorHex;
  final bool isDefault;

  const Category({
    required this.id,
    required this.name,
    required this.iconCodePoint,
    required this.colorHex,
    this.isDefault = true,
  });

  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'iconCodePoint': iconCodePoint,
        'colorHex': colorHex,
        'isDefault': isDefault,
      };

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json['id'] as String,
        name: json['name'] as String,
        iconCodePoint: json['iconCodePoint'] as int,
        colorHex: json['colorHex'] as int,
        isDefault: json['isDefault'] as bool? ?? true,
      );

  static List<Category> get defaultCategories => [
        const Category(
          id: 'cat_housing',
          name: 'Housing & Rent',
          iconCodePoint: 0xe318, // Icons.home
          colorHex: 0xFF2E7D32,
        ),
        const Category(
          id: 'cat_groceries',
          name: 'Groceries',
          iconCodePoint: 0xe59c, // Icons.shopping_cart
          colorHex: 0xFF388E3C,
        ),
        const Category(
          id: 'cat_dining',
          name: 'Dining & Drinks',
          iconCodePoint: 0xe57a, // Icons.restaurant
          colorHex: 0xFFE65100,
        ),
        const Category(
          id: 'cat_transport',
          name: 'Transportation',
          iconCodePoint: 0xe1d7, // Icons.directions_car
          colorHex: 0xFF0277BD,
        ),
        const Category(
          id: 'cat_utilities',
          name: 'Utilities & Bills',
          iconCodePoint: 0xe3ae, // Icons.lightbulb
          colorHex: 0xFFF57F17,
        ),
        const Category(
          id: 'cat_health',
          name: 'Health & Wellness',
          iconCodePoint: 0xe3ab, // Icons.local_hospital / favorite
          colorHex: 0xFFC2185B,
        ),
        const Category(
          id: 'cat_entertainment',
          name: 'Entertainment',
          iconCodePoint: 0xe40f, // Icons.movie
          colorHex: 0xFF7B1FA2,
        ),
        const Category(
          id: 'cat_shopping',
          name: 'Shopping & Gear',
          iconCodePoint: 0xe59b, // Icons.shopping_bag
          colorHex: 0xFFD84315,
        ),
        const Category(
          id: 'cat_income_career',
          name: 'Salary & Career',
          iconCodePoint: 0xe6f2, // Icons.work
          colorHex: 0xFF00695C,
        ),
        const Category(
          id: 'cat_investing',
          name: 'Investments',
          iconCodePoint: 0xe655, // Icons.trending_up
          colorHex: 0xFF4A148C,
        ),
        const Category(
          id: 'cat_savings',
          name: 'Savings & Reserve',
          iconCodePoint: 0xe040, // Icons.savings
          colorHex: 0xFF00838F,
        ),
        const Category(
          id: 'cat_other',
          name: 'General & Other',
          iconCodePoint: 0xe3e6, // Icons.more_horiz
          colorHex: 0xFF546E7A,
        ),
      ];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
