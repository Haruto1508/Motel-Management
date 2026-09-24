import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rental_management/core/utils/currency_formatter.dart';
import 'package:rental_management/core/utils/date_formatter.dart';
import 'package:rental_management/core/widgets/app_card.dart';
import 'package:rental_management/core/widgets/confirm_dialog.dart';
import 'package:rental_management/core/widgets/error_view.dart';
import 'package:rental_management/core/widgets/loading_view.dart';
import 'package:rental_management/features/contracts/domain/entities/contract_status.dart';
import 'package:rental_management/features/contracts/presentation/providers/contract_providers.dart';
import 'package:rental_management/features/contracts/presentation/providers/contracts_list_controller.dart';
import 'package:rental_management/features/contracts/presentation/widgets/contract_status_chip.dart';

class ContractDetailPage extends ConsumerWidget {
  final String contractId;

  const ContractDetailPage({super.key, required this.contractId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contractAsync = ref.watch(contractDetailProvider(contractId));
    final theme = Theme.of(context);

    return contractAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Chi tiết hợp đồng')),
        body: const LoadingView(message: 'Đang tải chi tiết hợp đồng...'),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Chi tiết hợp đồng')),
        body: ErrorView(
          message: error.toString(),
          onRetry: () => ref.refresh(contractDetailProvider(contractId)),
        ),
      ),
      data: (contract) {
        return Scaffold(
          appBar: AppBar(
            title: Text(contract.contractNumber),
            actions: [
              if (contract.status == ContractStatus.active)
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Chỉnh sửa',
                  onPressed: () => context.push('/contracts/${contract.id}/edit'),
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                AppCard(
                  margin: EdgeInsets.zero,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Số hợp đồng', style: theme.textTheme.bodySmall),
                          Text(
                            contract.contractNumber,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      ContractStatusChip(status: contract.status),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Đối tượng hợp đồng: Phòng & Khách thuê
                Text('Đối tượng hợp đồng', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                AppCard(
                  margin: EdgeInsets.zero,
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () => context.push('/rooms/${contract.roomId}'),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.meeting_room_outlined, color: theme.colorScheme.primary),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Phòng thuê', style: theme.textTheme.bodySmall),
                                    Text(
                                      contract.roomCode ?? 'Phòng ${contract.roomId}',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Icon(Icons.chevron_right, size: 18),
                          ],
                        ),
                      ),
                      const Divider(height: 24),
                      InkWell(
                        onTap: () => context.push('/tenants/${contract.primaryTenantId}'),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.person_outline, color: theme.colorScheme.primary),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Người đại diện thuê', style: theme.textTheme.bodySmall),
                                    Text(
                                      contract.primaryTenantName ?? 'Khách thuê',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                    if (contract.primaryTenantPhone != null)
                                      Text(
                                        contract.primaryTenantPhone!,
                                        style: theme.textTheme.bodySmall,
                                      ),
                                  ],
                                ),
                              ],
                            ),
                            const Icon(Icons.chevron_right, size: 18),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Tài chính & Kỳ hạn
                Text('Thời hạn & Tài chính', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                AppCard(
                  margin: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _buildInfoRow('Ngày bắt đầu', DateFormatter.format(contract.startDate)),
                      const Divider(height: 20),
                      _buildInfoRow('Ngày kết thúc', DateFormatter.format(contract.endDate)),
                      const Divider(height: 20),
                      _buildInfoRow(
                        'Thời gian còn lại',
                        contract.isActive
                            ? '${contract.remainingDays} ngày'
                            : contract.status.label,
                      ),
                      const Divider(height: 20),
                      _buildInfoRow(
                        'Giá thuê hàng tháng',
                        CurrencyFormatter.format(contract.monthlyRent),
                        isHighlight: true,
                      ),
                      const Divider(height: 20),
                      _buildInfoRow('Tiền đặt cọc', CurrencyFormatter.format(contract.depositAmount)),
                      const Divider(height: 20),
                      _buildInfoRow('Ngày thu tiền định kỳ', 'Ngày ${contract.paymentDueDay} hàng tháng'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Điều khoản hợp đồng
                if (contract.terms != null && contract.terms!.isNotEmpty) ...[
                  Text('Điều khoản & Ghi chú', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  AppCard(
                    margin: EdgeInsets.zero,
                    child: Text(
                      contract.terms!,
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Action buttons (Thanh lý hợp đồng)
                if (contract.status == ContractStatus.active) ...[
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('Thanh lý / Chấm dứt hợp đồng'),
                      onPressed: () async {
                        final confirm = await ConfirmDialog.show(
                          context,
                          title: 'Thanh lý hợp đồng',
                          content: 'Bạn có chắc chắn muốn thanh lý hợp đồng ${contract.contractNumber}? Trạng thái sẽ chuyển sang "Đã thanh lý".',
                          confirmText: 'Xác nhận thanh lý',
                          isDestructive: true,
                        );
                        if (confirm == true) {
                          await ref
                              .read(contractsListControllerProvider.notifier)
                              .terminateContract(contract.id);
                          ref.invalidate(contractDetailProvider(contract.id));
                        }
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isHighlight ? Colors.blue.shade700 : null,
            fontSize: isHighlight ? 16 : 14,
          ),
        ),
      ],
    );
  }
}
