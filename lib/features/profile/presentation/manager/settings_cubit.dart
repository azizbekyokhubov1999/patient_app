import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/mock_data.dart';
import '../../domain/repositories/profile_repository.dart';
import 'settings_state.dart';

const String _kNotificationsPrefKey = 'notifications_enabled';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({
    ProfileRepository? profileRepository,
    FirebaseAuth? auth,
    SharedPreferences? preferences,
  })  : _profileRepository = profileRepository,
        _auth = auth ?? FirebaseAuth.instance,
        _preferences = preferences,
        super(const SettingsInitial());

  final ProfileRepository? _profileRepository;
  final FirebaseAuth _auth;
  SharedPreferences? _preferences;

  bool _notificationsEnabled = mockNotificationsEnabled;

  bool get notificationsEnabled => _notificationsEnabled;

  Future<SharedPreferences> _prefs() async {
    return _preferences ??= await SharedPreferences.getInstance();
  }

  Future<void> loadSettings() async {
    emit(const SettingsLoading());

    if (kUseProfileMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      _notificationsEnabled = mockNotificationsEnabled;
      emit(SettingsLoaded(notificationsEnabled: _notificationsEnabled));
      return;
    }

    final repository = _profileRepository;
    if (repository == null) {
      _notificationsEnabled = true;
      emit(SettingsLoaded(notificationsEnabled: _notificationsEnabled));
      return;
    }

    try {
      final uid = _auth.currentUser!.uid;
      _notificationsEnabled = await repository.getNotificationsEnabled(uid);
      emit(SettingsLoaded(notificationsEnabled: _notificationsEnabled));
    } catch (e, st) {
      developer.log('loadSettings error', error: e, stackTrace: st);
      _notificationsEnabled = true;
      emit(SettingsLoaded(notificationsEnabled: _notificationsEnabled));
    }
  }

  Future<void> updateNotificationPreferences(bool enabled) async {
    final previous = state;
    final previousValue = previous is SettingsLoaded
        ? previous.notificationsEnabled
        : _notificationsEnabled;

    _notificationsEnabled = enabled;
    if (previous is SettingsLoaded) {
      emit(SettingsLoaded(notificationsEnabled: enabled));
    }

    if (kUseProfileMockData) {
      emit(SettingsLoaded(notificationsEnabled: enabled));
      return;
    }

    final repository = _profileRepository;
    if (repository == null) {
      emit(const SettingsError('Failed to update notification settings'));
      _notificationsEnabled = previousValue;
      emit(SettingsLoaded(notificationsEnabled: previousValue));
      return;
    }

    try {
      final uid = _auth.currentUser!.uid;
      await repository.setNotificationsEnabled(uid: uid, enabled: enabled);
      emit(SettingsLoaded(notificationsEnabled: enabled));
    } catch (e, st) {
      developer.log('updateNotificationPreferences error', error: e, stackTrace: st);
      _notificationsEnabled = previousValue;
      emit(const SettingsError('Failed to update notification settings'));
      emit(SettingsLoaded(notificationsEnabled: previousValue));
    }
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (currentPassword.trim().isEmpty) {
      emit(const SettingsError('Enter current password'));
      return;
    }
    if (newPassword.length < 6) {
      emit(const SettingsError('Minimum 6 characters'));
      return;
    }
    if (newPassword != confirmPassword) {
      emit(const SettingsError('Passwords do not match'));
      return;
    }

    emit(const SettingsLoading());

    if (kUseProfileMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      emit(const SettingsActionSuccess('Password updated successfully'));
      emit(const SettingsInitial());
      return;
    }

    final repository = _profileRepository;
    if (repository == null) {
      emit(const SettingsError('Password update is unavailable'));
      emit(const SettingsInitial());
      return;
    }

    try {
      await repository.updatePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      emit(const SettingsActionSuccess('Password updated successfully'));
      emit(const SettingsInitial());
    } on FirebaseAuthException catch (e) {
      emit(SettingsError(_authErrorMessage(e)));
      emit(const SettingsInitial());
    } catch (e, st) {
      developer.log('updatePassword error', error: e, stackTrace: st);
      emit(SettingsError(e.toString()));
      emit(const SettingsInitial());
    }
  }

  Future<bool> deleteUserAccount({
    required String confirmationPassword,
  }) async {
    if (confirmationPassword.trim().isEmpty) {
      emit(const SettingsError('Please enter your password'));
      return false;
    }

    if (kUseProfileMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      emit(const SettingsActionSuccess('Account deleted (mock)'));
      emit(SettingsLoaded(notificationsEnabled: _notificationsEnabled));
      return false;
    }

    final repository = _profileRepository;
    if (repository == null) {
      emit(const SettingsError('Account deletion is unavailable'));
      return false;
    }

    try {
      await repository.deleteUserAccount(
        confirmationPassword: confirmationPassword,
      );

      final prefs = await _prefs();
      await prefs.remove(_kNotificationsPrefKey);

      emit(const SettingsActionSuccess('Account deleted'));
      emit(const SettingsInitial());
      return true;
    } on FirebaseAuthException catch (e) {
      emit(SettingsError(_deleteAuthErrorMessage(e)));
      emit(SettingsLoaded(notificationsEnabled: _notificationsEnabled));
      return false;
    } catch (e, st) {
      developer.log('deleteUserAccount error', error: e, stackTrace: st);
      emit(SettingsError(e.toString()));
      emit(SettingsLoaded(notificationsEnabled: _notificationsEnabled));
      return false;
    }
  }

  String _deleteAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect password. Please try again.';
      case 'requires-recent-login':
        return 'Please sign in again and retry this action.';
      case 'no-current-user':
        return 'No signed-in user';
      default:
        return e.message ?? 'Authentication failed';
    }
  }

  String _authErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'wrong-password':
      case 'invalid-credential':
        return 'Current password is incorrect';
      case 'weak-password':
        return 'New password is too weak.';
      case 'requires-recent-login':
        return 'Please sign in again and retry this action.';
      case 'no-current-user':
        return 'No signed-in user';
      default:
        return e.message ?? 'Authentication failed';
    }
  }
}
