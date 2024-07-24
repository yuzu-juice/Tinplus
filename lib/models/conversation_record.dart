import 'package:flutter/foundation.dart';

@immutable
class ConversationRecord {
  final DateTime date;
  final String reflection;
  final int rating;

  const ConversationRecord({
    required this.date,
    required this.reflection,
    required this.rating,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'reflection': reflection,
        'rating': rating,
      };

  factory ConversationRecord.fromJson(Map<String, dynamic> json) =>
      ConversationRecord(
        date: DateTime.parse(json['date']),
        reflection: json['reflection'],
        rating: json['rating'],
      );

  ConversationRecord copyWith({
    DateTime? date,
    String? reflection,
    int? rating,
  }) {
    return ConversationRecord(
      date: date ?? this.date,
      reflection: reflection ?? this.reflection,
      rating: rating ?? this.rating,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationRecord &&
          runtimeType == other.runtimeType &&
          date == other.date &&
          reflection == other.reflection &&
          rating == other.rating;

  @override
  int get hashCode => date.hashCode ^ reflection.hashCode ^ rating.hashCode;
}
