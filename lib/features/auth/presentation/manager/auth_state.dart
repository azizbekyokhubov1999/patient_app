import '../../domain/entities/user_entity.dart';

/// UI flows that emit one-shot navigation events from [AuthCubit].
enum AuthFlow {
  sessionCheck,
  signIn,
  createAccount,
  verifyCode,
  newPassword,
  completeProfile,
  locationAccess,
  notificationAccess,
}

sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading({this.flow});

  final AuthFlow? flow;
}

class Authenticated extends AuthState {
  const Authenticated({
    required this.user,
    this.completedFlow,
    this.noticeMessage,
    this.offerOpenSettings = false,
  });

  final UserEntity user;
  final AuthFlow? completedFlow;

  /// One-shot message (e.g. permission denied but user may continue).
  final String? noticeMessage;

  final bool offerOpenSettings;

  bool get isProfileComplete => user.isProfileComplete;

  Authenticated copyWith({
    UserEntity? user,
    AuthFlow? completedFlow,
    bool clearCompletedFlow = false,
    String? noticeMessage,
    bool clearNotice = false,
    bool? offerOpenSettings,
  }) {
    return Authenticated(
      user: user ?? this.user,
      completedFlow:
          clearCompletedFlow ? null : completedFlow ?? this.completedFlow,
      noticeMessage:
          clearNotice ? null : noticeMessage ?? this.noticeMessage,
      offerOpenSettings: offerOpenSettings ?? this.offerOpenSettings,
    );
  }
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class AuthError extends AuthState {
  const AuthError({
    required this.message,
    this.flow,
  });

  final String message;
  final AuthFlow? flow;
}
