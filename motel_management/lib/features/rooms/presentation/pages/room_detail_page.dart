import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rental_management/core/utils/currency_formatter.dart';
import 'package:rental_management/core/utils/date_formatter.dart';
import 'package:rental_management/core/widgets/app_button.dart';
import 'package:rental_management/core/widgets/app_card.dart';
import 'package:rental_management/core/widgets/confirm_dialog.dart';
import 'package:rental_management/core/widgets/empty_state.dart';
import 'package:rental_management/core/widgets/error_view.dart';
import 'package:rental_management/core/widgets/loading_view.dart';
import 'package:rental_management/core/widgets/status_badge.dart';
import 'package:rental_management/features/rooms/domain/entities/room_detail_entity.dart';
import 'package:rental_management/features/rooms/presentation/providers/rooms_providers.dart';
import 'package:rental_management/features/rooms/presentation/widgets/room_status_chip.dart';
import 'package:rental_management/features/tenants/presentation/providers/tenant_providers.dart';
import 'package:rental_management/features/tenants/presentation/widgets/add_member_dialog.dart';

class RoomDetailPage extends ConsumerStatefulWidget {
  final String roomId;

  const RoomDetailPage({super.key, required this.roomId});

  @override
  ConsumerState<RoomDetailPage> createState() => _RoomDetailPageState();
}

