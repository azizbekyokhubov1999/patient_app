import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class SaveUserProfileUseCase {
  const SaveUserProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Future<UserProfile> call(UserProfile profile) {
    return _repository.saveUserProfile(profile);
  }
}
