import 'dart:async';
import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/message_model.dart';
import 'chat_detail_state.dart';

/// Demo messages while Firestore has no rows (presentation).
const bool _kPresentationMockChatDetail = true;

List<MessageModel> _presentationMockMessages({
  required String doctorId,
  required String doctorName,
  required String patientId,
  required String patientName,
}) {
  final today = DateTime.now();
  final base = DateTime(today.year, today.month, today.day, 20, 4);

  return [
    MessageModel(
      messageId: 'msg-1',
      senderId: doctorId,
      senderName: doctorName,
      receiverId: patientId,
      content:
          'Hello! How can I help you today? Please let me know if you have any questions about your appointment.',
      type: MessageType.text,
      timestamp: base.subtract(const Duration(minutes: 18)),
    ),
    MessageModel(
      messageId: 'msg-2',
      senderId: patientId,
      senderName: patientName,
      receiverId: doctorId,
      content: 'Hi Doctor, I wanted to ask about my follow-up visit.',
      type: MessageType.text,
      timestamp: base.subtract(const Duration(minutes: 12)),
    ),
    MessageModel(
      messageId: 'msg-3',
      senderId: doctorId,
      senderName: doctorName,
      receiverId: patientId,
      content: 'https://picsum.photos/400/280?medical',
      type: MessageType.image,
      timestamp: base.subtract(const Duration(minutes: 8)),
    ),
    MessageModel(
      messageId: 'msg-4',
      senderId: patientId,
      senderName: patientName,
      receiverId: doctorId,
      content: 'voice-placeholder.mp3',
      type: MessageType.audio,
      timestamp: base,
      duration: '0:13',
    ),
  ];
}

class ChatDetailCubit extends Cubit<ChatDetailState> {
  ChatDetailCubit({
    required this.currentUserId,
    required this.currentUserName,
    required this.peerId,
    required this.peerName,
    FirebaseFirestore? firestore,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        super(const ChatDetailState());

  final String currentUserId;
  final String currentUserName;
  final String peerId;
  final String peerName;

  final FirebaseFirestore _firestore;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;

  void listenToMessages(String chatId) {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    unawaited(_subscription?.cancel());

    if (_kPresentationMockChatDetail) {
      final messages = _presentationMockMessages(
        doctorId: peerId,
        doctorName: peerName,
        patientId: currentUserId,
        patientName: currentUserName,
      );
      emit(
        state.copyWith(
          messages: messages,
          isLoading: false,
        ),
      );
      return;
    }

    _subscription = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .listen(
      (snapshot) {
        final messages =
            snapshot.docs.map(MessageModel.fromFirestore).toList();
        emit(
          state.copyWith(
            messages: messages,
            isLoading: false,
            errorMessage: null,
          ),
        );
      },
      onError: (Object e, StackTrace st) {
        developer.log('listenToMessages error', error: e, stackTrace: st);
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: e.toString(),
          ),
        );
      },
    );
  }

  Future<void> sendTextMessage(String chatId, String senderId, String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    emit(state.copyWith(isSending: true, errorMessage: null));

    final message = MessageModel(
      messageId: '',
      senderId: senderId,
      senderName: currentUserName,
      receiverId: peerId,
      content: trimmed,
      type: MessageType.text,
      timestamp: DateTime.now(),
    );

    try {
      if (_kPresentationMockChatDetail) {
        await Future<void>.delayed(const Duration(milliseconds: 200));
        emit(
          state.copyWith(
            messages: [...state.messages, message.copyWith(messageId: 'local-${state.messages.length}')],
            isSending: false,
          ),
        );
        return;
      }

      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add(message.toJson()..remove('messageId'));

      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': trimmed,
        'lastMessageTime': FieldValue.serverTimestamp(),
      });

      emit(state.copyWith(isSending: false));
    } catch (e) {
      emit(
        state.copyWith(
          isSending: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> sendImageMessage(String chatId) async {
    developer.log('sendImageMessage placeholder for chat $chatId');
  }

  Future<void> sendVoiceMessage(
    String chatId,
    String filePath,
    String duration,
  ) async {
    developer.log(
      'sendVoiceMessage placeholder for chat $chatId path=$filePath duration=$duration',
    );
  }

  void clearMessages() {
    emit(state.copyWith(messages: [], errorMessage: null));
  }

  @override
  Future<void> close() {
    unawaited(_subscription?.cancel());
    return super.close();
  }
}
