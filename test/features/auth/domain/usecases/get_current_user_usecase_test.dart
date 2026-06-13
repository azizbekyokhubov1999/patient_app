import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patient_app/core/errors/failures.dart';
import 'package:patient_app/features/auth/domain/entities/user_entity.dart';
import 'package:patient_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:patient_app/features/auth/domain/usecases/get_current_user_usecase.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    return const Right(
      UserEntity(
        uid: '1',
        name: 'Demo User',
        email: 'demo@mail.com',
      ),
    );
  }

  @override
  Stream<UserEntity?> authStateChanges() => const Stream.empty();

  @override
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  }) async => throw UnimplementedError();

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async => throw UnimplementedError();

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail({
    required String email,
  }) async => throw UnimplementedError();

  @override
  Future<Either<Failure, UserEntity>> completeProfile({
    required String name,
    required String phone,
    required String gender,
    String countryCode = '+1',
  }) async => throw UnimplementedError();

  @override
  Future<Either<Failure, void>> updateUserLocation({
    required String uid,
    required double latitude,
    required double longitude,
  }) async => throw UnimplementedError();

  @override
  Future<Either<Failure, void>> updateNotificationPreference({
    required String uid,
    required bool notificationsEnabled,
  }) async => throw UnimplementedError();

  @override
  Future<Either<Failure, void>> signOut() async => throw UnimplementedError();
}

void main() {
  test('returns current user from repository', () async {
    final useCase = GetCurrentUserUseCase(_FakeAuthRepository());

    final result = await useCase();

    expect(result.isRight(), true);
    result.fold(
      (failure) => fail('Expected Right but got Left: $failure'),
      (user) {
        expect(user, isNotNull);
        expect(user?.uid, '1');
        expect(user?.email, 'demo@mail.com');
      },
    );
  });
}