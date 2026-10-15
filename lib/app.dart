import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'providers/expense_provider.dart';
import 'screens/home_screen.dart';
import 'services/database_service.dart';

class ReceiptLensApp extends StatelessWidget {
  const ReceiptLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ExpenseProvider(DatabaseService())..loadExpenses(),
      child: MaterialApp(
        title: 'Receipt Lens',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}
