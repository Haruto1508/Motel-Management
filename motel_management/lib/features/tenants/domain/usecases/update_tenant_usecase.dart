import 'package:rental_management/features/tenants/domain/entities/tenant_entity.dart';
import 'package:rental_management/features/tenants/domain/repositories/tenant_repository.dart';

class UpdateTenantParams {
  final String? fullName;
  final String? phone;
  final String? email;
  final String? identityNumber;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? hometown;
  final String? occupation;
  final String? emergencyContact;
  final String? emergencyPhone;
  final String? note;
  final String? status;

  const UpdateTenantParams({
    this.fullName,
    this.phone,
    this.email,
    this.identityNumber,
    this.dateOfBirth,
    this.gender,
    this.hometown,
    this.occupation,
    this.emergencyContact,
    this.emergencyPhone,
    this.note,
    this.status,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (fullName != null) map['fullName'] = fullName!.trim();
    if (phone != null) map['phone'] = phone!.trim();
    if (email != null) map['email'] = email!.trim();
    if (identityNumber != null) map['identityNumber'] = identityNumber!.trim();
    if (dateOfBirth != null) map['dateOfBirth'] = dateOfBirth!.toIso8601String();
    if (gender != null) map['gender'] = gender;
    if (hometown != null) map['hometown'] = hometown!.trim();
    if (occupation != null) map['occupation'] = occupation!.trim();
    if (emergencyContact != null) map['emergencyContact'] = emergencyContact!.trim();
    if (emergencyPhone != null) map['emergencyPhone'] = emergencyPhone!.trim();
    if (note != null) map['note'] = note!.trim();
    if (status != null) map['status'] = status;
    return map;
  }
}

class UpdateTenantUseCase {
  final TenantRepository repository;

  UpdateTenantUseCase(this.repository);

  Future<TenantEntity> call(String id, UpdateTenantParams params) {
    return repository.updateTenant(id, params.toJson());
  }
}
