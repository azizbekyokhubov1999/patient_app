import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/user_model.dart';
import 'profile_state.dart';

/// Demo profile while Firestore has no user document.
const bool _kPresentationMockProfile = true;

UserModel _presentationMockUser(String uid) {
  return UserModel(
    uid: uid,
    displayName: 'Jennifer Aaker',
    email: 'example@gmail.com',
    photoUrl: 'https://picsum.photos/200?profile-jennifer',
    phone: '(208) 555-0112',
    countryCode: '+1',
    dateOfBirth: '15/02/2002',
    gender: 'Female',
  );
}

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        super(const ProfileState());

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Future<void> loadUserProfile() async {
    emit(state.copyWith(status: ProfileStatus.loading, errorMessage: null));

    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: 'No signed-in user',
        ),
      );
      return;
    }

    try {
      if (_kPresentationMockProfile) {
        await Future<void>.delayed(const Duration(milliseconds: 400));
        emit(
          state.copyWith(
            user: _presentationMockUser(firebaseUser.uid),
            status: ProfileStatus.success,
          ),
        );
        return;
      }

      final doc =
          await _firestore.collection('users').doc(firebaseUser.uid).get();

      final user = doc.exists
          ? UserModel.fromFirestore(doc)
          : UserModel(
              uid: firebaseUser.uid,
              displayName: firebaseUser.displayName ?? 'Patient',
              email: firebaseUser.email ?? '',
              photoUrl: firebaseUser.photoURL ?? '',
            );

      emit(
        state.copyWith(
          user: user,
          status: ProfileStatus.success,
        ),
      );
    } catch (e, st) {
      developer.log('loadUserProfile error', error: e, stackTrace: st);
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> updateUserProfile({required UserModel updatedUser}) async {
    emit(state.copyWith(status: ProfileStatus.updating, errorMessage: null));

    try {
      if (!_kPresentationMockProfile) {
        await _firestore
            .collection('users')
            .doc(updatedUser.uid)
            .set(updatedUser.toMap(), SetOptions(merge: true));
      } else {
        await Future<void>.delayed(const Duration(milliseconds: 600));
      }

      emit(
        state.copyWith(
          user: updatedUser,
          status: ProfileStatus.updateSuccess,
        ),
      );
    } catch (e, st) {
      developer.log('updateUserProfile error', error: e, stackTrace: st);
      emit(
        state.copyWith(
          status: ProfileStatus.updateFailure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void resetUpdateStatus() {
    if (state.user != null) {
      emit(
        state.copyWith(
          status: ProfileStatus.success,
          errorMessage: null,
        ),
      );
    }
  }

  Future<void> updateProfilePicture() async {
    final current = state.user;
    if (current == null) return;

    emit(
      state.copyWith(status: ProfileStatus.updatingAvatar, errorMessage: null),
    );

    try {
      await Future<void>.delayed(const Duration(milliseconds: 800));

      final updatedPhoto =
          'https://picsum.photos/200?profile-${DateTime.now().millisecondsSinceEpoch}';

      if (!_kPresentationMockProfile) {
        await _firestore.collection('users').doc(current.uid).update({
          'photoUrl': updatedPhoto,
        });
      }

      emit(
        state.copyWith(
          user: current.copyWith(photoUrl: updatedPhoto),
          status: ProfileStatus.success,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<bool> logout() async {
    try {
      await _auth.signOut();
      emit(const ProfileState(status: ProfileStatus.initial));
      return true;
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: e.toString(),
        ),
      );
      return false;
    }
  }
}
