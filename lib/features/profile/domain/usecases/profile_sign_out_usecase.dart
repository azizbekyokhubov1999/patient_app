import '../repositories/profile_repository.dart';

class ProfileSignOutUseCase {
  const ProfileSignOutUseCase(this._repository);

  final ProfileRepository _repository;

  Future<void> call() => _repository.signOut();
}
