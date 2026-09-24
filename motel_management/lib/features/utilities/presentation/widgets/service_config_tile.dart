import 'package:flutter/material.dart';
import 'package:rental_management/core/utils/currency_formatter.dart';
import 'package:rental_management/core/widgets/app_card.dart';
import 'package:rental_management/features/utilities/domain/entities/service_config_entity.dart';

class ServiceConfigTile extends StatelessWidget {
  final ServiceConfigEntity service;
  final ValueChanged<double>? onUpdatePrice;

  const ServiceConfigTile({
    super.key,
    required this.service,
    this.onUpdatePrice,
  });

  IconData _getIconForService(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('điện')) return Icons.bolt;
    if (lower.contains('nước')) return Icons.water_drop;
    if (lower.contains('internet') || lower.contains('wifi')) return Icons.wifi;
    if (lower.contains('rác') || lower.contains('vệ sinh')) return Icons.delete_outline;
    if (lower.contains('xe')) return Icons.two_wheeler;
    return Icons.miscellaneous_services;
  }

  Color _getColorForService(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('điện')) return Colors.amber.shade800;
    if (lower.contains('nước')) return Colors.blue.shade600;
    if (lower.contains('internet') || lower.contains('wifi')) return Colors.indigo;
    if (lower.contains('rác')) return Colors.teal;
    return Colors.grey.shade700;
  }

  void _showEditPriceDialog(BuildContext context) {
    final controller = TextEditingController(text: service.unitPrice.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Sửa đơn giá: ${service.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Đơn vị tính: ${service.unitName}'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Đơn giá mới (VNĐ)',
                suffixText: '₫',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              final newPrice = double.tryParse(controller.text.trim());
              if (newPrice != null && newPrice >= 0) {
                Navigator.pop(ctx);
                onUpdatePrice?.call(newPrice);
              }
            },
            child: const Text('Cập nhật'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getColorForService(service.name);

    return AppCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_getIconForService(service.name), color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${CurrencyFormatter.format(service.unitPrice)} / ${service.unitName}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Sửa đơn giá',
            onPressed: () => _showEditPriceDialog(context),
          ),
        ],
      ),
    );
  }
}
