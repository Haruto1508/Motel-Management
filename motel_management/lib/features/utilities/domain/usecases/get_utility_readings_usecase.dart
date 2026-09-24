import 'package:rental_management/features/utilities/domain/entities/utility_reading_entity.dart';
import 'package:rental_management/features/utilities/domain/repositories/utility_repository.dart';

class GetUtilityReadingsUseCase {
  final UtilityRepository repository;

  GetUtilityReadingsUseCase(this.repository);

  Future<List<UtilityReadingEntity>> call({
    String? roomId,
    String? billingMonth,
  }) {
    return repository.getReadings(
      roomId: roomId,
      billingMonth: billingMonth,
    );
  }
}

class GetLatestReadingUseCase {
  final UtilityRepository repository;

  GetLatestReadingUseCase(this.repository);

  Future<UtilityReadingEntity?> call(String roomId) {
    return repository.getLatestReading(roomId);
  }
}
