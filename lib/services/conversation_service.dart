import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:idb_shim/idb.dart';
import 'package:idb_shim/idb_browser.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'dart:convert';
import '../models/conversation_record.dart';

class ConversationService {
  static const String _baseUrl = 'https://api.tinplus.harvestful.tokyo';
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
    final cognitoPlugin = Amplify.Auth.getPlugin(AmplifyAuthCognito.pluginKey);
    final session = await cognitoPlugin.fetchAuthSession();
    final idToken = session.userPoolTokensResult.value.idToken.raw;
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': idToken},
        body: json.encode(conversation.toJson()),
      );

      if (response.statusCode != 200) {
        throw Exception('データの保存中にエラーが発生しました');
      }

      await _addConversationToLocal(conversation.toJson());
    } catch (e) {
      throw Exception('ネットワークエラーが発生しました: $e');
    }
  }

  Future<List<ConversationRecord>> listConversations(String userId) async {
    final localData = await getLocalConversations();
    if (localData.isNotEmpty) {
      return localData;
    }
    final url = Uri.parse('$_baseUrl/data/list');
    final cognitoPlugin = Amplify.Auth.getPlugin(AmplifyAuthCognito.pluginKey);
    final session = await cognitoPlugin.fetchAuthSession();
    final idToken = session.userPoolTokensResult.value.idToken.raw;
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': idToken},
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
          safePrint('Raw result: $result');
          final conversations = result.map((data) {
            data.remove('id');
            data.remove('user_id');
            safePrint('Processed data: $data');
            var record = ConversationRecord.fromJson(data);
            return record;
          }).toList();
          safePrint('Conversations before saving: $conversations');
          await _saveConversationsToLocal(conversations);
          safePrint('Conversations after saving: $conversations');

          return conversations;
        } else {
          throw Exception('レスポンス形式が不正です');
        }
      } else {
        throw Exception('データの取得中にエラーが発生しました');
      }
    } catch (e, stackTrace) {
      safePrint('Error in listConversations: $e');
      safePrint('Stack trace: $stackTrace');
      throw Exception('ネットワークエラーが発生しました: $e');
    }
  }

  Future<void> _saveConversationsToLocal(
      List<ConversationRecord> conversations) async {
    await _openDb();
    final txn = _db!.transaction(storeName, idbModeReadWrite);
    final store = txn.objectStore(storeName);
    for (var conversation in conversations) {
      final json = conversation.toJson();
      safePrint('Saving conversation: $json');
      await store.put(json);
    }
    await txn.completed;
  }

  Future<List<ConversationRecord>> getLocalConversations() async {
    await _openDb();
    final txn = _db!.transaction(storeName, idbModeReadOnly);
    final store = txn.objectStore(storeName);
    final records = await store.getAll();
    await txn.completed;
    safePrint('Local records: $records');
    return records
        .map((e) => ConversationRecord.fromJson(e as Map<String, dynamic>))
        .toList();
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
