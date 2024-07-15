class ConversationRecord {
  final DateTime date;
  final String reflection;
  final int rating;

  ConversationRecord({
    required this.date,
    required this.reflection,
    required this.rating,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'reflection': reflection,
        'rating': rating,
      };

  factory ConversationRecord.fromJson(Map<String, dynamic> json) => ConversationRecord(
        date: DateTime.parse(json['date']),
        reflection: json['reflection'],
        rating: json['rating'],
      );
}
