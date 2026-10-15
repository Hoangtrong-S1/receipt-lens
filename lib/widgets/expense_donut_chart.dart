import 'dart:math';

import 'package:flutter/material.dart';

import '../core/utils/formatters.dart';
import '../models/expense_category.dart';

class ExpenseDonutChart extends StatefulWidget {
  const ExpenseDonutChart({super.key, required this.data});
  final Map<ExpenseCategory, double> data;

  @override
  State<ExpenseDonutChart> createState() => _ExpenseDonutChartState();
}

class _ExpenseDonutChartState extends State<ExpenseDonutChart> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 850))..forward();
  }

  @override
  void didUpdateWidget(covariant ExpenseDonutChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) _controller.forward(from: 0);
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final total = widget.data.values.fold(0.0, (a, b) => a + b);
    return Column(
      children: [
        SizedBox(
          height: 190,
          child: AnimatedBuilder(
            animation: CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
            builder: (_, __) => CustomPaint(
              painter: _DonutPainter(widget.data, _controller.value, Theme.of(context).colorScheme.outlineVariant),
              child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('Total', style: TextStyle(color: Colors.grey)),
                Text(formatVnd(total), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              ])),
            ),
          ),
        ),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: widget.data.entries.map((item) => _Legend(item.key, item.value)).toList(),
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend(this.category, this.amount);
  final ExpenseCategory category;
  final double amount;
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 9, height: 9, decoration: BoxDecoration(color: category.color, shape: BoxShape.circle)),
    const SizedBox(width: 5), Text('${category.label} ${formatVnd(amount)}', style: const TextStyle(fontSize: 11)),
  ]);
}

class _DonutPainter extends CustomPainter {
  _DonutPainter(this.data, this.progress, this.emptyColor);
  final Map<ExpenseCategory, double> data;
  final double progress;
  final Color emptyColor;
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final rect = Rect.fromCircle(center: center, radius: min(size.width, size.height) / 2 - 14);
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = 24..strokeCap = StrokeCap.round;
    final total = data.values.fold(0.0, (a, b) => a + b);
    if (total == 0) { canvas.drawCircle(center, rect.width / 2, paint..color = emptyColor); return; }
    var start = -pi / 2;
    for (final item in data.entries) {
      final sweep = (item.value / total) * 2 * pi * progress;
      canvas.drawArc(rect, start, sweep, false, paint..color = item.key.color);
      start += (item.value / total) * 2 * pi;
    }
  }
  @override bool shouldRepaint(covariant _DonutPainter old) => old.data != data || old.progress != progress;
}
