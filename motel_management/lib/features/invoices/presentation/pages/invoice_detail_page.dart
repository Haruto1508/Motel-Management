import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rental_management/core/utils/currency_formatter.dart';
import 'package:rental_management/core/utils/date_formatter.dart';
import 'package:rental_management/core/widgets/app_button.dart';
import 'package:rental_management/core/widgets/app_card.dart';
import 'package:rental_management/core/widgets/app_scaffold.dart';
import 'package:rental_management/core/widgets/confirm_dialog.dart';
import 'package:rental_management/core/widgets/error_view.dart';
import 'package:rental_management/core/widgets/loading_view.dart';
import 'package:rental_management/core/widgets/status_badge.dart';
import 'package:rental_management/features/invoices/domain/entities/invoice_entity.dart';
import 'package:rental_management/features/invoices/domain/entities/payment_entity.dart';
import 'package:rental_management/features/invoices/presentation/providers/invoice_providers.dart';
import 'package:rental_management/features/invoices/presentation/providers/invoices_list_controller.dart';
import 'package:rental_management/features/invoices/presentation/widgets/record_payment_dialog.dart';

class InvoiceDetailPage extends ConsumerWidget {
  final String invoiceId;

  const InvoiceDetailPage({super.key, required this.invoiceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoiceAsync = ref.watch(invoiceDetailProvider(invoiceId));
    final theme = Theme.of(context);

    return AppScaffold(
      title: 'Chi tiết hóa đơn',
      body: invoiceAsync.when(
        data: (invoice) => _buildContent(context, ref, invoice, theme),
        loading: () => const LoadingView(),
        error: (e, s) => ErrorView(
          message: 'Lỗi tải hóa đơn: $e',
          onRetry: () => ref.invalidate(invoiceDetailProvider(invoiceId)),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    InvoiceEntity invoice,
    ThemeData theme,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Header Card
          AppCard(
            margin: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Hóa đơn ${invoice.invoiceNumber}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    PaymentStatusBadge(status: invoice.status.code),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoRow('Phòng', invoice.roomCode ?? invoice.roomId),
                const Divider(),
                _buildInfoRow('Người thuê', invoice.primaryTenantName ?? 'Chưa xác định'),
                const Divider(),
                _buildInfoRow('Kỳ thanh toán', invoice.billingMonth),
                const Divider(),
                _buildInfoRow('Hạn đóng tiền', DateFormatter.format(invoice.dueDate)),
                if (invoice.paidAt != null) ...[
                  const Divider(),
                  _buildInfoRow('Ngày thanh toán xong', DateFormatter.format(invoice.paidAt!)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. Breakdown Card
          AppCard(
            margin: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chi tiết các khoản phí',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildItemRow('1. Tiền thuê phòng', invoice.rentAmount),
                if (invoice.electricityAmount > 0)
                  _buildItemRow('2. Tiền điện', invoice.electricityAmount),
                if (invoice.waterAmount > 0)
                  _buildItemRow('3. Tiền nước', invoice.waterAmount),
                if (invoice.internetAmount > 0)
                  _buildItemRow('4. Tiền Internet / WiFi', invoice.internetAmount),
                if (invoice.otherAmount > 0)
                  _buildItemRow('5. Dịch vụ khác / Rác', invoice.otherAmount),
                if (invoice.discountAmount > 0)
                  _buildItemRow('6. Giảm giá / Khuyến mãi', -invoice.discountAmount, isDiscount: true),
                const Divider(height: 24, thickness: 1.5),

                // Total, paid, remaining
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tổng cộng:',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      CurrencyFormatter.format(invoice.totalAmount),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Đã thanh toán:'),
                    Text(
                      CurrencyFormatter.format(invoice.paidAmount),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Còn nợ lại:'),
                    Text(
                      CurrencyFormatter.format(invoice.remainingAmount),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: invoice.remainingAmount > 0 ? Colors.red : Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. Payment History
          _buildPaymentHistorySection(context, ref, invoice, theme),
          const SizedBox(height: 24),

          // Actions
          if (!invoice.isPaid) ...[
            AppButton(
              text: 'Ghi nhận thanh toán',
              icon: Icons.payments_outlined,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => RecordPaymentDialog(invoice: invoice),
                );
              },
            ),
            const SizedBox(height: 12),
          ],

          OutlinedButton.icon(
            onPressed: () async {
              final confirmed = await ConfirmDialog.show(
                context,
                title: 'Hủy hóa đơn này?',
                content: 'Bạn có chắc chắn muốn hủy hóa đơn ${invoice.invoiceNumber} không?',
                confirmText: 'Hủy hóa đơn',
                isDestructive: true,
              );
              if (confirmed == true && context.mounted) {
                final cancelUseCase = ref.read(cancelInvoiceUseCaseProvider);
                await cancelUseCase.call(invoice.id);
                ref.invalidate(invoiceDetailProvider(invoice.id));
                await ref.read(invoicesListControllerProvider.notifier).refresh();
                if (context.mounted) context.pop();
              }
            },
            icon: const Icon(Icons.cancel_outlined, color: Colors.red),
            label: const Text('Hủy hóa đơn', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentHistorySection(
    BuildContext context,
    WidgetRef ref,
    InvoiceEntity invoice,
    ThemeData theme,
  ) {
    final paymentsAsync = ref.watch(invoicePaymentsProvider(invoice.id));

    return AppCard(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Lịch sử thanh toán',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Icon(Icons.history, size: 20, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 12),
          paymentsAsync.when(
            data: (payments) {
              final list = payments.isNotEmpty ? payments : invoice.payments;
              if (list.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Chưa có khoản thanh toán nào cho hóa đơn này.',
                    style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                  ),
                );
              }

              return Column(
                children: list.map((p) => _buildPaymentRow(p, theme)).toList(),
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => invoice.payments.isEmpty
                ? const Text('Chưa có lịch sử thanh toán')
                : Column(
                    children: invoice.payments.map((p) => _buildPaymentRow(p, theme)).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(PaymentEntity payment, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                payment.paymentMethod.label,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                DateFormatter.formatDateTime(payment.paymentDate),
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
              if (payment.transactionReference != null)
                Text(
                  'Mã GD: ${payment.transactionReference}',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
            ],
          ),
          Text(
            '+ ${CurrencyFormatter.format(payment.amount)}',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildItemRow(String label, double amount, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            CurrencyFormatter.format(amount),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDiscount ? Colors.red : null,
            ),
          ),
        ],
      ),
    );
  }
}
