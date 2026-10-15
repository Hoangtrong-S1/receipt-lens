import 'package:flutter/foundation.dart';

import '../models/expense.dart';
import '../models/expense_category.dart';
import '../services/database_service.dart';

class ExpenseProvider extends ChangeNotifier {
  ExpenseProvider(this._database);

  final DatabaseService _database;
  List<Expense> _expenses = [];
  bool _isLoading = true;
  String? _error;

  List<Expense> get expenses => List.unmodifiable(_expenses);
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get total => _expenses.fold(0, (sum, expense) => sum + expense.amount);

  Future<void> loadExpenses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _expenses = await _database.getExpenses();
    } catch (_) {
      _error = 'Could not open local expense data.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> add(Expense expense) async {
    try {
      final saved = await _database.insert(expense);
      _expenses = [saved, ..._expenses];
      notifyListeners();
      return true;
    } catch (_) {
      _error = 'Could not save this expense.';
      notifyListeners();
      return false;
    }
  }

  Future<void> remove(Expense expense) async {
    if (expense.id == null) return;
    await _database.delete(expense.id!);
    _expenses = _expenses.where((item) => item.id != expense.id).toList();
    notifyListeners();
  }

  Map<ExpenseCategory, double> get categoryTotals {
    final result = <ExpenseCategory, double>{};
    for (final item in _expenses) {
      result[item.category] = (result[item.category] ?? 0) + item.amount;
    }
    return result;
  }

  Map<DateTime, double> get weeklyTotals {
    final today = DateTime.now();
    final result = <DateTime, double>{};
    for (var offset = 6; offset >= 0; offset--) {
      final day = DateTime(today.year, today.month, today.day - offset);
      result[day] = 0;
    }
    for (final expense in _expenses) {
      final day = DateTime(expense.transactionDate.year, expense.transactionDate.month, expense.transactionDate.day);
      if (result.containsKey(day)) result[day] = result[day]! + expense.amount;
    }
    return result;
  }
}
