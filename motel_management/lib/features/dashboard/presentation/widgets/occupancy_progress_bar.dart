import 'package:flutter/material.dart';
import 'package:rental_management/app/theme/color_schemes.dart';

class OccupancyProgressBar extends StatelessWidget {
  final int totalRooms;
  final int occupiedRooms;
  final int availableRooms;
  final int maintenanceRooms;

  const OccupancyProgressBar({
    super.key,
    required this.totalRooms,
    required this.occupiedRooms,
    required this.availableRooms,
    required this.maintenanceRooms,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final occupancyRate = totalRooms > 0 ? (occupiedRooms / totalRooms) * 100 : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tỷ lệ lấp đầy',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${occupancyRate.toStringAsFixed(1)}%',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 10,
              child: totalRooms == 0
                  ? LinearProgressIndicator(
                      value: 0,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    )
                  : Row(
                      children: [
                        if (occupiedRooms > 0)
                          Expanded(
                            flex: occupiedRooms,
                            child: Container(color: AppStatusColors.success),
                          ),
                        if (availableRooms > 0)
                          Expanded(
                            flex: availableRooms,
                            child: Container(color: AppStatusColors.info),
                          ),
                        if (maintenanceRooms > 0)
                          Expanded(
                            flex: maintenanceRooms,
                            child: Container(color: AppStatusColors.warning),
                          ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLegend(
                color: AppStatusColors.success,
                label: 'Đang thuê ($occupiedRooms)',
              ),
              _buildLegend(
                color: AppStatusColors.info,
                label: 'Trống ($availableRooms)',
              ),
              _buildLegend(
                color: AppStatusColors.warning,
                label: 'Bảo trì ($maintenanceRooms)',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
