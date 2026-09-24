import 'package:equatable/equatable.dart';
import 'package:rental_management/features/invoices/domain/entities/invoice_status.dart';
import 'package:rental_management/features/invoices/domain/entities/payment_entity.dart';

class InvoiceEntity extends Equatable {
  final String id;
  final String invoiceNumber;
  final String roomId;
  final String? roomCode;
  final String tenantId;
  final String? primaryTenantName;
  final String? primaryTenantPhone;
  final String billingMonth;
  final double rentAmount;
  final double electricityAmount;
  final double waterAmount;
  final double internetAmount;
  final double otherAmount;
  final double discountAmount;
  final double totalAmount;
  final double paidAmount;
  final DateTime dueDate;
  final DateTime? paidAt;
  final InvoiceStatus status;
  final String? note;
  final DateTime? createdAt;
  final List<PaymentEntity> payments;

  const InvoiceEntity({
    required this.id,
    required this.invoiceNumber,
    required this.roomId,
    this.roomCode,
    required this.tenantId,
    this.primaryTenantName,
    this.primaryTenantPhone,
    required this.billingMonth,
    required this.rentAmount,
    this.electricityAmount = 0.0,
    this.waterAmount = 0.0,
    this.internetAmount = 0.0,
    this.otherAmount = 0.0,
    this.discountAmount = 0.0,
    required this.totalAmount,
    this.paidAmount = 0.0,
    required this.dueDate,
    this.paidAt,
    this.status = InvoiceStatus.unpaid,
    this.note,
    this.createdAt,
    this.payments = const [],
  });

  /// Số tiền còn phải đóng (VNĐ)
  double get remainingAmount {
    final diff = totalAmount - paidAmount;
    return diff > 0 ? diff : 0.0;
  }

  /// Đã đóng đủ tiền
  bool get isPaid => status == InvoiceStatus.paid || (paidAmount >= totalAmount && totalAmount > 0);

  /// Đã đóng một phần
  bool get isPartiallyPaid =>
      status == InvoiceStatus.partiallyPaid || (paidAmount > 0 && paidAmount < totalAmount);

  /// Đã quá hạn đóng tiền
  bool get isOverdue =>
      status == InvoiceStatus.overdue || (!isPaid && DateTime.now().isAfter(dueDate));

  @override
  List<Object?> get props => [
        id,
        invoiceNumber,
        roomId,
        roomCode,
        tenantId,
        primaryTenantName,
        primaryTenantPhone,
        billingMonth,
        rentAmount,
        electricityAmount,
        waterAmount,
        internetAmount,
        otherAmount,
        discountAmount,
        totalAmount,
        paidAmount,
        dueDate,
        paidAt,
        status,
        note,
        createdAt,
        payments,
      ];
}
