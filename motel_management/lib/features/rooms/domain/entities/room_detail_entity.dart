import 'package:equatable/equatable.dart';
import 'package:rental_management/features/rooms/domain/entities/room_entity.dart';

/// Aggregated domain entity for Room details view
class RoomDetailEntity extends Equatable {
  final RoomEntity room;
  final List<RoomMemberOverviewEntity> members;
  final RoomContractOverviewEntity? activeContract;
  final RoomUtilityOverviewEntity? latestUtilities;
  final RoomInvoiceOverviewEntity? currentInvoice;

  const RoomDetailEntity({
    required this.room,
    this.members = const [],
    this.activeContract,
    this.latestUtilities,
    this.currentInvoice,
  });

  @override
  List<Object?> get props => [
        room,
        members,
        activeContract,
        latestUtilities,
        currentInvoice,
      ];
}

class RoomMemberOverviewEntity extends Equatable {
  final String id;
  final String tenantId;
  final String fullName;
  final String phone;
  final String role; // PRIMARY or MEMBER
  final DateTime moveInDate;

  const RoomMemberOverviewEntity({
    required this.id,
    required this.tenantId,
    required this.fullName,
    required this.phone,
    required this.role,
    required this.moveInDate,
  });

  bool get isPrimary => role.toUpperCase() == 'PRIMARY';

  @override
  List<Object?> get props => [id, tenantId, fullName, phone, role, moveInDate];
}

class RoomContractOverviewEntity extends Equatable {
  final String id;
  final String contractNumber;
  final String primaryTenantName;
  final DateTime startDate;
  final DateTime endDate;
  final double depositAmount;
  final double monthlyRent;
  final String status;

  const RoomContractOverviewEntity({
    required this.id,
    required this.contractNumber,
    required this.primaryTenantName,
    required this.startDate,
    required this.endDate,
    required this.depositAmount,
    required this.monthlyRent,
    required this.status,
  });

  @override
  List<Object?> get props => [
        id,
        contractNumber,
        primaryTenantName,
        startDate,
        endDate,
        depositAmount,
        monthlyRent,
        status,
      ];
}

class RoomUtilityOverviewEntity extends Equatable {
  final num? previousElectricity;
  final num? currentElectricity;
  final num? previousWater;
  final num? currentWater;
  final DateTime readingDate;

  const RoomUtilityOverviewEntity({
    this.previousElectricity,
    this.currentElectricity,
    this.previousWater,
    this.currentWater,
    required this.readingDate,
  });

  num get electricityConsumption =>
      (currentElectricity ?? 0) - (previousElectricity ?? 0);

  num get waterConsumption => (currentWater ?? 0) - (previousWater ?? 0);

  @override
  List<Object?> get props => [
        previousElectricity,
        currentElectricity,
        previousWater,
        currentWater,
        readingDate,
      ];
}

class RoomInvoiceOverviewEntity extends Equatable {
  final String id;
  final String invoiceNumber;
  final String billingMonth;
  final double totalAmount;
  final double paidAmount;
  final String status; // UNPAID, PARTIALLY_PAID, PAID, OVERDUE
  final DateTime dueDate;

  const RoomInvoiceOverviewEntity({
    required this.id,
    required this.invoiceNumber,
    required this.billingMonth,
    required this.totalAmount,
    this.paidAmount = 0.0,
    required this.status,
    required this.dueDate,
  });

  double get remainingAmount => totalAmount - paidAmount > 0 ? totalAmount - paidAmount : 0.0;

  @override
  List<Object?> get props => [
        id,
        invoiceNumber,
        billingMonth,
        totalAmount,
        paidAmount,
        status,
        dueDate,
      ];
}
