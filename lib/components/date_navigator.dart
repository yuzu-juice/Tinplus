import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateNavigator extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;

  const DateNavigator({
    Key? key,
    required this.selectedDate,
    required this.onDateChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            onDateChanged(selectedDate.subtract(const Duration(days: 1)));
          },
        ),
        Text(
          DateFormat('yyyy年MM月dd日').format(selectedDate),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: selectedDate.isBefore(DateTime.now())
              ? () {
                  onDateChanged(selectedDate.add(const Duration(days: 1)));
                }
              : null,
        ),
      ],
    );
  }
}
