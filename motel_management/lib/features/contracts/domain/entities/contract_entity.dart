import 'package:equatable/equatable.dart';
import 'package:rental_management/features/contracts/domain/entities/contract_status.dart';

class ContractEntity extends Equatable {
  final String id;
  final String contractNumber;
  final String roomId;
  final String? roomCode;
  final String primaryTenantId;
  final String? primaryTenantName;
  final String? primaryTenantPhone;
  final DateTime startDate;
  final DateTime endDate;
  final double monthlyRent;
  final double depositAmount;
  final int paymentDueDay;
  final ContractStatus status;
  final String? terms;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ContractEntity({
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
    this.status = ContractStatus.active,
    this.terms,
    this.createdAt,
    this.updatedAt,
  });

  bool get isActive => status == ContractStatus.active;
  bool get isExpired => DateTime.now().isAfter(endDate);

  int get remainingDays {
    final diff = endDate.difference(DateTime.now()).inDays;
    return diff > 0 ? diff : 0;
  }

  @override
  List<Object?> get props => [
        id,
        contractNumber,
        roomId,
        roomCode,
        primaryTenantId,
        primaryTenantName,
        primaryTenantPhone,
        startDate,
        endDate,
        monthlyRent,
        depositAmount,
        paymentDueDay,
        status,
        terms,
        createdAt,
        updatedAt,
      ];
}
