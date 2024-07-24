// lib/pages/report_page/report_page.dart

import 'package:flutter/material.dart';
import '../models/conversation_record.dart';
import '../services/conversation_repository.dart';
import 'package:intl/intl.dart';

class ReportPage extends StatelessWidget {
  final ConversationRepository repository;

  const ReportPage({Key? key, required this.repository}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sortedDates = repository.eventMap.keys.toList()
      ..sort((a, b) => b.compareTo(a));
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: sortedDates.length,
              itemBuilder: (context, index) {
                final date = sortedDates[index];
                final records = repository.eventMap[date]!;
                return ExpansionTile(
                  title: Text(DateFormat('yyyy年MM月dd日').format(date)),
                  children: records
                      .map((record) => _buildRecordTile(record))
                      .toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordTile(ConversationRecord record) {
    return ListTile(
      title: Text(record.reflection),
      subtitle: Row(
        children: List.generate(5, (index) {
          return Icon(
            index < record.rating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 20,
          );
        }),
      ),
    );
  }
}
