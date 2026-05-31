import 'package:cloud_firestore/cloud_firestore.dart';

import 'notification_type.dart';

class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.isRead,
    required this.relatedId,
  });

  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;
  final String relatedId;

  NotificationModel copyWith({
    String? id,
    String? userId,
    NotificationType? type,
    String? title,
    String? body,
    DateTime? createdAt,
    bool? isRead,
    String? relatedId,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      relatedId: relatedId ?? this.relatedId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.name,
      'title': title,
      'body': body,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
      'relatedId': relatedId,
    };
  }

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    return NotificationModel.fromJson(
      doc.data() as Map<String, dynamic>? ?? {},
      doc.id,
    );
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json, [String? id]) {
    final createdRaw = json['createdAt'];
    DateTime createdAt;
    if (createdRaw is Timestamp) {
      createdAt = createdRaw.toDate();
    } else if (createdRaw is DateTime) {
      createdAt = createdRaw;
    } else if (createdRaw is String) {
      createdAt = DateTime.tryParse(createdRaw) ?? DateTime.now();
    } else {
      createdAt = DateTime.now();
    }

    return NotificationModel(
      id: id ?? json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      type: _parseType(json['type'] as String?),
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      createdAt: createdAt,
      isRead: json['isRead'] as bool? ?? false,
      relatedId: json['relatedId'] as String? ?? '',
    );
  }

  static NotificationType _parseType(String? raw) {
    if (raw == null || raw.isEmpty) {
      return NotificationType.appointmentConfirmed;
    }

    if (raw == 'paymentAdded') {
      return NotificationType.paymentMethodAdded;
    }

    for (final value in NotificationType.values) {
      if (value.name == raw) return value;
    }
    return NotificationType.appointmentConfirmed;
  }
}
