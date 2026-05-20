sealed class PrivacyPolicyState {
  const PrivacyPolicyState();
}

class PrivacyPolicyLoading extends PrivacyPolicyState {
  const PrivacyPolicyLoading();
}

class PrivacyPolicyLoaded extends PrivacyPolicyState {
  const PrivacyPolicyLoaded({
    required this.cancellationPolicyText,
    required this.termsAndConditionsText,
  });

  final String cancellationPolicyText;
  final String termsAndConditionsText;
}

class PrivacyPolicyError extends PrivacyPolicyState {
  const PrivacyPolicyError(this.message);

  final String message;
}
