import 'package:rental_management/features/tenants/domain/repositories/tenant_repository.dart';

class DeleteTenantUseCase {
  final TenantRepository repository;

  DeleteTenantUseCase(this.repository);

  Future<void> call(String id) {
    return repository.deleteTenant(id);
  }
}
