import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../features/conversation/domain/entities/conversation_record.dart';

class SharedPrefs {
  static Future<Map<DateTime, List<ConversationRecord>>> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString('conversation_records');
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      final Map<DateTime, List<ConversationRecord>> eventMap = {};
      for (var item in jsonList) {
        final record = ConversationRecord.fromJson(item);
        final date = DateTime(record.date.year, record.date.month, record.date.day);
        if (!eventMap.containsKey(date)) {
          eventMap[date] = [];
        }
        eventMap[date]!.add(record);
      }
      return eventMap;
    } else {
      return {};
    }
  }

  static Future<void> saveData(Map<DateTime, List<ConversationRecord>> eventMap) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> jsonList = [];
    for (var records in eventMap.values) {
      for (var record in records) {
        jsonList.add(record.toJson());
      }
    }
    await prefs.setString('conversation_records', json.encode(jsonList));
  }
}
