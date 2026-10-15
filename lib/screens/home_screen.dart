import 'package:flutter/material.dart';

import 'dashboard_screen.dart';
import 'receipt_camera_screen.dart';
import 'transactions_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _index = 0;
  final _pages = const [DashboardScreen(), TransactionsScreen()];
  @override
  Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(index: _index, children: _pages),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ReceiptCameraScreen())),
      icon: const Icon(Icons.document_scanner_outlined),
      label: const Text('Scan receipt'),
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _index,
      onDestinationSelected: (value) => setState(() => _index = value),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.pie_chart_outline), selectedIcon: Icon(Icons.pie_chart), label: 'Overview'),
        NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Transactions'),
      ],
    ),
  );
}
