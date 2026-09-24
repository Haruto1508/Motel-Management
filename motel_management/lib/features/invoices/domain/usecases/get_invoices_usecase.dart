import 'package:rental_management/features/invoices/domain/entities/invoice_entity.dart';
import 'package:rental_management/features/invoices/domain/entities/invoice_status.dart';
import 'package:rental_management/features/invoices/domain/repositories/invoice_repository.dart';

class GetInvoicesUseCase {
  final InvoiceRepository repository;

  GetInvoicesUseCase(this.repository);

  Future<List<InvoiceEntity>> call({
    String? roomId,
    String? billingMonth,
    InvoiceStatus? status,
    String? query,
  }) {
    return repository.getInvoices(
      roomId: roomId,
      billingMonth: billingMonth,
      status: status,
      query: query,
    );
  }
}

class GetInvoiceByIdUseCase {
  final InvoiceRepository repository;

  GetInvoiceByIdUseCase(this.repository);

  Future<InvoiceEntity> call(String id) {
    return repository.getInvoiceById(id);
  }
}
