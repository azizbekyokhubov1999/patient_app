import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/doctor.dart';
import '../../domain/entities/doctor_review.dart';
import 'leave_review_doctor_state.dart';

class LeaveReviewDoctorCubit extends Cubit<LeaveReviewDoctorState> {
  LeaveReviewDoctorCubit(this.doctor)
    : super(
        const LeaveReviewDoctorState(
          rating: 5,
          reviewText: '',
          isSubmitting: false,
        ),
      );

  final Doctor doctor;

  void setRating(int value) {
    emit(state.copyWith(rating: value.clamp(1, 5)));
  }

  void setReviewText(String value) {
    emit(state.copyWith(reviewText: value));
  }

  DoctorReview submitReview() {
    final text = state.reviewText.trim().isEmpty
        ? 'Great experience with clear explanations and very friendly staff.'
        : state.reviewText.trim();

    return DoctorReview(
      authorName: 'You',
      avatarUrl:
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=200&q=80',
      verified: true,
      timeAgo: 'just now',
      text: text,
      rating: state.rating.toDouble(),
    );
  }
}
