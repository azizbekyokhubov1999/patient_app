import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  const ReviewModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhoto,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String userName;
  final String userPhoto;
  final double rating;
  final String comment;
  final DateTime createdAt;

  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ReviewModel._fromMap(data, doc.id);
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map, String id) =>
      ReviewModel._fromMap(map, id);

  factory ReviewModel._fromMap(Map<String, dynamic> map, String id) {
    return ReviewModel(
      id: id,
      userId: map['userId'] as String? ?? '',
      userName: map['userName'] as String? ?? '',
      userPhoto: map['userPhoto'] as String? ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      comment: map['comment'] as String? ?? '',
      createdAt: _parseTimestamp(map['createdAt']),
    );
  }

  static DateTime _parseTimestamp(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}
