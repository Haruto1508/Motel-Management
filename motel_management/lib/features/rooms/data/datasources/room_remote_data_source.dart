import 'package:rental_management/core/constants/app_constants.dart';
import 'package:rental_management/core/network/api_client.dart';
import 'package:rental_management/features/rooms/data/models/room_model.dart';

abstract class RoomRemoteDataSource {
  Future<List<RoomModel>> getRooms({
    String? query,
    String? status,
    int? floor,
  });

  Future<RoomDetailModel> getRoomById(String id);

  Future<RoomModel> createRoom(Map<String, dynamic> data);

  Future<RoomModel> updateRoom(String id, Map<String, dynamic> data);

  Future<void> deleteRoom(String id);
}

class RoomRemoteDataSourceImpl implements RoomRemoteDataSource {
  final ApiClient _apiClient;

  RoomRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<RoomModel>> getRooms({
    String? query,
    String? status,
    int? floor,
  }) async {
    final queryParams = <String, dynamic>{};
    if (query != null && query.isNotEmpty) queryParams['query'] = query;
    if (status != null && status.isNotEmpty) queryParams['status'] = status;
    if (floor != null) queryParams['floor'] = floor;

    final response = await _apiClient.get(
      AppConstants.endpointRooms,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    final rawData = response.data;
    final List<dynamic> list = rawData is Map<String, dynamic>
        ? (rawData['data'] as List<dynamic>? ?? [])
        : (rawData is List ? rawData : []);

    return list
        .map((item) => RoomModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<RoomDetailModel> getRoomById(String id) async {
    final response = await _apiClient.get('${AppConstants.endpointRooms}/$id');

    final rawData = response.data;
    final Map<String, dynamic> data = rawData is Map<String, dynamic>
        ? (rawData['data'] is Map<String, dynamic>
            ? rawData['data'] as Map<String, dynamic>
            : rawData)
        : <String, dynamic>{};

    return RoomDetailModel.fromJson(data);
  }

  @override
  Future<RoomModel> createRoom(Map<String, dynamic> data) async {
    final response = await _apiClient.post(
      AppConstants.endpointRooms,
      data: data,
    );

    final rawData = response.data;
    final Map<String, dynamic> resData = rawData is Map<String, dynamic>
        ? (rawData['data'] is Map<String, dynamic>
            ? rawData['data'] as Map<String, dynamic>
            : rawData)
        : <String, dynamic>{};

    return RoomModel.fromJson(resData);
  }

  @override
  Future<RoomModel> updateRoom(String id, Map<String, dynamic> data) async {
    final response = await _apiClient.put(
      '${AppConstants.endpointRooms}/$id',
      data: data,
    );

    final rawData = response.data;
    final Map<String, dynamic> resData = rawData is Map<String, dynamic>
        ? (rawData['data'] is Map<String, dynamic>
            ? rawData['data'] as Map<String, dynamic>
            : rawData)
        : <String, dynamic>{};

    return RoomModel.fromJson(resData);
  }

  @override
  Future<void> deleteRoom(String id) async {
    await _apiClient.delete('${AppConstants.endpointRooms}/$id');
  }
}
