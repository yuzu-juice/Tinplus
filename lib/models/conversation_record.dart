import 'package:flutter/foundation.dart';

@immutable
class ConversationRecord {
  final DateTime date;
  final String comment;
  final int evaluation;
  final String userId;

  const ConversationRecord({
    required this.date,
    required this.comment,
    required this.evaluation,
    required this.userId,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'comment': comment,
        'evaluation': evaluation,
        'user_id': userId,
      };

  factory ConversationRecord.fromJson(Map<String, dynamic> json) =>
      ConversationRecord(
        date: DateTime.parse(json['date']),
        comment: json['comment'],
        evaluation: json['evaluation'],
        userId: json['user_id'],
      );

  ConversationRecord copyWith({
    DateTime? date,
    String? comment,
    int? evaluation,
    String? userId,
  }) {
    return ConversationRecord(
      date: date ?? this.date,
      comment: comment ?? this.comment,
      evaluation: evaluation ?? this.evaluation,
      userId: userId ?? this.userId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationRecord &&
          runtimeType == other.runtimeType &&
          date == other.date &&
          comment == other.comment &&
          evaluation == other.evaluation &&
          userId == other.userId;

  @override
  int get hashCode =>
      date.hashCode ^ comment.hashCode ^ evaluation.hashCode ^ userId.hashCode;
}
