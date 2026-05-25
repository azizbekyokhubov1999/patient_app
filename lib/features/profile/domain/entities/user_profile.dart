/// Patient profile stored in Firestore `users` collection.
class UserProfile {
  const UserProfile({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.photoUrl,
    this.phone = '',
    this.countryCode = '+1',
    this.dateOfBirth = '',
    this.gender = 'Female',
  });

  final String uid;
  final String displayName;
  final String email;
  final String photoUrl;
  final String phone;
  final String countryCode;
  final String dateOfBirth;
  final String gender;
}
