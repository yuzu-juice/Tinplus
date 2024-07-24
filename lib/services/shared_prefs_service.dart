import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SharedPrefsService {
  static const String _conversationRecordsKey = 'conversation_records';

  Future<List<dynamic>> getConversationRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_conversationRecordsKey);
    if (jsonString != null) {
      return json.decode(jsonString);
    } else {
      return [];
    }
  }

  Future<void> saveConversationRecords(
      List<Map<String, dynamic>> records) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_conversationRecordsKey, json.encode(records));
  }

  Future<void> clearConversationRecords() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_conversationRecordsKey);
  }
}
