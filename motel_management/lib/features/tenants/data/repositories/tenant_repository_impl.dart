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
      await localDataSource.cacheTenants(models);

      return models.map((m) => m.toEntity()).toList();
    } catch (e) {
      // Khi offline / server chưa bật: Fallback đọc từ SQLite
      final cachedModels = await localDataSource.getCachedTenants(
        query: query,
        status: status?.code,
      );

      if (cachedModels.isNotEmpty) {
        return cachedModels.map((m) => m.toEntity()).toList();
      }

      rethrow;
    }
  }

  @override
  Future<TenantEntity> getTenantById(String id) async {
    try {
      final model = await remoteDataSource.getTenantById(id);
      await localDataSource.cacheTenants([model]);
      return model.toEntity();
    } catch (e) {
      final cachedModel = await localDataSource.getCachedTenantById(id);
      if (cachedModel != null) {
        return cachedModel.toEntity();
      }
      rethrow;
    }
  }

  @override
  Future<TenantEntity> createTenant(Map<String, dynamic> data) async {
    final model = await remoteDataSource.createTenant(data);
    await localDataSource.cacheTenants([model]);
    return model.toEntity();
  }

  @override
  Future<TenantEntity> updateTenant(String id, Map<String, dynamic> data) async {
    final model = await remoteDataSource.updateTenant(id, data);
    await localDataSource.cacheTenants([model]);
    return model.toEntity();
  }

  @override
  Future<void> deleteTenant(String id) async {
    await remoteDataSource.deleteTenant(id);
    await localDataSource.deleteCachedTenant(id);
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
