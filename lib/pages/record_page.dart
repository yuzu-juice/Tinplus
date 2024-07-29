import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../components/calendar_widget.dart';
import '../components/conversation_button.dart';
import '../models/conversation_record.dart';
import '../services/conversation_service.dart';
import '../provider/conversation_provider.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  RecordPageState createState() => RecordPageState();
}

class RecordPageState extends State<RecordPage> {
  late DateTime _selectedDate;
  int _rating = 3;
  String _userId = '';
  final ConversationService _conversationService = ConversationService();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final provider = Provider.of<ConversationProvider>(context, listen: false);
    _userId = await _conversationService.getUserId();
    provider.loadConversations();
  }

  Future<void> _showReflectionDialog() async {
    String reflection = '';
    setState(() {
      _rating = 3;
    });

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            return AlertDialog(
              title: const Text('会話の振り返り'),
              content: SizedBox(
                width: MediaQuery.of(dialogContext).size.width * 0.8,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 20),
                    _buildRatingStars(setState),
                    TextField(
                      decoration:
                          const InputDecoration(hintText: '反省文を入力してください'),
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      onChanged: (value) => reflection = value,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('キャンセル'),
                  onPressed: () => Navigator.of(dialogContext).pop(),
                ),
                _isSaving
                    ? const CircularProgressIndicator()
                    : TextButton(
                        child: const Text('保存'),
                        onPressed: () async {
                          setState(() {
                            _isSaving = true;
                          });
                          await _saveData(reflection);
                          setState(() {
                            _isSaving = false;
                          });
                          Navigator.of(dialogContext).pop();
                        },
                      ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _saveData(String reflection) async {
    if (_userId.isEmpty) {
      _showSnackBar('ユーザーIDが取得できていません。再ログインしてください。');
      return;
    }

    try {
      final conversation = ConversationRecord(
        date: _selectedDate,
        comment: reflection,
        evaluation: _rating,
        userId: _userId,
      );

      await Provider.of<ConversationProvider>(context, listen: false)
          .addConversation(conversation);
      _showSnackBar('データが正常に保存されました');
    } catch (e) {
      _showSnackBar(e.toString());
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildRatingStars(Function setState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < _rating ? Icons.star : Icons.star_border,
            color: Colors.amber,
          ),
          onPressed: () {
            setState(() {
              _rating = index + 1;
            });
          },
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ConversationProvider>(
        builder: (context, provider, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  DateFormat('yyyy年MM月dd日').format(_selectedDate),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ConversationButton(onPressed: _showReflectionDialog),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: SizedBox(
                      height: 400,
                      child: CalendarWidget(
                        selectedDate: _selectedDate,
                        eventMap: provider.groupedConversations,
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() => _selectedDate = selectedDay);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
