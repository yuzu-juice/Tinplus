import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ConversationBarChart extends StatelessWidget {
  final List<BarChartGroupData> barGroups;
  final double interval;
  final double maxY;
  final String Function(double) getBottomTitle;
  final String Function(double, TitleMeta, bool) getTitlesWidget;
  final bool animate;
  final Duration animationDuration;

  const ConversationBarChart({
    super.key,
    required this.barGroups,
    required this.interval,
    required this.getBottomTitle,
    required this.getTitlesWidget,
    required this.maxY,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 250),
  });

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        maxY: maxY,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${getBottomTitle(group.x.toDouble())}\n',
                const TextStyle(color: Colors.white),
                children: <TextSpan>[
                  TextSpan(
                    text: '会話回数: ${rod.toY.toInt()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) =>
                  Text(getTitlesWidget(value, meta, true)),
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: interval,
              getTitlesWidget: (value, meta) =>
                  Text(getTitlesWidget(value, meta, false)),
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: barGroups,
      ),
    );
  }
}
