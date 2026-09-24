import 'package:rental_management/core/constants/app_constants.dart';
import 'package:rental_management/core/network/api_client.dart';
import 'package:rental_management/features/contracts/data/models/contract_model.dart';

abstract class ContractRemoteDataSource {
  Future<List<ContractModel>> getContracts({String? query, String? status});

  Future<ContractModel> getContractById(String id);

  Future<ContractModel> createContract(Map<String, dynamic> data);

  Future<ContractModel> updateContract(String id, Map<String, dynamic> data);

  Future<void> terminateContract(String id, {String? reason});

  Future<ContractModel> renewContract(
    String id, {
    required DateTime newEndDate,
    double? newMonthlyRent,
  });
}

class ContractRemoteDataSourceImpl implements ContractRemoteDataSource {
  final ApiClient _apiClient;

  ContractRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<ContractModel>> getContracts({String? query, String? status}) async {
    final queryParams = <String, dynamic>{};
    if (query != null && query.isNotEmpty) queryParams['query'] = query;
    if (status != null && status.isNotEmpty) queryParams['status'] = status;

    final response = await _apiClient.get(
      AppConstants.endpointContracts,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    final rawData = response.data;
    final List<dynamic> list = rawData is Map<String, dynamic>
        ? (rawData['data'] as List<dynamic>? ?? [])
        : (rawData is List ? rawData : []);

    return list
        .map((item) => ContractModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ContractModel> getContractById(String id) async {
    final response = await _apiClient.get('${AppConstants.endpointContracts}/$id');

    final rawData = response.data;
    final Map<String, dynamic> data = rawData is Map<String, dynamic>
        ? (rawData['data'] is Map<String, dynamic>
            ? rawData['data'] as Map<String, dynamic>
            : rawData)
        : <String, dynamic>{};

    return ContractModel.fromJson(data);
  }

  @override
  Future<ContractModel> createContract(Map<String, dynamic> data) async {
    final response = await _apiClient.post(
      AppConstants.endpointContracts,
      data: data,
    );

    final rawData = response.data;
    final Map<String, dynamic> resData = rawData is Map<String, dynamic>
        ? (rawData['data'] is Map<String, dynamic>
            ? rawData['data'] as Map<String, dynamic>
            : rawData)
        : <String, dynamic>{};

    return ContractModel.fromJson(resData);
  }

  @override
  Future<ContractModel> updateContract(String id, Map<String, dynamic> data) async {
    final response = await _apiClient.put(
      '${AppConstants.endpointContracts}/$id',
      data: data,
    );

    final rawData = response.data;
    final Map<String, dynamic> resData = rawData is Map<String, dynamic>
        ? (rawData['data'] is Map<String, dynamic>
            ? rawData['data'] as Map<String, dynamic>
            : rawData)
        : <String, dynamic>{};

    return ContractModel.fromJson(resData);
  }

  @override
  Future<void> terminateContract(String id, {String? reason}) async {
    await _apiClient.post(
      '${AppConstants.endpointContracts}/$id/terminate',
      data: {if (reason != null) 'reason': reason},
    );
  }

  @override
  Future<ContractModel> renewContract(
    String id, {
    required DateTime newEndDate,
    double? newMonthlyRent,
  }) async {
    final response = await _apiClient.post(
      '${AppConstants.endpointContracts}/$id/renew',
      data: {
        'newEndDate': newEndDate.toIso8601String(),
        if (newMonthlyRent != null) 'newMonthlyRent': newMonthlyRent,
      },
    );

    final rawData = response.data;
    final Map<String, dynamic> resData = rawData is Map<String, dynamic>
        ? (rawData['data'] is Map<String, dynamic>
            ? rawData['data'] as Map<String, dynamic>
            : rawData)
        : <String, dynamic>{};

    return ContractModel.fromJson(resData);
  }
}
