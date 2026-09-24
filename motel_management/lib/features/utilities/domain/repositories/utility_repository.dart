import 'package:rental_management/features/utilities/domain/entities/service_config_entity.dart';
import 'package:rental_management/features/utilities/domain/entities/utility_reading_entity.dart';

abstract class UtilityRepository {
  Future<List<UtilityReadingEntity>> getReadings({
    String? roomId,
    String? billingMonth,
  });

  Future<UtilityReadingEntity?> getLatestReading(String roomId);

  Future<UtilityReadingEntity> recordReading(Map<String, dynamic> data);

  Future<UtilityReadingEntity> updateReading(String id, Map<String, dynamic> data);

  Future<void> deleteReading(String id);

  Future<List<ServiceConfigEntity>> getServices();

  Future<ServiceConfigEntity> updateService(String id, double unitPrice);
}
