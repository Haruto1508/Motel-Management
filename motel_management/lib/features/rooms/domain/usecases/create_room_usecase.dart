import 'package:rental_management/features/rooms/domain/entities/room_entity.dart';
import 'package:rental_management/features/rooms/domain/repositories/room_repository.dart';

class CreateRoomUseCase {
  final RoomRepository _repository;

  CreateRoomUseCase(this._repository);

  Future<RoomEntity> call(CreateRoomParams params) async {
    return await _repository.createRoom(params);
  }
}
