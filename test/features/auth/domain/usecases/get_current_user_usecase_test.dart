import 'package:flutter_test/flutter_test.dart';
import 'package:patient_app/features/auth/domain/entities/app_user.dart';
import 'package:patient_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:patient_app/features/auth/domain/usecases/get_current_user_usecase.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<AppUser?> getCurrentUser() async {
    return const AppUser(id: '1', email: 'demo@mail.com');
  }
}

void main() {
  test('returns current user from repository', () async {
    final useCase = GetCurrentUserUseCase(_FakeAuthRepository());

    final user = await useCase();

    expect(user, isNotNull);
    expect(user?.id, '1');
  });
}
