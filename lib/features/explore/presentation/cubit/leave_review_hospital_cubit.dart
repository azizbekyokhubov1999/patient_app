import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../home/domain/entities/doctor.dart';
import '../../../home/domain/entities/doctor_review.dart';
import '../../../home/domain/entities/hospital.dart';
import '../../../home/domain/entities/hospital_review.dart';
import 'leave_review_hospital_state.dart';

class LeaveReviewHospitalCubit extends Cubit<LeaveReviewHospitalState> {
  LeaveReviewHospitalCubit(this.hospital)
    : super(
        LeaveReviewHospitalState(
          rating: 5,
          selectedSpecialist: hospital.specialists.isNotEmpty
              ? hospital.specialists.first
              : null,
          reviewText: '',
          isSubmitting: false,
        ),
      );

  final Hospital hospital;

  void setRating(int value) {
    emit(state.copyWith(rating: value.clamp(1, 5)));
  }

  void setSpecialist(Doctor doctor) {
    emit(state.copyWith(selectedSpecialist: doctor));
  }

  void setReviewText(String value) {
    emit(state.copyWith(reviewText: value));
  }

  Hospital submitReview() {
    final comment = state.reviewText.trim().isEmpty
        ? 'Great experience with the hospital team and overall service quality.'
        : state.reviewText.trim();

    final newHospitalReview = HospitalReview(
      userName: 'You',
      userAvatar:
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=200&q=80',
      rating: state.rating.toDouble(),
      comment: comment,
      createdAt: 'just now',
      isVerified: true,
    );

    final specialist = state.selectedSpecialist;
    if (specialist == null) {
      return hospital.copyWith(
        reviews: [newHospitalReview, ...hospital.reviews],
      );
    }

    final specialistReview = DoctorReview(
      authorName: 'You',
      avatarUrl: newHospitalReview.userAvatar,
      verified: true,
      timeAgo: 'just now',
      text: comment,
      rating: state.rating.toDouble(),
    );

    final updatedSpecialists = hospital.specialists.map((d) {
      if (d.name != specialist.name) return d;
      return d.copyWith(
        patientReviews: [specialistReview, ...d.patientReviews],
        reviewsCount: d.reviewsCount + 1,
        rating:
            ((d.rating * d.reviewsCount) + state.rating) / (d.reviewsCount + 1),
      );
    }).toList();

    return hospital.copyWith(
      reviews: [newHospitalReview, ...hospital.reviews],
      specialists: updatedSpecialists,
    );
  }
}
