import 'package:rental_management/features/contracts/domain/entities/contract_entity.dart';
import 'package:rental_management/features/contracts/domain/repositories/contract_repository.dart';

class UpdateContractParams {
  final DateTime? startDate;
  final DateTime? endDate;
  final double? monthlyRent;
  final double? depositAmount;
  final int? paymentDueDay;
  final String? terms;
  final String? status;

  const UpdateContractParams({
    this.startDate,
    this.endDate,
    this.monthlyRent,
    this.depositAmount,
    this.paymentDueDay,
    this.terms,
    this.status,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (startDate != null) map['startDate'] = startDate!.toIso8601String();
    if (endDate != null) map['endDate'] = endDate!.toIso8601String();
    if (monthlyRent != null) map['monthlyRent'] = monthlyRent;
    if (depositAmount != null) map['depositAmount'] = depositAmount;
    if (paymentDueDay != null) map['paymentDueDay'] = paymentDueDay;
    if (terms != null) map['terms'] = terms!.trim();
    if (status != null) map['status'] = status;
    return map;
  }
}

class UpdateContractUseCase {
  final ContractRepository repository;

  UpdateContractUseCase(this.repository);

  Future<ContractEntity> call(String id, UpdateContractParams params) {
    return repository.updateContract(id, params.toJson());
  }
}

class TerminateContractUseCase {
  final ContractRepository repository;

  TerminateContractUseCase(this.repository);

  Future<void> call(String id, {String? reason}) {
    return repository.terminateContract(id, reason: reason);
  }
}
