import 'package:rental_management/features/rooms/domain/entities/room_detail_entity.dart';
import 'package:rental_management/features/rooms/domain/entities/room_entity.dart';
import 'package:rental_management/features/rooms/domain/entities/room_status.dart';

class RoomModel {
  final String id;
  final String roomCode;
  final String name;
  final int floor;
  final double area;
  final double monthlyRent;
  final int capacity;
  final String status;
  final String? description;
  final int currentOccupancy;
  final String? createdAt;
  final String? updatedAt;

  const RoomModel({
    required this.id,
    required this.roomCode,
    required this.name,
    required this.floor,
    required this.area,
    required this.monthlyRent,
    required this.capacity,
    required this.status,
    this.description,
    this.currentOccupancy = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id']?.toString() ?? '',
      roomCode: json['roomCode'] as String? ?? json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      floor: json['floor'] as int? ?? 1,
      area: (json['area'] as num?)?.toDouble() ?? 0.0,
      monthlyRent: (json['monthlyRent'] as num?)?.toDouble() ??
          (json['price'] as num?)?.toDouble() ??
          0.0,
      capacity: json['capacity'] as int? ?? 1,
      status: json['status'] as String? ?? 'AVAILABLE',
      description: json['description'] as String?,
      currentOccupancy: json['currentOccupancy'] as int? ?? 0,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomCode': roomCode,
      'name': name,
      'floor': floor,
      'area': area,
      'monthlyRent': monthlyRent,
      'capacity': capacity,
      'status': status,
      'description': description,
      'currentOccupancy': currentOccupancy,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  RoomEntity toEntity() {
    return RoomEntity(
      id: id,
      roomCode: roomCode,
      name: name,
      floor: floor,
      area: area,
      monthlyRent: monthlyRent,
      capacity: capacity,
      status: RoomStatus.fromString(status),
      description: description,
      currentOccupancy: currentOccupancy,
      createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
      updatedAt: updatedAt != null ? DateTime.tryParse(updatedAt!) : null,
    );
  }
}

class RoomDetailModel {
  final RoomModel room;
  final List<RoomMemberOverviewModel> members;
  final RoomContractOverviewModel? activeContract;
  final RoomUtilityOverviewModel? latestUtilities;
  final RoomInvoiceOverviewModel? currentInvoice;

  const RoomDetailModel({
    required this.room,
    this.members = const [],
    this.activeContract,
    this.latestUtilities,
    this.currentInvoice,
  });

  factory RoomDetailModel.fromJson(Map<String, dynamic> json) {
    final roomMap = json['room'] is Map<String, dynamic>
        ? json['room'] as Map<String, dynamic>
        : json;

    final membersList = json['members'] is List
        ? (json['members'] as List)
            .map((m) => RoomMemberOverviewModel.fromJson(m as Map<String, dynamic>))
            .toList()
        : <RoomMemberOverviewModel>[];

    final contractMap = json['activeContract'] is Map<String, dynamic>
        ? json['activeContract'] as Map<String, dynamic>
        : null;

    final utilityMap = json['latestUtilities'] is Map<String, dynamic>
        ? json['latestUtilities'] as Map<String, dynamic>
        : null;

    final invoiceMap = json['currentInvoice'] is Map<String, dynamic>
        ? json['currentInvoice'] as Map<String, dynamic>
        : null;

    return RoomDetailModel(
      room: RoomModel.fromJson(roomMap),
      members: membersList,
      activeContract: contractMap != null
          ? RoomContractOverviewModel.fromJson(contractMap)
          : null,
      latestUtilities: utilityMap != null
          ? RoomUtilityOverviewModel.fromJson(utilityMap)
          : null,
      currentInvoice: invoiceMap != null
          ? RoomInvoiceOverviewModel.fromJson(invoiceMap)
          : null,
    );
  }

  RoomDetailEntity toEntity() {
    return RoomDetailEntity(
      room: room.toEntity(),
      members: members.map((m) => m.toEntity()).toList(),
      activeContract: activeContract?.toEntity(),
      latestUtilities: latestUtilities?.toEntity(),
      currentInvoice: currentInvoice?.toEntity(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'room': room.toJson(),
      'members': members.map((m) => m.toJson()).toList(),
      'activeContract': activeContract?.toJson(),
      'latestUtilities': latestUtilities?.toJson(),
      'currentInvoice': currentInvoice?.toJson(),
    };
  }
}

class RoomMemberOverviewModel {
  final String id;
  final String tenantId;
  final String fullName;
  final String phone;
  final String role;
  final String moveInDate;

  const RoomMemberOverviewModel({
    required this.id,
    required this.tenantId,
    required this.fullName,
    required this.phone,
    required this.role,
    required this.moveInDate,
  });

  factory RoomMemberOverviewModel.fromJson(Map<String, dynamic> json) {
    return RoomMemberOverviewModel(
      id: json['id']?.toString() ?? '',
      tenantId: json['tenantId']?.toString() ?? '',
      fullName: json['fullName'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      role: json['role'] as String? ?? 'MEMBER',
      moveInDate: json['moveInDate'] as String? ??
          DateTime.now().toIso8601String(),
    );
  }

  RoomMemberOverviewEntity toEntity() {
    return RoomMemberOverviewEntity(
      id: id,
      tenantId: tenantId,
      fullName: fullName,
      phone: phone,
      role: role,
      moveInDate: DateTime.tryParse(moveInDate) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenantId': tenantId,
      'fullName': fullName,
      'phone': phone,
      'role': role,
      'moveInDate': moveInDate,
    };
  }
}

class RoomContractOverviewModel {
  final String id;
  final String contractNumber;
  final String primaryTenantName;
  final String startDate;
  final String endDate;
  final double depositAmount;
  final double monthlyRent;
  final String status;

  const RoomContractOverviewModel({
    required this.id,
    required this.contractNumber,
    required this.primaryTenantName,
    required this.startDate,
    required this.endDate,
    required this.depositAmount,
    required this.monthlyRent,
    required this.status,
  });

  factory RoomContractOverviewModel.fromJson(Map<String, dynamic> json) {
    return RoomContractOverviewModel(
      id: json['id']?.toString() ?? '',
      contractNumber: json['contractNumber'] as String? ?? '',
      primaryTenantName: json['primaryTenantName'] as String? ?? '',
      startDate: json['startDate'] as String? ?? '',
      endDate: json['endDate'] as String? ?? '',
      depositAmount: (json['depositAmount'] as num?)?.toDouble() ?? 0.0,
      monthlyRent: (json['monthlyRent'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'ACTIVE',
    );
  }

  RoomContractOverviewEntity toEntity() {
    return RoomContractOverviewEntity(
      id: id,
      contractNumber: contractNumber,
      primaryTenantName: primaryTenantName,
      startDate: DateTime.tryParse(startDate) ?? DateTime.now(),
      endDate: DateTime.tryParse(endDate) ?? DateTime.now(),
      depositAmount: depositAmount,
      monthlyRent: monthlyRent,
      status: status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contractNumber': contractNumber,
      'primaryTenantName': primaryTenantName,
      'startDate': startDate,
      'endDate': endDate,
      'depositAmount': depositAmount,
      'monthlyRent': monthlyRent,
      'status': status,
    };
  }
}

class RoomUtilityOverviewModel {
  final num? previousElectricity;
  final num? currentElectricity;
  final num? previousWater;
  final num? currentWater;
  final String readingDate;

  const RoomUtilityOverviewModel({
    this.previousElectricity,
    this.currentElectricity,
    this.previousWater,
    this.currentWater,
    required this.readingDate,
  });

  factory RoomUtilityOverviewModel.fromJson(Map<String, dynamic> json) {
    return RoomUtilityOverviewModel(
      previousElectricity: json['previousElectricity'] as num?,
      currentElectricity: json['currentElectricity'] as num?,
      previousWater: json['previousWater'] as num?,
      currentWater: json['currentWater'] as num?,
      readingDate: json['readingDate'] as String? ?? '',
    );
  }

  RoomUtilityOverviewEntity toEntity() {
    return RoomUtilityOverviewEntity(
      previousElectricity: previousElectricity,
      currentElectricity: currentElectricity,
      previousWater: previousWater,
      currentWater: currentWater,
      readingDate: DateTime.tryParse(readingDate) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'previousElectricity': previousElectricity,
      'currentElectricity': currentElectricity,
      'previousWater': previousWater,
      'currentWater': currentWater,
      'readingDate': readingDate,
    };
  }
}

class RoomInvoiceOverviewModel {
  final String id;
  final String invoiceNumber;
  final String billingMonth;
  final double totalAmount;
  final double paidAmount;
  final String status;
  final String dueDate;

  const RoomInvoiceOverviewModel({
    required this.id,
    required this.invoiceNumber,
    required this.billingMonth,
    required this.totalAmount,
    this.paidAmount = 0.0,
    required this.status,
    required this.dueDate,
  });

  factory RoomInvoiceOverviewModel.fromJson(Map<String, dynamic> json) {
    return RoomInvoiceOverviewModel(
      id: json['id']?.toString() ?? '',
      invoiceNumber: json['invoiceNumber'] as String? ?? '',
      billingMonth: json['billingMonth'] as String? ?? '',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'UNPAID',
      dueDate: json['dueDate'] as String? ?? '',
    );
  }

  RoomInvoiceOverviewEntity toEntity() {
    return RoomInvoiceOverviewEntity(
      id: id,
      invoiceNumber: invoiceNumber,
      billingMonth: billingMonth,
      totalAmount: totalAmount,
      paidAmount: paidAmount,
      status: status,
      dueDate: DateTime.tryParse(dueDate) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoiceNumber': invoiceNumber,
      'billingMonth': billingMonth,
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'status': status,
      'dueDate': dueDate,
    };
  }
}
