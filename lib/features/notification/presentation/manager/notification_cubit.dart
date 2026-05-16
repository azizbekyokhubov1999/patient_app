import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/notification_model.dart';
import '../../domain/entities/notification_type.dart';
import '../../domain/repositories/notification_repository.dart';
import 'notification_state.dart';

/// Bypass `[NotificationRepository]` stream for demos.
const bool _kPresentationMockNotifications = true;

List<NotificationModel> _presentationNotificationSeed(DateTime now) {
  return [
    NotificationModel(
      id: 'demo-notif-appt-confirmed',
      type: NotificationType.appointmentConfirmed,
      title: 'Appointment Confirmed!',
      body:
          'Your appointment with Dr. Jenny Wilson has been successfully booked for Jan 20.',
      createdAt: now.subtract(const Duration(hours: 2)),
      isRead: false,
      relatedId: 'Dr_Jenny_Wilson',
    ),
    NotificationModel(
      id: 'demo-notif-sched-reminder',
      type: NotificationType.scheduleReminder,
      title: 'Schedule Reminder',
      body:
          "Don't forget your consultation with Dr. Sophia Rossi today at 15:00.",
      createdAt: now.subtract(const Duration(days: 1)),
      isRead: true,
      relatedId: null,
    ),
    NotificationModel(
      id: 'demo-notif-system',
      type: NotificationType.systemUpdate,
      title: 'System Update',
      body:
          'New specialized clinical setups are now available in nearby areas.',
      createdAt: now.subtract(const Duration(days: 3)),
      isRead: true,
      relatedId: null,
    ),
  ];
}

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit(this._repository) : super(NotificationState.initial());

  final NotificationRepository _repository;
  StreamSubscription<List<NotificationModel>>? _subscription;

  List<NotificationModel>? _presentationBuffer;

  void _emitFromList(List<NotificationModel> items) {
    final grouped = groupNotifications(items);
    final unread = items.where((n) => !n.isRead).length;
    emit(
      state.copyWith(
        groupedNotifications: grouped,
        unreadCount: unread,
        isLoading: false,
        errorMessage: null,
      ),
    );
  }

  /// Inserts [TODAY], [YESTERDAY] first, then other labels by most recent first.
  static List<String> sortedGroupLabels(
    Map<String, List<NotificationModel>> grouped,
  ) {
    const priority = ['TODAY', 'YESTERDAY'];
    final keys = grouped.keys.toList();
    keys.sort((a, b) {
      final ia = priority.indexOf(a);
      final ib = priority.indexOf(b);
      if (ia != -1 && ib != -1) return ia.compareTo(ib);
      if (ia != -1) return -1;
      if (ib != -1) return 1;
      final da = grouped[a]!.first.createdAt;
      final db = grouped[b]!.first.createdAt;
      return db.compareTo(da);
    });
    return keys;
  }

  static Map<String, List<NotificationModel>> groupNotifications(
    List<NotificationModel> items,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final formatter = DateFormat('MMMM dd, yyyy');

    final grouped = <String, List<NotificationModel>>{};
    for (final n in items) {
      final day = DateTime(
        n.createdAt.year,
        n.createdAt.month,
        n.createdAt.day,
      );
      late final String label;
      if (day == today) {
        label = 'TODAY';
      } else if (day == yesterday) {
        label = 'YESTERDAY';
      } else {
        label = formatter.format(n.createdAt);
      }
      grouped.putIfAbsent(label, () => <NotificationModel>[]).add(n);
    }
    return grouped;
  }

  void loadNotifications() {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    unawaited(_subscription?.cancel());

    if (_kPresentationMockNotifications) {
      _presentationBuffer =
          List<NotificationModel>.from(_presentationNotificationSeed(DateTime.now()));
      _subscription = null;
      _emitFromList(_presentationBuffer!);
      return;
    }

    _presentationBuffer = null;
    _subscription = _repository.getNotifications().listen(
      _emitFromList,
      onError: (Object e, StackTrace st) {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: e.toString(),
          ),
        );
      },
    );
  }

  Future<void> markGroupAsRead(String groupLabel) async {
    final grouped = state.groupedNotifications[groupLabel];
    final items = grouped;
    if (items == null) return;
    final ids = items.where((n) => !n.isRead).map((n) => n.id).toList();
    if (ids.isEmpty) return;

    if (_kPresentationMockNotifications && _presentationBuffer != null) {
      final idsSet = ids.toSet();
      _presentationBuffer = _presentationBuffer!
          .map(
            (n) => idsSet.contains(n.id) ? n.copyWith(isRead: true) : n,
          )
          .toList();
      _emitFromList(_presentationBuffer!);
      return;
    }

    await _repository.markGroupAsRead(ids);
  }

  Future<void> markNotificationAsRead(String id) async {
    if (_kPresentationMockNotifications && _presentationBuffer != null) {
      _presentationBuffer = _presentationBuffer!
          .map((n) => n.id == id ? n.copyWith(isRead: true) : n)
          .toList();
      _emitFromList(_presentationBuffer!);
      return;
    }
    await _repository.markAsRead(id);
  }

  @override
  Future<void> close() {
    unawaited(_subscription?.cancel());
    return super.close();
  }
}
