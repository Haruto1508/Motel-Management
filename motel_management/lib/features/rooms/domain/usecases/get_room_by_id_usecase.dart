import 'package:rental_management/features/rooms/domain/entities/room_detail_entity.dart';
import 'package:rental_management/features/rooms/domain/repositories/room_repository.dart';

class GetRoomByIdUseCase {
  final RoomRepository _repository;

  GetRoomByIdUseCase(this._repository);

  Future<RoomDetailEntity> call(String id) async {
    return await _repository.getRoomById(id);
  }
}
