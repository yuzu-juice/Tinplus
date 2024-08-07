import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/conversation_service.dart';
import '../models/conversation_record.dart';
import '../components/date_navigator.dart';
import '../components/segmented_control.dart';
import '../components/conversation_bar_chart.dart';

class GraphPage extends StatefulWidget {
  const GraphPage({super.key});

  @override
  GraphPageState createState() => GraphPageState();
}

class GraphPageState extends State<GraphPage> {
  final ConversationService _conversationService = ConversationService();
  List<ConversationRecord> _conversations = [];
  List<ConversationRecord> _filteredConversations = [];
  bool _isLoading = true;
  String _currentView = 'W'; // D: Day, W: Week, M: Month, Y: Year
  DateTime _selectedDate = DateTime.now();

  static const Map<String, int> _viewDurations = {
    'D': 1,
    'W': 7,
    'M': 30,
    'Y': 365,
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final List<ConversationRecord> conversations =
          await _conversationService.getLocalConversations();
      setState(() {
        _conversations = conversations;
        _filteredConversations = _filterConversations(conversations);
      });
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<ConversationRecord> _filterConversations(
      List<ConversationRecord> conversations) {
    final DateTime startDate = _getStartDate();
    final DateTime endDate = _getEndDate();

    return conversations.where((conversation) {
      return conversation.date.isAfter(startDate) &&
          conversation.date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  DateTime _getStartDate() {
    switch (_currentView) {
      case 'D':
        return _selectedDate;
      case 'W':
        return _selectedDate
            .subtract(Duration(days: _selectedDate.weekday - 1));
      case 'M':
        return DateTime(_selectedDate.year, _selectedDate.month - 4, 1);
      case 'Y':
        return DateTime(_selectedDate.year - 4, 1, 1);
      default:
        return _selectedDate;
    }
  }

  DateTime _getEndDate() {
    switch (_currentView) {
      case 'D':
        return _selectedDate;
      case 'W':
        return _getStartDate().add(const Duration(days: 6));
      case 'M':
        return DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
      case 'Y':
        return DateTime(_selectedDate.year, 12, 31);
      default:
        return _selectedDate;
    }
  }

  List<BarChartGroupData> _getBarGroups() {
    final Map<DateTime, int> groupedData = _initializeGroupedData();
    _populateGroupedData(groupedData);
    return _createBarChartGroups(groupedData);
  }

  Map<DateTime, int> _initializeGroupedData() {
    final Map<DateTime, int> groupedData = {};
    final DateTime startDate = _getStartDate();

    switch (_currentView) {
      case 'W':
        for (int i = 0; i < 7; i++) {
          final DateTime date = startDate.add(Duration(days: i));
          groupedData[DateTime(date.year, date.month, date.day)] = 0;
        }
        break;
      case 'M':
        for (int i = 0; i < 5; i++) {
          final DateTime date =
              DateTime(startDate.year, startDate.month + i, 1);
          groupedData[DateTime(date.year, date.month)] = 0;
        }
        break;
      case 'Y':
        for (int i = 0; i < 5; i++) {
          final DateTime date = DateTime(startDate.year + i, 1, 1);
          groupedData[DateTime(date.year)] = 0;
        }
        break;
    }

    return groupedData;
  }

  void _populateGroupedData(Map<DateTime, int> groupedData) {
    for (final ConversationRecord conversation in _filteredConversations) {
      final DateTime key = _getKeyForConversation(conversation);
      if (_currentView == 'W' && key.isBefore(_getStartDate())) continue;
      groupedData[key] = (groupedData[key] ?? 0) + 1;
    }
  }

  DateTime _getKeyForConversation(ConversationRecord conversation) {
    switch (_currentView) {
      case 'D':
      case 'W':
        return DateTime(conversation.date.year, conversation.date.month,
            conversation.date.day);
      case 'M':
        return DateTime(conversation.date.year, conversation.date.month);
      case 'Y':
        return DateTime(conversation.date.year);
      default:
        return conversation.date;
    }
  }

  List<BarChartGroupData> _createBarChartGroups(
      Map<DateTime, int> groupedData) {
    final List<MapEntry<DateTime, int>> sortedEntries =
        groupedData.entries.toList()..sort((a, b) => a.key.compareTo(b.key));

    return sortedEntries.map((entry) {
      return BarChartGroupData(
        x: entry.key.millisecondsSinceEpoch,
        barRods: [
          BarChartRodData(
            toY: entry.value.toDouble(),
            color: Colors.teal[300]!,
            width: 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();
  }

  double _getInterval() {
    final double maxY = _getMaxY();
    if (maxY < 10) return 1;
    if (maxY <= 50) return 5;
    if (maxY <= 100) return 10;
    if (maxY <= 500) return 50;
    return 100;
  }

  double _getMaxY() {
    final List<BarChartGroupData> barGroups = _getBarGroups();
    if (barGroups.isEmpty) return 10;
    final double maxY = barGroups
        .map((group) => group.barRods.first.toY)
        .reduce((a, b) => a > b ? a : b);
    return maxY < 10 ? 10 : maxY;
  }

  String _getBottomTitle(double value) {
    final DateTime date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
    switch (_currentView) {
      case 'D':
        return DateFormat('d').format(date);
      case 'W':
        return DateFormat('M/d').format(date);
      case 'M':
        return DateFormat('M月', 'ja').format(date);
      case 'Y':
        return DateFormat('yyyy').format(date);
      default:
        return '';
    }
  }

  void _onViewChanged(String? value) {
    if (value != null) {
      setState(() {
        _currentView = value;
        _filteredConversations = _filterConversations(_conversations);
      });
    }
  }

  void _onDateChanged(bool isNext) {
    setState(() {
      final int days = _viewDurations[_currentView] ?? 1;
      final Duration duration = Duration(days: days);

      if (isNext) {
        final DateTime newDate = _selectedDate.add(duration);
        if (_isValidNextDate(newDate)) {
          _selectedDate = newDate;
        }
      } else {
        _selectedDate = _selectedDate.subtract(duration);
      }

      _filteredConversations = _filterConversations(_conversations);
    });
  }

  bool _isValidNextDate(DateTime newDate) {
    final DateTime now = DateTime.now();
    switch (_currentView) {
      case 'W':
        return newDate.isBefore(now.add(Duration(days: 7 - now.weekday)));
      case 'M':
        return newDate.isBefore(DateTime(now.year, now.month + 1, 0));
      case 'Y':
        return newDate.isBefore(DateTime(now.year + 1));
      default:
        return newDate.isBefore(now.add(const Duration(days: 1)));
    }
  }

  String _getTitlesWidget(double value, TitleMeta meta, bool isBottom) {
    return isBottom ? _getBottomTitle(value) : value.toInt().toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CupertinoActivityIndicator())
          : _conversations.isEmpty
              ? const Center(child: Text('データがありません'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      SegmentedControl(
                        currentView: _currentView,
                        onViewChanged: _onViewChanged,
                      ),
                      DateNavigator(
                        currentView: _currentView,
                        selectedDate: _selectedDate,
                        onPrevious: () => _onDateChanged(false),
                        onNext: () => _onDateChanged(true),
                      ),
                      Expanded(
                        child: ConversationBarChart(
                          barGroups: _getBarGroups(),
                          interval: _getInterval(),
                          getBottomTitle: _getBottomTitle,
                          getTitlesWidget: _getTitlesWidget,
                          maxY: _getMaxY(),
                          animate: false,
                          animationDuration: Duration.zero,
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
