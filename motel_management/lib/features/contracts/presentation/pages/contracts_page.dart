import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rental_management/core/widgets/app_scaffold.dart';
import 'package:rental_management/core/widgets/app_text_field.dart';
import 'package:rental_management/core/widgets/empty_state.dart';
import 'package:rental_management/core/widgets/error_view.dart';
import 'package:rental_management/core/widgets/loading_view.dart';
import 'package:rental_management/features/contracts/domain/entities/contract_status.dart';
import 'package:rental_management/features/contracts/presentation/providers/contracts_list_controller.dart';
import 'package:rental_management/features/contracts/presentation/widgets/contract_card.dart';

class ContractsPage extends ConsumerStatefulWidget {
  const ContractsPage({super.key});

  @override
  ConsumerState<ContractsPage> createState() => _ContractsPageState();
}

class _ContractsPageState extends ConsumerState<ContractsPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(contractsListControllerProvider);
    final controller = ref.read(contractsListControllerProvider.notifier);

    return AppScaffold(
      title: 'Hợp đồng thuê phòng',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/contracts/create'),
        icon: const Icon(Icons.note_add_outlined),
        label: const Text('Tạo hợp đồng'),
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                AppTextField(
                  hint: 'Tìm theo số HĐ, mã phòng hoặc tên khách...',
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
                        label: const Text('Đang hiệu lực'),
                        selected: stateAsync.value?.selectedStatus == ContractStatus.active,
                        onSelected: (_) => controller.filterByStatus(ContractStatus.active),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Đã hết hạn'),
                        selected: stateAsync.value?.selectedStatus == ContractStatus.expired,
                        onSelected: (_) => controller.filterByStatus(ContractStatus.expired),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Đã thanh lý'),
                        selected: stateAsync.value?.selectedStatus == ContractStatus.terminated,
                        onSelected: (_) => controller.filterByStatus(ContractStatus.terminated),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Contracts List Body
          Expanded(
            child: stateAsync.when(
              loading: () => const LoadingView(message: 'Đang tải danh sách hợp đồng...'),
              error: (err, _) => ErrorView(
                message: err.toString(),
                onRetry: () => controller.refresh(),
              ),
              data: (state) {
                if (state.contracts.isEmpty) {
                  return EmptyState(
                    title: 'Chưa có hợp đồng nào',
                    description: state.searchQuery.isNotEmpty
                        ? 'Không tìm thấy hợp đồng khớp với từ khóa tìm kiếm.'
                        : 'Danh sách hợp đồng đang trống. Bấm "Tạo hợp đồng" để bắt đầu.',
                    icon: Icons.description_outlined,
                    actionText: state.searchQuery.isNotEmpty ? 'Xóa tìm kiếm' : 'Tạo hợp đồng ngay',
                    onAction: () {
                      if (state.searchQuery.isNotEmpty) {
                        _searchController.clear();
                        controller.search('');
                      } else {
                        context.push('/contracts/create');
                      }
                    },
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => controller.refresh(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    itemCount: state.contracts.length,
                    itemBuilder: (context, index) {
                      final contract = state.contracts[index];
                      return ContractCard(
                        contract: contract,
                        onTap: () => context.push('/contracts/${contract.id}'),
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
