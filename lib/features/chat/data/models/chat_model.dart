import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  const ChatModel({
    required this.chatId,
    required this.doctorId,
    required this.doctorName,
    required this.doctorAvatar,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    required this.isReadBySub,
    required this.isOnline,
  });

  final String chatId;
  final String doctorId;
  final String doctorName;
  final String doctorAvatar;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isReadBySub;
  final bool isOnline;

  String get firstName {
    final parts = doctorName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return doctorName;
    final first = parts.first;
    if (first.toLowerCase().startsWith('dr.')) {
      return parts.length > 1 ? parts[1] : first;
    }
    return first;
  }

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      chatId: json['chatId'] as String? ?? json['id'] as String? ?? '',
      doctorId: json['doctorId'] as String? ?? '',
      doctorName: json['doctorName'] as String? ?? '',
      doctorAvatar: json['doctorAvatar'] as String? ?? '',
      lastMessage: json['lastMessage'] as String? ?? '',
      lastMessageTime: _parseDateTime(json['lastMessageTime']),
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      isReadBySub: json['isReadBySub'] as bool? ?? false,
      isOnline: json['isOnline'] as bool? ?? false,
    );
  }

  factory ChatModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return ChatModel.fromJson({
      ...data,
      'chatId': doc.id,
    });
  }

  Map<String, dynamic> toJson() {
    return {
      'chatId': chatId,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorAvatar': doctorAvatar,
      'lastMessage': lastMessage,
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
      'unreadCount': unreadCount,
      'isReadBySub': isReadBySub,
      'isOnline': isOnline,
    };
  }

  ChatModel copyWith({
    String? chatId,
    String? doctorId,
    String? doctorName,
    String? doctorAvatar,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
    bool? isReadBySub,
    bool? isOnline,
  }) {
    return ChatModel(
      chatId: chatId ?? this.chatId,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      doctorAvatar: doctorAvatar ?? this.doctorAvatar,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      isReadBySub: isReadBySub ?? this.isReadBySub,
      isOnline: isOnline ?? this.isOnline,
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
}
