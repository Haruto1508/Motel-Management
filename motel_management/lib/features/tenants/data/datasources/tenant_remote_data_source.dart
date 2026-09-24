import 'package:rental_management/core/constants/app_constants.dart';
import 'package:rental_management/core/network/api_client.dart';
import 'package:rental_management/features/tenants/data/models/room_member_model.dart';
import 'package:rental_management/features/tenants/data/models/tenant_model.dart';

abstract class TenantRemoteDataSource {
  Future<List<TenantModel>> getTenants({String? query, String? status});

  Future<TenantModel> getTenantById(String id);

  Future<TenantModel> createTenant(Map<String, dynamic> data);

  Future<TenantModel> updateTenant(String id, Map<String, dynamic> data);

  Future<void> deleteTenant(String id);

  Future<RoomMemberModel> addMemberToRoom({
    required String roomId,
    required String tenantId,
    required String role,
    required DateTime moveInDate,
  });

  Future<void> removeMemberFromRoom({
    required String roomId,
    required String memberId,
  });
}

class TenantRemoteDataSourceImpl implements TenantRemoteDataSource {
  final ApiClient _apiClient;

  TenantRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<TenantModel>> getTenants({String? query, String? status}) async {
    final queryParams = <String, dynamic>{};
    if (query != null && query.isNotEmpty) queryParams['query'] = query;
    if (status != null && status.isNotEmpty) queryParams['status'] = status;

    final response = await _apiClient.get(
      AppConstants.endpointTenants,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    final rawData = response.data;
    final List<dynamic> list = rawData is Map<String, dynamic>
        ? (rawData['data'] as List<dynamic>? ?? [])
        : (rawData is List ? rawData : []);

    return list
        .map((item) => TenantModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<TenantModel> getTenantById(String id) async {
    final response = await _apiClient.get('${AppConstants.endpointTenants}/$id');

    final rawData = response.data;
    final Map<String, dynamic> data = rawData is Map<String, dynamic>
        ? (rawData['data'] is Map<String, dynamic>
            ? rawData['data'] as Map<String, dynamic>
            : rawData)
        : <String, dynamic>{};

    return TenantModel.fromJson(data);
  }

  @override
  Future<TenantModel> createTenant(Map<String, dynamic> data) async {
    final response = await _apiClient.post(
      AppConstants.endpointTenants,
      data: data,
    );

    final rawData = response.data;
    final Map<String, dynamic> resData = rawData is Map<String, dynamic>
        ? (rawData['data'] is Map<String, dynamic>
            ? rawData['data'] as Map<String, dynamic>
            : rawData)
        : <String, dynamic>{};

    return TenantModel.fromJson(resData);
  }

  @override
  Future<TenantModel> updateTenant(String id, Map<String, dynamic> data) async {
    final response = await _apiClient.put(
      '${AppConstants.endpointTenants}/$id',
      data: data,
    );

    final rawData = response.data;
    final Map<String, dynamic> resData = rawData is Map<String, dynamic>
        ? (rawData['data'] is Map<String, dynamic>
            ? rawData['data'] as Map<String, dynamic>
            : rawData)
        : <String, dynamic>{};

    return TenantModel.fromJson(resData);
  }

  @override
  Future<void> deleteTenant(String id) async {
    await _apiClient.delete('${AppConstants.endpointTenants}/$id');
  }

  @override
  Future<RoomMemberModel> addMemberToRoom({
    required String roomId,
    required String tenantId,
    required String role,
    required DateTime moveInDate,
  }) async {
    final response = await _apiClient.post(
      '${AppConstants.endpointRooms}/$roomId/members',
      data: {
        'tenantId': tenantId,
        'role': role,
        'moveInDate': moveInDate.toIso8601String(),
      },
    );

    final rawData = response.data;
    final Map<String, dynamic> resData = rawData is Map<String, dynamic>
        ? (rawData['data'] is Map<String, dynamic>
            ? rawData['data'] as Map<String, dynamic>
            : rawData)
        : <String, dynamic>{};

    return RoomMemberModel.fromJson(resData);
  }

  @override
  Future<void> removeMemberFromRoom({
    required String roomId,
    required String memberId,
  }) async {
    await _apiClient.delete('${AppConstants.endpointRooms}/$roomId/members/$memberId');
  }
}
