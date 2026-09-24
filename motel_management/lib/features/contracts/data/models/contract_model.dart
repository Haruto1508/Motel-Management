import 'package:rental_management/features/contracts/domain/entities/contract_entity.dart';
import 'package:rental_management/features/contracts/domain/entities/contract_status.dart';

class ContractModel {
  final String id;
  final String contractNumber;
  final String roomId;
  final String? roomCode;
  final String primaryTenantId;
  final String? primaryTenantName;
  final String? primaryTenantPhone;
  final String startDate;
  final String endDate;
  final double monthlyRent;
  final double depositAmount;
  final int paymentDueDay;
  final String status;
  final String? terms;
  final String? createdAt;
  final String? updatedAt;

  const ContractModel({
    required this.id,
    required this.contractNumber,
    required this.roomId,
    this.roomCode,
    required this.primaryTenantId,
    this.primaryTenantName,
    this.primaryTenantPhone,
    required this.startDate,
    required this.endDate,
    required this.monthlyRent,
    required this.depositAmount,
    this.paymentDueDay = 5,
    this.status = 'ACTIVE',
    this.terms,
    this.createdAt,
    this.updatedAt,
  });

  factory ContractModel.fromJson(Map<String, dynamic> json) {
    return ContractModel(
      id: json['id']?.toString() ?? '',
      contractNumber: json['contractNumber'] as String? ?? json['number'] as String? ?? '',
      roomId: json['roomId']?.toString() ?? '',
      roomCode: json['roomCode'] as String? ?? json['room']?['roomCode'] as String?,
      primaryTenantId: json['primaryTenantId']?.toString() ?? '',
      primaryTenantName: json['primaryTenantName'] as String? ??
          json['primaryTenant']?['fullName'] as String? ??
          json['tenantName'] as String?,
      primaryTenantPhone: json['primaryTenantPhone'] as String? ??
          json['primaryTenant']?['phone'] as String? ??
          json['tenantPhone'] as String?,
      startDate: json['startDate'] as String? ?? DateTime.now().toIso8601String(),
      endDate: json['endDate'] as String? ?? DateTime.now().add(const Duration(days: 365)).toIso8601String(),
      monthlyRent: (json['monthlyRent'] as num?)?.toDouble() ?? 0.0,
      depositAmount: (json['depositAmount'] as num?)?.toDouble() ?? 0.0,
      paymentDueDay: json['paymentDueDay'] as int? ?? 5,
      status: json['status'] as String? ?? 'ACTIVE',
      terms: json['terms'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contractNumber': contractNumber,
      'roomId': roomId,
      'roomCode': roomCode,
      'primaryTenantId': primaryTenantId,
      'primaryTenantName': primaryTenantName,
      'primaryTenantPhone': primaryTenantPhone,
      'startDate': startDate,
      'endDate': endDate,
      'monthlyRent': monthlyRent,
      'depositAmount': depositAmount,
      'paymentDueDay': paymentDueDay,
      'status': status,
      'terms': terms,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  ContractEntity toEntity() {
    return ContractEntity(
      id: id,
      contractNumber: contractNumber,
      roomId: roomId,
      roomCode: roomCode,
      primaryTenantId: primaryTenantId,
      primaryTenantName: primaryTenantName,
      primaryTenantPhone: primaryTenantPhone,
      startDate: DateTime.tryParse(startDate) ?? DateTime.now(),
      endDate: DateTime.tryParse(endDate) ?? DateTime.now(),
      monthlyRent: monthlyRent,
      depositAmount: depositAmount,
      paymentDueDay: paymentDueDay,
      status: ContractStatus.fromString(status),
      terms: terms,
      createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
      updatedAt: updatedAt != null ? DateTime.tryParse(updatedAt!) : null,
    );
  }
}
