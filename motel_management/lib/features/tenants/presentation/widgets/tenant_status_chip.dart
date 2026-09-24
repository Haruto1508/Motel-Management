import 'package:flutter/material.dart';
import 'package:rental_management/features/tenants/domain/entities/tenant_status.dart';

class TenantStatusChip extends StatelessWidget {
  final TenantStatus status;

  const TenantStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case TenantStatus.active:
        backgroundColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        break;
      case TenantStatus.inactive:
        backgroundColor = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        break;
      case TenantStatus.left:
        backgroundColor = Colors.grey.shade100;
        textColor = Colors.grey.shade600;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: textColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
