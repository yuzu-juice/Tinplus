import 'package:flutter/foundation.dart';
import '../../models/conversation_record.dart';
import '../../services/conversation_service.dart';

class ConversationProvider extends ChangeNotifier {
  final ConversationService _service = ConversationService();
  Map<DateTime, List<ConversationRecord>> _groupedConversations = {};
  bool _isLoading = false;
  String _errorMessage = '';

  Map<DateTime, List<ConversationRecord>> get groupedConversations =>
      _groupedConversations;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> loadConversations() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final userId = await _service.getUserId();
      final conversations = await _service.listConversations(userId);

      final grouped = <DateTime, List<ConversationRecord>>{};
      for (var conversation in conversations) {
        final date = DateTime(conversation.date.year, conversation.date.month,
            conversation.date.day);
        if (!grouped.containsKey(date)) {
          grouped[date] = [];
        }
        grouped[date]!.add(conversation);
      }

      _groupedConversations = Map.fromEntries(
          grouped.entries.toList()..sort((a, b) => b.key.compareTo(a.key)));
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addConversation(ConversationRecord conversation) async {
    try {
      await _service.insertConversation(conversation);
      await loadConversations(); // 会話を追加した後、すべての会話を再読み込み
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
