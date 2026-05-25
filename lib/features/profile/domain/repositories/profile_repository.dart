import '../entities/user_profile.dart';

abstract class ProfileRepository {
  Future<UserProfile?> getUserProfile(String uid);

  Future<UserProfile> saveUserProfile(UserProfile profile);

  Future<void> updatePhotoUrl({
    required String uid,
    required String photoUrl,
  });

  Future<void> signOut();
}
