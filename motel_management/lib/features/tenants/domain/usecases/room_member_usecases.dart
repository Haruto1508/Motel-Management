import 'package:rental_management/features/tenants/domain/entities/room_member_entity.dart';
import 'package:rental_management/features/tenants/domain/repositories/tenant_repository.dart';

class AddMemberToRoomParams {
  final String roomId;
  final String tenantId;
  final String role; // PRIMARY, MEMBER
  final DateTime moveInDate;

  const AddMemberToRoomParams({
    required this.roomId,
    required this.tenantId,
    this.role = 'MEMBER',
    required this.moveInDate,
  });
}

class AddMemberToRoomUseCase {
  final TenantRepository repository;

  AddMemberToRoomUseCase(this.repository);

  Future<RoomMemberEntity> call(AddMemberToRoomParams params) {
    return repository.addMemberToRoom(
      roomId: params.roomId,
      tenantId: params.tenantId,
      role: params.role,
      moveInDate: params.moveInDate,
    );
  }
}

class RemoveMemberFromRoomUseCase {
  final TenantRepository repository;

  RemoveMemberFromRoomUseCase(this.repository);

  Future<void> call({required String roomId, required String memberId}) {
    return repository.removeMemberFromRoom(roomId: roomId, memberId: memberId);
  }
}
