import 'package:rental_management/features/rooms/domain/entities/room_entity.dart';
import 'package:rental_management/features/rooms/domain/entities/room_status.dart';
import 'package:rental_management/features/rooms/domain/repositories/room_repository.dart';

class GetRoomsUseCase {
  final RoomRepository _repository;

  GetRoomsUseCase(this._repository);

  Future<List<RoomEntity>> call({
    String? query,
    RoomStatus? status,
    int? floor,
  }) async {
    return await _repository.getRooms(
      query: query,
      status: status,
      floor: floor,
    );
  }
}
