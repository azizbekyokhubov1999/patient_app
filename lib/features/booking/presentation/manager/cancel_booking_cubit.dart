import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cancel_booking_state.dart';

/// Skip Firestore writes for diploma / UI demos.
const bool _kPresentationMockCancelBooking = true;

class CancelBookingCubit extends Cubit<CancelBookingState> {
  CancelBookingCubit({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        super(const CancelBookingState());

  final FirebaseFirestore _firestore;

  void selectReason(String reason) {
    emit(
      state.copyWith(
        selectedReason: reason,
        otherReasonText:
            reason == CancelBookingState.otherReasonLabel ? state.otherReasonText : '',
        errorMessage: null,
        isSuccess: false,
      ),
    );
  }

  void updateOtherReasonText(String text) {
    emit(
      state.copyWith(
        otherReasonText: text,
        errorMessage: null,
        isSuccess: false,
      ),
    );
  }

  Future<void> submitCancellation(String appointmentId) async {
    if (!state.canSubmit || appointmentId.isEmpty) return;

    emit(
      state.copyWith(
        isSubmitting: true,
        errorMessage: null,
        isSuccess: false,
      ),
    );

    final reason = state.selectedReason == CancelBookingState.otherReasonLabel
        ? state.otherReasonText.trim()
        : state.selectedReason;

    try {
      if (!_kPresentationMockCancelBooking) {
        await _firestore.collection('appointments').doc(appointmentId).update({
          'status': 'cancelled',
          'cancellationReason': reason,
        });
      } else {
        await Future<void>.delayed(const Duration(milliseconds: 600));
      }

      emit(
        state.copyWith(
          isSubmitting: false,
          isSuccess: true,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isSubmitting: false,
          isSuccess: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
