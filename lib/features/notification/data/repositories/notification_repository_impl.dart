import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/notification_model.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_data_source.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(
    this._remote, {
    FirebaseAuth? auth,
  }) : _auth = auth ?? FirebaseAuth.instance;

  final NotificationRemoteDataSource _remote;
  final FirebaseAuth _auth;

  @override
  Stream<List<NotificationModel>> getNotifications() {
    return _auth.authStateChanges().asyncExpand((user) {
      if (user == null) {
        return Stream<List<NotificationModel>>.value(<NotificationModel>[]);
      }
      return _remote.watchNotifications(user.uid);
    });
  }

  @override
  Future<void> markAsRead(String id) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _remote.markAsRead(user.uid, id);
  }

  @override
  Future<void> markGroupAsRead(List<String> ids) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _remote.markGroupAsRead(user.uid, ids);
  }

  @override
  Future<void> deleteNotification(String id) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _remote.deleteNotification(user.uid, id);
  }
}
