import 'dart:async';
import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/chat_model.dart';
import '../../domain/repositories/chat_repository.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit({
    required ChatRepository repository,
    FirebaseAuth? auth,
  })  : _repository = repository,
        _auth = auth ?? FirebaseAuth.instance,
        super(const ChatState());

  final ChatRepository _repository;
  final FirebaseAuth _auth;

  StreamSubscription<List<ChatModel>>? _subscription;

  void loadChats() {
    streamChats();
  }

  void streamChats() {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    unawaited(_subscription?.cancel());

    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      _emitChats(const [], activeDoctors: const []);
      return;
    }

    _subscription = _repository.getChats(uid).listen(
      (chats) {
        final active = chats.where((c) => c.isOnline).toList();
        _emitChats(chats, activeDoctors: active);
      },
      onError: (Object e, StackTrace st) {
        developer.log('streamChats error', error: e, stackTrace: st);
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: e.toString(),
          ),
        );
      },
    );
  }

  void _emitChats(
    List<ChatModel> chats, {
    required List<ChatModel> activeDoctors,
  }) {
    emit(
      state.copyWith(
        allChats: chats,
        activeDoctors: activeDoctors,
        isLoading: false,
        errorMessage: null,
      ),
    );
    _applyFilters();
  }

  void switchTab(String tab) {
    emit(state.copyWith(selectedTab: tab));
    _applyFilters();
  }

  void searchChats(String query) {
    emit(state.copyWith(searchQuery: query));
    _applyFilters();
  }

  void _applyFilters() {
    var list = List<ChatModel>.from(state.allChats);

    if (state.selectedTab == ChatState.tabUnread) {
      list = list.where((chat) => chat.unreadCount > 0).toList();
    }

    final query = state.searchQuery.trim().toLowerCase();
    if (query.isNotEmpty) {
      list = list
          .where((chat) => chat.doctorName.toLowerCase().contains(query))
          .toList();
    }

    emit(state.copyWith(filteredChats: list));
  }

  @override
  Future<void> close() {
    unawaited(_subscription?.cancel());
    return super.close();
  }
}
