enum PaymentMethod {
  cash('CASH', 'Tiền mặt'),
  bankTransfer('BANK_TRANSFER', 'Chuyển khoản ngân hàng'),
  eWallet('E_WALLET', 'Ví điện tử'),
  other('OTHER', 'Khác');

  final String code;
  final String label;

  const PaymentMethod(this.code, this.label);

  static PaymentMethod fromString(String? method) {
    if (method == null) return PaymentMethod.cash;
    return PaymentMethod.values.firstWhere(
      (e) => e.code.toUpperCase() == method.toUpperCase(),
      orElse: () => PaymentMethod.cash,
    );
  }
}
