import 'package:rental_management/core/constants/app_constants.dart';
import 'package:rental_management/core/network/api_client.dart';
import 'package:rental_management/features/utilities/data/models/service_config_model.dart';
import 'package:rental_management/features/utilities/data/models/utility_reading_model.dart';

abstract class UtilityRemoteDataSource {
  Future<List<UtilityReadingModel>> getReadings({String? roomId, String? billingMonth});

  Future<UtilityReadingModel?> getLatestReading(String roomId);

  Future<UtilityReadingModel> recordReading(Map<String, dynamic> data);

  Future<UtilityReadingModel> updateReading(String id, Map<String, dynamic> data);

  Future<void> deleteReading(String id);

  Future<List<ServiceConfigModel>> getServices();

  Future<ServiceConfigModel> updateService(String id, double unitPrice);
}

class UtilityRemoteDataSourceImpl implements UtilityRemoteDataSource {
  final ApiClient _apiClient;

  UtilityRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<UtilityReadingModel>> getReadings({String? roomId, String? billingMonth}) async {
    final queryParams = <String, dynamic>{};
    if (roomId != null && roomId.isNotEmpty) queryParams['roomId'] = roomId;
    if (billingMonth != null && billingMonth.isNotEmpty) queryParams['billingMonth'] = billingMonth;

    final response = await _apiClient.get(
      AppConstants.endpointUtilityReadings,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    final rawData = response.data;
    final List<dynamic> list = rawData is Map<String, dynamic>
        ? (rawData['data'] as List<dynamic>? ?? [])
        : (rawData is List ? rawData : []);

    return list
        .map((item) => UtilityReadingModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<UtilityReadingModel?> getLatestReading(String roomId) async {
    try {
      final response = await _apiClient.get(
        '${AppConstants.endpointUtilityReadings}/latest',
        queryParameters: {'roomId': roomId},
      );

      final rawData = response.data;
      if (rawData == null) return null;

      final Map<String, dynamic> data = rawData is Map<String, dynamic>
          ? (rawData['data'] is Map<String, dynamic>
              ? rawData['data'] as Map<String, dynamic>
              : rawData)
          : <String, dynamic>{};

      if (data.isEmpty) return null;
      return UtilityReadingModel.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<UtilityReadingModel> recordReading(Map<String, dynamic> data) async {
    final response = await _apiClient.post(
      AppConstants.endpointUtilityReadings,
      data: data,
    );

    final rawData = response.data;
    final Map<String, dynamic> resData = rawData is Map<String, dynamic>
        ? (rawData['data'] is Map<String, dynamic>
            ? rawData['data'] as Map<String, dynamic>
            : rawData)
        : <String, dynamic>{};

    return UtilityReadingModel.fromJson(resData);
  }

  @override
  Future<UtilityReadingModel> updateReading(String id, Map<String, dynamic> data) async {
    final response = await _apiClient.put(
      '${AppConstants.endpointUtilityReadings}/$id',
      data: data,
    );

    final rawData = response.data;
    final Map<String, dynamic> resData = rawData is Map<String, dynamic>
        ? (rawData['data'] is Map<String, dynamic>
            ? rawData['data'] as Map<String, dynamic>
            : rawData)
        : <String, dynamic>{};

    return UtilityReadingModel.fromJson(resData);
  }

  @override
  Future<void> deleteReading(String id) async {
    await _apiClient.delete('${AppConstants.endpointUtilityReadings}/$id');
  }

  @override
  Future<List<ServiceConfigModel>> getServices() async {
    final response = await _apiClient.get(AppConstants.endpointServices);

    final rawData = response.data;
    final List<dynamic> list = rawData is Map<String, dynamic>
        ? (rawData['data'] as List<dynamic>? ?? [])
        : (rawData is List ? rawData : []);

    return list
        .map((item) => ServiceConfigModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ServiceConfigModel> updateService(String id, double unitPrice) async {
    final response = await _apiClient.put(
      '${AppConstants.endpointServices}/$id',
      data: {'unitPrice': unitPrice},
    );

    final rawData = response.data;
    final Map<String, dynamic> resData = rawData is Map<String, dynamic>
        ? (rawData['data'] is Map<String, dynamic>
            ? rawData['data'] as Map<String, dynamic>
            : rawData)
        : <String, dynamic>{};

    return ServiceConfigModel.fromJson(resData);
  }
}
