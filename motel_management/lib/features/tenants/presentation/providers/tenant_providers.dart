import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_management/features/auth/presentation/providers/auth_providers.dart';
import 'package:rental_management/features/rooms/presentation/providers/rooms_providers.dart';
import 'package:rental_management/features/tenants/data/datasources/tenant_local_data_source.dart';
import 'package:rental_management/features/tenants/data/datasources/tenant_remote_data_source.dart';
import 'package:rental_management/features/tenants/data/repositories/tenant_repository_impl.dart';
import 'package:rental_management/features/tenants/domain/entities/tenant_entity.dart';
import 'package:rental_management/features/tenants/domain/repositories/tenant_repository.dart';
import 'package:rental_management/features/tenants/domain/usecases/create_tenant_usecase.dart';
import 'package:rental_management/features/tenants/domain/usecases/delete_tenant_usecase.dart';
import 'package:rental_management/features/tenants/domain/usecases/get_tenant_by_id_usecase.dart';
import 'package:rental_management/features/tenants/domain/usecases/get_tenants_usecase.dart';
import 'package:rental_management/features/tenants/domain/usecases/room_member_usecases.dart';
import 'package:rental_management/features/tenants/domain/usecases/update_tenant_usecase.dart';

final Provider<TenantRemoteDataSource> tenantRemoteDataSourceProvider =
    Provider<TenantRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TenantRemoteDataSourceImpl(apiClient);
});

final Provider<TenantLocalDataSource> tenantLocalDataSourceProvider =
    Provider<TenantLocalDataSource>((ref) {
  final dbService = ref.watch(sqliteDatabaseServiceProvider);
  return TenantLocalDataSourceImpl(dbService);
});

final Provider<TenantRepository> tenantRepositoryProvider =
    Provider<TenantRepository>((ref) {
  final remoteDataSource = ref.watch(tenantRemoteDataSourceProvider);
  final localDataSource = ref.watch(tenantLocalDataSourceProvider);

  return TenantRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );
});

final Provider<GetTenantsUseCase> getTenantsUseCaseProvider =
    Provider<GetTenantsUseCase>((ref) {
  final repository = ref.watch(tenantRepositoryProvider);
  return GetTenantsUseCase(repository);
});

final Provider<GetTenantByIdUseCase> getTenantByIdUseCaseProvider =
    Provider<GetTenantByIdUseCase>((ref) {
  final repository = ref.watch(tenantRepositoryProvider);
  return GetTenantByIdUseCase(repository);
});

final Provider<CreateTenantUseCase> createTenantUseCaseProvider =
    Provider<CreateTenantUseCase>((ref) {
  final repository = ref.watch(tenantRepositoryProvider);
  return CreateTenantUseCase(repository);
});

final Provider<UpdateTenantUseCase> updateTenantUseCaseProvider =
    Provider<UpdateTenantUseCase>((ref) {
  final repository = ref.watch(tenantRepositoryProvider);
  return UpdateTenantUseCase(repository);
});

final Provider<DeleteTenantUseCase> deleteTenantUseCaseProvider =
    Provider<DeleteTenantUseCase>((ref) {
  final repository = ref.watch(tenantRepositoryProvider);
  return DeleteTenantUseCase(repository);
});

final Provider<AddMemberToRoomUseCase> addMemberToRoomUseCaseProvider =
    Provider<AddMemberToRoomUseCase>((ref) {
  final repository = ref.watch(tenantRepositoryProvider);
  return AddMemberToRoomUseCase(repository);
});

final Provider<RemoveMemberFromRoomUseCase> removeMemberFromRoomUseCaseProvider =
    Provider<RemoveMemberFromRoomUseCase>((ref) {
  final repository = ref.watch(tenantRepositoryProvider);
  return RemoveMemberFromRoomUseCase(repository);
});

final AutoDisposeFutureProviderFamily<TenantEntity, String> tenantDetailProvider =
    FutureProvider.autoDispose.family<TenantEntity, String>((ref, id) async {
  final useCase = ref.watch(getTenantByIdUseCaseProvider);
  return useCase(id);
});
