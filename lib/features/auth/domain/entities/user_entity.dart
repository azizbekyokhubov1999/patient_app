/// Authenticated patient user (Firebase Auth + Firestore profile).
class UserEntity {
  const UserEntity({
    required this.uid,
    required this.name,
    required this.email,
    this.walletBalance = 0,
    this.phone = '',
    this.gender = '',
    this.photoUrl = '',
    this.countryCode = '+1',
    this.isProfileComplete = false,
  });

  final String uid;
  final String name;
  final String email;
  final double walletBalance;
  final String phone;
  final String gender;
  final String photoUrl;
  final String countryCode;
  final bool isProfileComplete;
}
