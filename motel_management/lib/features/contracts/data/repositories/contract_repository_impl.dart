import 'package:rental_management/features/contracts/data/datasources/contract_local_data_source.dart';
import 'package:rental_management/features/contracts/data/datasources/contract_remote_data_source.dart';
import 'package:rental_management/features/contracts/domain/entities/contract_entity.dart';
import 'package:rental_management/features/contracts/domain/entities/contract_status.dart';
import 'package:rental_management/features/contracts/domain/repositories/contract_repository.dart';

class ContractRepositoryImpl implements ContractRepository {
  final ContractRemoteDataSource remoteDataSource;
  final ContractLocalDataSource localDataSource;

  ContractRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<ContractEntity>> getContracts({String? query, ContractStatus? status}) async {
    try {
      final models = await remoteDataSource.getContracts(
        query: query,
        status: status?.code,
      );

      // Lưu trữ đồng bộ vào SQLite phục vụ Offline
      await localDataSource.cacheContracts(models);

      return models.map((m) => m.toEntity()).toList();
    } catch (e) {
      final cachedModels = await localDataSource.getCachedContracts(
        query: query,
        status: status?.code,
      );

      if (cachedModels.isNotEmpty) {
        return cachedModels.map((m) => m.toEntity()).toList();
      }

      rethrow;
    }
  }

  @override
  Future<ContractEntity> getContractById(String id) async {
    try {
      final model = await remoteDataSource.getContractById(id);
      await localDataSource.cacheContracts([model]);
      return model.toEntity();
    } catch (e) {
      final cachedModel = await localDataSource.getCachedContractById(id);
      if (cachedModel != null) {
        return cachedModel.toEntity();
      }
      rethrow;
    }
  }

  @override
  Future<ContractEntity> createContract(Map<String, dynamic> data) async {
    final model = await remoteDataSource.createContract(data);
    await localDataSource.cacheContracts([model]);
    return model.toEntity();
  }

  @override
  Future<ContractEntity> updateContract(String id, Map<String, dynamic> data) async {
    final model = await remoteDataSource.updateContract(id, data);
    await localDataSource.cacheContracts([model]);
    return model.toEntity();
  }

  @override
  Future<void> terminateContract(String id, {String? reason}) async {
    await remoteDataSource.terminateContract(id, reason: reason);
    final cached = await localDataSource.getCachedContractById(id);
    if (cached != null) {
      final updated = Map<String, dynamic>.from(cached.toJson());
      updated['status'] = 'TERMINATED';
      await localDataSource.cacheContracts([
        ...await localDataSource.getCachedContracts(),
      ]);
    }
  }

  @override
  Future<ContractEntity> renewContract(
    String id, {
    required DateTime newEndDate,
    double? newMonthlyRent,
  }) async {
    final model = await remoteDataSource.renewContract(
      id,
      newEndDate: newEndDate,
      newMonthlyRent: newMonthlyRent,
    );
    await localDataSource.cacheContracts([model]);
    return model.toEntity();
  }
}
