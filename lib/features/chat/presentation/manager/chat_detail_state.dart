import '../../data/models/message_model.dart';

class ChatDetailState {
  const ChatDetailState({
    this.messages = const [],
    this.isLoading = false,
    this.isSending = false,
    this.errorMessage,
  });

  final List<MessageModel> messages;
  final bool isLoading;
  final bool isSending;
  final String? errorMessage;

  ChatDetailState copyWith({
    List<MessageModel>? messages,
    bool? isLoading,
    bool? isSending,
    Object? errorMessage = _sentinel,
  }) {
    return ChatDetailState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  static const Object _sentinel = Object();
}
