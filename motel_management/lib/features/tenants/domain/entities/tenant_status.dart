enum TenantStatus {
  active('ACTIVE', 'Đang thuê'),
  inactive('INACTIVE', 'Tạm ngưng'),
  left('LEFT', 'Đã trả phòng');

  final String code;
  final String label;

  const TenantStatus(this.code, this.label);

  static TenantStatus fromString(String? status) {
    if (status == null) return TenantStatus.active;
    return TenantStatus.values.firstWhere(
      (e) => e.code.toUpperCase() == status.toUpperCase(),
      orElse: () => TenantStatus.active,
    );
  }
}
