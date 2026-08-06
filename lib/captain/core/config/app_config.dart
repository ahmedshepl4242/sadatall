class AppConfig {
  static const String appName = 'SADAT Captain';
  static const String appVersion = '1.0.0';
  
  // Location update settings
  static const int locationUpdateIntervalSeconds = 30;
  static const double proximityThresholdMeters = 100.0;
  
  // Firebase settings
  static const String firebaseProjectId = 'sadat-delivery';
  
  // Cache settings
  static const Duration tokenCacheExpiry = Duration(hours: 24);
  static const Duration dataCacheExpiry = Duration(minutes: 15);
  
  // UI settings
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 8.0;
  static const double buttonHeight = 48.0;
}