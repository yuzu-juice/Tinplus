import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateNavigator extends StatelessWidget {
  final String currentView;
  final DateTime selectedDate;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const DateNavigator({
    super.key,
    required this.currentView,
    required this.selectedDate,
    required this.onPrevious,
    required this.onNext,
  });

  String _getDateRangeText() {
    switch (currentView) {
      case 'D':
        return DateFormat('yyyy年M月d日').format(selectedDate);
      case 'W':
        final weekStart =
            selectedDate.subtract(Duration(days: selectedDate.weekday % 7 - 1));
        final weekEnd = weekStart.add(const Duration(days: 6));
        return '${DateFormat('M月d日').format(weekStart)} - ${DateFormat('M月d日').format(weekEnd)}';
      case 'M':
        return DateFormat('yyyy年M月').format(selectedDate);
      case 'Y':
        return DateFormat('yyyy年').format(selectedDate);
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: onPrevious,
          ),
          Text(
            _getDateRangeText(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}
