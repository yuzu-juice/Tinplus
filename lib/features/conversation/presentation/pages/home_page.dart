import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/conversation_record.dart';
import '../../../../core/utils/shared_prefs.dart';
import '../widgets/calendar_widget.dart';
import '../widgets/conversation_button.dart';
import '../widgets/date_navigator.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _currentIndex = 1;
  DateTime _selectedDate = DateTime.now();
  Map<DateTime, List<ConversationRecord>> eventMap = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final data = await SharedPrefs.loadData();
    setState(() {
      eventMap = data;
    });
  }

  Future<void> _addConversationRecord(DateTime date, String reflection, int rating) async {
    final record = ConversationRecord(date: date, reflection: reflection, rating: rating);
    setState(() {
      final key = DateTime(date.year, date.month, date.day);
      if (!eventMap.containsKey(key)) {
        eventMap[key] = [];
      }
      eventMap[key]!.add(record);
    });
    await SharedPrefs.saveData(eventMap);
  }

  Future<void> _showReflectionDialog() async {
    String reflection = '';
    int rating = 3;

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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                          ),
                          onPressed: () {
                            setState(() {
                              rating = index + 1;
                            });
                          },
                        );
                      }),
                    ),
                    TextField(
                      decoration: const InputDecoration(hintText: '反省文を入力してください'),
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
                    _addConversationRecord(_selectedDate, reflection, rating);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tinplus🌵'),
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildRecordContent();
      case 1:
        return _buildReportContent();
      default:
        return _buildRecordContent();
    }
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: '記録する'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'レポート'),
      ],
    );
  }

  Widget _buildRecordContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          DateNavigator(
            selectedDate: _selectedDate,
            onDateChanged: (date) {
              setState(() {
                _selectedDate = date;
              });
            },
          ),
          const SizedBox(height: 20),
          ConversationButton(
            onPressed: _showReflectionDialog,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: CalendarWidget(
              selectedDate: _selectedDate,
              eventMap: eventMap,
              onDaySelected: (selectedDay) {
                setState(() {
                  _selectedDate = selectedDay;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportContent() {
    final sortedDates = eventMap.keys.toList()..sort((a, b) => b.compareTo(a));
    return ListView.builder(
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final records = eventMap[date]!;
        return ExpansionTile(
          title: Text(DateFormat('yyyy年MM月dd日').format(date)),
          initiallyExpanded: true,
          children: records.map((record) {
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
          }).toList(),
        );
      },
    );
  }
}
