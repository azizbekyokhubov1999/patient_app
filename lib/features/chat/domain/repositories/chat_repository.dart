import 'dart:io';

import '../../data/models/chat_model.dart';
import '../../data/models/message_model.dart';

abstract class ChatRepository {
  Stream<List<ChatModel>> getChats(String uid);

  Stream<List<MessageModel>> getMessages(String chatId);

  Future<void> sendTextMessage(
    String chatId,
    String senderId,
    String senderName,
    String text,
  );

  Future<void> sendImageMessage(
    String chatId,
    String senderId,
    String senderName,
    File imageFile,
  );

  Future<void> markMessagesAsRead(String chatId, String currentUserId);

  Future<String> createChat({
    required String patientId,
    required String doctorId,
    required String doctorName,
    required String doctorImage,
    required String doctorSpecialty,
    required String patientName,
    required String patientImage,
    String? appointmentId,
  });
}
