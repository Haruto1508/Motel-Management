import 'package:rental_management/features/utilities/domain/entities/utility_reading_entity.dart';
import 'package:rental_management/features/utilities/domain/entities/water_calc_method.dart';
import 'package:rental_management/features/utilities/domain/repositories/utility_repository.dart';

class RecordUtilityParams {
  final String roomId;
  final String billingMonth;
  final DateTime readingDate;
  final double? previousElectricity;
  final double currentElectricity;
  final double electricityPrice;
  final double? previousWater;
  final double currentWater;
  final double waterPrice;
  final WaterCalcMethod waterCalcMethod;
  final int numberOfTenants;
  final String? note;

  const RecordUtilityParams({
    required this.roomId,
    required this.billingMonth,
    required this.readingDate,
    this.previousElectricity,
    required this.currentElectricity,
    this.electricityPrice = 3500.0,
    this.previousWater,
    required this.currentWater,
    this.waterPrice = 25000.0,
    this.waterCalcMethod = WaterCalcMethod.meter,
    this.numberOfTenants = 1,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'roomId': roomId,
      'billingMonth': billingMonth,
      'readingDate': readingDate.toIso8601String(),
      if (previousElectricity != null) 'previousElectricity': previousElectricity,
      'currentElectricity': currentElectricity,
      'electricityPrice': electricityPrice,
      if (previousWater != null) 'previousWater': previousWater,
      'currentWater': currentWater,
      'waterPrice': waterPrice,
      'waterCalcMethod': waterCalcMethod.code,
      'numberOfTenants': numberOfTenants,
      if (note != null && note!.trim().isNotEmpty) 'note': note!.trim(),
    };
  }
}

class RecordUtilityReadingUseCase {
  final UtilityRepository repository;

  RecordUtilityReadingUseCase(this.repository);

  Future<UtilityReadingEntity> call(RecordUtilityParams params) {
    if (params.previousElectricity != null &&
        params.currentElectricity < params.previousElectricity!) {
      throw ArgumentError(
        'Chỉ số điện mới (${params.currentElectricity}) không thể nhỏ hơn chỉ số cũ (${params.previousElectricity})',
      );
    }

    if (params.waterCalcMethod == WaterCalcMethod.meter &&
        params.previousWater != null &&
        params.currentWater < params.previousWater!) {
      throw ArgumentError(
        'Chỉ số nước mới (${params.currentWater}) không thể nhỏ hơn chỉ số cũ (${params.previousWater})',
      );
    }

    if (params.electricityPrice < 0) {
      throw ArgumentError('Đơn giá điện không thể âm');
    }

    if (params.waterPrice < 0) {
      throw ArgumentError('Đơn giá nước không thể âm');
    }

    return repository.recordReading(params.toJson());
  }
}
