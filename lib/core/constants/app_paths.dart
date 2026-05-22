abstract final class AppPaths {
  static const String splash = '/splash';
  static const String welcome = '/welcome';
  static const String onboarding = '/onboarding';
  static const String auth = '/auth';
  static const String signUp = '/sign-up';
  static const String signIn = '/sign-in';
  static const String createAccount = '/create-account';
  static const String verifyCode = '/verify-code';
  static const String newPassword = '/new-password';
  static const String completeProfile = '/complete-profile';
  static const String yourLocation = '/your-location';
  static const String enterLocation = '/enter-location';
  static const String notificationAccess = '/notification-access';

  static const String search = '/search';
  static const String services = '/services';
  static const String upcomingAppointments = '/upcoming-appointments';
  static const String appointmentDetail = '/appointment-detail';
  static const String nearbyHospitals = '/nearby-hospitals';
  static const String getDirection = '/get-direction';
  static const String getDirection2 = '/get-direction-2';
  static const String youHaveArrived = '/you-have-arrived';
  static const String hospitalDetail = '/hospital-detail';
  static const String filter = '/filter';
  static const String home = '/home';
  static const String explore = '/explore';
  static const String appointments = '/appointments';

  /// Legacy alias — same tab route as [appointments].
  static const String booking = appointments;
  static const String bookAppointment = '/book-appointment';

  /// Booking entry from favourites doctor cards.
  static const String makeAppointment = bookAppointment;
  static const String selectPackage = '/booking/select-package';
  static const String patientDetails = '/booking/patient-details';
  static const String paymentMethod = '/booking/payment-method';
  static const String addCard = '/booking/payment-methods/add-card';
  static const String reviewSummary = '/booking/review-summary';
  static const String bookingSuccess = '/booking/success';
  static const String eReceipt = '/booking/e-receipt';
  static const String cancelBooking = '/cancel-booking';
  static const String consultationEnded = '/consultation-ended';

  /// Offline / online appointment workflow (aliases for scheduling UI).
  static const String appointmentGetDirection = '/appointments/get-direction';
  static const String appointmentGetDirection2 = '/appointments/get-direction-2';
  static const String appointmentYouHaveArrived = '/appointments/you-have-arrived';
  static const String appointmentEReceipt = '/appointments/e-receipt';
  static const String appointmentQueueStatus = '/appointments/queue-status';
  static const String appointmentConsultationEnded =
      '/appointments/consultation-ended';
  static const String chat = '/chat';
  static const String chatDetail = '/chat-detail';
  static const String videoCall = '/video-call';
  static const String voiceCall = '/voice-call';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String profilePaymentMethods = '/profile/payment-methods';
  static const String settings = '/profile/settings';
  static const String notificationSettings = '/profile/settings/notifications';
  static const String passwordManager = '/profile/settings/password-manager';
  static const String helpCenter = '/profile/help-center';
  static const String privacyPolicy = '/profile/privacy-policy';
  static const String myFavourites = '/profile/my-favourites';
  static const String myCoupons = '/profile/my-coupons';
  static const String myWallet = '/profile/my-wallet';
  static const String addMoney = '/profile/my-wallet/add-money';
  static const String topUpSuccess = '/profile/my-wallet/top-up-success';

  static const String notifications = '/notifications';

  static const String doctorDetails = '/doctor-details';
  static const String topSpecialist = '/top-specialist';

  /// Alias of [doctorDetails] for navigation with `extra: Doctor`.
  static const String doctorDetail = doctorDetails;
  static const String leaveReviewDoctor = '/leave-review-doctor';
  static const String leaveReviewHospital = '/leave-review-hospital';
  static const String hospitalDetails = '/hospital-details';

  /// Leave review for a doctor (same as [leaveReviewDoctor]).
  static const String leaveReview = leaveReviewDoctor;

  /// Payment methods during booking (same as [paymentMethod]).
  static const String paymentMethods = paymentMethod;
}
