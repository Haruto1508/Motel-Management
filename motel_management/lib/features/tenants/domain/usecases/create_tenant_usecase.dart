import 'package:rental_management/features/tenants/domain/entities/tenant_entity.dart';
import 'package:rental_management/features/tenants/domain/repositories/tenant_repository.dart';

class CreateTenantParams {
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

  const CreateTenantParams({
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
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName.trim(),
      'phone': phone.trim(),
      if (email != null && email!.isNotEmpty) 'email': email!.trim(),
      if (identityNumber != null && identityNumber!.isNotEmpty)
        'identityNumber': identityNumber!.trim(),
      if (dateOfBirth != null) 'dateOfBirth': dateOfBirth!.toIso8601String(),
      if (gender != null && gender!.isNotEmpty) 'gender': gender,
      if (hometown != null && hometown!.isNotEmpty) 'hometown': hometown!.trim(),
      if (occupation != null && occupation!.isNotEmpty)
        'occupation': occupation!.trim(),
      if (emergencyContact != null && emergencyContact!.isNotEmpty)
        'emergencyContact': emergencyContact!.trim(),
      if (emergencyPhone != null && emergencyPhone!.isNotEmpty)
        'emergencyPhone': emergencyPhone!.trim(),
      if (note != null && note!.isNotEmpty) 'note': note!.trim(),
    };
  }
}

class CreateTenantUseCase {
  final TenantRepository repository;

  CreateTenantUseCase(this.repository);

  Future<TenantEntity> call(CreateTenantParams params) {
    return repository.createTenant(params.toJson());
  }
}
