import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_management/core/utils/currency_formatter.dart';
import 'package:rental_management/features/invoices/domain/entities/invoice_entity.dart';
import 'package:rental_management/features/invoices/domain/entities/payment_method.dart';
import 'package:rental_management/features/invoices/domain/usecases/record_payment_usecase.dart';
import 'package:rental_management/features/invoices/presentation/providers/invoice_providers.dart';
import 'package:rental_management/features/invoices/presentation/providers/invoices_list_controller.dart';

class RecordPaymentDialog extends ConsumerStatefulWidget {
  final InvoiceEntity invoice;

  const RecordPaymentDialog({super.key, required this.invoice});

  @override
  ConsumerState<RecordPaymentDialog> createState() => _RecordPaymentDialogState();
}

class _RecordPaymentDialogState extends ConsumerState<RecordPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  final _referenceController = TextEditingController();
  final _noteController = TextEditingController();

  PaymentMethod _paymentMethod = PaymentMethod.bankTransfer;
  final DateTime _paymentDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.invoice.remainingAmount.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    if (amount <= 0) return;

    setState(() => _isLoading = true);
    try {
      final params = RecordPaymentParams(
        invoiceId: widget.invoice.id,
        amount: amount,
        paymentMethod: _paymentMethod,
        paymentDate: _paymentDate,
        transactionReference: _referenceController.text.trim().isEmpty
            ? null
            : _referenceController.text.trim(),
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      );

      final useCase = ref.read(recordPaymentUseCaseProvider);
      await useCase.call(params);

      // Invalidate relevant providers
      ref.invalidate(invoiceDetailProvider(widget.invoice.id));
      ref.invalidate(invoicePaymentsProvider(widget.invoice.id));
      await ref.read(invoicesListControllerProvider.notifier).refresh();

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ghi nhận thanh toán ${CurrencyFormatter.format(amount)} thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ghi nhận thanh toán'),
          const SizedBox(height: 4),
          Text(
            'Phòng ${widget.invoice.roomCode ?? ""} - Kỳ: ${widget.invoice.billingMonth}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Số tiền còn nợ:'),
                    Text(
                      CurrencyFormatter.format(widget.invoice.remainingAmount),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Số tiền thanh toán *',
                  suffixText: '₫',
                  border: const OutlineInputBorder(),
                  suffixIcon: TextButton(
                    onPressed: () {
                      _amountController.text =
                          widget.invoice.remainingAmount.toStringAsFixed(0);
                    },
                    child: const Text('Trả hết'),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Nhập số tiền';
                  final numVal = double.tryParse(val.trim());
                  if (numVal == null || numVal <= 0) return 'Số tiền phải > 0';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<PaymentMethod>(
                initialValue: _paymentMethod,
                decoration: const InputDecoration(
                  labelText: 'Hình thức thanh toán',
                  border: OutlineInputBorder(),
                ),
                items: PaymentMethod.values.map((m) {
                  return DropdownMenuItem(
                    value: m,
                    child: Text(m.label),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _paymentMethod = val);
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _referenceController,
                decoration: const InputDecoration(
                  labelText: 'Mã tham chiếu / Số GD ngân hàng',
                  hintText: 'Ví dụ: FT260920...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _noteController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Ghi chú thanh toán',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _handleSubmit,
          child: _isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Xác nhận thu tiền'),
        ),
      ],
    );
  }
}
