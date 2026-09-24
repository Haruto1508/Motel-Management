import 'package:rental_management/features/invoices/domain/entities/invoice_entity.dart';
import 'package:rental_management/features/invoices/domain/entities/invoice_status.dart';
import 'package:rental_management/features/invoices/domain/entities/payment_entity.dart';

abstract class InvoiceRepository {
  Future<List<InvoiceEntity>> getInvoices({
    String? roomId,
    String? billingMonth,
    InvoiceStatus? status,
    String? query,
  });

  Future<InvoiceEntity> getInvoiceById(String id);

  Future<InvoiceEntity> createInvoice(Map<String, dynamic> data);

  Future<InvoiceEntity> updateInvoice(String id, Map<String, dynamic> data);

  Future<void> cancelInvoice(String id);

  Future<PaymentEntity> recordPayment(Map<String, dynamic> data);

  Future<List<PaymentEntity>> getPaymentsByInvoiceId(String invoiceId);
}
