import 'package:flutter_bloc/flutter_bloc.dart';

enum AuthAction {
  signIn,
  createAccount,
  verifyCode,
  newPassword,
  completeProfile,
  locationAccess,
  notificationAccess,
}

sealed class AuthState {
  const AuthState({this.action});

  final AuthAction? action;
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading({required super.action});
}

class AuthSuccess extends AuthState {
  const AuthSuccess({required super.action});
}

class AuthFailure extends AuthState {
  const AuthFailure({required super.action, required this.message});

  final String message;
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthInitial());

  Future<void> signIn({required String email, required String password}) async {
    emit(const AuthLoading(action: AuthAction.signIn));
    await Future<void>.delayed(const Duration(milliseconds: 250));

    if (email.trim().isEmpty || password.trim().isEmpty) {
      emit(
        const AuthFailure(
          action: AuthAction.signIn,
          message: 'Email and password are required',
        ),
      );
      return;
    }

    emit(const AuthSuccess(action: AuthAction.signIn));
  }

  Future<void> createAccount({
    required String name,
    required String email,
    required String password,
    required bool acceptedTerms,
  }) async {
    emit(const AuthLoading(action: AuthAction.createAccount));
    await Future<void>.delayed(const Duration(milliseconds: 250));

    if (name.trim().isEmpty ||
        email.trim().isEmpty ||
        password.trim().isEmpty) {
      emit(
        const AuthFailure(
          action: AuthAction.createAccount,
          message: 'Please complete all required fields',
        ),
      );
      return;
    }

    if (!acceptedTerms) {
      emit(
        const AuthFailure(
          action: AuthAction.createAccount,
          message: 'Please accept Terms & Condition',
        ),
      );
      return;
    }

    emit(const AuthSuccess(action: AuthAction.createAccount));
  }

  Future<void> verifyCode({required String code}) async {
    emit(const AuthLoading(action: AuthAction.verifyCode));
    await Future<void>.delayed(const Duration(milliseconds: 250));

    if (code.trim().length != 4) {
      emit(
        const AuthFailure(
          action: AuthAction.verifyCode,
          message: 'Please enter all 4 digits',
        ),
      );
      return;
    }

    emit(const AuthSuccess(action: AuthAction.verifyCode));
  }

  Future<void> setNewPassword({
    required String newPassword,
    required String confirmPassword,
  }) async {
    emit(const AuthLoading(action: AuthAction.newPassword));
    await Future<void>.delayed(const Duration(milliseconds: 250));

    if (newPassword.trim().isEmpty || confirmPassword.trim().isEmpty) {
      emit(
        const AuthFailure(
          action: AuthAction.newPassword,
          message: 'Please complete all password fields',
        ),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      emit(
        const AuthFailure(
          action: AuthAction.newPassword,
          message: 'Passwords do not match',
        ),
      );
      return;
    }

    emit(const AuthSuccess(action: AuthAction.newPassword));
  }

  Future<void> completeProfile({
    required String name,
    required String phone,
    required String? gender,
  }) async {
    emit(const AuthLoading(action: AuthAction.completeProfile));
    await Future<void>.delayed(const Duration(milliseconds: 250));

    if (name.trim().isEmpty || phone.trim().isEmpty || gender == null) {
      emit(
        const AuthFailure(
          action: AuthAction.completeProfile,
          message: 'Please complete all required profile fields',
        ),
      );
      return;
    }

    emit(const AuthSuccess(action: AuthAction.completeProfile));
  }

  Future<void> requestLocationAccess() async {
    emit(const AuthLoading(action: AuthAction.locationAccess));
    await Future<void>.delayed(const Duration(milliseconds: 250));
    emit(const AuthSuccess(action: AuthAction.locationAccess));
  }

  Future<void> requestNotificationAccess() async {
    emit(const AuthLoading(action: AuthAction.notificationAccess));
    await Future<void>.delayed(const Duration(milliseconds: 250));
    emit(const AuthSuccess(action: AuthAction.notificationAccess));
  }
}
