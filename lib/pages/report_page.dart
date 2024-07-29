import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../provider/conversation_provider.dart';
import '../models/conversation_record.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ConversationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage.isNotEmpty) {
            return Center(child: Text('エラー: ${provider.errorMessage}'));
          }

          return ListView.builder(
            itemCount: provider.groupedConversations.length,
            itemBuilder: (context, index) {
              final date = provider.groupedConversations.keys.elementAt(index);
              final conversations = provider.groupedConversations[date]!;
              return ExpansionTile(
                initiallyExpanded: true,
                title: Text(
                  DateFormat('yyyy年MM月dd日').format(date),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                children: conversations
                    .map((conversation) => _buildConversationTile(conversation))
                    .toList(),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildConversationTile(ConversationRecord conversation) {
    return ListTile(
      title: Text(conversation.comment),
      subtitle: Row(
        children: [
          const SizedBox(width: 10),
          ...List.generate(5, (index) {
            return Icon(
              index < conversation.evaluation ? Icons.star : Icons.star_border,
              color: Colors.amber,
              size: 20,
            );
          }),
        ],
      ),
    );
  }
}
