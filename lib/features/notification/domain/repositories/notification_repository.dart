import '../entities/notification_model.dart';

abstract class NotificationRepository {
  Stream<List<NotificationModel>> getNotifications();

  Future<void> markAsRead(String id);

  Future<void> markGroupAsRead(List<String> ids);

  Future<void> createNotification({
    required String userId,
    required String type,
    required String title,
    required String body,
    required String relatedId,
  });

  Future<void> deleteNotification(String id);
}
