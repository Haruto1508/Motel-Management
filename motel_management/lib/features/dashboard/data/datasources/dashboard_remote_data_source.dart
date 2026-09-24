import 'package:rental_management/core/network/api_client.dart';
import 'package:rental_management/features/dashboard/data/models/dashboard_stats_model.dart';

abstract class DashboardRemoteDataSource {
  Future<DashboardStatsModel> getStats({String? billingMonth});
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final ApiClient _apiClient;

  DashboardRemoteDataSourceImpl(this._apiClient);

  @override
  Future<DashboardStatsModel> getStats({String? billingMonth}) async {
    final response = await _apiClient.get(
      '/dashboard/stats',
      queryParameters: billingMonth != null ? {'billingMonth': billingMonth} : null,
    );

    final rawData = response.data;
    final Map<String, dynamic> data = rawData is Map<String, dynamic>
        ? (rawData['data'] is Map<String, dynamic>
            ? rawData['data'] as Map<String, dynamic>
            : rawData)
        : <String, dynamic>{};

    return DashboardStatsModel.fromJson(data);
  }
}
