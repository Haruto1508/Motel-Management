import 'package:flutter/material.dart';
import 'package:rental_management/app/theme/color_schemes.dart';

enum RoomStatus {
  available('AVAILABLE', 'Trống'),
  occupied('OCCUPIED', 'Đang thuê'),
  maintenance('MAINTENANCE', 'Bảo trì'),
  inactive('INACTIVE', 'Ngừng hoạt động');

  final String code;
  final String label;

  const RoomStatus(this.code, this.label);

  static RoomStatus fromString(String? code) {
    if (code == null) return RoomStatus.available;
    for (final status in RoomStatus.values) {
      if (status.code.toUpperCase() == code.toUpperCase() ||
          status.name.toUpperCase() == code.toUpperCase()) {
        return status;
      }
    }
    return RoomStatus.available;
  }

  Color get color {
    switch (this) {
      case RoomStatus.available:
        return AppStatusColors.info;
      case RoomStatus.occupied:
        return AppStatusColors.success;
      case RoomStatus.maintenance:
        return AppStatusColors.warning;
      case RoomStatus.inactive:
        return AppStatusColors.neutral;
    }
  }

  Color get containerColor {
    switch (this) {
      case RoomStatus.available:
        return AppStatusColors.infoContainer;
      case RoomStatus.occupied:
        return AppStatusColors.successContainer;
      case RoomStatus.maintenance:
        return AppStatusColors.warningContainer;
      case RoomStatus.inactive:
        return AppStatusColors.neutralContainer;
    }
  }

  Color get onContainerColor {
    switch (this) {
      case RoomStatus.available:
        return AppStatusColors.onInfoContainer;
      case RoomStatus.occupied:
        return AppStatusColors.onSuccessContainer;
      case RoomStatus.maintenance:
        return AppStatusColors.onWarningContainer;
      case RoomStatus.inactive:
        return AppStatusColors.onNeutralContainer;
    }
  }

  IconData get icon {
    switch (this) {
      case RoomStatus.available:
        return Icons.meeting_room_outlined;
      case RoomStatus.occupied:
        return Icons.person_pin_circle_outlined;
      case RoomStatus.maintenance:
        return Icons.build_outlined;
      case RoomStatus.inactive:
        return Icons.do_not_disturb_on_outlined;
    }
  }
}
