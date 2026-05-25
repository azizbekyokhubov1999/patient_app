import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Stream<UserEntity?> authStateChanges();

  Future<Either<Failure, UserEntity?>> getCurrentUser();

  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  });

  Future<Either<Failure, void>> sendPasswordResetEmail({required String email});

  Future<Either<Failure, UserEntity>> completeProfile({
    required String name,
    required String phone,
    required String gender,
    String countryCode = '+1',
  });

  Future<Either<Failure, void>> updateUserLocation({
    required String uid,
    required double latitude,
    required double longitude,
  });

  Future<Either<Failure, void>> updateNotificationPreference({
    required String uid,
    required bool notificationsEnabled,
  });

  Future<Either<Failure, void>> signOut();
}
