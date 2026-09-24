import 'package:equatable/equatable.dart';

class RoomMemberEntity extends Equatable {
  final String id;
  final String roomId;
  final String tenantId;
  final String fullName;
  final String phone;
  final String role; // PRIMARY, MEMBER
  final DateTime moveInDate;
  final DateTime? moveOutDate;
  final bool isPrimaryTenant;

  const RoomMemberEntity({
    required this.id,
    required this.roomId,
    required this.tenantId,
    required this.fullName,
    required this.phone,
    this.role = 'MEMBER',
    required this.moveInDate,
    this.moveOutDate,
    this.isPrimaryTenant = false,
  });

  @override
  List<Object?> get props => [
        id,
        roomId,
        tenantId,
        fullName,
        phone,
        role,
        moveInDate,
        moveOutDate,
        isPrimaryTenant,
      ];
}
