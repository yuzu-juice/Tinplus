import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:idb_shim/idb.dart';
import 'package:idb_shim/idb_browser.dart';
import 'dart:convert';
import '../models/conversation_record.dart';

class ConversationService {
  static const String _baseUrl =
      'https://k60jc7sfx3.execute-api.ap-northeast-1.amazonaws.com/v1';
  static const String dbName = 'tinplusDatabase';
  static const String storeName = 'conversations';
  Database? _db;

  Future<void> _openDb() async {
    if (_db == null) {
      final idbFactory = getIdbFactory();
      _db = await idbFactory?.open(dbName, version: 1,
          onUpgradeNeeded: (VersionChangeEvent e) {
        final db = e.database;
        db.createObjectStore(storeName, autoIncrement: true);
      });
    }
  }

  Future<String> getUserId() async {
    try {
      final user = await Amplify.Auth.getCurrentUser();
      return user.username;
    } on AuthException catch (e) {
      throw Exception('ユーザー情報の取得に失敗しました: ${e.message}');
    }
  }

  Future<void> insertConversation(ConversationRecord conversation) async {
    final url = Uri.parse('$_baseUrl/data/insert');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(conversation.toJson()),
      );

      if (response.statusCode != 200) {
        throw Exception('データの保存中にエラーが発生しました');
      }

      // Exclude user_id when storing locally
      final localConversation = conversation.toJson()..remove('user_id');
      await _addConversationToLocal(localConversation);
    } catch (e) {
      throw Exception('ネットワークエラーが発生しました: $e');
    }
  }

  Future<List<ConversationRecord>> listConversations(String userId) async {
    final localData = await _getLocalConversations();
    if (localData.isNotEmpty) {
      return localData;
    }

    final url = Uri.parse('$_baseUrl/data/list');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final responseBody = json.decode(jsonResponse['body']);
        if (responseBody.containsKey('result') &&
            responseBody['result'] is List) {
          final List<dynamic> result = responseBody['result'];
          final conversations =
              result.map((data) => ConversationRecord.fromJson(data)).toList();

          await _saveConversationsToLocal(conversations);

          return conversations;
        } else {
          throw Exception('レスポンス形式が不正です');
        }
      } else {
        throw Exception('データの取得中にエラーが発生しました');
      }
    } catch (e) {
      throw Exception('ネットワークエラーが発生しました: $e');
    }
  }

  Future<List<ConversationRecord>> _getLocalConversations() async {
    await _openDb();
    final txn = _db!.transaction(storeName, idbModeReadOnly);
    final store = txn.objectStore(storeName);
    final records = await store.getAll();
    await txn.completed;
    return records
        .map((e) => ConversationRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveConversationsToLocal(
      List<ConversationRecord> conversations) async {
    await _openDb();
    final txn = _db!.transaction(storeName, idbModeReadWrite);
    final store = txn.objectStore(storeName);
    for (var conversation in conversations) {
      // Exclude user_id when storing locally
      final localConversation = conversation.toJson()..remove('user_id');
      await store.put(localConversation);
    }
    await txn.completed;
  }

  Future<void> _addConversationToLocal(
      Map<String, dynamic> conversation) async {
    await _openDb();
    final txn = _db!.transaction(storeName, idbModeReadWrite);
    final store = txn.objectStore(storeName);
    await store.put(conversation);
    await txn.completed;
  }
}
