import 'package:rental_management/features/contracts/domain/entities/contract_entity.dart';
import 'package:rental_management/features/contracts/domain/entities/contract_status.dart';

abstract class ContractRepository {
  Future<List<ContractEntity>> getContracts({String? query, ContractStatus? status});

  Future<ContractEntity> getContractById(String id);

  Future<ContractEntity> createContract(Map<String, dynamic> data);

  Future<ContractEntity> updateContract(String id, Map<String, dynamic> data);

  Future<void> terminateContract(String id, {String? reason});

  Future<ContractEntity> renewContract(
    String id, {
    required DateTime newEndDate,
    double? newMonthlyRent,
  });
}
