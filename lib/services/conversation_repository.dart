import '../models/conversation_record.dart';
import 'shared_prefs_service.dart';

class ConversationRepository {
  final SharedPrefsService _sharedPrefsService;
  Map<DateTime, List<ConversationRecord>> _eventMap = {};

  ConversationRepository(this._sharedPrefsService);

  Future<Map<DateTime, List<ConversationRecord>>> loadData() async {
    final jsonList = await _sharedPrefsService.getConversationRecords();
    _eventMap = _parseConversationRecords(jsonList);
    return _eventMap;
  }

  Future<void> saveData() async {
    final jsonList = _convertToJsonList(_eventMap);
    await _sharedPrefsService.saveConversationRecords(jsonList);
  }

  void addRecord(ConversationRecord record) {
    final date = DateTime(record.date.year, record.date.month, record.date.day);
    if (!_eventMap.containsKey(date)) {
      _eventMap[date] = [];
    }
    _eventMap[date]!.add(record);
    saveData();
  }

  List<ConversationRecord> getRecordsForDate(DateTime date) {
    final key = DateTime(date.year, date.month, date.day);
    return _eventMap[key] ?? [];
  }

  List<ConversationRecord> getAllRecords() {
    return _eventMap.values.expand((records) => records).toList();
  }

  Map<DateTime, List<ConversationRecord>> get eventMap => _eventMap;

  Map<DateTime, List<ConversationRecord>> _parseConversationRecords(
      List<dynamic> jsonList) {
    final Map<DateTime, List<ConversationRecord>> eventMap = {};
    for (var item in jsonList) {
      final record = ConversationRecord.fromJson(item);
      final date =
          DateTime(record.date.year, record.date.month, record.date.day);
      if (!eventMap.containsKey(date)) {
        eventMap[date] = [];
      }
      eventMap[date]!.add(record);
    }
    return eventMap;
  }

  List<Map<String, dynamic>> _convertToJsonList(
      Map<DateTime, List<ConversationRecord>> eventMap) {
    return eventMap.values
        .expand((records) => records)
        .map((record) => record.toJson())
        .toList();
  }
}
