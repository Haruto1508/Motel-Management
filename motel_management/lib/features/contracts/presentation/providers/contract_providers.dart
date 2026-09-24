import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_management/features/auth/presentation/providers/auth_providers.dart';
import 'package:rental_management/features/contracts/data/datasources/contract_local_data_source.dart';
import 'package:rental_management/features/contracts/data/datasources/contract_remote_data_source.dart';
import 'package:rental_management/features/contracts/data/repositories/contract_repository_impl.dart';
import 'package:rental_management/features/contracts/domain/entities/contract_entity.dart';
import 'package:rental_management/features/contracts/domain/repositories/contract_repository.dart';
import 'package:rental_management/features/contracts/domain/usecases/create_contract_usecase.dart';
import 'package:rental_management/features/contracts/domain/usecases/get_contracts_usecase.dart';
import 'package:rental_management/features/contracts/domain/usecases/update_contract_usecase.dart';
import 'package:rental_management/features/rooms/presentation/providers/rooms_providers.dart';

final Provider<ContractRemoteDataSource> contractRemoteDataSourceProvider =
    Provider<ContractRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ContractRemoteDataSourceImpl(apiClient);
});

final Provider<ContractLocalDataSource> contractLocalDataSourceProvider =
    Provider<ContractLocalDataSource>((ref) {
  final dbService = ref.watch(sqliteDatabaseServiceProvider);
  return ContractLocalDataSourceImpl(dbService);
});

final Provider<ContractRepository> contractRepositoryProvider =
    Provider<ContractRepository>((ref) {
  final remoteDataSource = ref.watch(contractRemoteDataSourceProvider);
  final localDataSource = ref.watch(contractLocalDataSourceProvider);

  return ContractRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );
});

final Provider<GetContractsUseCase> getContractsUseCaseProvider =
    Provider<GetContractsUseCase>((ref) {
  final repository = ref.watch(contractRepositoryProvider);
  return GetContractsUseCase(repository);
});

final Provider<GetContractByIdUseCase> getContractByIdUseCaseProvider =
    Provider<GetContractByIdUseCase>((ref) {
  final repository = ref.watch(contractRepositoryProvider);
  return GetContractByIdUseCase(repository);
});

final Provider<CreateContractUseCase> createContractUseCaseProvider =
    Provider<CreateContractUseCase>((ref) {
  final repository = ref.watch(contractRepositoryProvider);
  return CreateContractUseCase(repository);
});

final Provider<UpdateContractUseCase> updateContractUseCaseProvider =
    Provider<UpdateContractUseCase>((ref) {
  final repository = ref.watch(contractRepositoryProvider);
  return UpdateContractUseCase(repository);
});

final Provider<TerminateContractUseCase> terminateContractUseCaseProvider =
    Provider<TerminateContractUseCase>((ref) {
  final repository = ref.watch(contractRepositoryProvider);
  return TerminateContractUseCase(repository);
});

final AutoDisposeFutureProviderFamily<ContractEntity, String> contractDetailProvider =
    FutureProvider.autoDispose.family<ContractEntity, String>((ref, id) async {
  final useCase = ref.watch(getContractByIdUseCaseProvider);
  return useCase(id);
});
