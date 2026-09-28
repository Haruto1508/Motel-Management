import 'package:rental_management/features/tenants/data/datasources/tenant_local_data_source.dart';
import 'package:rental_management/features/tenants/data/datasources/tenant_remote_data_source.dart';
import 'package:rental_management/features/tenants/domain/entities/room_member_entity.dart';
import 'package:rental_management/features/tenants/domain/entities/tenant_entity.dart';
import 'package:rental_management/features/tenants/domain/entities/tenant_status.dart';
import 'package:rental_management/features/tenants/domain/repositories/tenant_repository.dart';

class TenantRepositoryImpl implements TenantRepository {
  final TenantRemoteDataSource remoteDataSource;
  final TenantLocalDataSource localDataSource;

  TenantRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<TenantEntity>> getTenants({String? query, TenantStatus? status}) async {
    try {
      final models = await remoteDataSource.getTenants(
        query: query,
        status: status?.code,
      );

      // Lưu trữ đồng bộ vào SQLite phục vụ Offline
      try {
        await localDataSource.cacheTenants(models);
      } catch (_) {}

      return models.map((m) => m.toEntity()).toList();
    } catch (e) {
      // Khi offline / server chưa bật: Fallback đọc từ SQLite
      try {
        final cachedModels = await localDataSource.getCachedTenants(
          query: query,
          status: status?.code,
        );

        if (cachedModels.isNotEmpty) {
          return cachedModels.map((m) => m.toEntity()).toList();
        }
      } catch (_) {}

      rethrow;
    }
  }

  @override
  Future<TenantEntity> getTenantById(String id) async {
    try {
      final model = await remoteDataSource.getTenantById(id);
      try {
        await localDataSource.cacheTenants([model]);
      } catch (_) {}
      return model.toEntity();
    } catch (e) {
      try {
        final cachedModel = await localDataSource.getCachedTenantById(id);
        if (cachedModel != null) {
          return cachedModel.toEntity();
        }
      } catch (_) {}
      rethrow;
    }
  }

  @override
  Future<TenantEntity> createTenant(Map<String, dynamic> data) async {
    final model = await remoteDataSource.createTenant(data);
    try {
      await localDataSource.cacheTenants([model]);
    } catch (_) {}
    return model.toEntity();
  }

  @override
  Future<TenantEntity> updateTenant(String id, Map<String, dynamic> data) async {
    final model = await remoteDataSource.updateTenant(id, data);
    try {
      await localDataSource.cacheTenants([model]);
    } catch (_) {}
    return model.toEntity();
  }

  @override
  Future<void> deleteTenant(String id) async {
    await remoteDataSource.deleteTenant(id);
    try {
      await localDataSource.deleteCachedTenant(id);
    } catch (_) {}
  }

  @override
  Future<RoomMemberEntity> addMemberToRoom({
    required String roomId,
    required String tenantId,
    required String role,
    required DateTime moveInDate,
  }) async {
    final model = await remoteDataSource.addMemberToRoom(
      roomId: roomId,
      tenantId: tenantId,
      role: role,
      moveInDate: moveInDate,
    );
    return model.toEntity();
  }

  @override
  Future<void> removeMemberFromRoom({
    required String roomId,
    required String memberId,
  }) async {
    await remoteDataSource.removeMemberFromRoom(
      roomId: roomId,
      memberId: memberId,
    );
  }
}
