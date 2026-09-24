import 'package:rental_management/features/invoices/data/models/payment_model.dart';
import 'package:rental_management/features/invoices/domain/entities/invoice_entity.dart';
import 'package:rental_management/features/invoices/domain/entities/invoice_status.dart';

class InvoiceModel {
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
  final String status;
  final String? note;
  final DateTime? createdAt;
  final List<PaymentModel> payments;

  const InvoiceModel({
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
    this.status = 'UNPAID',
    this.note,
    this.createdAt,
    this.payments = const [],
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    final paymentsRaw = json['payments'] as List<dynamic>? ?? [];

    return InvoiceModel(
      id: json['id'] as String,
      invoiceNumber: json['invoiceNumber'] as String? ?? json['invoice_number'] as String? ?? '',
      roomId: json['roomId'] as String? ?? json['room_id'] as String? ?? '',
      roomCode: json['roomCode'] as String? ?? json['room_code'] as String?,
      tenantId: json['tenantId'] as String? ?? json['tenant_id'] as String? ?? '',
      primaryTenantName: json['primaryTenantName'] as String? ?? json['primary_tenant_name'] as String?,
      primaryTenantPhone: json['primaryTenantPhone'] as String? ?? json['primary_tenant_phone'] as String?,
      billingMonth: json['billingMonth'] as String? ?? json['billing_month'] as String? ?? '',
      rentAmount: ((json['rentAmount'] ?? json['rent_amount'] ?? json['room_amount'] ?? 0) as num).toDouble(),
      electricityAmount: ((json['electricityAmount'] ?? json['electricity_amount'] ?? 0) as num).toDouble(),
      waterAmount: ((json['waterAmount'] ?? json['water_amount'] ?? 0) as num).toDouble(),
      internetAmount: ((json['internetAmount'] ?? json['internet_amount'] ?? json['service_amount'] ?? 0) as num).toDouble(),
      otherAmount: ((json['otherAmount'] ?? json['other_amount'] ?? 0) as num).toDouble(),
      discountAmount: ((json['discountAmount'] ?? json['discount_amount'] ?? 0) as num).toDouble(),
      totalAmount: ((json['totalAmount'] ?? json['total_amount'] ?? 0) as num).toDouble(),
      paidAmount: ((json['paidAmount'] ?? json['paid_amount'] ?? 0) as num).toDouble(),
      dueDate: json['dueDate'] != null
          ? DateTime.tryParse(json['dueDate'].toString()) ?? DateTime.now().add(const Duration(days: 7))
          : (json['due_date'] != null
              ? DateTime.tryParse(json['due_date'].toString()) ?? DateTime.now().add(const Duration(days: 7))
              : DateTime.now().add(const Duration(days: 7))),
      paidAt: json['paidAt'] != null
          ? DateTime.tryParse(json['paidAt'].toString())
          : (json['paid_at'] != null ? DateTime.tryParse(json['paid_at'].toString()) : null),
      status: json['status'] as String? ?? 'UNPAID',
      note: json['note'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : (json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null),
      payments: paymentsRaw
          .map((p) => PaymentModel.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoiceNumber': invoiceNumber,
      'roomId': roomId,
      'roomCode': roomCode,
      'tenantId': tenantId,
      'primaryTenantName': primaryTenantName,
      'primaryTenantPhone': primaryTenantPhone,
      'billingMonth': billingMonth,
      'rentAmount': rentAmount,
      'electricityAmount': electricityAmount,
      'waterAmount': waterAmount,
      'internetAmount': internetAmount,
      'otherAmount': otherAmount,
      'discountAmount': discountAmount,
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'dueDate': dueDate.toIso8601String(),
      'paidAt': paidAt?.toIso8601String(),
      'status': status,
      'note': note,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  InvoiceEntity toEntity() {
    return InvoiceEntity(
      id: id,
      invoiceNumber: invoiceNumber,
      roomId: roomId,
      roomCode: roomCode,
      tenantId: tenantId,
      primaryTenantName: primaryTenantName,
      primaryTenantPhone: primaryTenantPhone,
      billingMonth: billingMonth,
      rentAmount: rentAmount,
      electricityAmount: electricityAmount,
      waterAmount: waterAmount,
      internetAmount: internetAmount,
      otherAmount: otherAmount,
      discountAmount: discountAmount,
      totalAmount: totalAmount,
      paidAmount: paidAmount,
      dueDate: dueDate,
      paidAt: paidAt,
      status: InvoiceStatus.fromString(status),
      note: note,
      createdAt: createdAt,
      payments: payments.map((p) => p.toEntity()).toList(),
    );
  }

  factory InvoiceModel.fromEntity(InvoiceEntity entity) {
    return InvoiceModel(
      id: entity.id,
      invoiceNumber: entity.invoiceNumber,
      roomId: entity.roomId,
      roomCode: entity.roomCode,
      tenantId: entity.tenantId,
      primaryTenantName: entity.primaryTenantName,
      primaryTenantPhone: entity.primaryTenantPhone,
      billingMonth: entity.billingMonth,
      rentAmount: entity.rentAmount,
      electricityAmount: entity.electricityAmount,
      waterAmount: entity.waterAmount,
      internetAmount: entity.internetAmount,
      otherAmount: entity.otherAmount,
      discountAmount: entity.discountAmount,
      totalAmount: entity.totalAmount,
      paidAmount: entity.paidAmount,
      dueDate: entity.dueDate,
      paidAt: entity.paidAt,
      status: entity.status.code,
      note: entity.note,
      createdAt: entity.createdAt,
      payments: entity.payments.map((p) => PaymentModel.fromEntity(p)).toList(),
    );
  }
}
