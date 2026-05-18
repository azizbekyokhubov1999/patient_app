import '../../data/models/user_model.dart';

/// Profile feature lifecycle statuses.
abstract final class ProfileStatus {
  static const String initial = 'initial';
  static const String loading = 'loading';
  static const String success = 'success';
  static const String failure = 'failure';
  static const String updatingAvatar = 'updatingAvatar';
  static const String updating = 'updating';
  static const String updateSuccess = 'updateSuccess';
  static const String updateFailure = 'updateFailure';
}

class ProfileState {
  const ProfileState({
    this.user,
    this.status = ProfileStatus.initial,
    this.errorMessage,
  });

  // Legacy aliases for existing profile screen code.
  static const String initial = ProfileStatus.initial;
  static const String loading = ProfileStatus.loading;
  static const String success = ProfileStatus.success;
  static const String failure = ProfileStatus.failure;
  static const String updatingAvatar = ProfileStatus.updatingAvatar;

  final UserModel? user;
  final String status;
  final String? errorMessage;

  bool get isInitial => status == ProfileStatus.initial;
  bool get isLoading => status == ProfileStatus.loading;
  bool get isSuccess => status == ProfileStatus.success;
  bool get isFailure => status == ProfileStatus.failure;
  bool get isUpdatingAvatar => status == ProfileStatus.updatingAvatar;
  bool get isUpdating => status == ProfileStatus.updating;
  bool get isUpdateSuccess => status == ProfileStatus.updateSuccess;
  bool get isUpdateFailure => status == ProfileStatus.updateFailure;

  ProfileState copyWith({
    UserModel? user,
    String? status,
    Object? errorMessage = _sentinel,
  }) {
    return ProfileState(
      user: user ?? this.user,
      status: status ?? this.status,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  static const Object _sentinel = Object();
}
