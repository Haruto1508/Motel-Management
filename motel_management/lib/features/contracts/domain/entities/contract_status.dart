enum ContractStatus {
  draft('DRAFT', 'Bản nháp'),
  active('ACTIVE', 'Đang hiệu lực'),
  expired('EXPIRED', 'Đã hết hạn'),
  terminated('TERMINATED', 'Đã thanh lý'),
  cancelled('CANCELLED', 'Đã hủy');

  final String code;
  final String label;

  const ContractStatus(this.code, this.label);

  static ContractStatus fromString(String? status) {
    if (status == null) return ContractStatus.active;
    return ContractStatus.values.firstWhere(
      (e) => e.code.toUpperCase() == status.toUpperCase(),
      orElse: () => ContractStatus.active,
    );
  }
}
