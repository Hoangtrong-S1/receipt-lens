import 'package:intl/intl.dart';

String formatVnd(num amount) => NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    ).format(amount);

String formatDate(DateTime date) => DateFormat('dd/MM/yyyy').format(date);
