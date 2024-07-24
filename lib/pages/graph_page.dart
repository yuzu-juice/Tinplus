import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/conversation_repository.dart';
import 'package:provider/provider.dart';

class GraphPage extends StatelessWidget {
  const GraphPage({Key? key}) : super(key: key); // Key パラメータを追加

  @override
  Widget build(BuildContext context) {
    final repository = Provider.of<ConversationRepository>(context);
    final records = repository.getAllRecords();

    // 日付ごとの平均評価を計算
    final Map<DateTime, double> averageRatings = {};
    for (var record in records) {
      final date =
          DateTime(record.date.year, record.date.month, record.date.day);
      if (!averageRatings.containsKey(date)) {
        averageRatings[date] = 0;
      }
      averageRatings[date] = (averageRatings[date]! + record.rating) / 2;
    }

    final sortedDates = averageRatings.keys.toList()..sort();
    final spots = sortedDates.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), averageRatings[entry.value]!);
    }).toList();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: false),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() >= 0 &&
                        value.toInt() < sortedDates.length) {
                      final date = sortedDates[value.toInt()];
                      return Text('${date.month}/${date.day}');
                    }
                    return const Text('');
                  },
                  reservedSize: 22,
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    return Text(value.toInt().toString());
                  },
                  reservedSize: 28,
                ),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: const Color(0xff37434d), width: 1),
            ),
            minX: 0,
            maxX: (sortedDates.length - 1).toDouble(),
            minY: 0,
            maxY: 5,
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: Colors.teal,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(show: false),
                belowBarData: BarAreaData(show: false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
