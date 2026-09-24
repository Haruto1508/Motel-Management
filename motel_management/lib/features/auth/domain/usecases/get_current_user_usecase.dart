import 'package:rental_management/features/auth/domain/entities/user_entity.dart';
import 'package:rental_management/features/auth/domain/repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository _repository;

  GetCurrentUserUseCase(this._repository);

  Future<UserEntity> call() async {
    return await _repository.getCurrentUser();
  }
}
