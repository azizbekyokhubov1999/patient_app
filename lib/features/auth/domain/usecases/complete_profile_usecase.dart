import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class CompleteProfileUseCase {
  const CompleteProfileUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, UserEntity>> call({
    required String name,
    required String phone,
    required String gender,
    String countryCode = '+1',
  }) {
    return _repository.completeProfile(
      name: name,
      phone: phone,
      gender: gender,
      countryCode: countryCode,
    );
  }
}
