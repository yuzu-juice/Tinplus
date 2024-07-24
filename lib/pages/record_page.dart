import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../components/calendar_widget.dart';
import '../components/conversation_button.dart';
import '../models/conversation_record.dart';
import '../services/conversation_repository.dart';

class RecordPage extends StatefulWidget {
  final ConversationRepository repository;

  const RecordPage({Key? key, required this.repository}) : super(key: key);

  @override
  _RecordPageState createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  late DateTime _selectedDate;
  Map<DateTime, List<ConversationRecord>> _eventMap = {};
  int _rating = 3; // ここでratingを状態として保持

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await widget.repository.loadData();
    setState(() => _eventMap = data);
  }

  Future<void> _addConversationRecord(
      DateTime date, String reflection, int rating) async {
    widget.repository.addRecord(
        ConversationRecord(date: date, reflection: reflection, rating: rating));
    await _loadData();
  }

  Future<void> _showReflectionDialog() async {
    String reflection = '';
    setState(() {
      _rating = 3; // ダイアログを表示する前にratingをリセット
    });

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('会話の振り返り'),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 20),
                    _buildRatingStars(setState), // setStateを渡す
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
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: const Text('保存'),
                  onPressed: () {
                    _addConversationRecord(_selectedDate, reflection, _rating);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              DateFormat('yyyy年MM月dd日').format(_selectedDate),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ConversationButton(onPressed: _showReflectionDialog),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: SizedBox(
                  height: 400, // この高さは適宜調整してください
                  child: CalendarWidget(
                    selectedDate: _selectedDate,
                    eventMap: _eventMap,
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() => _selectedDate = selectedDay);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
