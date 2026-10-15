import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeeklyBarChart extends StatefulWidget {
  const WeeklyBarChart({super.key, required this.data});
  final Map<DateTime, double> data;

  @override
  State<WeeklyBarChart> createState() => _WeeklyBarChartState();
}

class _WeeklyBarChartState extends State<WeeklyBarChart> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  @override void initState() { super.initState(); _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..forward(); }
  @override void didUpdateWidget(covariant WeeklyBarChart oldWidget) { super.didUpdateWidget(oldWidget); if (oldWidget.data != widget.data) _controller.forward(from: 0); }
  @override void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 180,
    child: AnimatedBuilder(
      animation: CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      builder: (_, __) => CustomPaint(
        painter: _BarPainter(widget.data, _controller.value, Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.outlineVariant),
        child: const SizedBox.expand(),
      ),
    ),
  );
}

class _BarPainter extends CustomPainter {
  _BarPainter(this.data, this.progress, this.color, this.gridColor);
  final Map<DateTime, double> data;
  final double progress;
  final Color color;
  final Color gridColor;
  @override
  void paint(Canvas canvas, Size size) {
    const bottom = 26.0;
    final values = data.values.toList();
    final maxValue = max(1.0, values.fold(0.0, max));
    final chartHeight = size.height - bottom - 8;
    final gridPaint = Paint()..color = gridColor.withOpacity(.55)..strokeWidth = 1;
    for (var i = 1; i <= 3; i++) canvas.drawLine(Offset(0, chartHeight * i / 4), Offset(size.width, chartHeight * i / 4), gridPaint);
    final slot = size.width / max(1, values.length);
    final textPainter = TextPainter(textDirection: ui.TextDirection.ltr, textAlign: TextAlign.center);
    for (var i = 0; i < values.length; i++) {
      final height = chartHeight * values[i] / maxValue * progress;
      final rect = RRect.fromRectAndRadius(Rect.fromLTWH(i * slot + slot * .23, chartHeight - height, slot * .54, height), const Radius.circular(6));
      canvas.drawRRect(rect, Paint()..color = color);
      textPainter.text = TextSpan(text: DateFormat.E().format(data.keys.elementAt(i)).substring(0, 1), style: TextStyle(color: gridColor, fontSize: 11));
      textPainter.layout(maxWidth: slot);
      textPainter.paint(canvas, Offset(i * slot + (slot - textPainter.width) / 2, chartHeight + 8));
    }
  }
  @override bool shouldRepaint(covariant _BarPainter old) => old.data != data || old.progress != progress;
}
