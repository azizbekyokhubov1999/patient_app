import 'dart:async';
import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/chat_model.dart';
import 'chat_state.dart';

/// Demo data while Firestore has no chat rows (presentation).
const bool _kPresentationMockChats = true;

List<ChatModel> _presentationMockChats() {
  final now = DateTime.now();
  return [
    ChatModel(
      chatId: 'chat-1',
      doctorId: 'doc-sheila',
      doctorName: 'Dr. Sheila Lemke',
      doctorAvatar: 'https://picsum.photos/200?sheila',
      lastMessage: 'How Are You?',
      lastMessageTime: DateTime(now.year, now.month, now.day, 21, 34),
      unreadCount: 2,
      isReadBySub: false,
      isOnline: true,
    ),
    ChatModel(
      chatId: 'chat-2',
      doctorId: 'doc-sarah',
      doctorName: 'Sarah Williams',
      doctorAvatar: 'https://picsum.photos/200?sarah',
      lastMessage: 'Thanks!',
      lastMessageTime: DateTime(now.year, now.month, now.day, 20, 12),
      unreadCount: 0,
      isReadBySub: true,
      isOnline: true,
    ),
    ChatModel(
      chatId: 'chat-3',
      doctorId: 'doc-michael',
      doctorName: 'Michael Brown',
      doctorAvatar: 'https://picsum.photos/200?michael',
      lastMessage: 'Welcome!',
      lastMessageTime: DateTime(now.year, now.month, now.day, 18, 45),
      unreadCount: 0,
      isReadBySub: true,
      isOnline: false,
    ),
    ChatModel(
      chatId: 'chat-4',
      doctorId: 'doc-jenny',
      doctorName: 'Dr. Jenny William',
      doctorAvatar: 'https://picsum.photos/200?jenny',
      lastMessage: 'See you at the clinic.',
      lastMessageTime: DateTime(now.year, now.month, now.day, 16, 20),
      unreadCount: 3,
      isReadBySub: false,
      isOnline: true,
    ),
    ChatModel(
      chatId: 'chat-5',
      doctorId: 'doc-sophia',
      doctorName: 'Dr. Sophia Rossi',
      doctorAvatar: 'https://picsum.photos/200?sophia',
      lastMessage: 'Your report is ready.',
      lastMessageTime: DateTime(now.year, now.month, now.day - 1, 14, 5),
      unreadCount: 0,
      isReadBySub: true,
      isOnline: true,
    ),
  ];
}

List<ChatModel> _presentationActiveDoctors() {
  return [
    ChatModel(
      chatId: 'active-sophia',
      doctorId: 'doc-sophia',
      doctorName: 'Sophia Rossi',
      doctorAvatar: 'https://picsum.photos/200?sophia',
      lastMessage: '',
      lastMessageTime: DateTime.now(),
      unreadCount: 0,
      isReadBySub: true,
      isOnline: true,
    ),
    ChatModel(
      chatId: 'active-james',
      doctorId: 'doc-james',
      doctorName: 'James Miller',
      doctorAvatar: 'https://picsum.photos/200?james',
      lastMessage: '',
      lastMessageTime: DateTime.now(),
      unreadCount: 0,
      isReadBySub: true,
      isOnline: true,
    ),
    ChatModel(
      chatId: 'active-robert',
      doctorId: 'doc-robert',
      doctorName: 'Robert Lee',
      doctorAvatar: 'https://picsum.photos/200?robert',
      lastMessage: '',
      lastMessageTime: DateTime.now(),
      unreadCount: 0,
      isReadBySub: true,
      isOnline: true,
    ),
    ChatModel(
      chatId: 'active-jenny',
      doctorId: 'doc-jenny',
      doctorName: 'Jenny William',
      doctorAvatar: 'https://picsum.photos/200?jenny',
      lastMessage: '',
      lastMessageTime: DateTime.now(),
      unreadCount: 0,
      isReadBySub: true,
      isOnline: true,
    ),
  ];
}

class ChatCubit extends Cubit<ChatState> {
  ChatCubit({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        super(const ChatState());

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;

  void streamChats() {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    unawaited(_subscription?.cancel());

    if (_kPresentationMockChats) {
      final chats = _presentationMockChats();
      _emitChats(chats, activeDoctors: _presentationActiveDoctors());
      return;
    }

    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      _emitChats(const [], activeDoctors: const []);
      return;
    }

    _subscription = _firestore
        .collection('chats')
        .where('patientId', isEqualTo: uid)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .listen(
      (snapshot) {
        final chats = snapshot.docs.map(ChatModel.fromFirestore).toList();
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
