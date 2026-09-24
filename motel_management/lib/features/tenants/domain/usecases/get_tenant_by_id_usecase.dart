import 'package:rental_management/features/tenants/domain/entities/tenant_entity.dart';
import 'package:rental_management/features/tenants/domain/repositories/tenant_repository.dart';

class GetTenantByIdUseCase {
  final TenantRepository repository;

  GetTenantByIdUseCase(this.repository);

  Future<TenantEntity> call(String id) {
    return repository.getTenantById(id);
  }
}
