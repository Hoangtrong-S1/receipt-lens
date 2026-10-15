import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/expense_provider.dart';
import '../widgets/expense_tile.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final state = context.watch<ExpenseProvider>();
    return SafeArea(child: Scaffold(
      appBar: AppBar(title: const Text('Transactions', style: TextStyle(fontWeight: FontWeight.w800))),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.expenses.isEmpty
              ? const Center(child: Text('No expenses yet. Scan a receipt to add one.'))
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 104),
                  itemCount: state.expenses.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (_, index) {
                    final expense = state.expenses[index];
                    return Card(child: ExpenseTile(expense: expense, onDelete: () => state.remove(expense)));
                  },
                ),
    ));
  }
}
