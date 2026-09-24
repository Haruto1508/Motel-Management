import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rental_management/core/utils/currency_formatter.dart';
import 'package:rental_management/core/widgets/app_card.dart';
import 'package:rental_management/core/widgets/app_scaffold.dart';
import 'package:rental_management/core/widgets/empty_state.dart';
import 'package:rental_management/core/widgets/error_view.dart';
import 'package:rental_management/core/widgets/loading_view.dart';
import 'package:rental_management/features/rooms/presentation/providers/rooms_providers.dart';
import 'package:rental_management/features/utilities/presentation/providers/utilities_controller.dart';
import 'package:rental_management/features/utilities/presentation/providers/utility_providers.dart';
import 'package:rental_management/features/utilities/presentation/widgets/service_config_tile.dart';
import 'package:rental_management/features/utilities/presentation/widgets/utility_reading_card.dart';

class UtilitiesPage extends ConsumerStatefulWidget {
  const UtilitiesPage({super.key});

  @override
  ConsumerState<UtilitiesPage> createState() => _UtilitiesPageState();
}

class _UtilitiesPageState extends ConsumerState<UtilitiesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(utilitiesControllerProvider);

    return AppScaffold(
      title: 'Quản lý Điện, Nước & Dịch vụ',
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Ghi chỉ số'),
        onPressed: () => context.push('/utilities/record'),
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: theme.colorScheme.primary,
            indicatorColor: theme.colorScheme.primary,
            tabs: const [
              Tab(icon: Icon(Icons.meeting_room_outlined), text: 'Theo phòng'),
              Tab(icon: Icon(Icons.history_outlined), text: 'Lịch sử ghi số'),
              Tab(icon: Icon(Icons.tune_outlined), text: 'Bảng giá dịch vụ'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRoomsTab(theme),
                _buildHistoryTab(theme, state),
                _buildServicesTab(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 1: DANH SÁCH THEO PHÒNG ---
  Widget _buildRoomsTab(ThemeData theme) {
    final roomsAsync = ref.watch(roomsListProvider);

    return roomsAsync.when(
      data: (rooms) {
        if (rooms.isEmpty) {
          return const EmptyState(
            title: 'Chưa có phòng trọ nào',
            description: 'Vui lòng thêm phòng trước khi ghi chỉ số điện nước.',
            icon: Icons.meeting_room_outlined,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: rooms.length,
          itemBuilder: (context, index) {
            final room = rooms[index];
            final latestAsync = ref.watch(latestReadingProvider(room.id));

            return AppCard(
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      room.roomCode,
                      style: theme.textTheme.titleMedium?.copyWith(
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
                          room.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        latestAsync.when(
                          data: (latest) {
                            if (latest == null) {
                              return Text(
                                'Chưa có chỉ số nào',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              );
                            }
                            return Text(
                              'Gần nhất: ${latest.currentElectricity.toStringAsFixed(0)} kWh | ${latest.currentWater.toStringAsFixed(0)} m³ (${latest.billingMonth})',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            );
                          },
                          loading: () => const Text('Đang tải chỉ số...', style: TextStyle(fontSize: 12)),
                          error: (_, __) => const Text('Chưa có chỉ số', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                  FilledButton.tonal(
                    onPressed: () => context.push('/utilities/record?roomId=${room.id}'),
                    child: const Text('Ghi số'),
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const LoadingView(),
      error: (e, s) => ErrorView(
        message: 'Lỗi tải danh sách phòng: $e',
        onRetry: () => ref.invalidate(roomsListProvider),
      ),
    );
  }

  // --- TAB 2: LỊCH SỬ CHỐT SỐ ---
  Widget _buildHistoryTab(ThemeData theme, UtilitiesState state) {
    final readingsAsync = ref.watch(utilityReadingsProvider((roomId: null, billingMonth: null)));

    return readingsAsync.when(
      data: (readings) {
        if (readings.isEmpty) {
          return EmptyState(
            title: 'Chưa có lịch sử chốt số',
            description: 'Bấm nút bên dưới để ghi chỉ số điện nước đầu tiên.',
            icon: Icons.bolt_outlined,
            actionText: 'Ghi chỉ số ngay',
            onAction: () => context.push('/utilities/record'),
          );
        }

        // Calculate summary for this list
        double totalKwh = 0;
        double totalM3 = 0;
        double totalAmount = 0;

        for (final r in readings) {
          totalKwh += r.electricityConsumption;
          totalM3 += r.waterConsumption;
          totalAmount += r.totalAmount;
        }

        return Column(
          children: [
            // Summary banner
            Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('Tổng điện', '${totalKwh.toStringAsFixed(0)} kWh', Colors.amber.shade800),
                  _buildStatItem('Tổng nước', '${totalM3.toStringAsFixed(0)} m³', Colors.blue.shade600),
                  _buildStatItem('Tổng tiền', CurrencyFormatter.format(totalAmount), theme.colorScheme.primary),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: readings.length,
                itemBuilder: (context, index) {
                  return UtilityReadingCard(reading: readings[index]);
                },
              ),
            ),
          ],
        );
      },
      loading: () => const LoadingView(),
      error: (e, s) => ErrorView(
        message: 'Lỗi tải lịch sử chốt số: $e',
        onRetry: () => ref.invalidate(utilityReadingsProvider),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  // --- TAB 3: CẤU HÌNH BẢNG GIÁ DỊCH VỤ ---
  Widget _buildServicesTab(ThemeData theme) {
    final servicesAsync = ref.watch(serviceConfigsProvider);

    return servicesAsync.when(
      data: (services) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Đơn giá dịch vụ áp dụng',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Các đơn giá này sẽ được dùng để tự động tính toán tiền điện, nước, internet khi ghi số và lập hóa đơn.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            ...services.map((svc) {
              return ServiceConfigTile(
                service: svc,
                onUpdatePrice: (newPrice) {
                  ref.read(utilitiesControllerProvider.notifier).updateServicePrice(svc.id, newPrice);
                },
              );
            }),
          ],
        );
      },
      loading: () => const LoadingView(),
      error: (e, s) => ErrorView(
        message: 'Lỗi tải cấu hình dịch vụ: $e',
        onRetry: () => ref.invalidate(serviceConfigsProvider),
      ),
    );
  }
}
