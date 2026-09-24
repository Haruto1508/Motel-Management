/// Application-wide constants
class AppConstants {
  AppConstants._();

  // Storage Keys
  static const String keyAccessToken = 'auth_access_token';
  static const String keyRefreshToken = 'auth_refresh_token';
  static const String keyUserId = 'auth_user_id';
  static const String keyUserEmail = 'auth_user_email';
  static const String keyUserRole = 'auth_user_role';
  static const String keyThemeMode = 'app_theme_mode';

  // API Endpoints
  static const String endpointLogin = '/auth/login';
  static const String endpointRefresh = '/auth/refresh';
  static const String endpointLogout = '/auth/logout';
  static const String endpointCurrentUser = '/auth/me';

  static const String endpointRooms = '/rooms';
  static const String endpointTenants = '/tenants';
  static const String endpointContracts = '/contracts';
  static const String endpointElectricityReadings = '/electricity/readings';
  static const String endpointWaterReadings = '/water/readings';
  static const String endpointUtilityReadings = '/utilities/readings';
  static const String endpointServices = '/utilities/services';
  static const String endpointInvoices = '/invoices';
  static const String endpointPayments = '/payments';

  // Formatting
  static const String defaultDateFormat = 'dd/MM/yyyy';
  static const String defaultDateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String currencySymbol = '₫';
  static const String localeVi = 'vi_VN';
}
