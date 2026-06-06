class AppConstants {
  static const String appName = 'Sadat Customer App';
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://delivery-sadatcity.duckdns.org/api',
    //    defaultValue: 'http://34.29.244.211:3004/api',
  );

  // User API Endpoints
  static const String userLoginEndpoint = '/auth/login/user';
  static const String userSignupEndpoint = '/auth/signup/user';
  static const String refreshTokenEndpoint = '/auth/refresh-token';
  static const String logoutEndpoint = '/auth/logout';
  static const String deleteAccountEndpoint = '/users/delete-account';

  // Menu Endpoints
  static const String menusEndpoint = '/menus';
  static const String menuStatsEndpoint = '/menus/stats';

  static const String userProfileEndpoint = '/users/profile';
  static const String fcmTokenEndpoint = '/users/fcm-token';

  // Other Endpoints
  static const String neighborhoodsEndpoint = '/neighborhoods';
  static const String vendorsEndpoint = '/vendors';
  static const String vendorMenusEndpoint = '/menus/vendor';
  static const String vendorItemsEndpoint = '/items/vendors';
  static const String categoriesEndpoint = '/categories';

  // User Order Endpoints
  static const String userOrdersEndpoint = '/orders/user/orders';
  static const String createOrderByUserEndpoint = '/orders/create-by-user';
  static const String approveOrderEndpoint = '/orders'; // /{id}/user-approve
  static const String deleteOrderEndpoint = '/orders'; // /{id}

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String languageKey = 'language';
  static const String themeKey = 'theme';

  // Regex Patterns
  static const String phoneRegex = r'^\+?[0-9]{10,15}$';
  static const String emailRegex =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int minNameLength = 2;
  static const int maxNameLength = 100;
  static const int maxAddressLength = 200;
  static const int maxDescriptionLength = 500;

  // Timeouts
  static const int connectionTimeout = 30; // seconds
  static const int receiveTimeout = 30; // seconds

  // Tenant Configuration
  static const String tenantId = 'SADAT';

  // Image
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png'];

  // Location
  static const double locationAccuracy = 100.0; // meters
  static const int locationTimeout = 30; // seconds

  // Wasabi S3 Configuration
  static const String wasabiAccessKey = 'RM7Z7JVNTNZ5CBI4BGKH';
  static const String wasabiSecretKey =
      'O0l5jOmAQHaAOOenncAdeWDHvvouv9GhJP5zD3fB';
  static const String wasabiBucket = 'deliveryapp';
  static const String wasabiEndpoint = 'https://s3.wasabisys.com';
  static const String wasabiRegion = 'eu-south-1';

  // Attachment Constraints
  static const int maxImages = 5;
  static const int maxVoiceNoteDuration = 300; // 5 minutes in seconds
  static const int maxImageSizeMB = 5;
  static const int maxVoiceNoteSizeMB = 10;
}
