import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rental_management/core/utils/date_formatter.dart';
import 'package:rental_management/core/widgets/app_card.dart';
import 'package:rental_management/core/widgets/confirm_dialog.dart';
import 'package:rental_management/core/widgets/error_view.dart';
import 'package:rental_management/core/widgets/loading_view.dart';
import 'package:rental_management/features/tenants/presentation/providers/tenant_providers.dart';
import 'package:rental_management/features/tenants/presentation/providers/tenants_list_controller.dart';
import 'package:rental_management/features/tenants/presentation/widgets/tenant_status_chip.dart';

class TenantDetailPage extends ConsumerWidget {
  final String tenantId;

  const TenantDetailPage({super.key, required this.tenantId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tenantAsync = ref.watch(tenantDetailProvider(tenantId));
    final theme = Theme.of(context);

    return tenantAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Chi tiết khách thuê')),
        body: const LoadingView(message: 'Đang tải thông tin khách thuê...'),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Chi tiết khách thuê')),
        body: ErrorView(
          message: error.toString(),
          onRetry: () => ref.refresh(tenantDetailProvider(tenantId)),
        ),
      ),
      data: (tenant) {
        return Scaffold(
          appBar: AppBar(
            title: Text(tenant.fullName),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Sửa thông tin',
                onPressed: () => context.push('/tenants/${tenant.id}/edit'),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Xóa hồ sơ',
                onPressed: () async {
                  final confirm = await ConfirmDialog.show(
                    context,
                    title: 'Xóa khách thuê',
                    content: 'Bạn có chắc chắn muốn xóa hồ sơ ${tenant.fullName}?',
                    confirmText: 'Xóa',
                    isDestructive: true,
                  );
                  if (confirm == true) {
                    final success = await ref
                        .read(tenantsListControllerProvider.notifier)
                        .deleteTenant(tenant.id);
                    if (context.mounted && success) {
                      context.pop();
                    }
                  }
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header profile card
                AppCard(
                  margin: EdgeInsets.zero,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Text(
                          tenant.fullName.isNotEmpty
                              ? tenant.fullName.trim().split(' ').last[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tenant.fullName,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TenantStatusChip(status: tenant.status),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Phòng hiện tại (nếu có)
                if (tenant.currentRoomId != null) ...[
                  AppCard(
                    margin: EdgeInsets.zero,
                    onTap: () => context.push('/rooms/${tenant.currentRoomId}'),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.meeting_room, color: theme.colorScheme.primary),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Phòng đang ở', style: theme.textTheme.bodySmall),
                                Text(
                                  tenant.currentRoomCode ?? 'Xem chi tiết phòng',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 16),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Thông tin cá nhân
                Text('Thông tin cá nhân', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                AppCard(
                  margin: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _buildInfoRow('Số điện thoại', tenant.phone, isPhone: true),
                      const Divider(height: 20),
                      _buildInfoRow('CCCD / CMND', tenant.identityNumber ?? 'Chưa cập nhật'),
                      const Divider(height: 20),
                      _buildInfoRow('Email', tenant.email ?? 'Chưa cập nhật'),
                      const Divider(height: 20),
                      _buildInfoRow(
                        'Ngày sinh',
                        tenant.dateOfBirth != null
                            ? DateFormatter.format(tenant.dateOfBirth!)
                            : 'Chưa cập nhật',
                      ),
                      const Divider(height: 20),
                      _buildInfoRow('Giới tính', tenant.gender ?? 'Chưa cập nhật'),
                      const Divider(height: 20),
                      _buildInfoRow('Quê quán', tenant.hometown ?? 'Chưa cập nhật'),
                      const Divider(height: 20),
                      _buildInfoRow('Nghề nghiệp', tenant.occupation ?? 'Chưa cập nhật'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Liên hệ khẩn cấp
                Text('Liên hệ khẩn cấp', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                AppCard(
                  margin: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _buildInfoRow('Người liên hệ', tenant.emergencyContact ?? 'Chưa có thông tin'),
                      const Divider(height: 20),
                      _buildInfoRow('SĐT khẩn cấp', tenant.emergencyPhone ?? 'Chưa có thông tin', isPhone: true),
                    ],
                  ),
                ),

                if (tenant.note != null && tenant.note!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text('Ghi chú', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  AppCard(
                    margin: EdgeInsets.zero,
                    child: Text(tenant.note!),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isPhone = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isPhone && value != 'Chưa có thông tin' ? Colors.blue.shade700 : null,
          ),
        ),
      ],
    );
  }
}
