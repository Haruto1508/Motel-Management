import 'package:rental_management/features/rooms/domain/repositories/room_repository.dart';

class DeleteRoomUseCase {
  final RoomRepository _repository;

  DeleteRoomUseCase(this._repository);

  Future<void> call(String id) async {
    return await _repository.deleteRoom(id);
  }
}
