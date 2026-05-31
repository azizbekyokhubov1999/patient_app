import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/chat_model.dart';
import '../models/message_model.dart';

abstract class ChatRemoteDataSource {
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

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  ChatRemoteDataSourceImpl({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  CollectionReference<Map<String, dynamic>> get _chats =>
      _firestore.collection('chats');

  @override
  Stream<List<ChatModel>> getChats(String uid) {
    final trimmedUid = uid.trim();
    if (trimmedUid.isEmpty) {
      return Stream<List<ChatModel>>.value(const []);
    }

    final controller = StreamController<List<ChatModel>>.broadcast();
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? patientSub;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? doctorSub;

    var patientDocs = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
    var doctorDocs = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
    var patientOrdered = true;
    var doctorOrdered = true;

    void emitMerged() {
      final byId = <String, ChatModel>{};
      for (final doc in [...patientDocs, ...doctorDocs]) {
        final chat = ChatModel.fromFirestore(doc);
        byId[chat.id] = chat;
      }
      final list = byId.values.toList()
        ..sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
      controller.add(list);
    }

    void listenPatient() {
      patientSub?.cancel();
      Query<Map<String, dynamic>> query =
          _chats.where('patientId', isEqualTo: trimmedUid);
      if (patientOrdered) {
        query = query.orderBy('lastMessageTime', descending: true);
      }

      patientSub = query.snapshots().listen(
        (snapshot) {
          patientDocs = snapshot.docs;
          emitMerged();
        },
        onError: (Object error) {
          if (patientOrdered) {
            patientOrdered = false;
            listenPatient();
            return;
          }
          controller.addError(error);
        },
      );
    }

    void listenDoctor() {
      doctorSub?.cancel();
      Query<Map<String, dynamic>> query =
          _chats.where('doctorId', isEqualTo: trimmedUid);
      if (doctorOrdered) {
        query = query.orderBy('lastMessageTime', descending: true);
      }

      doctorSub = query.snapshots().listen(
        (snapshot) {
          doctorDocs = snapshot.docs;
          emitMerged();
        },
        onError: (Object error) {
          if (doctorOrdered) {
            doctorOrdered = false;
            listenDoctor();
            return;
          }
          controller.addError(error);
        },
      );
    }

    listenPatient();
    listenDoctor();

    controller.onCancel = () {
      patientSub?.cancel();
      doctorSub?.cancel();
    };

    return controller.stream;
  }

  @override
  Stream<List<MessageModel>> getMessages(String chatId) {
    final trimmedChatId = chatId.trim();
    if (trimmedChatId.isEmpty) {
      return Stream<List<MessageModel>>.value(const []);
    }

    final controller = StreamController<List<MessageModel>>.broadcast();
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? subscription;
    var useOrderedQuery = true;

    void listen() {
      subscription?.cancel();
      Query<Map<String, dynamic>> query = _chats
          .doc(trimmedChatId)
          .collection('messages');

      if (useOrderedQuery) {
        query = query.orderBy('createdAt', descending: false);
      }

      subscription = query.snapshots().listen(
        (snapshot) {
          final messages = snapshot.docs
              .map(MessageModel.fromFirestore)
              .toList(growable: false);
          if (!useOrderedQuery) {
            messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          }
          controller.add(messages);
        },
        onError: (Object error, StackTrace stackTrace) {
          if (useOrderedQuery) {
            useOrderedQuery = false;
            listen();
            return;
          }
          controller.addError(error, stackTrace);
        },
      );
    }

    listen();
    controller.onCancel = () => subscription?.cancel();
    return controller.stream;
  }

  @override
  Future<void> sendTextMessage(
    String chatId,
    String senderId,
    String senderName,
    String text,
  ) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final chatSnap = await _chats.doc(chatId).get();
    final patientId = chatSnap.data()?['patientId'] as String? ?? '';
    final incrementUnread = senderId != patientId;

    final batch = _firestore.batch();
    final messageRef = _chats.doc(chatId).collection('messages').doc();

    batch.set(messageRef, {
      'senderId': senderId,
      'senderName': senderName,
      'text': trimmed,
      'type': 'text',
      'imageUrl': '',
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });

    final chatUpdate = <String, dynamic>{
      'lastMessage': trimmed,
      'lastMessageTime': FieldValue.serverTimestamp(),
    };
    if (incrementUnread) {
      chatUpdate['unreadCount'] = FieldValue.increment(1);
    }
    batch.update(_chats.doc(chatId), chatUpdate);

    await batch.commit();
  }

  @override
  Future<void> sendImageMessage(
    String chatId,
    String senderId,
    String senderName,
    File imageFile,
  ) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final storageRef =
        _storage.ref().child('chat_images/$chatId/$timestamp.jpg');

    await storageRef.putFile(imageFile);
    final downloadUrl = await storageRef.getDownloadURL();

    const lastMessagePreview = '📷 Photo';

    final chatSnap = await _chats.doc(chatId).get();
    final patientId = chatSnap.data()?['patientId'] as String? ?? '';
    final incrementUnread = senderId != patientId;

    final batch = _firestore.batch();
    final messageRef = _chats.doc(chatId).collection('messages').doc();

    batch.set(messageRef, {
      'senderId': senderId,
      'senderName': senderName,
      'text': '',
      'type': 'image',
      'imageUrl': downloadUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });

    final chatUpdate = <String, dynamic>{
      'lastMessage': lastMessagePreview,
      'lastMessageTime': FieldValue.serverTimestamp(),
    };
    if (incrementUnread) {
      chatUpdate['unreadCount'] = FieldValue.increment(1);
    }
    batch.update(_chats.doc(chatId), chatUpdate);

    await batch.commit();
  }

  @override
  Future<void> markMessagesAsRead(
    String chatId,
    String currentUserId,
  ) async {
    final messagesSnap = await _chats
        .doc(chatId)
        .collection('messages')
        .where('isRead', isEqualTo: false)
        .get();

    final toUpdate = messagesSnap.docs
        .where((doc) => doc.data()['senderId'] != currentUserId)
        .toList();

    if (toUpdate.isEmpty) {
      await _chats.doc(chatId).update({'unreadCount': 0});
      return;
    }

    final batch = _firestore.batch();
    for (final doc in toUpdate) {
      batch.update(doc.reference, {'isRead': true});
    }
    batch.update(_chats.doc(chatId), {'unreadCount': 0});
    await batch.commit();
  }

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
  }) async {
    final existing = await _chats
        .where('patientId', isEqualTo: patientId)
        .where('doctorId', isEqualTo: doctorId)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      final chatId = existing.docs.first.id;
      if (appointmentId != null && appointmentId.isNotEmpty) {
        await _chats.doc(chatId).update({'appointmentId': appointmentId});
      }
      return chatId;
    }

    final doc = await _chats.add({
      'patientId': patientId,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorImage': doctorImage,
      'doctorSpecialty': doctorSpecialty,
      'patientName': patientName,
      'patientImage': patientImage,
      'lastMessage': '',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'unreadCount': 0,
      'appointmentId': appointmentId ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    });

    return doc.id;
  }
}
