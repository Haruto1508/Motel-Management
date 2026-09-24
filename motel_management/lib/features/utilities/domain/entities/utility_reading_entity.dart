import 'package:equatable/equatable.dart';
import 'package:rental_management/features/utilities/domain/entities/water_calc_method.dart';

class UtilityReadingEntity extends Equatable {
  final String id;
  final String roomId;
  final String? roomCode;
  final String billingMonth; // e.g. "09/2026"
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
  final DateTime? createdAt;

  const UtilityReadingEntity({
    required this.id,
    required this.roomId,
    this.roomCode,
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
    this.createdAt,
  });

  /// Số kWh điện tiêu thụ trong kỳ
  double get electricityConsumption {
    final prev = previousElectricity ?? currentElectricity;
    final diff = currentElectricity - prev;
    return diff > 0 ? diff : 0.0;
  }

  /// Thành tiền điện (VNĐ)
  double get electricityAmount => electricityConsumption * electricityPrice;

  /// Số m³ nước tiêu thụ trong kỳ (nếu tính theo đồng hồ)
  double get waterConsumption {
    if (waterCalcMethod != WaterCalcMethod.meter) return 0.0;
    final prev = previousWater ?? currentWater;
    final diff = currentWater - prev;
    return diff > 0 ? diff : 0.0;
  }

  /// Thành tiền nước (VNĐ)
  double get waterAmount {
    switch (waterCalcMethod) {
      case WaterCalcMethod.meter:
        return waterConsumption * waterPrice;
      case WaterCalcMethod.fixed:
        return waterPrice;
      case WaterCalcMethod.perPerson:
        final count = numberOfTenants > 0 ? numberOfTenants : 1;
        return waterPrice * count;
    }
  }

  /// Tổng tiền điện + nước đợt ghi này
  double get totalAmount => electricityAmount + waterAmount;

  @override
  List<Object?> get props => [
        id,
        roomId,
        roomCode,
        billingMonth,
        readingDate,
        previousElectricity,
        currentElectricity,
        electricityPrice,
        previousWater,
        currentWater,
        waterPrice,
        waterCalcMethod,
        numberOfTenants,
        note,
        createdAt,
      ];
}
