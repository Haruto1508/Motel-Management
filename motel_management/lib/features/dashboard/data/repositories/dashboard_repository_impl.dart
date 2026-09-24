import 'dart:convert';
import 'package:rental_management/core/storage/preferences_service.dart';
import 'package:rental_management/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:rental_management/features/dashboard/data/models/dashboard_stats_model.dart';
import 'package:rental_management/features/dashboard/domain/entities/dashboard_stats_entity.dart';
import 'package:rental_management/features/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;
  final PreferencesService preferences;

  static const String _cachedStatsKey = 'cached_dashboard_stats';

  DashboardRepositoryImpl({
    required this.remoteDataSource,
    required this.preferences,
  });

  @override
  Future<DashboardStatsEntity> getStats({String? billingMonth}) async {
    try {
      final model = await remoteDataSource.getStats(billingMonth: billingMonth);
      await preferences.setString(_cachedStatsKey, jsonEncode(model.toJson()));
      return model.toEntity();
    } catch (e) {
      final cachedJson = preferences.getString(_cachedStatsKey);
      if (cachedJson != null && cachedJson.isNotEmpty) {
        final Map<String, dynamic> data =
            jsonDecode(cachedJson) as Map<String, dynamic>;
        return DashboardStatsModel.fromJson(data).toEntity();
      }
      // If no cache and offline in demo/initial state, return clean initial stats
      return const DashboardStatsEntity(
        totalRooms: 0,
        occupiedRooms: 0,
        availableRooms: 0,
        maintenanceRooms: 0,
        totalTenants: 0,
        unpaidInvoices: 0,
        paidInvoices: 0,
        currentMonthRevenue: 0.0,
        currentMonthElectricityKwh: 0.0,
        currentMonthWaterM3: 0.0,
      );
    }
  }
}
