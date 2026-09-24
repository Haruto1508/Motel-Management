import 'package:flutter/material.dart';
import 'package:rental_management/features/rooms/domain/entities/room_status.dart';

class RoomStatusChip extends StatelessWidget {
  final RoomStatus status;

  const RoomStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status.containerColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 13, color: status.onContainerColor),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: status.onContainerColor,
            ),
          ),
        ],
      ),
    );
  }
}
