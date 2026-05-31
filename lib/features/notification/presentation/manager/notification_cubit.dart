import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/notification_model.dart';
import '../../domain/repositories/notification_repository.dart';
import 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit(this._repository) : super(NotificationState.initial());

  final NotificationRepository _repository;
  StreamSubscription<List<NotificationModel>>? _subscription;

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
    final formatter = DateFormat('MMM d, yyyy');

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

    _subscription = _repository.getNotifications().listen(
      _emitFromList,
      onError: (Object e, StackTrace st) {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: 'Failed to load notifications. Please try again.',
          ),
        );
      },
    );
  }

  Future<void> markGroupAsRead(String groupLabel) async {
    final items = state.groupedNotifications[groupLabel];
    if (items == null) return;

    final ids = items.where((n) => !n.isRead).map((n) => n.id).toList();
    if (ids.isEmpty) return;

    await _repository.markGroupAsRead(ids);
  }

  Future<void> markAsRead(String id) => markNotificationAsRead(id);

  Future<void> markNotificationAsRead(String id) async {
    await _repository.markAsRead(id);
  }

  @override
  Future<void> close() {
    unawaited(_subscription?.cancel());
    return super.close();
  }
}
