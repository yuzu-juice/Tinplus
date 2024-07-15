import '../../domain/entities/conversation_record.dart';

class ConversationRecordModel extends ConversationRecord {
  ConversationRecordModel({
    required DateTime date,
    required String reflection,
    required int rating,
  }) : super(date: date, reflection: reflection, rating: rating);

  factory ConversationRecordModel.fromJson(Map<String, dynamic> json) {
    return ConversationRecordModel(
      date: DateTime.parse(json['date']),
      reflection: json['reflection'],
      rating: json['rating'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'reflection': reflection,
      'rating': rating,
    };
  }
}
