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
        return Stream<List<NotificationModel>>.value(const []);
      }
      return _remote.getNotifications(user.uid);
    });
  }

  @override
  Future<void> markAsRead(String id) => _remote.markAsRead(id);

  @override
  Future<void> markGroupAsRead(List<String> ids) =>
      _remote.markGroupAsRead(ids);

  @override
  Future<void> createNotification({
    required String userId,
    required String type,
    required String title,
    required String body,
    required String relatedId,
  }) =>
      _remote.createNotification(
        userId: userId,
        type: type,
        title: title,
        body: body,
        relatedId: relatedId,
      );

  @override
  Future<void> deleteNotification(String id) =>
      _remote.deleteNotification(id);
}
