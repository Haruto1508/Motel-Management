/// Central form validation utility with user-friendly Vietnamese error messages.
class Validators {
  Validators._();

  /// Validates that a string field is not empty or whitespace
  static String? required(String? value, [String fieldName = 'Thông tin này']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName không được để trống';
    }
    return null;
  }

  /// Validates Vietnamese phone numbers (10 digits starting with 03, 05, 07, 08, 09)
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Số điện thoại không được để trống';
    }
    final clean = value.replaceAll(RegExp(r'\s+'), '');
    final phoneRegex = RegExp(r'^(0)(3|5|7|8|9)[0-9]{8}$');
    if (!phoneRegex.hasMatch(clean)) {
      return 'Số điện thoại không hợp lệ (gồm 10 số, bắt đầu bằng 03, 05, 07, 08, 09)';
    }
    return null;
  }

  /// Validates standard email address
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email không được để trống';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Địa chỉ email không hợp lệ';
    }
    return null;
  }

  /// Validates Vietnamese citizen identification card (CCCD: 12 digits, CMND: 9 digits)
  static String? identityNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Số CCCD/CMND không được để trống';
    }
    final clean = value.trim();
    if (!RegExp(r'^\d{9}$|^\d{12}$').hasMatch(clean)) {
      return 'Số CCCD/CMND phải gồm 9 hoặc 12 chữ số';
    }
    return null;
  }

  /// Validates positive monetary amount
  static String? positiveMoney(String? value, [String fieldName = 'Số tiền']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName không được để trống';
    }
    final clean = value.replaceAll(RegExp(r'[^0-9.]'), '');
    final amount = double.tryParse(clean);
    if (amount == null || amount <= 0) {
      return '$fieldName phải lớn hơn 0';
    }
    return null;
  }

  /// Validates positive meter reading (electricity or water)
  static String? positiveReading(String? value, [String fieldName = 'Chỉ số']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName không được để trống';
    }
    final reading = num.tryParse(value.trim());
    if (reading == null || reading < 0) {
      return '$fieldName không được là số âm';
    }
    return null;
  }

  /// Validates current reading against previous reading:
  /// currentReading cannot be lower than previousReading
  static String? meterReadingSequence({
    required num? previousReading,
    required num? currentReading,
    String readingName = 'Chỉ số',
  }) {
    if (previousReading == null || currentReading == null) {
      return null;
    }
    if (currentReading < previousReading) {
      return '$readingName mới ($currentReading) không được nhỏ hơn $readingName cũ ($previousReading)';
    }
    return null;
  }

  /// Validates room capacity (positive integer)
  static String? roomCapacity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Sức chứa phòng không được để trống';
    }
    final capacity = int.tryParse(value.trim());
    if (capacity == null || capacity <= 0) {
      return 'Sức chứa phải là số nguyên dương (ít nhất 1 người)';
    }
    return null;
  }

  /// Validates contract start and end dates
  static String? dateRange({
    required DateTime? startDate,
    required DateTime? endDate,
    String startName = 'Ngày bắt đầu',
    String endName = 'Ngày kết thúc',
  }) {
    if (startDate == null || endDate == null) return null;
    if (endDate.isBefore(startDate)) {
      return '$endName phải sau $startName';
    }
    return null;
  }

  /// Validates password strength
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mật khẩu không được để trống';
    }
    if (value.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    return null;
  }
}
