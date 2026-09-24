import 'package:rental_management/features/dashboard/domain/entities/dashboard_stats_entity.dart';
import 'package:rental_management/features/dashboard/domain/repositories/dashboard_repository.dart';

class GetDashboardStatsUseCase {
  final DashboardRepository _repository;

  GetDashboardStatsUseCase(this._repository);

  Future<DashboardStatsEntity> call({String? billingMonth}) async {
    return await _repository.getStats(billingMonth: billingMonth);
  }
}
