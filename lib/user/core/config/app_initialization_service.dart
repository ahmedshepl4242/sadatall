import 'package:sadat_delivery_merged/user/core/config/api_config.dart';
import 'package:sadat_delivery_merged/user/services/api_service.dart';
import 'package:sadat_delivery_merged/user/services/notification_service.dart';
import 'package:sadat_delivery_merged/user/utils/time_utils.dart';

class AppInitializationService {
  static Future<void> initializeApp() async {
    TimeUtils.initialize();

    // Firebase is already initialized in main.dart — skip re-init here.

    final apiConfigManager = ApiConfigManager();
    apiConfigManager.registerBaseUrlChangedCallback((newBaseUrl) {
      ApiService().reinitialize();
    });

    // Fetch base URL with timeout so app never hangs on slow network.
    try {
      await apiConfigManager.initialize().timeout(
        const Duration(seconds: 8),
        onTimeout: () {},
      );
    } catch (_) {}

    try {
      await ApiService().initializeAsync().timeout(
        const Duration(seconds: 5),
        onTimeout: () {},
      );
    } catch (_) {}

    try {
      await NotificationService().initialize().timeout(
        const Duration(seconds: 8),
        onTimeout: () {},
      );
    } catch (_) {}
  }
}