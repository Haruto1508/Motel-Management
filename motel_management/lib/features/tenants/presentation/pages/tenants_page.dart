import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rental_management/core/widgets/app_scaffold.dart';
import 'package:rental_management/core/widgets/app_text_field.dart';
import 'package:rental_management/core/widgets/empty_state.dart';
import 'package:rental_management/core/widgets/error_view.dart';
import 'package:rental_management/core/widgets/loading_view.dart';
import 'package:rental_management/features/tenants/domain/entities/tenant_status.dart';
import 'package:rental_management/features/tenants/presentation/providers/tenants_list_controller.dart';
import 'package:rental_management/features/tenants/presentation/widgets/tenant_card.dart';

class TenantsPage extends ConsumerStatefulWidget {
  const TenantsPage({super.key});

  @override
  ConsumerState<TenantsPage> createState() => _TenantsPageState();
}

class _TenantsPageState extends ConsumerState<TenantsPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(tenantsListControllerProvider);
    final controller = ref.read(tenantsListControllerProvider.notifier);

    return AppScaffold(
      title: 'Quản lý khách thuê',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/tenants/create'),
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Thêm khách'),
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                AppTextField(
                  hint: 'Tìm theo họ tên, SĐT hoặc CCCD...',
                  controller: _searchController,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            controller.search('');
                          },
                        )
                      : null,
                  onChanged: (val) => controller.search(val),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('Tất cả'),
                        selected: stateAsync.value?.selectedStatus == null,
                        onSelected: (_) => controller.filterByStatus(null),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Đang thuê'),
                        selected: stateAsync.value?.selectedStatus == TenantStatus.active,
                        onSelected: (_) => controller.filterByStatus(TenantStatus.active),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Tạm ngưng'),
                        selected: stateAsync.value?.selectedStatus == TenantStatus.inactive,
                        onSelected: (_) => controller.filterByStatus(TenantStatus.inactive),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Đã trả phòng'),
                        selected: stateAsync.value?.selectedStatus == TenantStatus.left,
                        onSelected: (_) => controller.filterByStatus(TenantStatus.left),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tenants List Body
          Expanded(
            child: stateAsync.when(
              loading: () => const LoadingView(message: 'Đang tải danh sách khách thuê...'),
              error: (err, _) => ErrorView(
                message: err.toString(),
                onRetry: () => controller.refresh(),
              ),
              data: (state) {
                if (state.tenants.isEmpty) {
                  return EmptyState(
                    title: 'Chưa có khách thuê',
                    description: state.searchQuery.isNotEmpty
                        ? 'Không tìm thấy khách thuê khớp với từ khóa tìm kiếm.'
                        : 'Danh sách khách thuê đang trống. Nhấn "Thêm khách" để bắt đầu.',
                    icon: Icons.people_outline,
                    actionText: state.searchQuery.isNotEmpty ? 'Xóa tìm kiếm' : 'Thêm khách ngay',
                    onAction: () {
                      if (state.searchQuery.isNotEmpty) {
                        _searchController.clear();
                        controller.search('');
                      } else {
                        context.push('/tenants/create');
                      }
                    },
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => controller.refresh(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    itemCount: state.tenants.length,
                    itemBuilder: (context, index) {
                      final tenant = state.tenants[index];
                      return TenantCard(
                        tenant: tenant,
                        onTap: () => context.push('/tenants/${tenant.id}'),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
