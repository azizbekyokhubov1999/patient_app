import '../entities/user_profile.dart';

abstract class ProfileRepository {
  Future<UserProfile?> getUserProfile(String uid);

  Future<UserProfile> saveUserProfile(UserProfile profile);

  Future<void> updatePhotoUrl({
    required String uid,
    required String photoUrl,
  });

  Future<void> signOut();

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<void> deleteUserAccount({
    required String confirmationPassword,
  });

  Future<bool> getNotificationsEnabled(String uid);

  Future<void> setNotificationsEnabled({
    required String uid,
    required bool enabled,
  });
}
