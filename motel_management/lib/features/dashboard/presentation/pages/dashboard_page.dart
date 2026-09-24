import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rental_management/app/router/app_router.dart';
import 'package:rental_management/app/theme/color_schemes.dart';
import 'package:rental_management/core/widgets/confirm_dialog.dart';
import 'package:rental_management/core/widgets/error_view.dart';
import 'package:rental_management/core/widgets/loading_view.dart';
import 'package:rental_management/features/auth/presentation/providers/auth_providers.dart';
import 'package:rental_management/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:rental_management/features/dashboard/presentation/widgets/occupancy_progress_bar.dart';
import 'package:rental_management/features/dashboard/presentation/widgets/revenue_summary_card.dart';
import 'package:rental_management/features/dashboard/presentation/widgets/stat_summary_card.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final statsAsync = ref.watch(dashboardStatsProvider);
    final user = authState.user;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Xin chào, ${user?.fullName ?? "Chủ nhà"}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Tổng quan tài sản & doanh thu',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Làm mới',
            onPressed: () => ref.refresh(dashboardStatsProvider),
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            tooltip: 'Đăng xuất',
            onPressed: () async {
              final confirm = await ConfirmDialog.show(
                context,
                title: 'Đăng xuất',
                content: 'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản?',
                confirmText: 'Đăng xuất',
                isDestructive: true,
              );
              if (confirm == true) {
                await ref.read(authControllerProvider.notifier).logout();
              }
            },
          ),
        ],
      ),
      body: statsAsync.when(
        loading: () => const LoadingView(message: 'Đang tải dữ liệu tổng quan...'),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.refresh(dashboardStatsProvider),
        ),
        data: (stats) => RefreshIndicator(
          onRefresh: () async => ref.refresh(dashboardStatsProvider),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Revenue Card
                RevenueSummaryCard(
                  revenue: stats.currentMonthRevenue,
                  paidInvoices: stats.paidInvoices,
                  unpaidInvoices: stats.unpaidInvoices,
                ),
                const SizedBox(height: 16),

                // Occupancy Bar
                OccupancyProgressBar(
                  totalRooms: stats.totalRooms,
                  occupiedRooms: stats.occupiedRooms,
                  availableRooms: stats.availableRooms,
                  maintenanceRooms: stats.maintenanceRooms,
                ),
                const SizedBox(height: 16),

                // Metrics Grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.45,
                  children: [
                    StatSummaryCard(
                      title: 'Tổng số phòng',
                      value: '${stats.totalRooms}',
                      icon: Icons.meeting_room_outlined,
                      color: theme.colorScheme.primary,
                      subtitle: '${stats.occupiedRooms} đang có khách',
                    ),
                    StatSummaryCard(
                      title: 'Khách thuê',
                      value: '${stats.totalTenants}',
                      icon: Icons.people_outline,
                      color: AppStatusColors.info,
                      subtitle: 'Đang lưu trú',
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => context.push(AppRoutes.utilities),
                      child: StatSummaryCard(
                        title: 'Điện tháng này',
                        value: '${stats.currentMonthElectricityKwh.toStringAsFixed(0)} kWh',
                        icon: Icons.bolt_outlined,
                        color: Colors.amber.shade800,
                        subtitle: 'Tổng tiêu thụ',
                      ),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => context.push(AppRoutes.utilities),
                      child: StatSummaryCard(
                        title: 'Nước tháng này',
                        value: '${stats.currentMonthWaterM3.toStringAsFixed(0)} m³',
                        icon: Icons.water_drop_outlined,
                        color: Colors.blue.shade600,
                        subtitle: 'Tổng tiêu thụ',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Quick Navigation Hub
                Text(
                  'Danh mục quản lý',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                _buildNavigationTile(
                  context,
                  title: 'Quản lý phòng trọ',
                  subtitle: 'Danh sách, tình trạng, thêm & chỉnh sửa phòng',
                  icon: Icons.meeting_room_rounded,
                  color: theme.colorScheme.primary,
                  onTap: () => context.push(AppRoutes.rooms),
                ),
                const SizedBox(height: 8),

                _buildNavigationTile(
                  context,
                  title: 'Quản lý khách thuê',
                  subtitle: 'Hồ sơ người thuê, thành viên phòng, CCCD',
                  icon: Icons.badge_outlined,
                  color: Colors.teal,
                  onTap: () => context.push(AppRoutes.tenants),
                ),
                const SizedBox(height: 8),

                _buildNavigationTile(
                  context,
                  title: 'Hợp đồng thuê phòng',
                  subtitle: 'Theo dõi thời hạn, tạo và gia hạn hợp đồng',
                  icon: Icons.description_outlined,
                  color: Colors.indigo,
                  onTap: () => context.push(AppRoutes.contracts),
                ),
                const SizedBox(height: 8),

                _buildNavigationTile(
                  context,
                  title: 'Chỉ số Điện & Nước',
                  subtitle: 'Ghi số định kỳ, tính tiêu thụ và quản lý bảng giá',
                  icon: Icons.bolt_outlined,
                  color: Colors.amber.shade800,
                  onTap: () => context.push(AppRoutes.utilities),
                ),
                const SizedBox(height: 8),

                _buildNavigationTile(
                  context,
                  title: 'Hóa đơn & Thanh toán',
                  subtitle: 'Tính tiền điện nước, thu tiền phòng hàng tháng',
                  icon: Icons.receipt_long_outlined,
                  color: Colors.orange.shade800,
                  onTap: () => context.push(AppRoutes.invoices),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
