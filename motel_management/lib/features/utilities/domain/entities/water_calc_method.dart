enum WaterCalcMethod {
  meter('METER', 'Theo đồng hồ (m³)'),
  fixed('FIXED', 'Khoán theo phòng'),
  perPerson('PER_PERSON', 'Khoán theo đầu người');

  final String code;
  final String label;

  const WaterCalcMethod(this.code, this.label);

  static WaterCalcMethod fromString(String? code) {
    if (code == null) return WaterCalcMethod.meter;
    return WaterCalcMethod.values.firstWhere(
      (e) => e.code.toUpperCase() == code.toUpperCase(),
      orElse: () => WaterCalcMethod.meter,
    );
  }
}
