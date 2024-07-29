import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/conversation_record.dart';

class ConversationService {
  static const String _baseUrl =
      'https://k60jc7sfx3.execute-api.ap-northeast-1.amazonaws.com/v1';

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
    } catch (e) {
      throw Exception('ネットワークエラーが発生しました: $e');
    }
  }

  Future<List<ConversationRecord>> listConversations(String userId) async {
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
          return result
              .map((data) => ConversationRecord.fromJson(data))
              .toList();
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
}
