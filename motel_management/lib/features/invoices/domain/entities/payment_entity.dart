import 'package:equatable/equatable.dart';
import 'package:rental_management/features/invoices/domain/entities/payment_method.dart';

class PaymentEntity extends Equatable {
  final String id;
  final String invoiceId;
  final double amount;
  final PaymentMethod paymentMethod;
  final DateTime paymentDate;
  final String? transactionReference;
  final String? note;

  const PaymentEntity({
    required this.id,
    required this.invoiceId,
    required this.amount,
    required this.paymentMethod,
    required this.paymentDate,
    this.transactionReference,
    this.note,
  });

  @override
  List<Object?> get props => [
        id,
        invoiceId,
        amount,
        paymentMethod,
        paymentDate,
        transactionReference,
        note,
      ];
}
