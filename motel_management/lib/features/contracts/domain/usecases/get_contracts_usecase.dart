import 'package:rental_management/features/contracts/domain/entities/contract_entity.dart';
import 'package:rental_management/features/contracts/domain/entities/contract_status.dart';
import 'package:rental_management/features/contracts/domain/repositories/contract_repository.dart';

class GetContractsUseCase {
  final ContractRepository repository;

  GetContractsUseCase(this.repository);

  Future<List<ContractEntity>> call({String? query, ContractStatus? status}) {
    return repository.getContracts(query: query, status: status);
  }
}

class GetContractByIdUseCase {
  final ContractRepository repository;

  GetContractByIdUseCase(this.repository);

  Future<ContractEntity> call(String id) {
    return repository.getContractById(id);
  }
}
