import '../../data/models/chat_model.dart';

class ChatState {
  const ChatState({
    this.allChats = const [],
    this.filteredChats = const [],
    this.activeDoctors = const [],
    this.isLoading = false,
    this.selectedTab = ChatState.tabAll,
    this.searchQuery = '',
    this.errorMessage,
  });

  static const String tabAll = 'All';
  static const String tabUnread = 'Unread';

  final List<ChatModel> allChats;
  final List<ChatModel> filteredChats;
  final List<ChatModel> activeDoctors;
  final bool isLoading;
  final String selectedTab;
  final String searchQuery;
  final String? errorMessage;

  int get allCount => allChats.length;

  int get unreadCount =>
      allChats.where((chat) => chat.unreadCount > 0).length;

  ChatState copyWith({
    List<ChatModel>? allChats,
    List<ChatModel>? filteredChats,
    List<ChatModel>? activeDoctors,
    bool? isLoading,
    String? selectedTab,
    String? searchQuery,
    Object? errorMessage = _sentinel,
  }) {
    return ChatState(
      allChats: allChats ?? this.allChats,
      filteredChats: filteredChats ?? this.filteredChats,
      activeDoctors: activeDoctors ?? this.activeDoctors,
      isLoading: isLoading ?? this.isLoading,
      selectedTab: selectedTab ?? this.selectedTab,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  static const Object _sentinel = Object();
}
