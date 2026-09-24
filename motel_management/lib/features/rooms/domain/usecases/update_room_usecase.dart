import 'package:rental_management/features/rooms/domain/entities/room_entity.dart';
import 'package:rental_management/features/rooms/domain/repositories/room_repository.dart';

class UpdateRoomUseCase {
  final RoomRepository _repository;

  UpdateRoomUseCase(this._repository);

  Future<RoomEntity> call(String id, UpdateRoomParams params) async {
    return await _repository.updateRoom(id, params);
  }
}
