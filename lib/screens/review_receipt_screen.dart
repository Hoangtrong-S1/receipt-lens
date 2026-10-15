import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/utils/formatters.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../models/receipt_draft.dart';
import '../providers/expense_provider.dart';
import '../services/receipt_image_service.dart';

class ReviewReceiptScreen extends StatefulWidget {
  const ReviewReceiptScreen({super.key, required this.draft});
  final ReceiptDraft draft;
  @override State<ReviewReceiptScreen> createState() => _ReviewReceiptScreenState();
}

class _ReviewReceiptScreenState extends State<ReviewReceiptScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _merchant;
  late final TextEditingController _amount;
  late DateTime _date;
  late ExpenseCategory _category;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _merchant = TextEditingController(text: widget.draft.merchant);
    _amount = TextEditingController(text: widget.draft.amount?.toStringAsFixed(0) ?? '');
    _date = widget.draft.transactionDate ?? DateTime.now();
    _category = widget.draft.category;
  }
  @override void dispose() { _merchant.dispose(); _amount.dispose(); super.dispose(); }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final imagePath = await ReceiptImageService().cacheReceipt(widget.draft.imagePath);
    if (!mounted) return;
    final expense = Expense(
      merchant: _merchant.text.trim(),
      amount: _parseVnd(_amount.text),
      transactionDate: _date,
      category: _category,
      imagePath: imagePath,
      rawText: widget.draft.rawText,
    );
    final success = await context.read<ExpenseProvider>().add(expense);
    if (!mounted) return;
    setState(() => _saving = false);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Receipt saved locally. Charts updated.')));
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not save receipt.')));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Review receipt')),
    body: Form(
      key: _formKey,
      child: ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 30), children: [
        ClipRRect(borderRadius: BorderRadius.circular(18), child: Image.file(File(widget.draft.imagePath), height: 190, width: double.infinity, fit: BoxFit.cover)),
        const SizedBox(height: 18),
        Text('Confirm extracted information', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        const Text('OCR can make mistakes. Edit every field before saving.'),
        const SizedBox(height: 18),
        TextFormField(controller: _merchant, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'Merchant name', prefixIcon: Icon(Icons.storefront_outlined)), validator: (v) => v == null || v.trim().length < 2 ? 'Enter a merchant name' : null),
        const SizedBox(height: 12),
        TextFormField(controller: _amount, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Total amount (VND)', prefixIcon: Icon(Icons.payments_outlined)), validator: (v) => _isValidAmount(v) ? null : 'Enter a valid amount'),
        const SizedBox(height: 12),
        ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
          leading: const Icon(Icons.calendar_today_outlined),
          title: const Text('Transaction date'),
          subtitle: Text(formatDate(_date)),
          onTap: () async {
            final selected = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2020), lastDate: DateTime.now());
            if (selected != null) setState(() => _date = selected);
          },
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<ExpenseCategory>(
          value: _category,
          decoration: const InputDecoration(labelText: 'Category', prefixIcon: Icon(Icons.category_outlined)),
          items: ExpenseCategory.values.map((item) => DropdownMenuItem(value: item, child: Text(item.label))).toList(),
          onChanged: (value) => setState(() => _category = value!),
        ),
        const SizedBox(height: 18),
        ExpansionTile(title: const Text('View raw OCR text'), children: [Padding(padding: const EdgeInsets.all(12), child: SelectableText(widget.draft.rawText.isEmpty ? 'No text was detected.' : widget.draft.rawText))]),
        const SizedBox(height: 22),
        FilledButton.icon(onPressed: _saving ? null : _save, icon: _saving ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save_outlined), label: Text(_saving ? 'Saving…' : 'Confirm & save expense')),
      ]),
    ),
  );

  bool _isValidAmount(String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    return double.tryParse(digits) != null && digits.isNotEmpty;
  }

  double _parseVnd(String value) => double.parse(value.replaceAll(RegExp(r'[^0-9]'), ''));
}
