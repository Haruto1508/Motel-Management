import 'package:rental_management/features/invoices/domain/entities/payment_entity.dart';
import 'package:rental_management/features/invoices/domain/entities/payment_method.dart';
import 'package:rental_management/features/invoices/domain/repositories/invoice_repository.dart';

class RecordPaymentParams {
  final String invoiceId;
  final double amount;
  final PaymentMethod paymentMethod;
  final DateTime paymentDate;
  final String? transactionReference;
  final String? note;

  const RecordPaymentParams({
    required this.invoiceId,
    required this.amount,
    this.paymentMethod = PaymentMethod.cash,
    required this.paymentDate,
    this.transactionReference,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'invoiceId': invoiceId,
      'amount': amount,
      'paymentMethod': paymentMethod.code,
      'paymentDate': paymentDate.toIso8601String(),
      if (transactionReference != null && transactionReference!.trim().isNotEmpty)
        'transactionReference': transactionReference!.trim(),
      if (note != null && note!.trim().isNotEmpty) 'note': note!.trim(),
    };
  }
}

class RecordPaymentUseCase {
  final InvoiceRepository repository;

  RecordPaymentUseCase(this.repository);

  Future<PaymentEntity> call(RecordPaymentParams params) {
    if (params.amount <= 0) {
      throw ArgumentError('Số tiền thanh toán phải lớn hơn 0');
    }

    return repository.recordPayment(params.toJson());
  }
}

class CancelInvoiceUseCase {
  final InvoiceRepository repository;

  CancelInvoiceUseCase(this.repository);

  Future<void> call(String id) {
    return repository.cancelInvoice(id);
  }
}
