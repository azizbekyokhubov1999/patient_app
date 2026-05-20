import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/mock_data.dart';
import 'settings_state.dart';

const String _kNotificationsPrefKey = 'notifications_enabled';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    SharedPreferences? preferences,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _preferences = preferences,
        super(const SettingsInitial());

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
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

    try {
      final prefs = await _prefs();
      _notificationsEnabled = prefs.getBool(_kNotificationsPrefKey) ?? true;

      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        final doc = await _firestore.collection('users').doc(uid).get();
        final remote = doc.data()?['notificationsEnabled'];
        if (remote is bool) {
          _notificationsEnabled = remote;
          await prefs.setBool(_kNotificationsPrefKey, remote);
        }
      }

      emit(SettingsLoaded(notificationsEnabled: _notificationsEnabled));
    } catch (e, st) {
      developer.log('loadSettings error', error: e, stackTrace: st);
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> updateNotificationPreferences(bool enabled) async {
    final previous = state;
    _notificationsEnabled = enabled;

    if (previous is SettingsLoaded) {
      emit(SettingsLoaded(notificationsEnabled: enabled));
    }

    if (kUseProfileMockData) {
      emit(
        SettingsActionSuccess(
          enabled ? 'Notifications enabled' : 'Notifications disabled',
        ),
      );
      emit(SettingsLoaded(notificationsEnabled: enabled));
      return;
    }

    try {
      final prefs = await _prefs();
      await prefs.setBool(_kNotificationsPrefKey, enabled);

      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        await _firestore.collection('users').doc(uid).set(
          {'notificationsEnabled': enabled},
          SetOptions(merge: true),
        );
      }

      emit(
        SettingsActionSuccess(
          enabled ? 'Notifications enabled' : 'Notifications disabled',
        ),
      );
      emit(SettingsLoaded(notificationsEnabled: enabled));
    } catch (e, st) {
      developer.log('updateNotificationPreferences error', error: e, stackTrace: st);
      _notificationsEnabled = !enabled;
      emit(SettingsError(e.toString()));
      if (previous is SettingsLoaded) {
        emit(SettingsLoaded(notificationsEnabled: previous.notificationsEnabled));
      }
    }
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    emit(const SettingsLoading());

    if (kUseProfileMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      emit(const SettingsActionSuccess('Password updated successfully'));
      emit(SettingsLoaded(notificationsEnabled: _notificationsEnabled));
      return;
    }

    try {
      final user = _auth.currentUser;
      final email = user?.email;
      if (user == null || email == null || email.isEmpty) {
        emit(const SettingsError('No signed-in user'));
        return;
      }

      final credential = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);

      emit(const SettingsActionSuccess('Password updated successfully'));
      emit(SettingsLoaded(notificationsEnabled: _notificationsEnabled));
    } on FirebaseAuthException catch (e) {
      emit(SettingsError(_authErrorMessage(e)));
    } catch (e, st) {
      developer.log('updatePassword error', error: e, stackTrace: st);
      emit(SettingsError(e.toString()));
    }
  }

  Future<bool> deleteUserAccount({
    required String confirmationPassword,
  }) async {
    emit(const SettingsLoading());

    if (kUseProfileMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      emit(const SettingsActionSuccess('Account deleted (mock)'));
      emit(const SettingsInitial());
      return false;
    }

    try {
      final user = _auth.currentUser;
      final uid = user?.uid;
      final email = user?.email;

      if (user == null || uid == null || email == null || email.isEmpty) {
        emit(const SettingsError('No signed-in user'));
        return false;
      }

      final credential = EmailAuthProvider.credential(
        email: email,
        password: confirmationPassword,
      );
      await user.reauthenticateWithCredential(credential);

      await _firestore.collection('users').doc(uid).delete();
      await user.delete();

      final prefs = await _prefs();
      await prefs.remove(_kNotificationsPrefKey);

      emit(const SettingsActionSuccess('Account deleted'));
      emit(const SettingsInitial());
      return true;
    } on FirebaseAuthException catch (e) {
      emit(SettingsError(_authErrorMessage(e)));
      return false;
    } catch (e, st) {
      developer.log('deleteUserAccount error', error: e, stackTrace: st);
      emit(SettingsError(e.toString()));
      return false;
    }
  }

  String _authErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect password. Please try again.';
      case 'weak-password':
        return 'New password is too weak.';
      case 'requires-recent-login':
        return 'Please sign in again and retry this action.';
      default:
        return e.message ?? 'Authentication failed';
    }
  }
}
