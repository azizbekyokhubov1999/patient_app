import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';
import '../models/user_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._remoteDataSource);

  final ProfileRemoteDataSource _remoteDataSource;

  @override
  Future<UserProfile?> getUserProfile(String uid) async {
    final model = await _remoteDataSource.getUserProfile(uid);
    return model == null ? null : _toEntity(model);
  }

  @override
  Future<UserProfile> saveUserProfile(UserProfile profile) async {
    final saved = await _remoteDataSource.saveUserProfile(_toModel(profile));
    return _toEntity(saved);
  }

  @override
  Future<void> updatePhotoUrl({
    required String uid,
    required String photoUrl,
  }) {
    return _remoteDataSource.updatePhotoUrl(uid: uid, photoUrl: photoUrl);
  }

  @override
  Future<void> signOut() {
    return _remoteDataSource.signOut();
  }

  UserProfile _toEntity(UserModel model) {
    return UserProfile(
      uid: model.uid,
      displayName: model.displayName,
      email: model.email,
      photoUrl: model.photoUrl,
      phone: model.phone,
      countryCode: model.countryCode,
      dateOfBirth: model.dateOfBirth,
      gender: model.gender,
      isProfileComplete: model.isProfileComplete,
    );
  }

  UserModel _toModel(UserProfile profile) {
    return UserModel(
      uid: profile.uid,
      displayName: profile.displayName,
      email: profile.email,
      photoUrl: profile.photoUrl,
      phone: profile.phone,
      countryCode: profile.countryCode,
      dateOfBirth: profile.dateOfBirth,
      gender: profile.gender,
      isProfileComplete: profile.isProfileComplete,
    );
  }
}
