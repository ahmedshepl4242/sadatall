import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_config_service.dart';
import 'notification_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }
}

class AppInitializationService {
  static Future<void> initializeApp() async {
    await Firebase.initializeApp();

    try {
      await FirebaseConfigService.getBaseUrlWithFallback()
          .timeout(const Duration(seconds: 8), onTimeout: () => '');
    } catch (_) {}

    try {
      await NotificationService()
          .initialize()
          .timeout(const Duration(seconds: 8), onTimeout: () {});
    } catch (_) {}

    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
  }
}
