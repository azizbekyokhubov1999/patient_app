import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  const ChatModel({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.doctorName,
    required this.doctorImage,
    required this.doctorSpecialty,
    required this.patientName,
    required this.patientImage,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    required this.appointmentId,
    required this.createdAt,
    this.isOnline = true,
  });

  final String id;
  final String patientId;
  final String doctorId;
  final String doctorName;
  final String doctorImage;
  final String doctorSpecialty;
  final String patientName;
  final String patientImage;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final String appointmentId;
  final DateTime createdAt;

  /// UI mock: always show online indicator.
  final bool isOnline;

  String get chatId => id;

  String get doctorAvatar => doctorImage;

  bool get isReadBySub => unreadCount == 0;

  String get firstName {
    final parts = doctorName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return doctorName;
    final first = parts.first;
    if (first.toLowerCase().startsWith('dr.')) {
      return parts.length > 1 ? parts[1] : first;
    }
    return first;
  }

  factory ChatModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return ChatModel(
      id: doc.id,
      patientId: data['patientId'] as String? ?? '',
      doctorId: data['doctorId'] as String? ?? '',
      doctorName: data['doctorName'] as String? ?? '',
      doctorImage: data['doctorImage'] as String? ??
          data['doctorAvatar'] as String? ??
          '',
      doctorSpecialty: data['doctorSpecialty'] as String? ?? '',
      patientName: data['patientName'] as String? ?? '',
      patientImage: data['patientImage'] as String? ?? '',
      lastMessage: data['lastMessage'] as String? ?? '',
      lastMessageTime: _parseDateTime(data['lastMessageTime']),
      unreadCount: (data['unreadCount'] as num?)?.toInt() ?? 0,
      appointmentId: data['appointmentId'] as String? ?? '',
      createdAt: _parseDateTime(data['createdAt']),
      isOnline: true,
    );
  }

  ChatModel copyWith({
    String? id,
    String? patientId,
    String? doctorId,
    String? doctorName,
    String? doctorImage,
    String? doctorSpecialty,
    String? patientName,
    String? patientImage,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
    String? appointmentId,
    DateTime? createdAt,
    bool? isOnline,
  }) {
    return ChatModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      doctorImage: doctorImage ?? this.doctorImage,
      doctorSpecialty: doctorSpecialty ?? this.doctorSpecialty,
      patientName: patientName ?? this.patientName,
      patientImage: patientImage ?? this.patientImage,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      appointmentId: appointmentId ?? this.appointmentId,
      createdAt: createdAt ?? this.createdAt,
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
