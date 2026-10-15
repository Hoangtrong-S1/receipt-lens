import 'package:flutter/material.dart';

enum ExpenseCategory { food, study, travel, gear, entertainment, other }

extension ExpenseCategoryX on ExpenseCategory {
  String get label => switch (this) {
        ExpenseCategory.food => 'Food',
        ExpenseCategory.study => 'Study',
        ExpenseCategory.travel => 'Travel',
        ExpenseCategory.gear => 'Gear',
        ExpenseCategory.entertainment => 'Entertainment',
        ExpenseCategory.other => 'Other',
      };

  IconData get icon => switch (this) {
        ExpenseCategory.food => Icons.restaurant_rounded,
        ExpenseCategory.study => Icons.menu_book_rounded,
        ExpenseCategory.travel => Icons.directions_bus_rounded,
        ExpenseCategory.gear => Icons.devices_rounded,
        ExpenseCategory.entertainment => Icons.movie_rounded,
        ExpenseCategory.other => Icons.receipt_long_rounded,
      };

  Color get color => switch (this) {
        ExpenseCategory.food => const Color(0xFFFF7A59),
        ExpenseCategory.study => const Color(0xFF6C63FF),
        ExpenseCategory.travel => const Color(0xFF11A683),
        ExpenseCategory.gear => const Color(0xFFF4B740),
        ExpenseCategory.entertainment => const Color(0xFFE35D9A),
        ExpenseCategory.other => const Color(0xFF8792A2),
      };

  static ExpenseCategory fromName(String value) => ExpenseCategory.values.firstWhere(
        (item) => item.name == value,
        orElse: () => ExpenseCategory.other,
      );
}
