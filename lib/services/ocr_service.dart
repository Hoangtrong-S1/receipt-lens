import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../models/expense_category.dart';
import '../models/receipt_draft.dart';

class OcrService {
  final TextRecognizer _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<ReceiptDraft> scan(String imagePath) async {
    final input = InputImage.fromFile(File(imagePath));
    final result = await _recognizer.processImage(input);
    final text = result.text;
    return ReceiptDraft(
      imagePath: imagePath,
      merchant: _merchant(text),
      amount: _total(text),
      transactionDate: _date(text),
      category: _category(text),
      rawText: text,
    );
  }

  Future<void> dispose() => _recognizer.close();

  double? _total(String source) {
    final labelled = RegExp(
      r'(?:grand\s*total|total\s*(?:amount|payment|due)?|t[oô]ng\s*(?:c[oộ]ng|thanh\s*to[aá]n)?|c[oộ]ng\s*ti[eề]n)\s*[:\-]?\s*([\d.,\s]+)\s*(?:vnd|vnđ|đ|₫)?',
      caseSensitive: false,
    ).allMatches(source);
    final candidates = <double>[];
    for (final match in labelled) {
      final value = _money(match.group(1) ?? '');
      if (value != null) candidates.add(value);
    }
    if (candidates.isNotEmpty) return candidates.reduce((a, b) => a > b ? a : b);

    final money = RegExp(r'\b([\d]{1,3}(?:[.,\s][\d]{3})+|\d{4,})\s*(?:vnd|vnđ|đ|₫)', caseSensitive: false)
        .allMatches(source)
        .map((m) => _money(m.group(1) ?? ''))
        .whereType<double>();
    return money.isEmpty ? null : money.reduce((a, b) => a > b ? a : b);
  }

  double? _money(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return null;
    final amount = double.tryParse(digits);
    return amount != null && amount > 500 ? amount : null;
  }

  DateTime? _date(String source) {
    final match = RegExp(r'\b(0?[1-9]|[12]\d|3[01])[\/-](0?[1-9]|1[0-2])[\/-](\d{2,4})\b').firstMatch(source);
    if (match == null) return null;
    final day = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    var year = int.parse(match.group(3)!);
    if (year < 100) year += 2000;
    try {
      final date = DateTime(year, month, day);
      return date.day == day && date.month == month ? date : null;
    } on ArgumentError {
      return null;
    }
  }

  String _merchant(String source) {
    final ignored = RegExp(r'(total|t[oô]ng|date|ng[aà]y|phone|tel|mst|tax|cash|change|ti[eề]n|invoice|h[oó]a\s*đ[oơ]n)', caseSensitive: false);
    for (final line in source.split(RegExp(r'\r?\n'))) {
      final value = line.trim().replaceAll(RegExp(r'\s+'), ' ');
      if (value.length >= 3 && value.length <= 60 && RegExp(r'[A-Za-zÀ-ỹ]').hasMatch(value) && !ignored.hasMatch(value)) {
        return value;
      }
    }
    return 'Unknown merchant';
  }

  ExpenseCategory _category(String source) {
    final text = source.toLowerCase();
    if (RegExp(r'coffee|cafe|restaurant|food|com |pho|tea|milk|pizza|mart|market|si[eê]u\s*th[iị]').hasMatch(text)) return ExpenseCategory.food;
    if (RegExp(r'book|s[aá]ch|stationery|v[aă]n\s*ph[oò]ng|course|kh[oó]a\s*h[oọ]c').hasMatch(text)) return ExpenseCategory.study;
    if (RegExp(r'grab|taxi|bus|x[eé]|petrol|gas|x[aă]ng').hasMatch(text)) return ExpenseCategory.travel;
    if (RegExp(r'laptop|phone|đi[eệ]n\s*tho[aạ]i|keyboard|tech|gear').hasMatch(text)) return ExpenseCategory.gear;
    if (RegExp(r'cinema|movie|game|netflix|karaoke').hasMatch(text)) return ExpenseCategory.entertainment;
    return ExpenseCategory.other;
  }
}
