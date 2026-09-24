import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_management/features/auth/presentation/providers/auth_providers.dart';
import 'package:rental_management/features/rooms/presentation/providers/rooms_providers.dart';
import 'package:rental_management/features/utilities/data/datasources/utility_local_data_source.dart';
import 'package:rental_management/features/utilities/data/datasources/utility_remote_data_source.dart';
import 'package:rental_management/features/utilities/data/repositories/utility_repository_impl.dart';
import 'package:rental_management/features/utilities/domain/entities/service_config_entity.dart';
import 'package:rental_management/features/utilities/domain/entities/utility_reading_entity.dart';
import 'package:rental_management/features/utilities/domain/repositories/utility_repository.dart';
import 'package:rental_management/features/utilities/domain/usecases/get_utility_readings_usecase.dart';
import 'package:rental_management/features/utilities/domain/usecases/record_utility_reading_usecase.dart';
import 'package:rental_management/features/utilities/domain/usecases/service_config_usecases.dart';

final Provider<UtilityRemoteDataSource> utilityRemoteDataSourceProvider =
    Provider<UtilityRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return UtilityRemoteDataSourceImpl(apiClient);
});

final Provider<UtilityLocalDataSource> utilityLocalDataSourceProvider =
    Provider<UtilityLocalDataSource>((ref) {
  final dbService = ref.watch(sqliteDatabaseServiceProvider);
  return UtilityLocalDataSourceImpl(dbService);
});

final Provider<UtilityRepository> utilityRepositoryProvider =
    Provider<UtilityRepository>((ref) {
  final remote = ref.watch(utilityRemoteDataSourceProvider);
  final local = ref.watch(utilityLocalDataSourceProvider);

  return UtilityRepositoryImpl(
    remoteDataSource: remote,
    localDataSource: local,
  );
});

final Provider<GetUtilityReadingsUseCase> getUtilityReadingsUseCaseProvider =
    Provider<GetUtilityReadingsUseCase>((ref) {
  final repository = ref.watch(utilityRepositoryProvider);
  return GetUtilityReadingsUseCase(repository);
});

final Provider<GetLatestReadingUseCase> getLatestReadingUseCaseProvider =
    Provider<GetLatestReadingUseCase>((ref) {
  final repository = ref.watch(utilityRepositoryProvider);
  return GetLatestReadingUseCase(repository);
});

final Provider<RecordUtilityReadingUseCase> recordUtilityReadingUseCaseProvider =
    Provider<RecordUtilityReadingUseCase>((ref) {
  final repository = ref.watch(utilityRepositoryProvider);
  return RecordUtilityReadingUseCase(repository);
});

final Provider<GetServiceConfigsUseCase> getServiceConfigsUseCaseProvider =
    Provider<GetServiceConfigsUseCase>((ref) {
  final repository = ref.watch(utilityRepositoryProvider);
  return GetServiceConfigsUseCase(repository);
});

final Provider<UpdateServiceConfigUseCase> updateServiceConfigUseCaseProvider =
    Provider<UpdateServiceConfigUseCase>((ref) {
  final repository = ref.watch(utilityRepositoryProvider);
  return UpdateServiceConfigUseCase(repository);
});

/// Provider for utility readings (optionally filtered by roomId and/or billingMonth)
final utilityReadingsProvider = FutureProvider.family<List<UtilityReadingEntity>, ({String? roomId, String? billingMonth})>(
  (ref, params) async {
    final useCase = ref.watch(getUtilityReadingsUseCaseProvider);
    return useCase.call(roomId: params.roomId, billingMonth: params.billingMonth);
  },
);

/// Provider for the latest reading of a room
final latestReadingProvider = FutureProvider.family<UtilityReadingEntity?, String>(
  (ref, roomId) async {
    final useCase = ref.watch(getLatestReadingUseCaseProvider);
    return useCase.call(roomId);
  },
);

/// Provider for service configs (electricity, water, internet, trash prices)
final serviceConfigsProvider = FutureProvider<List<ServiceConfigEntity>>((ref) async {
  final useCase = ref.watch(getServiceConfigsUseCaseProvider);
  return useCase.call();
});
