import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/complete_profile_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/send_password_reset_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  /// Temporary mock OTP while email verification has no 4-digit backend.
  static const String mockOtpCode = '1234';

  AuthCubit({
    required SignInUseCase signInUseCase,
    required SignUpUseCase signUpUseCase,
    required CompleteProfileUseCase completeProfileUseCase,
    required SendPasswordResetUseCase sendPasswordResetUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required SignOutUseCase signOutUseCase,
    required AuthRepository authRepository,
  })  : _signInUseCase = signInUseCase,
        _signUpUseCase = signUpUseCase,
        _completeProfileUseCase = completeProfileUseCase,
        _sendPasswordResetUseCase = sendPasswordResetUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _signOutUseCase = signOutUseCase,
        _authRepository = authRepository,
        super(const AuthInitial()) {
    _authSubscription = _authRepository.authStateChanges().listen(_onAuthStreamUser);
  }

  /// Cached signed-in user during multi-step onboarding (survives [AuthLoading]).
  UserEntity? _onboardingSessionUser;

  static bool _isOnboardingFlow(AuthFlow? flow) {
    return flow == AuthFlow.createAccount ||
        flow == AuthFlow.verifyCode ||
        flow == AuthFlow.completeProfile ||
        flow == AuthFlow.locationAccess ||
        flow == AuthFlow.notificationAccess;
  }

  void _onAuthStreamUser(UserEntity? user) {
    if (isClosed) return;

    if (user == null) {
      final current = state;
      if (current is AuthLoading && _isOnboardingFlow(current.flow)) {
        return;
      }
      if (current is! AuthLoading) {
        _onboardingSessionUser = null;
        emit(const Unauthenticated());
      }
      return;
    }

    _onboardingSessionUser = user;
    final current = state;

    if (current is AuthLoading && _isOnboardingFlow(current.flow)) {
      return;
    }

    if (current is Authenticated && current.user.uid == user.uid) {
      emit(
        Authenticated(
          user: user,
          completedFlow: current.completedFlow,
          noticeMessage: current.noticeMessage,
          offerOpenSettings: current.offerOpenSettings,
        ),
      );
    } else if (current is! AuthLoading) {
      emit(Authenticated(user: user));
    }
  }

  @override
  void emit(AuthState state) {
    if (state is Authenticated) {
      _onboardingSessionUser = state.user;
    } else if (state is Unauthenticated) {
      _onboardingSessionUser = null;
    }
    super.emit(state);
  }

  final SignInUseCase _signInUseCase;
  final SignUpUseCase _signUpUseCase;
  final CompleteProfileUseCase _completeProfileUseCase;
  final SendPasswordResetUseCase _sendPasswordResetUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final SignOutUseCase _signOutUseCase;
  final AuthRepository _authRepository;

  StreamSubscription<dynamic>? _authSubscription;

  void clearCompletedFlow() {
    final current = state;
    if (current is Authenticated) {
      emit(current.copyWith(clearCompletedFlow: true, clearNotice: true));
    }
  }

  Future<void> checkSession() async {
    emit(const AuthLoading(flow: AuthFlow.sessionCheck));
    final result = await _getCurrentUserUseCase();
    result.fold(
      (failure) => emit(AuthError(
        message: failure.message,
        flow: AuthFlow.sessionCheck,
      )),
      (user) {
        if (user == null) {
          emit(const Unauthenticated());
          return;
        }
        emit(
          Authenticated(
            user: user,
            completedFlow: AuthFlow.sessionCheck,
          ),
        );
      },
    );
  }

  Future<void> signIn({required String email, required String password}) async {
    emit(const AuthLoading(flow: AuthFlow.signIn));
    final result = await _signInUseCase(email: email, password: password);
    result.fold(
      (failure) => emit(AuthError(message: failure.message, flow: AuthFlow.signIn)),
      (user) => emit(
        Authenticated(user: user, completedFlow: AuthFlow.signIn),
      ),
    );
  }

  Future<void> createAccount({
    required String name,
    required String email,
    required String password,
    required bool acceptedTerms,
  }) async {
    emit(const AuthLoading(flow: AuthFlow.createAccount));

    if (name.trim().isEmpty ||
        email.trim().isEmpty ||
        password.trim().isEmpty) {
      emit(
        const AuthError(
          flow: AuthFlow.createAccount,
          message: 'Please complete all required fields',
        ),
      );
      return;
    }

    if (!acceptedTerms) {
      emit(
        const AuthError(
          flow: AuthFlow.createAccount,
          message: 'Please accept Terms & Condition',
        ),
      );
      return;
    }

    final result = await _signUpUseCase(
      name: name,
      email: email,
      password: password,
    );
    result.fold(
      (failure) => emit(
        AuthError(message: failure.message, flow: AuthFlow.createAccount),
      ),
      (user) => emit(
        Authenticated(user: user, completedFlow: AuthFlow.createAccount),
      ),
    );
  }

  /// Mock email verification — accepts [mockOtpCode] only (`1234`).
  Future<void> completeVerification({required String code}) async {
    final entered = code.trim();
    if (entered.length != 4) {
      emit(
        const AuthError(
          flow: AuthFlow.verifyCode,
          message: 'Please enter all 4 digits',
        ),
      );
      return;
    }

    if (entered != mockOtpCode) {
      emit(
        const AuthError(
          flow: AuthFlow.verifyCode,
          message: 'For testing, please enter code: 1234',
        ),
      );
      return;
    }

    final cachedSession = _currentUser ?? _onboardingSessionUser;
    emit(const AuthLoading(flow: AuthFlow.verifyCode));

    final user = cachedSession ?? await _reloadAndFetchSessionUser();
    if (user != null) {
      emit(Authenticated(user: user, completedFlow: AuthFlow.verifyCode));
      return;
    }

    emit(
      const AuthError(
        flow: AuthFlow.verifyCode,
        message: 'No active session. Please sign in again.',
      ),
    );
  }

  /// Reloads Firebase auth and hydrates [UserEntity] for onboarding recovery.
  Future<UserEntity?> _reloadAndFetchSessionUser() async {
    try {
      await FirebaseAuth.instance.currentUser?.reload();
    } catch (_) {
      // Non-fatal; Firestore profile may still be available.
    }

    final result = await _getCurrentUserUseCase();
    return result.fold(
      (_) => null,
      (user) {
        if (user != null) {
          _onboardingSessionUser = user;
        }
        return user;
      },
    );
  }

  /// Attempts session recovery after sign-up before forcing navigation.
  Future<bool> tryRecoverVerificationSession() async {
    final user = await _reloadAndFetchSessionUser();
    if (user == null) return false;
    emit(Authenticated(user: user, completedFlow: AuthFlow.verifyCode));
    return true;
  }

  /// @deprecated Use [completeVerification] instead.
  Future<void> verifyCode({required String code}) =>
      completeVerification(code: code);

  Future<void> sendPasswordReset({required String email}) async {
    emit(const AuthLoading(flow: AuthFlow.newPassword));

    if (email.trim().isEmpty) {
      emit(
        const AuthError(
          flow: AuthFlow.newPassword,
          message: 'Email is required',
        ),
      );
      return;
    }

    final result = await _sendPasswordResetUseCase(email: email);
    result.fold(
      (failure) => emit(
        AuthError(message: failure.message, flow: AuthFlow.newPassword),
      ),
      (_) {
        final user = _currentUser;
        if (user != null) {
          emit(Authenticated(user: user, completedFlow: AuthFlow.newPassword));
        } else {
          emit(const Unauthenticated());
        }
      },
    );
  }

  Future<void> completeProfile({
    required String name,
    required String phone,
    required String? gender,
    String countryCode = '+1',
  }) async {
    emit(const AuthLoading(flow: AuthFlow.completeProfile));

    if (name.trim().isEmpty || phone.trim().isEmpty || gender == null) {
      emit(
        const AuthError(
          flow: AuthFlow.completeProfile,
          message: 'Please complete all required profile fields',
        ),
      );
      return;
    }

    final result = await _completeProfileUseCase(
      name: name,
      phone: phone,
      gender: gender,
      countryCode: countryCode,
    );
    result.fold(
      (failure) => emit(
        AuthError(message: failure.message, flow: AuthFlow.completeProfile),
      ),
      (user) => emit(
        Authenticated(user: user, completedFlow: AuthFlow.completeProfile),
      ),
    );
  }

  Future<void> signOut() async {
    emit(const AuthLoading());
    final result = await _signOutUseCase();
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(const Unauthenticated()),
    );
  }

  static const String _locationPermissionNotice =
      'Location permission is required to calculate distances to nearby hospitals.';

  Future<void> requestLocationAccess() async {
    final user = _currentUser;
    if (user == null) {
      emit(const Unauthenticated());
      return;
    }

    emit(const AuthLoading(flow: AuthFlow.locationAccess));

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        emit(
          AuthError(
            flow: AuthFlow.locationAccess,
            message:
                'Location services are disabled. Please enable GPS and try again.',
          ),
        );
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      final granted = permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;

      if (!granted) {
        final deniedForever = permission == LocationPermission.deniedForever;
        emit(
          Authenticated(
            user: user,
            completedFlow: AuthFlow.locationAccess,
            noticeMessage: _locationPermissionNotice,
            offerOpenSettings: deniedForever,
          ),
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 15),
        ),
      );

      final saveResult = await _authRepository.updateUserLocation(
        uid: user.uid,
        latitude: position.latitude,
        longitude: position.longitude,
      );

      saveResult.fold(
        (failure) => emit(
          AuthError(
            flow: AuthFlow.locationAccess,
            message: failure.message,
          ),
        ),
        (_) => emit(
          Authenticated(
            user: user,
            completedFlow: AuthFlow.locationAccess,
          ),
        ),
      );
    } catch (e) {
      emit(
        AuthError(
          flow: AuthFlow.locationAccess,
          message: 'Could not access your location. Please try again.',
        ),
      );
    }
  }

  Future<void> requestNotificationAccess() async {
    final user = _currentUser;
    if (user == null) {
      emit(const Unauthenticated());
      return;
    }

    emit(const AuthLoading(flow: AuthFlow.notificationAccess));

    try {
      final status = await Permission.notification.request();
      final enabled = status.isGranted;

      final saveResult = await _authRepository.updateNotificationPreference(
        uid: user.uid,
        notificationsEnabled: enabled,
      );

      saveResult.fold(
        (failure) => emit(
          AuthError(
            flow: AuthFlow.notificationAccess,
            message: failure.message,
          ),
        ),
        (_) => emit(
          Authenticated(
            user: user,
            completedFlow: AuthFlow.notificationAccess,
          ),
        ),
      );
    } catch (e) {
      emit(
        AuthError(
          flow: AuthFlow.notificationAccess,
          message: 'Could not update notification settings. Please try again.',
        ),
      );
    }
  }

  /// Saves `notificationsEnabled: false` and completes onboarding.
  Future<void> skipNotificationAccess() async {
    final user = _currentUser;
    if (user == null) {
      emit(const Unauthenticated());
      return;
    }

    emit(const AuthLoading(flow: AuthFlow.notificationAccess));

    final saveResult = await _authRepository.updateNotificationPreference(
      uid: user.uid,
      notificationsEnabled: false,
    );

    saveResult.fold(
      (failure) => emit(
        AuthError(
          flow: AuthFlow.notificationAccess,
          message: failure.message,
        ),
      ),
      (_) => emit(
        Authenticated(
          user: user,
          completedFlow: AuthFlow.notificationAccess,
        ),
      ),
    );
  }

  UserEntity? get _currentUser {
    final current = state;
    if (current is Authenticated) return current.user;
    return _onboardingSessionUser;
  }

  @override
  Future<void> close() {
    unawaited(_authSubscription?.cancel());
    return super.close();
  }
}
