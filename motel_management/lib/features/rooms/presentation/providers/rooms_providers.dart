import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_management/features/auth/presentation/providers/auth_providers.dart';
import 'package:rental_management/features/rooms/data/datasources/room_remote_data_source.dart';
import 'package:rental_management/features/rooms/data/repositories/room_repository_impl.dart';
import 'package:rental_management/features/rooms/domain/entities/room_detail_entity.dart';
import 'package:rental_management/features/rooms/domain/entities/room_entity.dart';
import 'package:rental_management/features/rooms/domain/repositories/room_repository.dart';
import 'package:rental_management/features/rooms/domain/usecases/create_room_usecase.dart';
import 'package:rental_management/features/rooms/domain/usecases/delete_room_usecase.dart';
import 'package:rental_management/features/rooms/domain/usecases/get_room_by_id_usecase.dart';
import 'package:rental_management/features/rooms/domain/usecases/get_rooms_usecase.dart';
import 'package:rental_management/features/rooms/domain/usecases/update_room_usecase.dart';
import 'package:rental_management/features/rooms/presentation/providers/rooms_list_controller.dart';

import 'package:rental_management/core/database/sqlite_database_service.dart';
import 'package:rental_management/features/rooms/data/datasources/room_local_data_source.dart';

final Provider<SqliteDatabaseService> sqliteDatabaseServiceProvider =
    Provider<SqliteDatabaseService>((ref) {
  return SqliteDatabaseService();
});

final Provider<RoomLocalDataSource> roomLocalDataSourceProvider =
    Provider<RoomLocalDataSource>((ref) {
  final dbService = ref.watch(sqliteDatabaseServiceProvider);
  return RoomLocalDataSourceImpl(dbService);
});

final Provider<RoomRemoteDataSource> roomRemoteDataSourceProvider =
    Provider<RoomRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return RoomRemoteDataSourceImpl(apiClient);
});

final Provider<RoomRepository> roomRepositoryProvider =
    Provider<RoomRepository>((ref) {
  final remoteDataSource = ref.watch(roomRemoteDataSourceProvider);
  final localDataSource = ref.watch(roomLocalDataSourceProvider);

  return RoomRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );
});

final Provider<GetRoomsUseCase> getRoomsUseCaseProvider =
    Provider<GetRoomsUseCase>((ref) {
  final repository = ref.watch(roomRepositoryProvider);
  return GetRoomsUseCase(repository);
});

final Provider<GetRoomByIdUseCase> getRoomByIdUseCaseProvider =
    Provider<GetRoomByIdUseCase>((ref) {
  final repository = ref.watch(roomRepositoryProvider);
  return GetRoomByIdUseCase(repository);
});

final Provider<CreateRoomUseCase> createRoomUseCaseProvider =
    Provider<CreateRoomUseCase>((ref) {
  final repository = ref.watch(roomRepositoryProvider);
  return CreateRoomUseCase(repository);
});

final Provider<UpdateRoomUseCase> updateRoomUseCaseProvider =
    Provider<UpdateRoomUseCase>((ref) {
  final repository = ref.watch(roomRepositoryProvider);
  return UpdateRoomUseCase(repository);
});

final Provider<DeleteRoomUseCase> deleteRoomUseCaseProvider =
    Provider<DeleteRoomUseCase>((ref) {
  final repository = ref.watch(roomRepositoryProvider);
  return DeleteRoomUseCase(repository);
});

final StateNotifierProvider<RoomsListController, RoomsListState>
    roomsListControllerProvider =
    StateNotifierProvider<RoomsListController, RoomsListState>((ref) {
  final getRoomsUseCase = ref.watch(getRoomsUseCaseProvider);
  final deleteRoomUseCase = ref.watch(deleteRoomUseCaseProvider);

  return RoomsListController(
    getRoomsUseCase: getRoomsUseCase,
    deleteRoomUseCase: deleteRoomUseCase,
  );
});

final AutoDisposeFutureProviderFamily<RoomDetailEntity, String>
    roomDetailProvider =
    FutureProvider.autoDispose.family<RoomDetailEntity, String>((ref, id) async {
  final getRoomById = ref.watch(getRoomByIdUseCaseProvider);
  return await getRoomById(id);
});

final roomsListProvider = FutureProvider<List<RoomEntity>>((ref) async {
  final getRooms = ref.watch(getRoomsUseCaseProvider);
  return await getRooms();
});
