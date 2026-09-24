import 'package:flutter/material.dart';
import 'package:rental_management/app/theme/color_schemes.dart';

/// Reusable Chip/Badge to display generic status with background tint and colored text.
class StatusBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Specialized StatusBadge for Invoice / Payment status:
/// - UNPAID: "Chưa thanh toán"
/// - PARTIALLY_PAID: "Đã thanh toán một phần"
/// - PAID: "Đã thanh toán"
/// - OVERDUE: "Quá hạn"
/// - DRAFT: "Bản nháp"
/// - CANCELLED: "Đã hủy"
class PaymentStatusBadge extends StatelessWidget {
  final String status;

  const PaymentStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    switch (status.toUpperCase()) {
      case 'PAID':
        return const StatusBadge(
          label: 'Đã thanh toán',
          backgroundColor: AppStatusColors.successContainer,
          textColor: AppStatusColors.onSuccessContainer,
          icon: Icons.check_circle_outline,
        );

      case 'PARTIALLY_PAID':
        return const StatusBadge(
          label: 'Đã thanh toán một phần',
          backgroundColor: AppStatusColors.warningContainer,
          textColor: AppStatusColors.onWarningContainer,
          icon: Icons.timelapse,
        );

      case 'OVERDUE':
        return const StatusBadge(
          label: 'Quá hạn',
          backgroundColor: AppStatusColors.dangerContainer,
          textColor: AppStatusColors.onDangerContainer,
          icon: Icons.error_outline,
        );

      case 'UNPAID':
        return const StatusBadge(
          label: 'Chưa thanh toán',
          backgroundColor: AppStatusColors.dangerContainer,
          textColor: AppStatusColors.danger,
          icon: Icons.pending_actions,
        );

      case 'DRAFT':
        return const StatusBadge(
          label: 'Bản nháp',
          backgroundColor: AppStatusColors.infoContainer,
          textColor: AppStatusColors.onInfoContainer,
          icon: Icons.edit_note,
        );

      case 'CANCELLED':
      default:
        return const StatusBadge(
          label: 'Đã hủy',
          backgroundColor: AppStatusColors.neutralContainer,
          textColor: AppStatusColors.onNeutralContainer,
          icon: Icons.cancel_outlined,
        );
    }
  }
}
