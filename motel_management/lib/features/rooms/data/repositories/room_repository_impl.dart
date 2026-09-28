import 'package:rental_management/features/rooms/data/datasources/room_local_data_source.dart';
import 'package:rental_management/features/rooms/data/datasources/room_remote_data_source.dart';
import 'package:rental_management/features/rooms/domain/entities/room_detail_entity.dart';
import 'package:rental_management/features/rooms/domain/entities/room_entity.dart';
import 'package:rental_management/features/rooms/domain/entities/room_status.dart';
import 'package:rental_management/features/rooms/domain/repositories/room_repository.dart';

class RoomRepositoryImpl implements RoomRepository {
  final RoomRemoteDataSource remoteDataSource;
  final RoomLocalDataSource localDataSource;

  RoomRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<RoomEntity>> getRooms({
    String? query,
    RoomStatus? status,
    int? floor,
  }) async {
    try {
      final models = await remoteDataSource.getRooms(
        query: query,
        status: status?.code,
        floor: floor,
      );

      // Lưu trữ đồng bộ vào SQLite cục bộ phục vụ Offline
      try {
        await localDataSource.cacheRooms(models);
      } catch (_) {}

      return models.map((m) => m.toEntity()).toList();
    } catch (e) {
      // Khi mất mạng hoặc API lỗi: Tự động fallback đọc dữ liệu đã lưu trong SQLite
      try {
        final cachedModels = await localDataSource.getCachedRooms(
          query: query,
          status: status?.code,
          floor: floor,
        );

        if (cachedModels.isNotEmpty) {
          return cachedModels.map((m) => m.toEntity()).toList();
        }
      } catch (_) {}

      rethrow;
    }
  }

  @override
  Future<RoomDetailEntity> getRoomById(String id) async {
    try {
      final detailModel = await remoteDataSource.getRoomById(id);
      // Lưu chi tiết vào SQLite
      try {
        await localDataSource.cacheRoomDetail(id, detailModel);
      } catch (_) {}
      return detailModel.toEntity();
    } catch (e) {
      // Fallback chi tiết phòng từ SQLite khi offline
      try {
        final cachedDetail = await localDataSource.getCachedRoomDetail(id);
        if (cachedDetail != null) {
          return cachedDetail.toEntity();
        }
      } catch (_) {}
      rethrow;
    }
  }

  @override
  Future<RoomEntity> createRoom(CreateRoomParams params) async {
    final model = await remoteDataSource.createRoom(params.toJson());
    try {
      await localDataSource.cacheRooms([model]);
    } catch (_) {}
    return model.toEntity();
  }

  @override
  Future<RoomEntity> updateRoom(String id, UpdateRoomParams params) async {
    final model = await remoteDataSource.updateRoom(id, params.toJson());
    try {
      await localDataSource.cacheRooms([model]);
    } catch (_) {}
    return model.toEntity();
  }

  @override
  Future<void> deleteRoom(String id) async {
    await remoteDataSource.deleteRoom(id);
    try {
      await localDataSource.deleteCachedRoom(id);
    } catch (_) {}
  }
}
