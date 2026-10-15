import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_lens/models/expense.dart';
import 'package:receipt_lens/models/expense_category.dart';

void main() {
  test('Expense model serialization test', () {
    final expense = Expense(
      id: 1,
      merchant: 'Highlands Coffee',
      amount: 45000,
      transactionDate: DateTime(2026, 10, 15),
      category: ExpenseCategory.food,
    );

    final map = expense.toMap();
    expect(map['merchant'], 'Highlands Coffee');
    expect(map['amount'], 45000.0);
    expect(map['category'], 'food');

    final restored = Expense.fromMap(map);
    expect(restored.merchant, 'Highlands Coffee');
    expect(restored.amount, 45000.0);
    expect(restored.category, ExpenseCategory.food);
  });
}
