import 'package:rental_management/features/utilities/domain/entities/service_config_entity.dart';
import 'package:rental_management/features/utilities/domain/repositories/utility_repository.dart';

class GetServiceConfigsUseCase {
  final UtilityRepository repository;

  GetServiceConfigsUseCase(this.repository);

  Future<List<ServiceConfigEntity>> call() {
    return repository.getServices();
  }
}

class UpdateServiceConfigUseCase {
  final UtilityRepository repository;

  UpdateServiceConfigUseCase(this.repository);

  Future<ServiceConfigEntity> call(String id, double unitPrice) {
    if (unitPrice < 0) {
      throw ArgumentError('Đơn giá không thể âm');
    }
    return repository.updateService(id, unitPrice);
  }
}
