import 'package:flutter/material.dart';
import 'record_page.dart' as record_page;
import 'graph_page.dart';
import 'report_page.dart' as report_page;
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tinplus🔥')),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          record_page.RecordPage(),
          GraphPage(),
          report_page.ReportPage(),
          SettingsPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: '記録する'),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'グラフ'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'レポート'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '設定'),
        ],
      ),
    );
  }
}
