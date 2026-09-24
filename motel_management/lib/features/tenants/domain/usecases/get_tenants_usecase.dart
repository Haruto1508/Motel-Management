import 'package:rental_management/features/tenants/domain/entities/tenant_entity.dart';
import 'package:rental_management/features/tenants/domain/entities/tenant_status.dart';
import 'package:rental_management/features/tenants/domain/repositories/tenant_repository.dart';

class GetTenantsUseCase {
  final TenantRepository repository;

  GetTenantsUseCase(this.repository);

  Future<List<TenantEntity>> call({String? query, TenantStatus? status}) {
    return repository.getTenants(query: query, status: status);
  }
}
