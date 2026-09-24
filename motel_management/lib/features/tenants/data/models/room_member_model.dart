import 'package:rental_management/features/tenants/domain/entities/room_member_entity.dart';

class RoomMemberModel {
  final String id;
  final String roomId;
  final String tenantId;
  final String fullName;
  final String phone;
  final String role;
  final String moveInDate;
  final String? moveOutDate;
  final bool isPrimaryTenant;

  const RoomMemberModel({
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

  factory RoomMemberModel.fromJson(Map<String, dynamic> json) {
    return RoomMemberModel(
      id: json['id']?.toString() ?? '',
      roomId: json['roomId']?.toString() ?? '',
      tenantId: json['tenantId']?.toString() ?? '',
      fullName: json['fullName'] as String? ?? json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      role: json['role'] as String? ?? 'MEMBER',
      moveInDate: json['moveInDate'] as String? ?? DateTime.now().toIso8601String(),
      moveOutDate: json['moveOutDate'] as String?,
      isPrimaryTenant: json['isPrimaryTenant'] as bool? ?? (json['role'] == 'PRIMARY'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomId': roomId,
      'tenantId': tenantId,
      'fullName': fullName,
      'phone': phone,
      'role': role,
      'moveInDate': moveInDate,
      'moveOutDate': moveOutDate,
      'isPrimaryTenant': isPrimaryTenant,
    };
  }

  RoomMemberEntity toEntity() {
    return RoomMemberEntity(
      id: id,
      roomId: roomId,
      tenantId: tenantId,
      fullName: fullName,
      phone: phone,
      role: role,
      moveInDate: DateTime.tryParse(moveInDate) ?? DateTime.now(),
      moveOutDate: moveOutDate != null ? DateTime.tryParse(moveOutDate!) : null,
      isPrimaryTenant: isPrimaryTenant,
    );
  }
}
