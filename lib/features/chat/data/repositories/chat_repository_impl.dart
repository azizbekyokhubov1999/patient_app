import 'dart:io';

import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_data_source.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl(this._remote);

  final ChatRemoteDataSource _remote;

  @override
  Stream<List<ChatModel>> getChats(String uid) => _remote.getChats(uid);

  @override
  Stream<List<MessageModel>> getMessages(String chatId) =>
      _remote.getMessages(chatId);

  @override
  Future<void> sendTextMessage(
    String chatId,
    String senderId,
    String senderName,
    String text,
  ) =>
      _remote.sendTextMessage(chatId, senderId, senderName, text);

  @override
  Future<void> sendImageMessage(
    String chatId,
    String senderId,
    String senderName,
    File imageFile,
  ) =>
      _remote.sendImageMessage(chatId, senderId, senderName, imageFile);

  @override
  Future<void> markMessagesAsRead(String chatId, String currentUserId) =>
      _remote.markMessagesAsRead(chatId, currentUserId);

  @override
  Future<String> createChat({
    required String patientId,
    required String doctorId,
    required String doctorName,
    required String doctorImage,
    required String doctorSpecialty,
    required String patientName,
    required String patientImage,
    String? appointmentId,
  }) =>
      _remote.createChat(
        patientId: patientId,
        doctorId: doctorId,
        doctorName: doctorName,
        doctorImage: doctorImage,
        doctorSpecialty: doctorSpecialty,
        patientName: patientName,
        patientImage: patientImage,
        appointmentId: appointmentId,
      );
}
