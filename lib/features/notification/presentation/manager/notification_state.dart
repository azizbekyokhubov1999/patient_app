import '../../domain/entities/notification_model.dart';

const Object _kUnset = Object();

class NotificationState {
  const NotificationState({
    required this.groupedNotifications,
    required this.unreadCount,
    required this.isLoading,
    this.errorMessage,
  });

  factory NotificationState.initial() => const NotificationState(
        groupedNotifications: {},
        unreadCount: 0,
        isLoading: true,
      );

  final Map<String, List<NotificationModel>> groupedNotifications;
  final int unreadCount;
  final bool isLoading;
  final String? errorMessage;

  NotificationState copyWith({
    Map<String, List<NotificationModel>>? groupedNotifications,
    int? unreadCount,
    bool? isLoading,
    Object? errorMessage = _kUnset,
  }) {
    return NotificationState(
      groupedNotifications:
          groupedNotifications ?? this.groupedNotifications,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: identical(errorMessage, _kUnset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}
