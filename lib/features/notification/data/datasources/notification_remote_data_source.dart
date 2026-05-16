import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Stream<List<NotificationModel>> watchNotifications(String userId);

  Future<void> markAsRead(String userId, String notificationId);

  Future<void> markGroupAsRead(String userId, List<String> notificationIds);

  Future<void> deleteNotification(String userId, String notificationId);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  NotificationRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(String userId) {
    return _firestore.collection('users').doc(userId).collection('notifications');
  }

  @override
  Stream<List<NotificationModel>> watchNotifications(String userId) {
    return _collection(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
      (snapshot) {
        return snapshot.docs.map((doc) {
          final data = Map<String, dynamic>.from(doc.data());
          data['id'] = doc.id;
          return NotificationModel.fromJson(data);
        }).toList();
      },
    );
  }

  @override
  Future<void> markAsRead(String userId, String notificationId) {
    return _collection(userId).doc(notificationId).update({'isRead': true});
  }

  @override
  Future<void> markGroupAsRead(String userId, List<String> notificationIds) {
    if (notificationIds.isEmpty) return Future<void>.value();
    final batch = _firestore.batch();
    final col = _collection(userId);
    for (final id in notificationIds) {
      batch.update(col.doc(id), {'isRead': true});
    }
    return batch.commit();
  }

  @override
  Future<void> deleteNotification(String userId, String notificationId) {
    return _collection(userId).doc(notificationId).delete();
  }
}
