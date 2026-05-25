import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/errors/firebase_failure_mapper.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Stream<UserEntity?> authStateChanges() {
    return _remoteDataSource.authStateChanges();
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final user = await _remoteDataSource.getCurrentUser();
      return Right(user);
    } catch (e) {
      return Left(FirebaseFailureMapper.map(e));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _remoteDataSource.signInWithEmail(
        email: email,
        password: password,
      );
      return Right(user);
    } catch (e) {
      return Left(FirebaseFailureMapper.map(e));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final user = await _remoteDataSource.signUpWithEmail(
        email: email,
        password: password,
        name: name,
      );
      return Right(user);
    } catch (e) {
      return Left(FirebaseFailureMapper.map(e));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await _remoteDataSource.sendPasswordResetEmail(email: email);
      return const Right(null);
    } catch (e) {
      return Left(FirebaseFailureMapper.map(e));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> completeProfile({
    required String name,
    required String phone,
    required String gender,
    String countryCode = '+1',
  }) async {
    try {
      final user = await _remoteDataSource.completeProfile(
        name: name,
        phone: phone,
        gender: gender,
        countryCode: countryCode,
      );
      return Right(user);
    } catch (e) {
      return Left(FirebaseFailureMapper.map(e));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserLocation({
    required String uid,
    required double latitude,
    required double longitude,
  }) async {
    try {
      await _remoteDataSource.updateUserLocation(
        uid: uid,
        latitude: latitude,
        longitude: longitude,
      );
      return const Right(null);
    } catch (e) {
      return Left(FirebaseFailureMapper.map(e));
    }
  }

  @override
  Future<Either<Failure, void>> updateNotificationPreference({
    required String uid,
    required bool notificationsEnabled,
  }) async {
    try {
      await _remoteDataSource.updateNotificationPreference(
        uid: uid,
        notificationsEnabled: notificationsEnabled,
      );
      return const Right(null);
    } catch (e) {
      return Left(FirebaseFailureMapper.map(e));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _remoteDataSource.signOut();
      return const Right(null);
    } catch (e) {
      return Left(FirebaseFailureMapper.map(e));
    }
  }
}
