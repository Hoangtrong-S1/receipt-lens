import 'expense_category.dart';

class Expense {
  const Expense({
    this.id,
    required this.merchant,
    required this.amount,
    required this.transactionDate,
    required this.category,
    this.imagePath,
    this.note,
    this.rawText,
  });

  final int? id;
  final String merchant;
  final double amount;
  final DateTime transactionDate;
  final ExpenseCategory category;
  final String? imagePath;
  final String? note;
  final String? rawText;

  Map<String, Object?> toMap() => {
        'id': id,
        'merchant': merchant,
        'amount': amount,
        'transaction_date': transactionDate.toIso8601String(),
        'category': category.name,
        'image_path': imagePath,
        'note': note,
        'raw_text': rawText,
      };

  factory Expense.fromMap(Map<String, Object?> map) => Expense(
        id: map['id'] as int?,
        merchant: map['merchant'] as String,
        amount: (map['amount'] as num).toDouble(),
        transactionDate: DateTime.parse(map['transaction_date'] as String),
        category: ExpenseCategoryX.fromName(map['category'] as String),
        imagePath: map['image_path'] as String?,
        note: map['note'] as String?,
        rawText: map['raw_text'] as String?,
      );
}
