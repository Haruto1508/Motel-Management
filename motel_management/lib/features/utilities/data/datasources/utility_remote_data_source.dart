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

  Map<String, dynamic> _extractDataMap(dynamic rawData) {
    if (rawData is Map<String, dynamic>) {
      if (rawData.containsKey('data')) {
        final d = rawData['data'];
        if (d is Map<String, dynamic>) return d;
        if (d == null) return <String, dynamic>{};
      }
      return rawData;
    }
    return <String, dynamic>{};
  }

  List<dynamic> _extractDataList(dynamic rawData) {
    if (rawData is Map<String, dynamic>) {
      final d = rawData['data'];
      if (d is List) return d;
      return [];
    } else if (rawData is List) {
      return rawData;
    }
    return [];
  }

  @override
  Future<List<UtilityReadingModel>> getReadings({String? roomId, String? billingMonth}) async {
    final queryParams = <String, dynamic>{};
    if (roomId != null && roomId.isNotEmpty) queryParams['roomId'] = roomId;
    if (billingMonth != null && billingMonth.isNotEmpty) queryParams['billingMonth'] = billingMonth;

    final response = await _apiClient.get(
      AppConstants.endpointUtilityReadings,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    final list = _extractDataList(response.data);
    return list
        .whereType<Map<String, dynamic>>()
        .map((item) => UtilityReadingModel.fromJson(item))
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

      final data = _extractDataMap(rawData);
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

    final resData = _extractDataMap(response.data);
    return UtilityReadingModel.fromJson(resData);
  }

  @override
  Future<UtilityReadingModel> updateReading(String id, Map<String, dynamic> data) async {
    final response = await _apiClient.put(
      '${AppConstants.endpointUtilityReadings}/$id',
      data: data,
    );

    final resData = _extractDataMap(response.data);
    return UtilityReadingModel.fromJson(resData);
  }

  @override
  Future<void> deleteReading(String id) async {
    await _apiClient.delete('${AppConstants.endpointUtilityReadings}/$id');
  }

  @override
  Future<List<ServiceConfigModel>> getServices() async {
    final response = await _apiClient.get(AppConstants.endpointServices);

    final list = _extractDataList(response.data);
    return list
        .whereType<Map<String, dynamic>>()
        .map((item) => ServiceConfigModel.fromJson(item))
        .toList();
  }

  @override
  Future<ServiceConfigModel> updateService(String id, double unitPrice) async {
    final response = await _apiClient.put(
      '${AppConstants.endpointServices}/$id',
      data: {'unitPrice': unitPrice},
    );

    final resData = _extractDataMap(response.data);
    return ServiceConfigModel.fromJson(resData);
  }
}
