enum InvoiceStatus {
  draft('DRAFT', 'Bản nháp'),
  unpaid('UNPAID', 'Chưa thanh toán'),
  partiallyPaid('PARTIALLY_PAID', 'Đã thanh toán một phần'),
  paid('PAID', 'Đã thanh toán'),
  overdue('OVERDUE', 'Quá hạn'),
  cancelled('CANCELLED', 'Đã hủy');

  final String code;
  final String label;

  const InvoiceStatus(this.code, this.label);

  static InvoiceStatus fromString(String? status) {
    if (status == null) return InvoiceStatus.unpaid;
    return InvoiceStatus.values.firstWhere(
      (e) => e.code.toUpperCase() == status.toUpperCase(),
      orElse: () => InvoiceStatus.unpaid,
    );
  }
}
