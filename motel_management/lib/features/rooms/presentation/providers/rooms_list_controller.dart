import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_management/features/rooms/domain/entities/room_entity.dart';
import 'package:rental_management/features/rooms/domain/entities/room_status.dart';
import 'package:rental_management/features/rooms/domain/usecases/delete_room_usecase.dart';
import 'package:rental_management/features/rooms/domain/usecases/get_rooms_usecase.dart';

class RoomsFilterState extends Equatable {
  final String searchQuery;
  final RoomStatus? selectedStatus;
  final int? selectedFloor;

  const RoomsFilterState({
    this.searchQuery = '',
    this.selectedStatus,
    this.selectedFloor,
  });

  RoomsFilterState copyWith({
    String? searchQuery,
    RoomStatus? selectedStatus,
    int? selectedFloor,
    bool clearStatus = false,
    bool clearFloor = false,
  }) {
    return RoomsFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedStatus: clearStatus ? null : (selectedStatus ?? this.selectedStatus),
      selectedFloor: clearFloor ? null : (selectedFloor ?? this.selectedFloor),
    );
  }

  @override
  List<Object?> get props => [searchQuery, selectedStatus, selectedFloor];
}

class RoomsListState extends Equatable {
  final bool isLoading;
  final List<RoomEntity> rooms;
  final String? errorMessage;
  final RoomsFilterState filter;

  const RoomsListState({
    this.isLoading = false,
    this.rooms = const [],
    this.errorMessage,
    this.filter = const RoomsFilterState(),
  });

  RoomsListState copyWith({
    bool? isLoading,
    List<RoomEntity>? rooms,
    String? errorMessage,
    RoomsFilterState? filter,
  }) {
    return RoomsListState(
      isLoading: isLoading ?? this.isLoading,
      rooms: rooms ?? this.rooms,
      errorMessage: errorMessage,
      filter: filter ?? this.filter,
    );
  }

  @override
  List<Object?> get props => [isLoading, rooms, errorMessage, filter];
}

class RoomsListController extends StateNotifier<RoomsListState> {
  final GetRoomsUseCase getRoomsUseCase;
  final DeleteRoomUseCase deleteRoomUseCase;

  RoomsListController({
    required this.getRoomsUseCase,
    required this.deleteRoomUseCase,
  }) : super(const RoomsListState(isLoading: true)) {
    loadRooms();
  }

  Future<void> loadRooms() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final rooms = await getRoomsUseCase(
        query: state.filter.searchQuery.isEmpty ? null : state.filter.searchQuery,
        status: state.filter.selectedStatus,
        floor: state.filter.selectedFloor,
      );
      state = state.copyWith(isLoading: false, rooms: rooms);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Không thể tải danh sách phòng. Vui lòng thử lại.',
      );
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(
      filter: state.filter.copyWith(searchQuery: query),
    );
    loadRooms();
  }

  void setStatusFilter(RoomStatus? status) {
    state = state.copyWith(
      filter: status == null
          ? state.filter.copyWith(clearStatus: true)
          : state.filter.copyWith(selectedStatus: status),
    );
    loadRooms();
  }

  void setFloorFilter(int? floor) {
    state = state.copyWith(
      filter: floor == null
          ? state.filter.copyWith(clearFloor: true)
          : state.filter.copyWith(selectedFloor: floor),
    );
    loadRooms();
  }

  Future<bool> deleteRoom(String id) async {
    try {
      await deleteRoomUseCase(id);
      await loadRooms();
      return true;
    } catch (e) {
      return false;
    }
  }
}
