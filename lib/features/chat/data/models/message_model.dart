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
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.type,
    required this.imageUrl,
    required this.createdAt,
    required this.isRead,
    this.duration,
  });

  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final String type;
  final String imageUrl;
  final DateTime createdAt;
  final bool isRead;
  final String? duration;

  String get messageId => id;

  MessageType get messageType => MessageTypeX.fromFirestoreValue(type);

  String get content {
    if (messageType == MessageType.image) {
      return imageUrl.isNotEmpty ? imageUrl : text;
    }
    return text;
  }

  DateTime get timestamp => createdAt;

  factory MessageModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final rawType = data['type'] as String? ?? 'text';

    return MessageModel(
      id: doc.id,
      senderId: data['senderId'] as String? ?? '',
      senderName: data['senderName'] as String? ?? '',
      text: data['text'] as String? ?? data['content'] as String? ?? '',
      type: rawType,
      imageUrl: data['imageUrl'] as String? ?? '',
      createdAt: _parseDateTime(
        data['createdAt'] ?? data['timestamp'],
      ),
      isRead: data['isRead'] as bool? ?? false,
      duration: data['duration'] as String?,
    );
  }

  MessageModel copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? text,
    String? type,
    String? imageUrl,
    DateTime? createdAt,
    bool? isRead,
    Object? duration = _sentinel,
  }) {
    return MessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      text: text ?? this.text,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
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
