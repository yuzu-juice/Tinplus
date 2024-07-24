import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/conversation_record.dart';
import '../utils/date_utils.dart' as date_utils;

class CalendarWidget extends StatelessWidget {
  final DateTime selectedDate;
  final Map<DateTime, List<ConversationRecord>> eventMap;
  final void Function(DateTime, DateTime) onDaySelected;

  const CalendarWidget({
    Key? key,
    required this.selectedDate,
    required this.eventMap,
    required this.onDaySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.now(),
      focusedDay: selectedDate,
      selectedDayPredicate: (day) =>
          date_utils.DateUtils.isSameDay(selectedDate, day),
      onDaySelected: (selectedDay, focusedDay) {
        onDaySelected(selectedDay, focusedDay);
      },
      eventLoader: _getEventsForDay,
      calendarStyle: _buildCalendarStyle(),
      headerStyle: _buildHeaderStyle(),
      calendarBuilders: _buildCalendarBuilders(),
    );
  }

  List<ConversationRecord> _getEventsForDay(DateTime day) {
    final key = date_utils.DateUtils.truncateToDate(day);
    return eventMap[key] ?? [];
  }

  CalendarStyle _buildCalendarStyle() {
    return const CalendarStyle(
      todayDecoration: BoxDecoration(
        color: Colors.blueGrey,
        shape: BoxShape.circle,
      ),
      selectedDecoration: BoxDecoration(
        color: Colors.green,
        shape: BoxShape.circle,
      ),
      markerDecoration: BoxDecoration(
        color: Colors.transparent,
      ),
    );
  }

  HeaderStyle _buildHeaderStyle() {
    return const HeaderStyle(
      formatButtonVisible: false,
      titleCentered: true,
    );
  }

  CalendarBuilders _buildCalendarBuilders() {
    return CalendarBuilders(
      markerBuilder: (context, date, events) {
        if (events.isNotEmpty) {
          return Positioned(
            right: 1,
            bottom: 1,
            child: Container(
              padding: const EdgeInsets.all(2),
              child: Text(
                '${events.length}回',
                style: const TextStyle(
                  color: Color.fromARGB(255, 147, 147, 147),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }
        return null;
      },
    );
  }
}
