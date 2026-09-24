/// Environment and global configuration settings for the rental management application.
class AppEnvironment {
  AppEnvironment._();

  /// Default API base URL. Can be overridden via `--dart-define=API_BASE_URL=...`
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080/api/v1',
  );

  /// Network timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 15);

  /// App Info
  static const String appName = 'Quản Lý Thuê Trọ';
  static const String appVersion = '1.0.0';
}
