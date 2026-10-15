import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/utils/formatters.dart';
import '../providers/expense_provider.dart';
import '../widgets/expense_donut_chart.dart';
import '../widgets/expense_tile.dart';
import '../widgets/weekly_bar_chart.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final state = context.watch<ExpenseProvider>();
    return SafeArea(child: Scaffold(
      appBar: AppBar(title: const Text('Receipt Lens', style: TextStyle(fontWeight: FontWeight.w800))),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: state.loadExpenses,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 104),
                children: [
                  _BalanceCard(total: state.total, count: state.expenses.length),
                  const SizedBox(height: 20),
                  Text('Spending by category', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Card(child: Padding(padding: const EdgeInsets.all(16), child: ExpenseDonutChart(data: state.categoryTotals))),
                  const SizedBox(height: 20),
                  Text('Last 7 days', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Card(child: Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 4), child: WeeklyBarChart(data: state.weeklyTotals))),
                  const SizedBox(height: 20),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Recent receipts', style: Theme.of(context).textTheme.titleLarge),
                    Text('${state.expenses.length} saved', style: Theme.of(context).textTheme.bodySmall),
                  ]),
                  const SizedBox(height: 6),
                  if (state.expenses.isEmpty)
                    const Padding(padding: EdgeInsets.all(28), child: Center(child: Text('Scan your first receipt to see spending insights.')))
                  else
                    ...state.expenses.take(3).map((expense) => Card(margin: const EdgeInsets.only(bottom: 8), child: ExpenseTile(expense: expense))),
                ],
              ),
            ),
    ));
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.total, required this.count});
  final double total;
  final int count;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(24)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('All-time spending', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary.withOpacity(.76))),
      const SizedBox(height: 6),
      Text(formatVnd(total), style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 31, fontWeight: FontWeight.w800)),
      const SizedBox(height: 13),
      Text('$count receipt${count == 1 ? '' : 's'} stored locally', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary.withOpacity(.8))),
    ]),
  );
}
