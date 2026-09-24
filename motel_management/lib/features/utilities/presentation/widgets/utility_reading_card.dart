import 'package:flutter/material.dart';
import 'package:rental_management/core/utils/currency_formatter.dart';
import 'package:rental_management/core/utils/date_formatter.dart';
import 'package:rental_management/core/widgets/app_card.dart';
import 'package:rental_management/features/utilities/domain/entities/utility_reading_entity.dart';
import 'package:rental_management/features/utilities/domain/entities/water_calc_method.dart';

class UtilityReadingCard extends StatelessWidget {
  final UtilityReadingEntity reading;
  final VoidCallback? onTap;

  const UtilityReadingCard({
    super.key,
    required this.reading,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      reading.roomCode ?? 'Phòng',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Kỳ: ${reading.billingMonth}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                DateFormatter.format(reading.readingDate),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Electricity row
          _buildMetricRow(
            context,
            icon: Icons.bolt,
            color: Colors.amber.shade800,
            title: 'Điện',
            readingsText: '${reading.previousElectricity?.toStringAsFixed(0) ?? '--'} ➔ ${reading.currentElectricity.toStringAsFixed(0)}',
            consumptionText: '${reading.electricityConsumption.toStringAsFixed(0)} kWh',
            amountText: CurrencyFormatter.format(reading.electricityAmount),
          ),
          const SizedBox(height: 8),

          // Water row
          _buildMetricRow(
            context,
            icon: Icons.water_drop,
            color: Colors.blue.shade600,
            title: 'Nước',
            readingsText: reading.waterCalcMethod == WaterCalcMethod.meter
                ? '${reading.previousWater?.toStringAsFixed(0) ?? '--'} ➔ ${reading.currentWater.toStringAsFixed(0)}'
                : reading.waterCalcMethod.label,
            consumptionText: reading.waterCalcMethod == WaterCalcMethod.meter
                ? '${reading.waterConsumption.toStringAsFixed(0)} m³'
                : 'Khoán',
            amountText: CurrencyFormatter.format(reading.waterAmount),
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // Total row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tổng tiền điện nước:',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                CurrencyFormatter.format(reading.totalAmount),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String readingsText,
    required String consumptionText,
    required String amountText,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        SizedBox(
          width: 50,
          child: Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: Text(
            readingsText,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            consumptionText,
            style: theme.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 80,
          child: Text(
            amountText,
            textAlign: TextAlign.end,
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
