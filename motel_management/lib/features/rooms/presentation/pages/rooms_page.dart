import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rental_management/core/widgets/app_scaffold.dart';
import 'package:rental_management/core/widgets/empty_state.dart';
import 'package:rental_management/core/widgets/error_view.dart';
import 'package:rental_management/core/widgets/loading_view.dart';
import 'package:rental_management/features/rooms/domain/entities/room_status.dart';
import 'package:rental_management/features/rooms/presentation/providers/rooms_providers.dart';
import 'package:rental_management/features/rooms/presentation/widgets/room_card.dart';

class RoomsPage extends ConsumerWidget {
  const RoomsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(roomsListControllerProvider);
    final controller = ref.read(roomsListControllerProvider.notifier);

    return AppScaffold(
      title: 'Quản lý phòng trọ',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/rooms/create'),
        icon: const Icon(Icons.add),
        label: const Text('Thêm phòng'),
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm theo mã phòng hoặc tên...',
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                suffixIcon: state.filter.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () => controller.setSearchQuery(''),
                      )
                    : null,
              ),
              onChanged: (val) => controller.setSearchQuery(val),
            ),
          ),

          // Horizontal Status Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                _buildFilterChip(
                  context,
                  label: 'Tất cả',
                  isSelected: state.filter.selectedStatus == null,
                  onSelected: () => controller.setStatusFilter(null),
                ),
                const SizedBox(width: 8),
                ...RoomStatus.values.map(
                  (status) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildFilterChip(
                      context,
                      label: status.label,
                      isSelected: state.filter.selectedStatus == status,
                      onSelected: () => controller.setStatusFilter(status),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // Rooms List Content
          Expanded(
            child: Builder(
              builder: (context) {
                if (state.isLoading && state.rooms.isEmpty) {
                  return const LoadingView(message: 'Đang tải danh sách phòng...');
                }

                if (state.errorMessage != null && state.rooms.isEmpty) {
                  return ErrorView(
                    message: state.errorMessage!,
                    onRetry: () => controller.loadRooms(),
                  );
                }

                if (state.rooms.isEmpty) {
                  return EmptyState(
                    title: 'Không tìm thấy phòng nào',
                    description: state.filter.searchQuery.isNotEmpty ||
                            state.filter.selectedStatus != null
                        ? 'Thử thay đổi bộ lọc tìm kiếm của bạn.'
                        : 'Bắt đầu bằng cách thêm phòng trọ đầu tiên vào danh sách quản lý.',
                    icon: Icons.meeting_room_outlined,
                    actionText: 'Thêm phòng mới',
                    onAction: () => context.push('/rooms/create'),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => controller.loadRooms(),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 80),
                    itemCount: state.rooms.length,
                    itemBuilder: (context, index) {
                      final room = state.rooms[index];
                      return RoomCard(
                        room: room,
                        onTap: () => context.push('/rooms/${room.id}'),
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

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    final theme = Theme.of(context);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurface,
      ),
      backgroundColor: theme.colorScheme.surface,
      selectedColor: theme.colorScheme.primaryContainer,
      showCheckmark: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
