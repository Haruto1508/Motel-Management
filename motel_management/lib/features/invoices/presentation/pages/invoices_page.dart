import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rental_management/core/utils/currency_formatter.dart';
import 'package:rental_management/core/widgets/app_scaffold.dart';
import 'package:rental_management/core/widgets/empty_state.dart';
import 'package:rental_management/core/widgets/error_view.dart';
import 'package:rental_management/core/widgets/loading_view.dart';
import 'package:rental_management/features/invoices/domain/entities/invoice_status.dart';
import 'package:rental_management/features/invoices/presentation/providers/invoices_list_controller.dart';
import 'package:rental_management/features/invoices/presentation/widgets/invoice_card.dart';

class InvoicesPage extends ConsumerWidget {
  const InvoicesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(invoicesListControllerProvider);
    final controller = ref.read(invoicesListControllerProvider.notifier);
    final theme = Theme.of(context);

    return AppScaffold(
      title: 'Hóa đơn tiền phòng',
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Lập hóa đơn'),
        onPressed: () => context.push('/invoices/create'),
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.refresh(),
        child: Column(
          children: [
            // Revenue statistics banner
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem(
                    'Tổng phải thu',
                    CurrencyFormatter.format(state.totalBilledAmount),
                    theme.colorScheme.primary,
                  ),
                  Container(height: 35, width: 1, color: Colors.grey.withValues(alpha: 0.3)),
                  _buildSummaryItem(
                    'Đã thu',
                    CurrencyFormatter.format(state.totalCollectedAmount),
                    Colors.green.shade700,
                  ),
                  Container(height: 35, width: 1, color: Colors.grey.withValues(alpha: 0.3)),
                  _buildSummaryItem(
                    'Còn nợ',
                    CurrencyFormatter.format(state.totalPendingAmount),
                    state.totalPendingAmount > 0 ? Colors.red.shade700 : Colors.green,
                  ),
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm phòng, khách thuê, số hóa đơn...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (val) => controller.search(val),
              ),
            ),
            const SizedBox(height: 12),

            // Status filter chips
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildFilterChip(
                    context,
                    label: 'Tất cả',
                    isSelected: state.selectedStatus == null,
                    onTap: () => controller.setStatusFilter(null),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    context,
                    label: 'Chưa thanh toán',
                    isSelected: state.selectedStatus == InvoiceStatus.unpaid,
                    onTap: () => controller.setStatusFilter(InvoiceStatus.unpaid),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    context,
                    label: 'Đã trả một phần',
                    isSelected: state.selectedStatus == InvoiceStatus.partiallyPaid,
                    onTap: () => controller.setStatusFilter(InvoiceStatus.partiallyPaid),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    context,
                    label: 'Đã thanh toán',
                    isSelected: state.selectedStatus == InvoiceStatus.paid,
                    onTap: () => controller.setStatusFilter(InvoiceStatus.paid),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    context,
                    label: 'Quá hạn',
                    isSelected: state.selectedStatus == InvoiceStatus.overdue,
                    onTap: () => controller.setStatusFilter(InvoiceStatus.overdue),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // List of invoices
            Expanded(
              child: Builder(
                builder: (context) {
                  if (state.isLoading && state.invoices.isEmpty) {
                    return const LoadingView();
                  }

                  if (state.errorMessage != null && state.invoices.isEmpty) {
                    return ErrorView(
                      message: state.errorMessage!,
                      onRetry: () => controller.refresh(),
                    );
                  }

                  if (state.invoices.isEmpty) {
                    return EmptyState(
                      title: 'Chưa có hóa đơn nào',
                      description: 'Nhấn nút "Lập hóa đơn" để tạo hóa đơn thu tiền phòng.',
                      icon: Icons.receipt_long_outlined,
                      actionText: 'Lập hóa đơn ngay',
                      onAction: () => context.push('/invoices/create'),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    itemCount: state.invoices.length,
                    itemBuilder: (context, index) {
                      final invoice = state.invoices[index];
                      return InvoiceCard(
                        invoice: invoice,
                        onTap: () => context.push('/invoices/${invoice.id}'),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
    );
  }
}
