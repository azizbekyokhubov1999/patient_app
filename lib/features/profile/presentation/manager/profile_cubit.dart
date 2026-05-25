import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/mock_data.dart';
import '../../../../core/errors/firebase_failure_mapper.dart';
import '../../data/models/user_model.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
import '../../domain/usecases/profile_sign_out_usecase.dart';
import '../../domain/usecases/save_user_profile_usecase.dart';
import '../manager/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required GetUserProfileUseCase getUserProfileUseCase,
    required SaveUserProfileUseCase saveUserProfileUseCase,
    required ProfileSignOutUseCase profileSignOutUseCase,
    FirebaseAuth? auth,
  })  : _getUserProfileUseCase = getUserProfileUseCase,
        _saveUserProfileUseCase = saveUserProfileUseCase,
        _profileSignOutUseCase = profileSignOutUseCase,
        _auth = auth ?? FirebaseAuth.instance,
        super(const ProfileState());

  final GetUserProfileUseCase _getUserProfileUseCase;
  final SaveUserProfileUseCase _saveUserProfileUseCase;
  final ProfileSignOutUseCase _profileSignOutUseCase;
  final FirebaseAuth _auth;

  Future<void> loadUserProfile() async {
    emit(state.copyWith(status: ProfileStatus.loading, errorMessage: null));

    if (kUseProfileMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      emit(
        state.copyWith(
          user: mockProfileUser,
          status: ProfileStatus.success,
          errorMessage: null,
        ),
      );
      return;
    }

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
      final profile = await _getUserProfileUseCase(firebaseUser.uid);
      final user = profile == null
          ? UserModel(
              uid: firebaseUser.uid,
              displayName: firebaseUser.displayName ?? 'Patient',
              email: firebaseUser.email ?? '',
              photoUrl: firebaseUser.photoURL ?? '',
            )
          : _toUserModel(profile);

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
          errorMessage: FirebaseFailureMapper.map(e).message,
        ),
      );
    }
  }

  Future<void> updateUserProfile({required UserModel updatedUser}) async {
    emit(state.copyWith(status: ProfileStatus.updating, errorMessage: null));

    try {
      if (kUseProfileMockData) {
        await Future<void>.delayed(const Duration(milliseconds: 600));
      } else {
        await _saveUserProfileUseCase(_toUserProfile(updatedUser));
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
          errorMessage: FirebaseFailureMapper.map(e).message,
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

      if (!kUseProfileMockData) {
        final profile = _toUserProfile(current.copyWith(photoUrl: updatedPhoto));
        await _saveUserProfileUseCase(profile);
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
          errorMessage: FirebaseFailureMapper.map(e).message,
        ),
      );
    }
  }

  Future<bool> logout() async {
    try {
      await _profileSignOutUseCase();
      emit(const ProfileState(status: ProfileStatus.initial));
      return true;
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: FirebaseFailureMapper.map(e).message,
        ),
      );
      return false;
    }
  }

  UserModel _toUserModel(UserProfile profile) {
    return UserModel(
      uid: profile.uid,
      displayName: profile.displayName,
      email: profile.email,
      photoUrl: profile.photoUrl,
      phone: profile.phone,
      countryCode: profile.countryCode,
      dateOfBirth: profile.dateOfBirth,
      gender: profile.gender,
    );
  }

  UserProfile _toUserProfile(UserModel model) {
    return UserProfile(
      uid: model.uid,
      displayName: model.displayName,
      email: model.email,
      photoUrl: model.photoUrl,
      phone: model.phone,
      countryCode: model.countryCode,
      dateOfBirth: model.dateOfBirth,
      gender: model.gender,
    );
  }
}
