class CancelBookingState {
  const CancelBookingState({
    this.selectedReason = '',
    this.otherReasonText = '',
    this.isSubmitting = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  final String selectedReason;
  final String otherReasonText;
  final bool isSubmitting;
  final String? errorMessage;
  final bool isSuccess;

  bool get canSubmit {
    if (selectedReason.isEmpty) return false;
    if (selectedReason == CancelBookingState.otherReasonLabel &&
        otherReasonText.trim().isEmpty) {
      return false;
    }
    return true;
  }

  static const String otherReasonLabel = 'Other';

  CancelBookingState copyWith({
    String? selectedReason,
    String? otherReasonText,
    bool? isSubmitting,
    Object? errorMessage = _sentinel,
    bool? isSuccess,
  }) {
    return CancelBookingState(
      selectedReason: selectedReason ?? this.selectedReason,
      otherReasonText: otherReasonText ?? this.otherReasonText,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  static const Object _sentinel = Object();
}
