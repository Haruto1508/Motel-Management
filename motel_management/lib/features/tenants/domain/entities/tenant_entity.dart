import 'package:equatable/equatable.dart';
import 'package:rental_management/features/tenants/domain/entities/tenant_status.dart';

class TenantEntity extends Equatable {
  final String id;
  final String fullName;
  final String phone;
  final String? email;
  final String? identityNumber;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? hometown;
  final String? occupation;
  final String? emergencyContact;
  final String? emergencyPhone;
  final String? note;
  final TenantStatus status;
  final String? currentRoomCode;
  final String? currentRoomId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TenantEntity({
    required this.id,
    required this.fullName,
    required this.phone,
    this.email,
    this.identityNumber,
    this.dateOfBirth,
    this.gender,
    this.hometown,
    this.occupation,
    this.emergencyContact,
    this.emergencyPhone,
    this.note,
    this.status = TenantStatus.active,
    this.currentRoomCode,
    this.currentRoomId,
    this.createdAt,
    this.updatedAt,
  });

  bool get isStaying => status == TenantStatus.active && currentRoomId != null;

  @override
  List<Object?> get props => [
        id,
        fullName,
        phone,
        email,
        identityNumber,
        dateOfBirth,
        gender,
        hometown,
        occupation,
        emergencyContact,
        emergencyPhone,
        note,
        status,
        currentRoomCode,
        currentRoomId,
        createdAt,
        updatedAt,
      ];
}
