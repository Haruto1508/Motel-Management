import 'package:rental_management/features/invoices/domain/entities/payment_entity.dart';
import 'package:rental_management/features/invoices/domain/entities/payment_method.dart';

class PaymentModel {
  final String id;
  final String invoiceId;
  final double amount;
  final String paymentMethod;
  final DateTime paymentDate;
  final String? transactionReference;
  final String? note;

  const PaymentModel({
    required this.id,
    required this.invoiceId,
    required this.amount,
    required this.paymentMethod,
    required this.paymentDate,
    this.transactionReference,
    this.note,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as String,
      invoiceId: json['invoiceId'] as String? ?? json['invoice_id'] as String? ?? '',
      amount: ((json['amount'] ?? 0) as num).toDouble(),
      paymentMethod: json['paymentMethod'] as String? ?? json['payment_method'] as String? ?? 'CASH',
      paymentDate: json['paymentDate'] != null
          ? DateTime.tryParse(json['paymentDate'].toString()) ?? DateTime.now()
          : (json['payment_date'] != null
              ? DateTime.tryParse(json['payment_date'].toString()) ?? DateTime.now()
              : DateTime.now()),
      transactionReference:
          json['transactionReference'] as String? ?? json['transaction_reference'] as String?,
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoiceId': invoiceId,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'paymentDate': paymentDate.toIso8601String(),
      'transactionReference': transactionReference,
      'note': note,
    };
  }

  PaymentEntity toEntity() {
    return PaymentEntity(
      id: id,
      invoiceId: invoiceId,
      amount: amount,
      paymentMethod: PaymentMethod.fromString(paymentMethod),
      paymentDate: paymentDate,
      transactionReference: transactionReference,
      note: note,
    );
  }

  factory PaymentModel.fromEntity(PaymentEntity entity) {
    return PaymentModel(
      id: entity.id,
      invoiceId: entity.invoiceId,
      amount: entity.amount,
      paymentMethod: entity.paymentMethod.code,
      paymentDate: entity.paymentDate,
      transactionReference: entity.transactionReference,
      note: entity.note,
    );
  }
}
