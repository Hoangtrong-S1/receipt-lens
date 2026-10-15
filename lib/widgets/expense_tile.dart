import 'dart:io';

import 'package:flutter/material.dart';

import '../core/utils/formatters.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';

class ExpenseTile extends StatelessWidget {
  const ExpenseTile({super.key, required this.expense, this.onDelete});
  final Expense expense;
  final VoidCallback? onDelete;
  @override
  Widget build(BuildContext context) => Dismissible(
    key: ValueKey(expense.id),
    direction: onDelete == null ? DismissDirection.none : DismissDirection.endToStart,
    onDismissed: (_) => onDelete?.call(),
    background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 22), color: Colors.red, child: const Icon(Icons.delete_outline, color: Colors.white)),
    child: ListTile(
      leading: _ImageOrIcon(expense: expense),
      title: Text(expense.merchant, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text('${formatDate(expense.transactionDate)} · ${expense.category.label}'),
      trailing: Text(formatVnd(expense.amount), style: const TextStyle(fontWeight: FontWeight.w700)),
    ),
  );
}

class _ImageOrIcon extends StatelessWidget {
  const _ImageOrIcon({required this.expense});
  final Expense expense;
  @override
  Widget build(BuildContext context) {
    if (expense.imagePath != null && File(expense.imagePath!).existsSync()) {
      return ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(File(expense.imagePath!), width: 48, height: 48, fit: BoxFit.cover));
    }
    return CircleAvatar(backgroundColor: expense.category.color.withOpacity(.15), child: Icon(expense.category.icon, color: expense.category.color));
  }
}
