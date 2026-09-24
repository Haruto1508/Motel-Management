import 'package:rental_management/features/invoices/domain/entities/invoice_entity.dart';
import 'package:rental_management/features/invoices/domain/repositories/invoice_repository.dart';

class CreateInvoiceParams {
  final String invoiceNumber;
  final String roomId;
  final String tenantId;
  final String billingMonth;
  final double rentAmount;
  final double electricityAmount;
  final double waterAmount;
  final double internetAmount;
  final double otherAmount;
  final double discountAmount;
  final DateTime dueDate;
  final String? note;

  const CreateInvoiceParams({
    required this.invoiceNumber,
    required this.roomId,
    required this.tenantId,
    required this.billingMonth,
    required this.rentAmount,
    this.electricityAmount = 0.0,
    this.waterAmount = 0.0,
    this.internetAmount = 0.0,
    this.otherAmount = 0.0,
    this.discountAmount = 0.0,
    required this.dueDate,
    this.note,
  });

  double get calculatedTotal {
    final subtotal = rentAmount + electricityAmount + waterAmount + internetAmount + otherAmount;
    final total = subtotal - discountAmount;
    return total > 0 ? total : 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'invoiceNumber': invoiceNumber.trim(),
      'roomId': roomId,
      'tenantId': tenantId,
      'billingMonth': billingMonth,
      'rentAmount': rentAmount,
      'electricityAmount': electricityAmount,
      'waterAmount': waterAmount,
      'internetAmount': internetAmount,
      'otherAmount': otherAmount,
      'discountAmount': discountAmount,
      'totalAmount': calculatedTotal,
      'paidAmount': 0.0,
      'dueDate': dueDate.toIso8601String(),
      'status': 'UNPAID',
      if (note != null && note!.trim().isNotEmpty) 'note': note!.trim(),
    };
  }
}

class CreateInvoiceUseCase {
  final InvoiceRepository repository;

  CreateInvoiceUseCase(this.repository);

  Future<InvoiceEntity> call(CreateInvoiceParams params) {
    if (params.rentAmount < 0) {
      throw ArgumentError('Tiền thuê phòng không thể âm');
    }
    if (params.electricityAmount < 0 || params.waterAmount < 0 || params.internetAmount < 0) {
      throw ArgumentError('Chi phí dịch vụ không thể âm');
    }
    if (params.calculatedTotal <= 0) {
      throw ArgumentError('Tổng tiền hóa đơn phải lớn hơn 0');
    }

    return repository.createInvoice(params.toJson());
  }
}
