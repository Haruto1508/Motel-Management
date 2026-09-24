import 'package:rental_management/features/dashboard/domain/entities/dashboard_stats_entity.dart';

/// Contract interface for dashboard statistics
abstract class DashboardRepository {
  /// Fetches aggregated statistics for a specific billing month (format: "yyyy-MM" or null for current)
  Future<DashboardStatsEntity> getStats({String? billingMonth});
}
