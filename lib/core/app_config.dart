/// Central app configuration.
///
/// The mobile app is a pure CLIENT of the existing MyIndustryHouse backend.
/// It never defines its own endpoints or business rules - it consumes the
/// REST API exactly as deployed (no backend modifications were made).
class AppConfig {
  AppConfig._();

  /// Base URL of the existing production backend.
  /// (Local development: change to http://10.0.2.2:8081 for Android emulator
  ///  or http://localhost:8081 for iOS simulator.)
  static const String apiBaseUrl = 'https://www.myindustryhouse.com';

  static const Duration apiConnectTimeout = Duration(seconds: 15);
  static const Duration apiReceiveTimeout = Duration(seconds: 20);

  /// Message shown when an admin account tries to log in on mobile.
  static const String adminBlockedMessage =
      'Admin access is restricted to the web portal.';
}
