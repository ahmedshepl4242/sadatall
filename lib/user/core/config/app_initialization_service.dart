import 'package:firebase_core/firebase_core.dart';
import 'package:sadat_delivery_merged/user/core/config/api_config.dart';
import 'package:sadat_delivery_merged/user/firebase_options.dart';
import 'package:sadat_delivery_merged/user/services/api_service.dart';
import 'package:sadat_delivery_merged/user/services/notification_service.dart';
import 'package:sadat_delivery_merged/user/utils/time_utils.dart';

class AppInitializationService {
  static Future<void> initializeApp() async {
    // Initialize timezone for Cairo
    TimeUtils.initialize();

    // Initialize Firebase
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    // Initialize API configuration (fetches base URL from Firestore)
    final apiConfigManager = ApiConfigManager();
    
    // Set up the callback to update API service when base URL changes
    apiConfigManager.registerBaseUrlChangedCallback((newBaseUrl) {
      ApiService().reinitialize();
    });

    // Initialize the API configuration which will fetch the base URL
    await apiConfigManager.initialize();

    // Now initialize the API service with the potentially updated base URL
    await ApiService().initializeAsync();
    
    // Initialize other services
    await NotificationService().initialize();
  }
}