class _RoomDetailPageState extends ConsumerState<RoomDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(roomDetailProvider(widget.roomId));
    final theme = Theme.of(context);

    return detailAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Chi tiết phòng')),
        body: const LoadingView(message: 'Đang tải thông tin chi tiết phòng...'),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Chi tiết phòng')),
        body: ErrorView(
          message: error.toString(),
          onRetry: () => ref.refresh(roomDetailProvider(widget.roomId)),
        ),
      ),
      data: (detail) {
        final room = detail.room;

        return Scaffold(
          appBar: AppBar(
            title: Text('${room.roomCode} - ${room.name}'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Chỉnh sửa phòng',
                onPressed: () => context.push('/rooms/${room.id}/edit'),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Xóa phòng',
                onPressed: () async {
                  final confirm = await ConfirmDialog.show(
                    context,
                    title: 'Xóa phòng',
                    content: 'Bạn có chắc chắn muốn xóa phòng ${room.roomCode}?',
                    confirmText: 'Xóa',
                    isDestructive: true,
                  );
                  if (confirm == true) {
                    final success = await ref
                        .read(roomsListControllerProvider.notifier)
                        .deleteRoom(room.id);
                    if (context.mounted && success) {
                      context.pop();
                    }
                  }
                },
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelPadding: const EdgeInsets.symmetric(horizontal: 16),
              tabs: const [
                Tab(text: 'Tổng quan'),
                Tab(text: 'Thành viên'),
                Tab(text: 'Hợp đồng'),
                Tab(text: 'Điện & Nước'),
                Tab(text: 'Hóa đơn'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(detail, theme),
              _buildMembersTab(detail, theme),
              _buildContractTab(detail, theme),
              _buildUtilitiesTab(detail, theme),
              _buildInvoiceTab(detail, theme),
            ],
          ),
        );
      },
    );
  }

  // --- TAB 1: TỔNG QUAN ---
  Widget _buildOverviewTab(RoomDetailEntity detail, ThemeData theme) {
    final room = detail.room;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status and Rent Card
          AppCard(
            margin: EdgeInsets.zero,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Giá thuê hàng tháng',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      CurrencyFormatter.format(room.monthlyRent),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                RoomStatusChip(status: room.status),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Specifications Card
          Text(
            'Thông tin cơ bản',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          AppCard(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                _buildInfoRow('Mã phòng', room.roomCode),
                const Divider(),
                _buildInfoRow('Tên phòng', room.name),
                const Divider(),
                _buildInfoRow('Tầng', 'Tầng ${room.floor}'),
                const Divider(),
                _buildInfoRow('Diện tích', '${room.area} m²'),
                const Divider(),
                _buildInfoRow(
                  'Sức chứa',
                  '${room.currentOccupancy}/${room.capacity} người (${room.availableSlots} chỗ trống)',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Description Card
          if (room.description != null && room.description!.isNotEmpty) ...[
            Text(
              'Mô tả / Ghi chú',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            AppCard(
              margin: EdgeInsets.zero,
              child: Text(
                room.description!,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // --- TAB 2: THÀNH VIÊN ---
  Widget _buildMembersTab(RoomDetailEntity detail, ThemeData theme) {
    final hasPrimary = detail.members.any((m) => m.isPrimary);

    return Column(
      children: [
        // Action Bar thêm thành viên
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Thành viên (${detail.members.length}/${detail.room.capacity})',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.person_add_outlined, size: 18),
                label: const Text('Thêm thành viên'),
                style: OutlinedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: () async {
                  final success = await AddMemberDialog.show(
                    context,
                    roomId: detail.room.id,
                    roomCode: detail.room.roomCode,
                    capacity: detail.room.capacity,
                    currentOccupancy: detail.members.length,
                    hasPrimaryTenant: hasPrimary,
                  );
                  if (success == true) {
                    ref.invalidate(roomDetailProvider(widget.roomId));
                  }
                },
              ),
            ],
          ),
        ),

        // Danh sách thành viên
        Expanded(
          child: detail.members.isEmpty
              ? EmptyState(
                  title: 'Chưa có thành viên nào',
                  description: 'Phòng hiện tại chưa có khách thuê được ghi nhận.',
                  icon: Icons.people_outline,
                  actionText: 'Thêm thành viên ngay',
                  onAction: () async {
                    final success = await AddMemberDialog.show(
                      context,
                      roomId: detail.room.id,
                      roomCode: detail.room.roomCode,
                      capacity: detail.room.capacity,
                      currentOccupancy: detail.members.length,
                      hasPrimaryTenant: hasPrimary,
                    );
                    if (success == true) {
                      ref.invalidate(roomDetailProvider(widget.roomId));
                    }
                  },
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: detail.members.length,
                  itemBuilder: (context, index) {
                    final member = detail.members[index];
                    return AppCard(
                      margin: const EdgeInsets.only(bottom: 10),
                      onTap: () => context.push('/tenants/${member.tenantId}'),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: member.isPrimary
                                ? theme.colorScheme.primaryContainer
                                : theme.colorScheme.surfaceContainerHighest,
                            child: Icon(
                              member.isPrimary ? Icons.star : Icons.person_outline,
                              color: member.isPrimary
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      member.fullName,
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (member.isPrimary) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primaryContainer,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'Đại diện',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.onPrimaryContainer,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'SĐT: ${member.phone} • Vào ở: ${DateFormatter.format(member.moveInDate)}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                            tooltip: 'Xóa khỏi phòng',
                            onPressed: () async {
                              final confirm = await ConfirmDialog.show(
                                context,
                                title: 'Rời phòng',
                                content: 'Bạn có chắc chắn muốn xóa ${member.fullName} khỏi phòng này?',
                                confirmText: 'Xác nhận',
                                isDestructive: true,
                              );
                              if (confirm == true) {
                                await ref
                                    .read(removeMemberFromRoomUseCaseProvider)
                                    .call(roomId: detail.room.id, memberId: member.id);
                                ref.invalidate(roomDetailProvider(widget.roomId));
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // --- TAB 3: HỢP ĐỒNG ---
  Widget _buildContractTab(RoomDetailEntity detail, ThemeData theme) {
    final contract = detail.activeContract;
    if (contract == null) {
      return EmptyState(
        title: 'Chưa có hợp đồng hiệu lực',
        description: 'Phòng này chưa liên kết với hợp đồng thuê đang hoạt động nào.',
        icon: Icons.description_outlined,
        actionText: 'Tạo hợp đồng ngay',
        onAction: () {
          context.push('/contracts/create?roomId=${detail.room.id}');
        },
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppCard(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                _buildInfoRow('Số hợp đồng', contract.contractNumber),
                const Divider(),
                _buildInfoRow('Người đứng tên', contract.primaryTenantName),
                const Divider(),
                _buildInfoRow('Thời hạn',
                    '${DateFormatter.format(contract.startDate)} - ${DateFormatter.format(contract.endDate)}'),
                const Divider(),
                _buildInfoRow('Tiền đặt cọc',
                    CurrencyFormatter.format(contract.depositAmount)),
                const Divider(),
                _buildInfoRow('Tiền thuê',
                    CurrencyFormatter.format(contract.monthlyRent)),
                const Divider(),
                _buildInfoRow('Trạng thái', contract.status),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppButton(
            text: 'Xem chi tiết hợp đồng',
            icon: Icons.arrow_forward,
            onPressed: () {
              context.push('/contracts/${contract.id}');
            },
          ),
        ],
      ),
    );
  }

  // --- TAB 4: ĐIỆN & NƯỚC ---
  Widget _buildUtilitiesTab(RoomDetailEntity detail, ThemeData theme) {
    final utils = detail.latestUtilities;
    if (utils == null) {
      return EmptyState(
        title: 'Chưa có chỉ số điện nước',
        description: 'Chưa có dữ liệu ghi số điện nước mới nhất cho phòng này.',
        icon: Icons.bolt_outlined,
        actionText: 'Ghi chỉ số ngay',
        onAction: () {
          context.push('/utilities/record?roomId=${detail.room.id}');
        },
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppCard(
            margin: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Chỉ số chốt gần nhất',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      DateFormatter.format(utils.readingDate),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildUtilityItem(
                  icon: Icons.bolt,
                  title: 'Điện (kWh)',
                  color: Colors.amber.shade800,
                  previous: utils.previousElectricity,
                  current: utils.currentElectricity,
                  consumption: utils.electricityConsumption,
                ),
                const Divider(height: 24),
                _buildUtilityItem(
                  icon: Icons.water_drop,
                  title: 'Nước (m³)',
                  color: Colors.blue.shade600,
                  previous: utils.previousWater,
                  current: utils.currentWater,
                  consumption: utils.waterConsumption,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppButton(
            text: 'Ghi chỉ số kỳ mới',
            icon: Icons.add,
            onPressed: () {
              context.push('/utilities/record?roomId=${detail.room.id}');
            },
          ),
          const SizedBox(height: 8),
          AppButton(
            text: 'Xem tất cả lịch sử điện nước',
            icon: Icons.history,
            variant: AppButtonVariant.outlined,
            onPressed: () {
              context.push('/utilities');
            },
          ),
        ],
      ),
    );
  }

  // --- TAB 5: HÓA ĐƠN ---
  Widget _buildInvoiceTab(RoomDetailEntity detail, ThemeData theme) {
    final invoice = detail.currentInvoice;
    if (invoice == null) {
      return EmptyState(
        title: 'Không có hóa đơn hiện tại',
        description: 'Phòng này chưa có hóa đơn cần thu cho chu kỳ hiện tại.',
        icon: Icons.receipt_long_outlined,
        actionText: 'Lập hóa đơn ngay',
        onAction: () {
          context.push('/invoices/create?roomId=${detail.room.id}');
        },
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppCard(
            margin: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Hóa đơn ${invoice.billingMonth}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    PaymentStatusBadge(status: invoice.status),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInfoRow('Mã hóa đơn', invoice.invoiceNumber),
                const Divider(),
                _buildInfoRow('Hạn đóng', DateFormatter.format(invoice.dueDate)),
                const Divider(),
                _buildInfoRow('Tổng tiền', CurrencyFormatter.format(invoice.totalAmount)),
                const Divider(),
                _buildInfoRow('Đã trả', CurrencyFormatter.format(invoice.paidAmount)),
                const Divider(),
                _buildInfoRow(
                  'Còn lại',
                  CurrencyFormatter.format(invoice.remainingAmount),
                  isHighlighted: invoice.remainingAmount > 0,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppButton(
            text: 'Xem chi tiết hóa đơn',
            icon: Icons.arrow_forward,
            onPressed: () {
              context.push('/invoices/${invoice.id}');
            },
          ),
          const SizedBox(height: 8),
          AppButton(
            text: 'Lập hóa đơn kỳ mới',
            icon: Icons.add,
            variant: AppButtonVariant.outlined,
            onPressed: () {
              context.push('/invoices/create?roomId=${detail.room.id}');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isHighlighted ? Colors.red : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUtilityItem({
    required IconData icon,
    required String title,
    required Color color,
    required num? previous,
    required num? current,
    required num consumption,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Cũ: ${previous ?? "-"}  ➔  Mới: ${current ?? "-"}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        Text(
          '+$consumption',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
      ],
    );
  }
}
