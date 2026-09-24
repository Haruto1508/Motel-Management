import 'package:flutter/material.dart';
import 'package:rental_management/features/contracts/domain/entities/contract_status.dart';

class ContractStatusChip extends StatelessWidget {
  final ContractStatus status;

  const ContractStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case ContractStatus.active:
        backgroundColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        break;
      case ContractStatus.draft:
        backgroundColor = Colors.blue.shade50;
        textColor = Colors.blue.shade700;
        break;
      case ContractStatus.expired:
        backgroundColor = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        break;
      case ContractStatus.terminated:
        backgroundColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        break;
      case ContractStatus.cancelled:
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
