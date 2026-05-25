import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class GetUserProfileUseCase {
  const GetUserProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Future<UserProfile?> call(String uid) => _repository.getUserProfile(uid);
}
