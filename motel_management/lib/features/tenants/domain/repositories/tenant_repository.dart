import 'package:rental_management/features/tenants/domain/entities/room_member_entity.dart';
import 'package:rental_management/features/tenants/domain/entities/tenant_entity.dart';
import 'package:rental_management/features/tenants/domain/entities/tenant_status.dart';

abstract class TenantRepository {
  Future<List<TenantEntity>> getTenants({String? query, TenantStatus? status});

  Future<TenantEntity> getTenantById(String id);

  Future<TenantEntity> createTenant(Map<String, dynamic> data);

  Future<TenantEntity> updateTenant(String id, Map<String, dynamic> data);

  Future<void> deleteTenant(String id);

  Future<RoomMemberEntity> addMemberToRoom({
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
