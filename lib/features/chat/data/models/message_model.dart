import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { text, image, audio }

extension MessageTypeX on MessageType {
  String get firestoreValue => name;

  static MessageType fromFirestoreValue(String? value) {
    switch (value) {
      case 'image':
        return MessageType.image;
      case 'audio':
        return MessageType.audio;
      default:
        return MessageType.text;
    }
  }
}

class MessageModel {
  const MessageModel({
    required this.messageId,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.content,
    required this.type,
    required this.timestamp,
    this.duration,
  });

  final String messageId;
  final String senderId;
  final String senderName;
  final String receiverId;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final String? duration;

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      messageId: json['messageId'] as String? ?? json['id'] as String? ?? '',
      senderId: json['senderId'] as String? ?? '',
      senderName: json['senderName'] as String? ?? '',
      receiverId: json['receiverId'] as String? ?? '',
      content: json['content'] as String? ?? '',
      type: MessageTypeX.fromFirestoreValue(json['type'] as String?),
      timestamp: _parseDateTime(json['timestamp']),
      duration: json['duration'] as String?,
    );
  }

  factory MessageModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return MessageModel.fromJson({
      ...data,
      'messageId': doc.id,
    });
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'senderId': senderId,
      'senderName': senderName,
      'receiverId': receiverId,
      'content': content,
      'type': type.firestoreValue,
      'timestamp': Timestamp.fromDate(timestamp),
      if (duration != null) 'duration': duration,
    };
  }

  MessageModel copyWith({
    String? messageId,
    String? senderId,
    String? senderName,
    String? receiverId,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    Object? duration = _sentinel,
  }) {
    return MessageModel(
      messageId: messageId ?? this.messageId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      duration: identical(duration, _sentinel)
          ? this.duration
          : duration as String?,
    );
  }

  static DateTime _parseDateTime(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return DateTime.now();
  }

  static const Object _sentinel = Object();
}
