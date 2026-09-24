import 'package:rental_management/features/contracts/domain/entities/contract_entity.dart';
import 'package:rental_management/features/contracts/domain/repositories/contract_repository.dart';

class CreateContractParams {
  final String contractNumber;
  final String roomId;
  final String primaryTenantId;
  final DateTime startDate;
  final DateTime endDate;
  final double monthlyRent;
  final double depositAmount;
  final int paymentDueDay;
  final String? terms;

  const CreateContractParams({
    required this.contractNumber,
    required this.roomId,
    required this.primaryTenantId,
    required this.startDate,
    required this.endDate,
    required this.monthlyRent,
    required this.depositAmount,
    this.paymentDueDay = 5,
    this.terms,
  });

  Map<String, dynamic> toJson() {
    return {
      'contractNumber': contractNumber.trim(),
      'roomId': roomId,
      'primaryTenantId': primaryTenantId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'monthlyRent': monthlyRent,
      'depositAmount': depositAmount,
      'paymentDueDay': paymentDueDay,
      if (terms != null && terms!.trim().isNotEmpty) 'terms': terms!.trim(),
    };
  }
}

class CreateContractUseCase {
  final ContractRepository repository;

  CreateContractUseCase(this.repository);

  Future<ContractEntity> call(CreateContractParams params) {
    if (params.endDate.isBefore(params.startDate)) {
      throw ArgumentError('Ngày kết thúc hợp đồng phải sau ngày bắt đầu');
    }
    if (params.monthlyRent <= 0) {
      throw ArgumentError('Tiền thuê phòng hàng tháng phải lớn hơn 0');
    }

    return repository.createContract(params.toJson());
  }
}
