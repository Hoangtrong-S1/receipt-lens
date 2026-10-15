import 'expense_category.dart';

class ReceiptDraft {
  const ReceiptDraft({
    required this.imagePath,
    required this.merchant,
    required this.amount,
    required this.transactionDate,
    required this.category,
    required this.rawText,
  });

  final String imagePath;
  final String merchant;
  final double? amount;
  final DateTime? transactionDate;
  final ExpenseCategory category;
  final String rawText;
}
