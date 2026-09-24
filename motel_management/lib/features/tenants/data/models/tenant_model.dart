import 'package:rental_management/features/tenants/domain/entities/tenant_entity.dart';
import 'package:rental_management/features/tenants/domain/entities/tenant_status.dart';

class TenantModel {
  final String id;
  final String fullName;
  final String phone;
  final String? email;
  final String? identityNumber;
  final String? dateOfBirth;
  final String? gender;
  final String? hometown;
  final String? occupation;
  final String? emergencyContact;
  final String? emergencyPhone;
  final String? note;
  final String status;
  final String? currentRoomCode;
  final String? currentRoomId;
  final String? createdAt;
  final String? updatedAt;

  const TenantModel({
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
    this.status = 'ACTIVE',
    this.currentRoomCode,
    this.currentRoomId,
    this.createdAt,
    this.updatedAt,
  });

  factory TenantModel.fromJson(Map<String, dynamic> json) {
    return TenantModel(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName'] as String? ?? json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String?,
      identityNumber: json['identityNumber'] as String? ?? json['identityCard'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      gender: json['gender'] as String?,
      hometown: json['hometown'] as String?,
      occupation: json['occupation'] as String?,
      emergencyContact: json['emergencyContact'] as String?,
      emergencyPhone: json['emergencyPhone'] as String?,
      note: json['note'] as String?,
      status: json['status'] as String? ?? 'ACTIVE',
      currentRoomCode: json['currentRoomCode'] as String? ?? json['roomCode'] as String?,
      currentRoomId: json['currentRoomId'] as String? ?? json['roomId'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'phone': phone,
      'email': email,
      'identityNumber': identityNumber,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'hometown': hometown,
      'occupation': occupation,
      'emergencyContact': emergencyContact,
      'emergencyPhone': emergencyPhone,
      'note': note,
      'status': status,
      'currentRoomCode': currentRoomCode,
      'currentRoomId': currentRoomId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  TenantEntity toEntity() {
    return TenantEntity(
      id: id,
      fullName: fullName,
      phone: phone,
      email: email,
      identityNumber: identityNumber,
      dateOfBirth: dateOfBirth != null ? DateTime.tryParse(dateOfBirth!) : null,
      gender: gender,
      hometown: hometown,
      occupation: occupation,
      emergencyContact: emergencyContact,
      emergencyPhone: emergencyPhone,
      note: note,
      status: TenantStatus.fromString(status),
      currentRoomCode: currentRoomCode,
      currentRoomId: currentRoomId,
      createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
      updatedAt: updatedAt != null ? DateTime.tryParse(updatedAt!) : null,
    );
  }
}
