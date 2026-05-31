import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Stream<List<NotificationModel>> getNotifications(String uid);

  Future<void> markAsRead(String notificationId);

  Future<void> markGroupAsRead(List<String> notificationIds);

  Future<void> createNotification({
    required String userId,
    required String type,
    required String title,
    required String body,
    required String relatedId,
  });

  Future<void> deleteNotification(String notificationId);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  NotificationRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('notifications');

  @override
  Stream<List<NotificationModel>> getNotifications(String uid) {
    final trimmedUid = uid.trim();
    if (trimmedUid.isEmpty) {
      return Stream<List<NotificationModel>>.value(const []);
    }

    final controller = StreamController<List<NotificationModel>>.broadcast();
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? subscription;
    var useOrderedQuery = true;

    void listen() {
      subscription?.cancel();

      Query<Map<String, dynamic>> query = _collection.where(
        'userId',
        isEqualTo: trimmedUid,
      );

      if (useOrderedQuery) {
        query = query.orderBy('createdAt', descending: true);
      }

      subscription = query.snapshots().listen(
        (snapshot) {
          final items = snapshot.docs
              .map(NotificationModel.fromFirestore)
              .toList(growable: false);
          if (!useOrderedQuery) {
            items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          }
          controller.add(items);
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
  Future<void> markAsRead(String notificationId) async {
    final trimmedId = notificationId.trim();
    if (trimmedId.isEmpty) return;

    await _collection.doc(trimmedId).update({'isRead': true});
  }

  @override
  Future<void> markGroupAsRead(List<String> notificationIds) async {
    final ids = notificationIds.map((id) => id.trim()).where((id) => id.isNotEmpty);
    if (ids.isEmpty) return;

    final batch = _firestore.batch();
    for (final id in ids) {
      batch.update(_collection.doc(id), {'isRead': true});
    }
    await batch.commit();
  }

  @override
  Future<void> createNotification({
    required String userId,
    required String type,
    required String title,
    required String body,
    required String relatedId,
  }) async {
    await _collection.add({
      'userId': userId,
      'type': type,
      'title': title,
      'body': body,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
      'relatedId': relatedId,
    });
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    final trimmedId = notificationId.trim();
    if (trimmedId.isEmpty) return;

    await _collection.doc(trimmedId).delete();
  }
}
