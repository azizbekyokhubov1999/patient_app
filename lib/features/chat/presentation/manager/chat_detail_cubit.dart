import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/models/message_model.dart';
import '../../domain/repositories/chat_repository.dart';
import 'chat_detail_state.dart';

class ChatDetailCubit extends Cubit<ChatDetailState> {
  ChatDetailCubit({
    required ChatRepository repository,
    required this.currentUserId,
    required this.currentUserName,
    required this.peerId,
    required this.peerName,
  })  : _repository = repository,
        super(const ChatDetailState());

  final ChatRepository _repository;
  final String currentUserId;
  final String currentUserName;
  final String peerId;
  final String peerName;

  final ImagePicker _imagePicker = ImagePicker();

  StreamSubscription<List<MessageModel>>? _subscription;

  void loadMessages(String chatId) {
    listenToMessages(chatId);
  }

  void listenToMessages(String chatId) {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    unawaited(_subscription?.cancel());

    _subscription = _repository.getMessages(chatId).listen(
      (messages) {
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

  Future<void> markAsRead(String chatId) async {
    try {
      await _repository.markMessagesAsRead(chatId, currentUserId);
    } catch (e, st) {
      developer.log('markAsRead error', error: e, stackTrace: st);
    }
  }

  Future<void> sendText(String chatId, String text) async {
    await sendTextMessage(chatId, currentUserId, text);
  }

  Future<void> sendTextMessage(
    String chatId,
    String senderId,
    String text,
  ) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    emit(state.copyWith(isSending: true, errorMessage: null));

    try {
      await _repository.sendTextMessage(
        chatId,
        senderId,
        currentUserName,
        trimmed,
      );
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

  Future<void> sendImage(String chatId, File imageFile) async {
    emit(state.copyWith(isSending: true, errorMessage: null));
    try {
      await _repository.sendImageMessage(
        chatId,
        currentUserId,
        currentUserName,
        imageFile,
      );
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

  Future<void> pickAndSendImage(String chatId) async {
    try {
      final picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked == null) return;
      await sendImage(chatId, File(picked.path));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> sendImageMessage(String chatId) async {
    await pickAndSendImage(chatId);
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
