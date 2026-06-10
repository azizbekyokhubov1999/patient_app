import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../home/domain/entities/hospital.dart';
import '../../../home/domain/repositories/home_repository.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import 'leave_review_hospital_state.dart';

class LeaveReviewHospitalCubit extends Cubit<LeaveReviewHospitalState> {
  LeaveReviewHospitalCubit({
    required this.hospital,
    required HomeRepository homeRepository,
    required ProfileRepository profileRepository,
    FirebaseAuth? auth,
  })  : _homeRepository = homeRepository,
        _profileRepository = profileRepository,
        _auth = auth ?? FirebaseAuth.instance,
        super(
          const LeaveReviewHospitalState(
            rating: 0,
            reviewText: '',
            isSubmitting: false,
          ),
        );

  final Hospital hospital;
  final HomeRepository _homeRepository;
  final ProfileRepository _profileRepository;
  final FirebaseAuth _auth;

  void setRating(int value) {
    emit(state.copyWith(rating: value.clamp(1, 5), submitError: null));
  }

  void setReviewText(String value) {
    emit(state.copyWith(reviewText: value, submitError: null));
  }

  Future<void> submitReview() async {
    if (state.isSubmitting) return;

    if (state.rating <= 0) {
      emit(
        state.copyWith(
          submitError: 'Please select a rating',
          submitSuccess: false,
        ),
      );
      return;
    }

    final hospitalId = hospital.id.trim();
    if (hospitalId.isEmpty) {
      emit(
        state.copyWith(
          submitError: 'Failed to submit review. Please try again.',
          submitSuccess: false,
        ),
      );
      return;
    }

    final user = _auth.currentUser;
    if (user == null) {
      emit(
        state.copyWith(
          submitError: 'Failed to submit review. Please try again.',
          submitSuccess: false,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        isSubmitting: true,
        submitSuccess: false,
        submitError: null,
      ),
    );

    try {
      final profile = await _profileRepository.getUserProfile(user.uid);
      final userName = profile?.displayName.trim().isNotEmpty == true
          ? profile!.displayName.trim()
          : (user.displayName?.trim().isNotEmpty == true
              ? user.displayName!.trim()
              : 'Patient');
      final userPhoto = profile?.photoUrl.trim().isNotEmpty == true
          ? profile!.photoUrl.trim()
          : (user.photoURL?.trim() ?? '');

      await _homeRepository.submitHospitalReview(
        hospitalId: hospitalId,
        userId: user.uid,
        userName: userName,
        userPhoto: userPhoto,
        rating: state.rating.toDouble(),
        comment: state.reviewText.trim(),
      );

      emit(
        state.copyWith(
          isSubmitting: false,
          submitSuccess: true,
          submitError: null,
        ),
      );
    } catch (e, st) {
      developer.log('submitHospitalReview error', error: e, stackTrace: st);
      emit(
        state.copyWith(
          isSubmitting: false,
          submitSuccess: false,
          submitError: 'Failed to submit review. Please try again.',
        ),
      );
    }
  }

  void clearSubmitStatus() {
    emit(state.copyWith(submitSuccess: false, submitError: null));
  }
}
