import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class SendPasswordResetUseCase {
  const SendPasswordResetUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, void>> call({required String email}) {
    return _repository.sendPasswordResetEmail(email: email);
  }
}
